///|
fn sample_graph() -> CsrGraph raise MetisError {
  CsrGraph::new(4, [0, 2, 4, 6, 8], [1, 3, 0, 2, 1, 3, 0, 2])
}

///|
fn sample_mesh() -> Mesh raise MetisError {
  Mesh::new(2, 4, [0, 3, 6], [0, 1, 2, 1, 2, 3])
}

///|
fn assert_partition(part : FixedArray[Int], nparts : Int) -> Unit {
  for value in part {
    guard value >= 0 && value < nparts
  }
}

///|
fn assert_permutation(perm : FixedArray[Int], iperm : FixedArray[Int]) -> Unit {
  guard perm.length() == iperm.length()
  let seen = FixedArray::make(perm.length(), false)
  for i in 0..<perm.length() {
    let p = perm[i]
    guard p >= 0 && p < perm.length()
    guard !seen[p]
    seen[p] = true
    guard iperm[p] == i
  }
}

///|
fn assert_is_permutation(perm : FixedArray[Int]) -> Unit {
  let seen = FixedArray::make(perm.length(), false)
  for value in perm {
    guard value >= 0 && value < perm.length()
    guard !seen[value]
    seen[value] = true
  }
}

///|
fn fail() -> Unit {
  guard false
}

///|
test "version" {
  let (major, minor, subminor) = version()
  guard major == 5
  guard minor == 2
  guard subminor == 1
  guard native_option_count() == 40
}

///|
test "part graph kway" {
  let graph = sample_graph()
  let result = part_graph_kway(graph, 2)
  inspect(result.part.length(), content="4")
  assert_partition(result.part, 2)
  guard result.objval >= 0
}

///|
test "part graph recursive" {
  let graph = sample_graph()
  let result = part_graph_recursive(graph, 2)
  inspect(result.part.length(), content="4")
  assert_partition(result.part, 2)
  guard result.objval >= 0
}

///|
test "graph exposes all constructor inputs" {
  let graph = CsrGraph::new(2, [0, 1, 2], [1, 0], vwgt=[2, 3], vsize=[1, 1], adjwgt=[
    4, 4,
  ])
  inspect(graph.nvtxs(), content="2")
  inspect(graph.ncon(), content="1")
  inspect(graph.xadj().length(), content="3")
  inspect(graph.adjncy().length(), content="2")
  match graph.vertex_weights() {
    Some(vwgt) => {
      guard vwgt.length() == 2
      guard vwgt[0] == 2
      guard vwgt[1] == 3
    }
    None => fail()
  }
  match graph.vertex_sizes() {
    Some(vsize) => {
      guard vsize.length() == 2
      guard vsize[0] == 1
      guard vsize[1] == 1
    }
    None => fail()
  }
  match graph.adjacency_weights() {
    Some(adjwgt) => {
      guard adjwgt.length() == 2
      guard adjwgt[0] == 4
      guard adjwgt[1] == 4
    }
    None => fail()
  }
}

///|
test "node ordering" {
  let graph = sample_graph()
  let result = node_nd(graph)
  assert_permutation(result.perm, result.iperm)
}

///|
test "parallel node ordering allocates separator sizes" {
  let graph = sample_graph()
  let result = node_ndp(graph, 2)
  assert_permutation(result.perm, result.iperm)
  inspect(result.sizes.length(), content="3")
}

///|
test "mesh to dual" {
  let mesh = sample_mesh()
  inspect(mesh.ne(), content="2")
  inspect(mesh.nn(), content="4")
  inspect(mesh.eptr().length(), content="3")
  inspect(mesh.eind().length(), content="6")
  let graph = mesh_to_dual(mesh, ncommon=2)
  let xadj = graph.xadj()
  let adjncy = graph.adjncy()
  guard xadj.length() == 3
  guard xadj[0] == 0
  guard xadj[1] == 1
  guard xadj[2] == 2
  guard adjncy.length() == 2
  guard adjncy[0] == 1
  guard adjncy[1] == 0
}

