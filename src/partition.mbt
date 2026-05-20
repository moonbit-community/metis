///|
pub(all) struct PartitionResult {
  objval : Int
  part : FixedArray[Int]
}

///|
pub fn part_graph_kway(
  graph : CsrGraph,
  nparts : Int,
  options? : Options,
  target_partition_weights? : FixedArray[Float],
  imbalance? : FixedArray[Float],
) -> PartitionResult raise MetisError {
  validate_partition_inputs(graph, nparts, target_partition_weights, imbalance)
  let options = option_or_default(options)
  let objval = Ref(0)
  let part = FixedArray::make(graph.nvtxs, 0)
  let status = metis_part_graph_kway_ffi(
    graph.nvtxs,
    graph.ncon,
    graph.xadj,
    graph.adjncy,
    int_array_or_empty(graph.vwgt),
    int_array_or_empty(graph.vsize),
    int_array_or_empty(graph.adjwgt),
    nparts,
    float_array_or_empty(target_partition_weights),
    float_array_or_empty(imbalance),
    options.raw(),
    objval,
    part,
  )
  raise_status(status)
  { objval: objval.val, part }
}

///|
pub fn part_graph_recursive(
  graph : CsrGraph,
  nparts : Int,
  options? : Options,
  target_partition_weights? : FixedArray[Float],
  imbalance? : FixedArray[Float],
) -> PartitionResult raise MetisError {
  validate_partition_inputs(graph, nparts, target_partition_weights, imbalance)
  let options = option_or_default(options)
  let objval = Ref(0)
  let part = FixedArray::make(graph.nvtxs, 0)
  let status = metis_part_graph_recursive_ffi(
    graph.nvtxs,
    graph.ncon,
    graph.xadj,
    graph.adjncy,
    int_array_or_empty(graph.vwgt),
    int_array_or_empty(graph.vsize),
    int_array_or_empty(graph.adjwgt),
    nparts,
    float_array_or_empty(target_partition_weights),
    float_array_or_empty(imbalance),
    options.raw(),
    objval,
    part,
  )
  raise_status(status)
  { objval: objval.val, part }
}

///|
pub fn cache_friendly_reordering(
  graph : CsrGraph,
  part : FixedArray[Int],
) -> FixedArray[Int] raise MetisError {
  graph.validate()
  if part.length() != graph.nvtxs {
    raise InvalidOptions
  }
  let old2new = FixedArray::make(graph.nvtxs, 0)
  let status = metis_cache_friendly_reordering_ffi(
    graph.nvtxs,
    graph.xadj,
    graph.adjncy,
    part,
    old2new,
  )
  raise_status(status)
  old2new
}
