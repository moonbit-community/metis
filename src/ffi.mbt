///|
priv type NativeGraphResult

///|
extern "c" fn metis_version_major() -> Int32 = "moonbit_metis_version_major"

///|
extern "c" fn metis_version_minor() -> Int32 = "moonbit_metis_version_minor"

///|
extern "c" fn metis_version_subminor() -> Int32 = "moonbit_metis_version_subminor"

///|
extern "c" fn metis_native_noptions() -> Int32 = "moonbit_metis_noptions"

///|
#borrow(xadj, adjncy, vwgt, vsize, adjwgt, tpwgts, ubvec, options, objval, part)
extern "c" fn metis_part_graph_kway_ffi(
  nvtxs : Int32,
  ncon : Int32,
  xadj : FixedArray[Int32],
  adjncy : FixedArray[Int32],
  vwgt : FixedArray[Int32],
  vsize : FixedArray[Int32],
  adjwgt : FixedArray[Int32],
  nparts : Int32,
  tpwgts : FixedArray[Float],
  ubvec : FixedArray[Float],
  options : FixedArray[Int32],
  objval : Ref[Int32],
  part : FixedArray[Int32],
) -> Int32 = "moonbit_metis_part_graph_kway"

///|
#borrow(xadj, adjncy, vwgt, vsize, adjwgt, tpwgts, ubvec, options, objval, part)
extern "c" fn metis_part_graph_recursive_ffi(
  nvtxs : Int32,
  ncon : Int32,
  xadj : FixedArray[Int32],
  adjncy : FixedArray[Int32],
  vwgt : FixedArray[Int32],
  vsize : FixedArray[Int32],
  adjwgt : FixedArray[Int32],
  nparts : Int32,
  tpwgts : FixedArray[Float],
  ubvec : FixedArray[Float],
  options : FixedArray[Int32],
  objval : Ref[Int32],
  part : FixedArray[Int32],
) -> Int32 = "moonbit_metis_part_graph_recursive"

///|
#borrow(eptr, eind)
extern "c" fn metis_mesh_to_dual_ffi(
  ne : Int32,
  nn : Int32,
  eptr : FixedArray[Int32],
  eind : FixedArray[Int32],
  ncommon : Int32,
  numflag : Int32,
) -> NativeGraphResult = "moonbit_metis_mesh_to_dual"

///|
#borrow(eptr, eind)
extern "c" fn metis_mesh_to_nodal_ffi(
  ne : Int32,
  nn : Int32,
  eptr : FixedArray[Int32],
  eind : FixedArray[Int32],
  numflag : Int32,
) -> NativeGraphResult = "moonbit_metis_mesh_to_nodal"

///|
#borrow(result)
extern "c" fn native_graph_result_status(result : NativeGraphResult) -> Int32 = "moonbit_metis_graph_result_status"

///|
#borrow(result)
extern "c" fn native_graph_result_xadj(
  result : NativeGraphResult,
) -> FixedArray[Int32] = "moonbit_metis_graph_result_xadj"

///|
#borrow(result)
extern "c" fn native_graph_result_adjncy(
  result : NativeGraphResult,
) -> FixedArray[Int32] = "moonbit_metis_graph_result_adjncy"

///|
#borrow(eptr, eind, vwgt, vsize, tpwgts, options, objval, epart, npart)
extern "c" fn metis_part_mesh_nodal_ffi(
  ne : Int32,
  nn : Int32,
  eptr : FixedArray[Int32],
  eind : FixedArray[Int32],
  vwgt : FixedArray[Int32],
  vsize : FixedArray[Int32],
  nparts : Int32,
  tpwgts : FixedArray[Float],
  options : FixedArray[Int32],
  objval : Ref[Int32],
  epart : FixedArray[Int32],
  npart : FixedArray[Int32],
) -> Int32 = "moonbit_metis_part_mesh_nodal"

///|
#borrow(eptr, eind, vwgt, vsize, tpwgts, options, objval, epart, npart)
extern "c" fn metis_part_mesh_dual_ffi(
  ne : Int32,
  nn : Int32,
  eptr : FixedArray[Int32],
  eind : FixedArray[Int32],
  vwgt : FixedArray[Int32],
  vsize : FixedArray[Int32],
  ncommon : Int32,
  nparts : Int32,
  tpwgts : FixedArray[Float],
  options : FixedArray[Int32],
  objval : Ref[Int32],
  epart : FixedArray[Int32],
  npart : FixedArray[Int32],
) -> Int32 = "moonbit_metis_part_mesh_dual"

///|
#borrow(xadj, adjncy, vwgt, options, perm, iperm)
extern "c" fn metis_node_nd_ffi(
  nvtxs : Int32,
  xadj : FixedArray[Int32],
  adjncy : FixedArray[Int32],
  vwgt : FixedArray[Int32],
  options : FixedArray[Int32],
  perm : FixedArray[Int32],
  iperm : FixedArray[Int32],
) -> Int32 = "moonbit_metis_node_nd"

///|
#borrow(xadj, adjncy, vwgt, options, perm, iperm, sizes)
extern "c" fn metis_node_ndp_ffi(
  nvtxs : Int32,
  xadj : FixedArray[Int32],
  adjncy : FixedArray[Int32],
  vwgt : FixedArray[Int32],
  npes : Int32,
  options : FixedArray[Int32],
  perm : FixedArray[Int32],
  iperm : FixedArray[Int32],
  sizes : FixedArray[Int32],
) -> Int32 = "moonbit_metis_node_ndp"

///|
#borrow(xadj, adjncy, vwgt, options, sepsize, part)
extern "c" fn metis_compute_vertex_separator_ffi(
  nvtxs : Int32,
  xadj : FixedArray[Int32],
  adjncy : FixedArray[Int32],
  vwgt : FixedArray[Int32],
  options : FixedArray[Int32],
  sepsize : Ref[Int32],
  part : FixedArray[Int32],
) -> Int32 = "moonbit_metis_compute_vertex_separator"

///|
#borrow(xadj, vwgt, adjncy, where_part, hmarker)
extern "c" fn metis_node_refine_ffi(
  nvtxs : Int32,
  xadj : FixedArray[Int32],
  vwgt : FixedArray[Int32],
  adjncy : FixedArray[Int32],
  where_part : FixedArray[Int32],
  hmarker : FixedArray[Int32],
  ubfactor : Float,
) -> Int32 = "moonbit_metis_node_refine"

///|
#borrow(xadj, adjncy, part, old2new)
extern "c" fn metis_cache_friendly_reordering_ffi(
  nvtxs : Int32,
  xadj : FixedArray[Int32],
  adjncy : FixedArray[Int32],
  part : FixedArray[Int32],
  old2new : FixedArray[Int32],
) -> Int32 = "moonbit_metis_cache_friendly_reordering"
