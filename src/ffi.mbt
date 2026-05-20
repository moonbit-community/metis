///|
priv type NativeGraphResult

///|
extern "c" fn metis_version_major() -> Int = "moonbit_metis_version_major"

///|
extern "c" fn metis_version_minor() -> Int = "moonbit_metis_version_minor"

///|
extern "c" fn metis_version_subminor() -> Int = "moonbit_metis_version_subminor"

///|
extern "c" fn metis_native_noptions() -> Int = "moonbit_metis_noptions"

///|
#borrow(xadj, adjncy, vwgt, vsize, adjwgt, tpwgts, ubvec, options, objval, part)
extern "c" fn metis_part_graph_kway_ffi(
  nvtxs : Int,
  ncon : Int,
  xadj : FixedArray[Int],
  adjncy : FixedArray[Int],
  vwgt : FixedArray[Int],
  vsize : FixedArray[Int],
  adjwgt : FixedArray[Int],
  nparts : Int,
  tpwgts : FixedArray[Float],
  ubvec : FixedArray[Float],
  options : FixedArray[Int],
  objval : Ref[Int],
  part : FixedArray[Int],
) -> Int = "moonbit_metis_part_graph_kway"

///|
#borrow(xadj, adjncy, vwgt, vsize, adjwgt, tpwgts, ubvec, options, objval, part)
extern "c" fn metis_part_graph_recursive_ffi(
  nvtxs : Int,
  ncon : Int,
  xadj : FixedArray[Int],
  adjncy : FixedArray[Int],
  vwgt : FixedArray[Int],
  vsize : FixedArray[Int],
  adjwgt : FixedArray[Int],
  nparts : Int,
  tpwgts : FixedArray[Float],
  ubvec : FixedArray[Float],
  options : FixedArray[Int],
  objval : Ref[Int],
  part : FixedArray[Int],
) -> Int = "moonbit_metis_part_graph_recursive"

///|
#borrow(eptr, eind)
extern "c" fn metis_mesh_to_dual_ffi(
  ne : Int,
  nn : Int,
  eptr : FixedArray[Int],
  eind : FixedArray[Int],
  ncommon : Int,
  numflag : Int,
) -> NativeGraphResult = "moonbit_metis_mesh_to_dual"

///|
#borrow(eptr, eind)
extern "c" fn metis_mesh_to_nodal_ffi(
  ne : Int,
  nn : Int,
  eptr : FixedArray[Int],
  eind : FixedArray[Int],
  numflag : Int,
) -> NativeGraphResult = "moonbit_metis_mesh_to_nodal"

///|
#borrow(result)
extern "c" fn native_graph_result_status(result : NativeGraphResult) -> Int = "moonbit_metis_graph_result_status"

///|
#borrow(result)
extern "c" fn native_graph_result_xadj(
  result : NativeGraphResult,
) -> FixedArray[Int] = "moonbit_metis_graph_result_xadj"

///|
#borrow(result)
extern "c" fn native_graph_result_adjncy(
  result : NativeGraphResult,
) -> FixedArray[Int] = "moonbit_metis_graph_result_adjncy"

///|
#borrow(eptr, eind, vwgt, vsize, tpwgts, options, objval, epart, npart)
extern "c" fn metis_part_mesh_nodal_ffi(
  ne : Int,
  nn : Int,
  eptr : FixedArray[Int],
  eind : FixedArray[Int],
  vwgt : FixedArray[Int],
  vsize : FixedArray[Int],
  nparts : Int,
  tpwgts : FixedArray[Float],
  options : FixedArray[Int],
  objval : Ref[Int],
  epart : FixedArray[Int],
  npart : FixedArray[Int],
) -> Int = "moonbit_metis_part_mesh_nodal"

///|
#borrow(eptr, eind, vwgt, vsize, tpwgts, options, objval, epart, npart)
extern "c" fn metis_part_mesh_dual_ffi(
  ne : Int,
  nn : Int,
  eptr : FixedArray[Int],
  eind : FixedArray[Int],
  vwgt : FixedArray[Int],
  vsize : FixedArray[Int],
  ncommon : Int,
  nparts : Int,
  tpwgts : FixedArray[Float],
  options : FixedArray[Int],
  objval : Ref[Int],
  epart : FixedArray[Int],
  npart : FixedArray[Int],
) -> Int = "moonbit_metis_part_mesh_dual"

///|
#borrow(xadj, adjncy, vwgt, options, perm, iperm)
extern "c" fn metis_node_nd_ffi(
  nvtxs : Int,
  xadj : FixedArray[Int],
  adjncy : FixedArray[Int],
  use_vwgt : Bool,
  vwgt : FixedArray[Int],
  options : FixedArray[Int],
  perm : FixedArray[Int],
  iperm : FixedArray[Int],
) -> Int = "moonbit_metis_node_nd"

///|
#borrow(xadj, adjncy, vwgt, options, perm, iperm, sizes)
extern "c" fn metis_node_ndp_ffi(
  nvtxs : Int,
  xadj : FixedArray[Int],
  adjncy : FixedArray[Int],
  use_vwgt : Bool,
  vwgt : FixedArray[Int],
  npes : Int,
  options : FixedArray[Int],
  perm : FixedArray[Int],
  iperm : FixedArray[Int],
  sizes : FixedArray[Int],
) -> Int = "moonbit_metis_node_ndp"

///|
#borrow(xadj, adjncy, vwgt, options, sepsize, part)
extern "c" fn metis_compute_vertex_separator_ffi(
  nvtxs : Int,
  xadj : FixedArray[Int],
  adjncy : FixedArray[Int],
  use_vwgt : Bool,
  vwgt : FixedArray[Int],
  options : FixedArray[Int],
  sepsize : Ref[Int],
  part : FixedArray[Int],
) -> Int = "moonbit_metis_compute_vertex_separator"

///|
#borrow(xadj, vwgt, adjncy, where_part, hmarker)
extern "c" fn metis_node_refine_ffi(
  nvtxs : Int,
  xadj : FixedArray[Int],
  vwgt : FixedArray[Int],
  adjncy : FixedArray[Int],
  where_part : FixedArray[Int],
  hmarker : FixedArray[Int],
  ubfactor : Float,
) -> Int = "moonbit_metis_node_refine"

///|
#borrow(xadj, adjncy, part, old2new)
extern "c" fn metis_cache_friendly_reordering_ffi(
  nvtxs : Int,
  xadj : FixedArray[Int],
  adjncy : FixedArray[Int],
  part : FixedArray[Int],
  old2new : FixedArray[Int],
) -> Int = "moonbit_metis_cache_friendly_reordering"
