///|
pub(all) struct VertexSeparatorResult {
  sepsize : Int
  part : FixedArray[Int]
}

///|
pub fn compute_vertex_separator(
  graph : CsrGraph,
  options? : Options,
) -> VertexSeparatorResult raise MetisError {
  graph.validate()
  let options = option_or_default(options)
  let sepsize = Ref(0)
  let part = FixedArray::make(graph.nvtxs, 0)
  let status = metis_compute_vertex_separator_ffi(
    graph.nvtxs,
    graph.xadj,
    graph.adjncy,
    use_int_array(graph.vwgt),
    int_array_or_empty(graph.vwgt),
    options.raw(),
    sepsize,
    part,
  )
  raise_status(status)
  { sepsize: sepsize.val, part }
}
