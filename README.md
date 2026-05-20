# moonbit-community/metis

MoonBit bindings to METIS.

This package vendors the upstream METIS and GKlib C sources into MoonBit native
stubs. The initial ABI uses 32-bit `idx_t` and 32-bit `real_t`, matching the
standard METIS build.

Graphs and meshes use MoonBit/C-style zero-based numbering. The safe API does
not expose METIS' Fortran-numbering option because that mode renumbers input
arrays in place inside METIS.

## Development

Generate vendored C sources:

```bash
python3 scripts/prepare.py
```

Validate:

```bash
moon check --target native
moon test --target native
python3 scripts/test.py --asan
moon fmt
moon info --target native
```

## Example

```moonbit
test "partition a four-cycle graph" {
  let graph = @metis.CsrGraph::new(
    4,
    [0, 2, 4, 6, 8],
    [1, 3, 0, 2, 1, 3, 0, 2],
  )
  let result = @metis.part_graph_kway(graph, 2)
  inspect(result.part.length(), content="4")
}
```

The public API validates CSR and mesh shapes before entering C. METIS-allocated
arrays from mesh conversion are copied into MoonBit-owned arrays and freed inside
the binding.
