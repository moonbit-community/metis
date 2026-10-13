///|
pub struct CsrGraph {
  priv nvtxs : Int32
  priv ncon : Int32
  priv xadj : FixedArray[Int32]
  priv adjncy : FixedArray[Int32]
  priv vwgt : FixedArray[Int32]?
  priv vsize : FixedArray[Int32]?
  priv adjwgt : FixedArray[Int32]?
}

///|
pub fn CsrGraph::CsrGraph(
  nvtxs : Int32,
  xadj : FixedArray[Int32],
  adjncy : FixedArray[Int32],
  ncon~ : Int32 = 1,
  vwgt? : FixedArray[Int32],
  vsize? : FixedArray[Int32],
  adjwgt? : FixedArray[Int32],
) -> CsrGraph raise MetisError {
  make_csr_graph(nvtxs, xadj, adjncy, ncon~, vwgt?, vsize?, adjwgt?)
}

///|
fn make_csr_graph(
  nvtxs : Int32,
  xadj : FixedArray[Int32],
  adjncy : FixedArray[Int32],
  ncon~ : Int32 = 1,
  vwgt? : FixedArray[Int32],
  vsize? : FixedArray[Int32],
  adjwgt? : FixedArray[Int32],
) -> CsrGraph raise MetisError {
  let graph = { nvtxs, ncon, xadj, adjncy, vwgt, vsize, adjwgt, }
  graph.validate()
  graph
}

///|
pub fn CsrGraph::new(
  nvtxs : Int32,
  xadj : FixedArray[Int32],
  adjncy : FixedArray[Int32],
  ncon~ : Int32 = 1,
  vwgt? : FixedArray[Int32],
  vsize? : FixedArray[Int32],
  adjwgt? : FixedArray[Int32],
) -> CsrGraph raise MetisError {
  make_csr_graph(nvtxs, xadj, adjncy, ncon~, vwgt?, vsize?, adjwgt?)
}

///|
pub fn CsrGraph::nvtxs(self : CsrGraph) -> Int32 {
  self.nvtxs
}

///|
pub fn CsrGraph::ncon(self : CsrGraph) -> Int32 {
  self.ncon
}

///|
pub fn CsrGraph::xadj(self : CsrGraph) -> FixedArray[Int32] {
  self.xadj
}

///|
pub fn CsrGraph::adjncy(self : CsrGraph) -> FixedArray[Int32] {
  self.adjncy
}

///|
pub fn CsrGraph::vertex_weights(self : CsrGraph) -> FixedArray[Int32]? {
  self.vwgt
}

///|
pub fn CsrGraph::vertex_sizes(self : CsrGraph) -> FixedArray[Int32]? {
  self.vsize
}

///|
pub fn CsrGraph::adjacency_weights(self : CsrGraph) -> FixedArray[Int32]? {
  self.adjwgt
}

///|
fn CsrGraph::validate(self : CsrGraph) -> Unit raise MetisError {
  if self.nvtxs <= 0 || self.ncon <= 0 {
    raise InvalidGraph
  }
  if self.xadj.length() != self.nvtxs + 1 {
    raise InvalidGraph
  }
  if self.xadj.length() == 0 || self.xadj[0] != 0 {
    raise InvalidGraph
  }
  for i in 0..<self.nvtxs {
    if self.xadj[i] > self.xadj[i + 1] {
      raise InvalidGraph
    }
  }
  if self.xadj[self.nvtxs] != self.adjncy.length() {
    raise InvalidGraph
  }
  for vertex in self.adjncy {
    if vertex < 0 || vertex >= self.nvtxs {
      raise InvalidGraph
    }
  }
  match self.vwgt {
    None => ()
    Some(vwgt) =>
      if vwgt.length() != self.nvtxs * self.ncon {
        raise InvalidGraph
      }
  }
  match self.vsize {
    None => ()
    Some(vsize) => if vsize.length() != self.nvtxs { raise InvalidGraph }
  }
  match self.adjwgt {
    None => ()
    Some(adjwgt) =>
      if adjwgt.length() != self.adjncy.length() {
        raise InvalidGraph
      }
  }
}

///|
fn int_array_or_empty(value : FixedArray[Int32]?) -> FixedArray[Int32] {
  match value {
    None => []
    Some(value) => value
  }
}

///|
fn float_array_or_empty(value : FixedArray[Float]?) -> FixedArray[Float] {
  match value {
    None => []
    Some(value) => value
  }
}

///|
fn validate_partition_inputs(
  graph : CsrGraph,
  nparts : Int32,
  target_partition_weights : FixedArray[Float]?,
  imbalance : FixedArray[Float]?,
) -> Unit raise MetisError {
  graph.validate()
  if nparts <= 0 {
    raise InvalidOptions
  }
  match target_partition_weights {
    None => ()
    Some(tpwgts) =>
      if tpwgts.length() != nparts * graph.ncon {
        raise InvalidOptions
      }
  }
  match imbalance {
    None => ()
    Some(ubvec) => if ubvec.length() != graph.ncon { raise InvalidOptions }
  }
}
