#!/usr/bin/env python3

from __future__ import annotations

import re
import shutil
import tarfile
import urllib.request
from dataclasses import dataclass
from pathlib import Path


METIS_REV = "dfded64f24664caa8809cacf416d378112e8867f"
GKLIB_REV = "e2856c2f595b153ca1ce9258c5301dbabc4f39f5"


PRELUDE = """#if defined(_WIN32)
#define WIN32
#define MSC
#define _CRT_SECURE_NO_DEPRECATE
#define USE_GKREGEX
#ifndef __thread
#define __thread __declspec(thread)
#endif
#else
#define LINUX
#define _FILE_OFFSET_BITS 64
#define _POSIX_C_SOURCE 200809L
#define NDEBUG
#define NDEBUG2
#define HAVE_GETLINE
#endif

#if defined(__APPLE__)
#define MACOS
#define HAVE_EXECINFO_H
#endif

#if defined(__linux__)
#define HAVE_EXECINFO_H
#endif
"""


@dataclass(frozen=True)
class Root:
    prefix: str
    path: Path


class Vendor:
    def __init__(self, target: Path, roots: list[Root], include_dirs: list[Path]):
        self.target = target
        self.roots = roots
        self.include_dirs = include_dirs
        self.copied: set[str] = set()
        self.overrides: dict[Path, str] = {}

    def root_for(self, path: Path) -> Root:
        resolved = path.resolve()
        for root in self.roots:
            try:
                resolved.relative_to(root.path.resolve())
                return root
            except ValueError:
                continue
        raise ValueError(f"{path} is outside configured roots")

    def mangled(self, path: Path) -> str:
        root = self.root_for(path)
        rel = path.resolve().relative_to(root.path.resolve())
        return "#".join([root.prefix, *rel.parts])

    def resolve_include(self, current: Path, header: str) -> Path | None:
        candidates = [current.parent, *self.include_dirs]
        for directory in candidates:
            candidate = (directory / header).resolve()
            if candidate.exists() and candidate.is_file():
                try:
                    self.root_for(candidate)
                    return candidate
                except ValueError:
                    continue
        return None

    def rewrite_includes(self, current: Path, content: str) -> str:
        pattern = re.compile(r'#(?P<indent>\s*)include\s+(?P<open>[<"])(?P<header>.*?)[>"]')

        def replace(match: re.Match[str]) -> str:
            header = match.group("header")
            resolved = self.resolve_include(current, header)
            if resolved is None:
                return match.group(0)
            self.copy(resolved, prelude=False)
            return f'#{match.group("indent")}include "{self.mangled(resolved)}"'

        return pattern.sub(replace, content)

    def copy(
        self,
        path: Path,
        *,
        prelude: bool = True,
        condition: str | None = None,
        content_override: str | None = None,
    ) -> None:
        path = path.resolve()
        target_name = self.mangled(path)
        if target_name in self.copied:
            return
        self.copied.add(target_name)

        if content_override is None:
            content = self.overrides.get(path)
            if content is None:
                content = path.read_text(encoding="utf-8", errors="ignore")
        else:
            content = content_override

        content = self.rewrite_includes(path, content)
        if prelude and path.suffix == ".c":
            content = PRELUDE + "\n" + content
        if condition is not None:
            content = f"#if {condition}\n{content}\n#endif\n"

        (self.target / target_name).write_text(content, encoding="utf-8")


def download_archive(owner: str, repo: str, rev: str, prepare: Path) -> Path:
    archive = prepare / f"{repo}-{rev}.tar.gz"
    if not archive.exists():
        url = f"https://github.com/{owner}/{repo}/archive/{rev}.tar.gz"
        with urllib.request.urlopen(url) as response, archive.open("wb") as out:
            shutil.copyfileobj(response, out)
    extract_dir = prepare / f"{repo}-{rev}"
    if not extract_dir.exists():
        with tarfile.open(archive, "r:gz") as tar:
            tar.extractall(prepare)
        extracted = next(path for path in prepare.glob(f"{repo}-*") if path.is_dir())
        if extracted != extract_dir:
            extracted.rename(extract_dir)
    return extract_dir


def clean_generated(src: Path) -> None:
    for path in src.iterdir():
        if path.name.startswith(("metis#", "gklib#")):
            path.unlink()


def update_moon_pkg(src: Path, generated_stubs: list[str]) -> None:
    moon_pkg = src / "moon.pkg"
    content = moon_pkg.read_text(encoding="utf-8")
    stubs = ["wrapper.c", *sorted(generated_stubs)]
    body = ",\n".join(f'    "{stub}"' for stub in stubs)
    replacement = f'"native-stub": [\n{body},\n  ]'
    content = re.sub(
        r'"native-stub":\s*\[.*?\]',
        replacement,
        content,
        flags=re.DOTALL,
    )
    moon_pkg.write_text(content, encoding="utf-8")


def main() -> None:
    repo = Path(__file__).resolve().parents[1]
    src = repo / "src"
    prepare = repo / ".prepare"
    prepare.mkdir(exist_ok=True)
    src.mkdir(exist_ok=True)
    clean_generated(src)

    metis = download_archive("KarypisLab", "METIS", METIS_REV, prepare)
    gklib = download_archive("KarypisLab", "GKlib", GKLIB_REV, prepare)

    roots = [Root("metis", metis), Root("gklib", gklib)]
    include_dirs = [
        metis / "include",
        metis / "libmetis",
        gklib / "include",
        gklib / "include" / "win32",
    ]
    vendor = Vendor(src, roots, include_dirs)

    metis_header = (metis / "include" / "metis.h").read_text(encoding="utf-8")
    vendor.overrides[(metis / "include" / "metis.h").resolve()] = (
        "#define IDXTYPEWIDTH 32\n"
        "#define REALTYPEWIDTH 32\n"
        + metis_header
    )

    for source in sorted((gklib / "src").glob("*.c")):
        vendor.copy(source)
    win_adapt = gklib / "src" / "win32" / "adapt.c"
    if win_adapt.exists():
        vendor.copy(win_adapt, condition="defined(_WIN32)")

    for source in sorted((metis / "libmetis").glob("*.c")):
        vendor.copy(source)

    generated_stubs = [
        path.name for path in src.iterdir()
        if path.suffix == ".c" and path.name.startswith(("metis#", "gklib#"))
    ]
    update_moon_pkg(src, generated_stubs)


if __name__ == "__main__":
    main()
