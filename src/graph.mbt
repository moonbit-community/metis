///|
pub struct CsrGraph {
  priv nvtxs : Int
  priv ncon : Int
  priv xadj : FixedArray[Int]
  priv adjncy : FixedArray[Int]
  priv vwgt : FixedArray[Int]?
  priv vsize : FixedArray[Int]?
  priv adjwgt : FixedArray[Int]?
}

///|
#as_free_fn
pub fn CsrGraph::CsrGraph(
  nvtxs : Int,
  xadj : FixedArray[Int],
  adjncy : FixedArray[Int],
  ncon? : Int = 1,
  vwgt? : FixedArray[Int],
  vsize? : FixedArray[Int],
  adjwgt? : FixedArray[Int],
) -> CsrGraph raise MetisError {
  make_csr_graph(nvtxs, xadj, adjncy, ncon~, vwgt?, vsize?, adjwgt?)
}

///|
fn make_csr_graph(
  nvtxs : Int,
  xadj : FixedArray[Int],
  adjncy : FixedArray[Int],
  ncon? : Int = 1,
  vwgt? : FixedArray[Int],
  vsize? : FixedArray[Int],
  adjwgt? : FixedArray[Int],
) -> CsrGraph raise MetisError {
  let graph = { nvtxs, ncon, xadj, adjncy, vwgt, vsize, adjwgt }
  graph.validate()
  graph
}

///|
pub fn CsrGraph::new(
  nvtxs : Int,
  xadj : FixedArray[Int],
  adjncy : FixedArray[Int],
  ncon? : Int = 1,
  vwgt? : FixedArray[Int],
  vsize? : FixedArray[Int],
  adjwgt? : FixedArray[Int],
) -> CsrGraph raise MetisError {
  make_csr_graph(nvtxs, xadj, adjncy, ncon~, vwgt?, vsize?, adjwgt?)
}

///|
pub fn CsrGraph::nvtxs(self : CsrGraph) -> Int {
  self.nvtxs
}

///|
pub fn CsrGraph::ncon(self : CsrGraph) -> Int {
  self.ncon
}

///|
pub fn CsrGraph::xadj(self : CsrGraph) -> FixedArray[Int] {
  self.xadj
}

///|
pub fn CsrGraph::adjncy(self : CsrGraph) -> FixedArray[Int] {
  self.adjncy
}

///|
pub fn CsrGraph::vertex_weights(self : CsrGraph) -> FixedArray[Int]? {
  self.vwgt
}

///|
pub fn CsrGraph::vertex_sizes(self : CsrGraph) -> FixedArray[Int]? {
  self.vsize
}

///|
pub fn CsrGraph::adjacency_weights(self : CsrGraph) -> FixedArray[Int]? {
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
fn int_array_or_empty(value : FixedArray[Int]?) -> FixedArray[Int] {
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
  nparts : Int,
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
