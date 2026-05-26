name = "Milky2018/metis"

version = "0.1.1"

readme = "README.md"

repository = "https://github.com/moonbit-community/metis"

license = "Apache-2.0"

keywords = [ "metis", "graph", "partitioning", "mesh", "ordering" ]

description = "MoonBit bindings to METIS"

preferred_target = "native"

supported_targets = "native+llvm"

options(
  source: "src",
)
