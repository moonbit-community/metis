#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import platform
import re
import shutil
import subprocess
from pathlib import Path


def find_clang() -> str:
    candidates: list[str] = []
    if platform.system() == "Darwin":
        brew = shutil.which("brew")
        if brew is not None:
            for name in ["llvm", "llvm@19", "llvm@18", "llvm@17"]:
                try:
                    prefix = subprocess.check_output(
                        [brew, "--prefix", name],
                        text=True,
                        stderr=subprocess.DEVNULL,
                    ).strip()
                except subprocess.CalledProcessError:
                    continue
                candidates.append(str(Path(prefix) / "bin" / "clang"))
    candidates.extend(["clang", "gcc", "cc"])
    for candidate in candidates:
        resolved = shutil.which(candidate) if "/" not in candidate else candidate
        if resolved is not None and Path(resolved).exists():
            return resolved
    raise RuntimeError("no C compiler found")


def find_darwin_asan_runtime(clang: str) -> str | None:
    roots = [
        Path(clang).parents[1],
        Path("/Applications/Xcode.app"),
        Path("/Library/Developer/CommandLineTools"),
    ]
    for root in roots:
        if not root.exists():
            continue
        matches = list(root.rglob("libclang_rt.asan_osx_dynamic.dylib"))
        if matches:
            return str(matches[0])
    return None


def patch_native_link(moon_pkg: Path, compiler: str) -> str:
    original = moon_pkg.read_text(encoding="utf-8")
    link = {"native": {"cc": compiler, "stub-cc": compiler}}
    line = f"  link: {json.dumps(link)},\n"
    patched = re.sub(r"options\(\n", "options(\n" + line, original, count=1)
    moon_pkg.write_text(patched, encoding="utf-8")
    return original


def write_asan_wrapper(compiler: str, directory: Path) -> Path:
    wrapper = directory / "cc-asan.sh"
    wrapper.write_text(
        "#!/bin/sh\n"
        f'exec "{compiler}" -g -fsanitize=address -fno-omit-frame-pointer "$@"\n',
        encoding="utf-8",
    )
    wrapper.chmod(0o755)
    return wrapper


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--asan", action="store_true")
    parser.add_argument("--target", default="native")
    parser.add_argument("--verbose", "-v", action="store_true")
    args = parser.parse_args()

    repo = Path(__file__).resolve().parents[1]
    moon_pkg = repo / "src" / "moon.pkg"
    env = os.environ.copy()
    restore: str | None = None
    temp_dir = repo / "_build" / "script-test"
    temp_dir.mkdir(parents=True, exist_ok=True)

    try:
        cmd = ["moon", "test", "--target", args.target]
        if args.verbose:
            cmd.append("-v")
        if args.asan:
            compiler = find_clang()
            restore = patch_native_link(moon_pkg, compiler)
            wrapper = write_asan_wrapper(compiler, temp_dir)
            env["MOON_CC"] = str(wrapper)
            env["MOON_AR"] = shutil.which("ar") or "/usr/bin/ar"
            env["ASAN_OPTIONS"] = "detect_leaks=0"
            if platform.system() == "Darwin":
                runtime = find_darwin_asan_runtime(compiler)
                if runtime is not None:
                    env["DYLD_INSERT_LIBRARIES"] = runtime
        subprocess.run(cmd, cwd=repo, env=env, check=True)
    finally:
        if restore is not None:
            moon_pkg.write_text(restore, encoding="utf-8")


if __name__ == "__main__":
    main()
