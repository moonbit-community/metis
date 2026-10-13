///|
pub(all) struct OrderingResult {
  perm : FixedArray[Int32]
  iperm : FixedArray[Int32]
}

///|
pub(all) struct ParallelOrderingResult {
  perm : FixedArray[Int32]
  iperm : FixedArray[Int32]
  sizes : FixedArray[Int32]
}

///|
pub fn node_nd(
  graph : CsrGraph,
  options? : Options,
) -> OrderingResult raise MetisError {
  graph.validate()
  let options = option_or_default(options)
  let perm = FixedArray::make(graph.nvtxs, 0)
  let iperm = FixedArray::make(graph.nvtxs, 0)
  let status = metis_node_nd_ffi(
    graph.nvtxs,
    graph.xadj,
    graph.adjncy,
    int_array_or_empty(graph.vwgt),
    options.raw(),
    perm,
    iperm,
  )
  raise_status(status)
  { perm, iperm, }
}

///|
pub fn node_ndp(
  graph : CsrGraph,
  npes : Int32,
  options? : Options,
) -> ParallelOrderingResult raise MetisError {
  graph.validate()
  if npes <= 0 {
    raise InvalidOptions
  }
  let options = option_or_default(options)
  let perm = FixedArray::make(graph.nvtxs, 0)
  let iperm = FixedArray::make(graph.nvtxs, 0)
  let sizes = FixedArray::make(2 * npes - 1, 0)
  let status = metis_node_ndp_ffi(
    graph.nvtxs,
    graph.xadj,
    graph.adjncy,
    int_array_or_empty(graph.vwgt),
    npes,
    options.raw(),
    perm,
    iperm,
    sizes,
  )
  raise_status(status)
  { perm, iperm, sizes, }
}

///|
pub fn node_refine(
  graph : CsrGraph,
  vwgt : FixedArray[Int32],
  where_part : FixedArray[Int32],
  hmarker : FixedArray[Int32],
  ubfactor : Float,
) -> FixedArray[Int32] raise MetisError {
  graph.validate()
  if vwgt.length() != graph.nvtxs ||
    where_part.length() != graph.nvtxs ||
    hmarker.length() != graph.nvtxs {
    raise InvalidOptions
  }
  let refined = FixedArray::make(graph.nvtxs, 0)
  for i in 0..<graph.nvtxs {
    refined[i] = where_part[i]
  }
  let status = metis_node_refine_ffi(
    graph.nvtxs,
    graph.xadj,
    vwgt,
    graph.adjncy,
    refined,
    hmarker,
    ubfactor,
  )
  raise_status(status)
  refined
}
