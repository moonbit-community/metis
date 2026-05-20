///|
pub struct Mesh {
  priv ne : Int
  priv nn : Int
  priv eptr : FixedArray[Int]
  priv eind : FixedArray[Int]
  priv vwgt : FixedArray[Int]?
  priv vsize : FixedArray[Int]?
}

///|
pub(all) struct MeshPartitionResult {
  objval : Int
  epart : FixedArray[Int]
  npart : FixedArray[Int]
}

///|
pub fn Mesh::new(
  ne : Int,
  nn : Int,
  eptr : FixedArray[Int],
  eind : FixedArray[Int],
  vwgt? : FixedArray[Int],
  vsize? : FixedArray[Int],
) -> Mesh raise MetisError {
  let mesh = { ne, nn, eptr, eind, vwgt, vsize }
  mesh.validate()
  mesh
}

///|
fn Mesh::validate(self : Mesh) -> Unit raise MetisError {
  if self.ne < 0 || self.nn < 0 {
    raise InvalidMesh
  }
  if self.eptr.length() != self.ne + 1 {
    raise InvalidMesh
  }
  if self.eptr.length() == 0 || self.eptr[0] != 0 {
    raise InvalidMesh
  }
  for i in 0..<self.ne {
    if self.eptr[i] > self.eptr[i + 1] {
      raise InvalidMesh
    }
  }
  if self.eptr[self.ne] != self.eind.length() {
    raise InvalidMesh
  }
  for node in self.eind {
    if node < 0 || node >= self.nn {
      raise InvalidMesh
    }
  }
  match self.vwgt {
    None => ()
    Some(vwgt) => if vwgt.length() != self.nn { raise InvalidMesh }
  }
  match self.vsize {
    None => ()
    Some(vsize) => if vsize.length() != self.nn { raise InvalidMesh }
  }
}

///|
pub fn mesh_to_dual(
  mesh : Mesh,
  ncommon? : Int = 1,
) -> CsrGraph raise MetisError {
  mesh.validate()
  if ncommon < 1 {
    raise InvalidOptions
  }
  let result = metis_mesh_to_dual_ffi(
    mesh.ne,
    mesh.nn,
    mesh.eptr,
    mesh.eind,
    ncommon,
    0,
  )
  raise_status(native_graph_result_status(result))
  CsrGraph::new(
    mesh.ne,
    native_graph_result_xadj(result),
    native_graph_result_adjncy(result),
  )
}

///|
pub fn mesh_to_nodal(mesh : Mesh) -> CsrGraph raise MetisError {
  mesh.validate()
  let result = metis_mesh_to_nodal_ffi(
    mesh.ne,
    mesh.nn,
    mesh.eptr,
    mesh.eind,
    0,
  )
  raise_status(native_graph_result_status(result))
  CsrGraph::new(
    mesh.nn,
    native_graph_result_xadj(result),
    native_graph_result_adjncy(result),
  )
}

///|
fn validate_mesh_partition_inputs(
  mesh : Mesh,
  nparts : Int,
  target_partition_weights : FixedArray[Float]?,
) -> Unit raise MetisError {
  mesh.validate()
  if nparts <= 0 {
    raise InvalidOptions
  }
  match target_partition_weights {
    None => ()
    Some(tpwgts) => if tpwgts.length() != nparts { raise InvalidOptions }
  }
}

///|
pub fn part_mesh_nodal(
  mesh : Mesh,
  nparts : Int,
  options? : Options,
  target_partition_weights? : FixedArray[Float],
) -> MeshPartitionResult raise MetisError {
  validate_mesh_partition_inputs(mesh, nparts, target_partition_weights)
  let options = option_or_default(options)
  let objval = Ref(0)
  let epart = FixedArray::make(mesh.ne, 0)
  let npart = FixedArray::make(mesh.nn, 0)
  let status = metis_part_mesh_nodal_ffi(
    mesh.ne,
    mesh.nn,
    mesh.eptr,
    mesh.eind,
    int_array_or_empty(mesh.vwgt),
    int_array_or_empty(mesh.vsize),
    nparts,
    float_array_or_empty(target_partition_weights),
    options.raw(),
    objval,
    epart,
    npart,
  )
  raise_status(status)
  { objval: objval.val, epart, npart }
}

///|
pub fn part_mesh_dual(
  mesh : Mesh,
  nparts : Int,
  ncommon? : Int = 1,
  options? : Options,
  target_partition_weights? : FixedArray[Float],
) -> MeshPartitionResult raise MetisError {
  validate_mesh_partition_inputs(mesh, nparts, target_partition_weights)
  if ncommon < 1 {
    raise InvalidOptions
  }
  let options = option_or_default(options)
  let objval = Ref(0)
  let epart = FixedArray::make(mesh.ne, 0)
  let npart = FixedArray::make(mesh.nn, 0)
  let status = metis_part_mesh_dual_ffi(
    mesh.ne,
    mesh.nn,
    mesh.eptr,
    mesh.eind,
    int_array_or_empty(mesh.vwgt),
    int_array_or_empty(mesh.vsize),
    ncommon,
    nparts,
    float_array_or_empty(target_partition_weights),
    options.raw(),
    objval,
    epart,
    npart,
  )
  raise_status(status)
  { objval: objval.val, epart, npart }
}