///|
test "mesh to nodal" {
  let mesh = sample_mesh()
  let graph = mesh_to_nodal(mesh)
  inspect(graph.nvtxs(), content="4")
  guard graph.xadj().length() == 5
}

///|
test "part mesh dual" {
  let mesh = sample_mesh()
  let result = part_mesh_dual(mesh, 2, ncommon=2)
  inspect(result.epart.length(), content="2")
  inspect(result.npart.length(), content="4")
  assert_partition(result.epart, 2)
  assert_partition(result.npart, 2)
}

///|
test "part mesh nodal" {
  let mesh = sample_mesh()
  let options = Options::default().set_partitioning_scheme(Kway)
  let result = part_mesh_nodal(mesh, 2, options~)
  inspect(result.epart.length(), content="2")
  inspect(result.npart.length(), content="4")
  assert_partition(result.epart, 2)
  assert_partition(result.npart, 2)
}

///|
test "mesh partition weights are scoped by graph kind" {
  let mesh = sample_mesh()
  let nodal = part_mesh_nodal(
    mesh,
    2,
    node_weights=FixedArray::make(4, 1),
    node_sizes=FixedArray::make(4, 1),
  )
  assert_partition(nodal.npart, 2)
  let dual = part_mesh_dual(
    mesh,
    2,
    ncommon=2,
    element_weights=FixedArray::make(2, 1),
    element_sizes=FixedArray::make(2, 1),
  )
  assert_partition(dual.epart, 2)
  try {
    ignore(part_mesh_nodal(mesh, 2, node_weights=FixedArray::make(2, 1)))
    fail()
  } catch {
    InvalidOptions => ()
    _ => fail()
  }
  try {
    ignore(part_mesh_dual(mesh, 2, element_weights=FixedArray::make(4, 1)))
    fail()
  } catch {
    InvalidOptions => ()
    _ => fail()
  }
}

///|
test "cache friendly reordering" {
  let graph = sample_graph()
  let result = part_graph_kway(graph, 2)
  let old2new = cache_friendly_reordering(graph, result.part)
  assert_is_permutation(old2new)
}

///|
test "vertex separator" {
  let graph = sample_graph()
  let result = compute_vertex_separator(graph)
  inspect(result.part.length(), content="4")
  guard result.sepsize >= 0
}

///|
test "node refine accepts weighted graph inputs" {
  let graph = sample_graph()
  let separator = compute_vertex_separator(graph)
  let vwgt = FixedArray::make(graph.nvtxs(), 1)
  let hmarker = FixedArray::make(graph.nvtxs(), -1)
  let refined = node_refine(graph, vwgt, separator.part, hmarker, 1.05)
  inspect(refined.length(), content="4")
  for value in refined {
    guard value >= 0 && value <= 2
  }
}

///|
test "options are accepted by metis" {
  let graph = sample_graph()
  let options = Options::default()
    .set_number_of_cuts(2)
    .set_number_of_iterations(5)
    .set_seed(7)
    .set_objective_type(Cut)
  let result = part_graph_kway(graph, 2, options~)
  assert_partition(result.part, 2)
}

///|
test "typed debug flags can be configured" {
  ignore(Options::default().set_debug_flags([Info, Time, Memory]))
}

///|
test "invalid csr is rejected before ffi" {
  try {
    ignore(CsrGraph::new(2, [0, 3], [1]))
    guard false
  } catch {
    InvalidGraph => ()
    _ => fail()
  }
}

///|
test "empty graph is rejected before ffi" {
  try {
    ignore(CsrGraph::new(0, [0], []))
    fail()
  } catch {
    InvalidGraph => ()
    _ => fail()
  }
}

///|
test "invalid mesh is rejected before ffi" {
  try {
    ignore(Mesh::new(1, 2, [0, 3], [0, 1]))
    fail()
  } catch {
    InvalidMesh => ()
    _ => fail()
  }
}

///|
test "empty mesh is rejected before ffi" {
  try {
    ignore(Mesh::new(0, 0, [0], []))
    fail()
  } catch {
    InvalidMesh => ()
    _ => fail()
  }
}
