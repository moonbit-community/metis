# Milky2018/metis

MoonBit bindings to [METIS](https://github.com/KarypisLab/METIS).

![Static overview of MoonBit METIS graph partitioning](docs/assets/metis-partition-example.svg)

This package vendors the upstream METIS and GKlib C sources into MoonBit native
stubs. The ABI uses 32-bit `idx_t` and 32-bit `real_t`, matching the standard
METIS build.

Graphs and meshes use MoonBit/C-style zero-based numbering. The safe API does
not expose METIS' Fortran-numbering option because that mode renumbers input
arrays in place inside METIS.

`Mesh` stores only element connectivity. Mesh partitioning weights are supplied
at the call site because `part_mesh_nodal` expects node weights of length `nn`,
while `part_mesh_dual` expects element weights of length `ne`.

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

The examples below are tested by MoonBit:

```bash
moon test src/README.mbt.md --target native
```

## Partition A CSR Graph

```mbt check
///|
test "partition a four-cycle graph" {
  let graph = CsrGraph::new(4, [0, 2, 4, 6, 8], [1, 3, 0, 2, 1, 3, 0, 2])
  let result = part_graph_kway(graph, 2)
  inspect(result.part.length(), content="4")
  for value in result.part {
    guard value >= 0 && value < 2
  }
}
```

## Nested Dissection Ordering

```mbt check
///|
test "compute a node ordering" {
  let graph = CsrGraph::new(4, [0, 2, 4, 6, 8], [1, 3, 0, 2, 1, 3, 0, 2])
  let result = node_nd(graph)
  inspect(result.perm.length(), content="4")
  inspect(result.iperm.length(), content="4")
}
```

## Mesh Conversion And Partitioning

```mbt check
///|
test "convert and partition a mesh" {
  let mesh = Mesh::new(2, 4, [0, 3, 6], [0, 1, 2, 1, 2, 3])
  let dual = mesh_to_dual(mesh, ncommon=2)
  inspect(dual.nvtxs(), content="2")
  let nodal = mesh_to_nodal(mesh)
  inspect(nodal.nvtxs(), content="4")

  let nodal_partition = part_mesh_nodal(
    mesh,
    2,
    node_weights=FixedArray::make(4, 1),
    node_sizes=FixedArray::make(4, 1),
  )
  inspect(nodal_partition.epart.length(), content="2")
  inspect(nodal_partition.npart.length(), content="4")

  let dual_partition = part_mesh_dual(
    mesh,
    2,
    ncommon=2,
    element_weights=FixedArray::make(2, 1),
    element_sizes=FixedArray::make(2, 1),
  )
  inspect(dual_partition.epart.length(), content="2")
  inspect(dual_partition.npart.length(), content="4")
}
```

The public API validates CSR and mesh shapes before entering C. METIS-allocated
arrays from mesh conversion are copied into MoonBit-owned arrays and freed inside
the binding.
