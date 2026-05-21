///|
pub struct Options {
  priv values : FixedArray[Int]
}

///|
pub(all) enum PartitioningScheme {
  RecursiveBisection
  Kway
}

///|
fn PartitioningScheme::to_int(self : PartitioningScheme) -> Int {
  match self {
    RecursiveBisection => 0
    Kway => 1
  }
}

///|
pub(all) enum ObjectiveType {
  Cut
  Volume
  Node
}

///|
fn ObjectiveType::to_int(self : ObjectiveType) -> Int {
  match self {
    Cut => 0
    Volume => 1
    Node => 2
  }
}

///|
pub(all) enum CoarseningScheme {
  RandomMatching
  SortedHeavyEdgeMatching
}

///|
fn CoarseningScheme::to_int(self : CoarseningScheme) -> Int {
  match self {
    RandomMatching => 0
    SortedHeavyEdgeMatching => 1
  }
}

///|
pub(all) enum InitialPartitioningScheme {
  Grow
  Random
  Edge
  Node
  MetisRecursiveBisection
}

///|
fn InitialPartitioningScheme::to_int(self : InitialPartitioningScheme) -> Int {
  match self {
    Grow => 0
    Random => 1
    Edge => 2
    Node => 3
    MetisRecursiveBisection => 4
  }
}

///|
pub(all) enum RefinementScheme {
  Fm
  Greedy
  SeparatorTwoSided
  SeparatorOneSided
}

///|
fn RefinementScheme::to_int(self : RefinementScheme) -> Int {
  match self {
    Fm => 0
    Greedy => 1
    SeparatorTwoSided => 2
    SeparatorOneSided => 3
  }
}

///|
pub(all) enum DebugFlag {
  Info
  Time
  Coarsen
  Refine
  InitialPartition
  MoveInfo
  SeparatorInfo
  ConnectivityInfo
  ContiguityInfo
  Memory
}

///|
fn DebugFlag::to_int(self : DebugFlag) -> Int {
  match self {
    Info => 1
    Time => 2
    Coarsen => 4
    Refine => 8
    InitialPartition => 16
    MoveInfo => 32
    SeparatorInfo => 64
    ConnectivityInfo => 128
    ContiguityInfo => 256
    Memory => 2048
  }
}

///|
pub fn Options::default() -> Options {
  let values = FixedArray::make(metis_noptions, -1)
  { values, }
}

///|
fn Options::raw(self : Options) -> FixedArray[Int] {
  self.values
}

///|
fn option_or_default(options : Options?) -> Options {
  match options {
    None => Options::default()
    Some(options) => options
  }
}

///|
pub fn Options::set_partitioning_scheme(
  self : Options,
  scheme : PartitioningScheme,
) -> Options {
  self.values[option_ptype] = scheme.to_int()
  self
}

///|
pub fn Options::set_objective_type(
  self : Options,
  objective : ObjectiveType,
) -> Options {
  self.values[option_objtype] = objective.to_int()
  self
}

///|
pub fn Options::set_coarsening_scheme(
  self : Options,
  scheme : CoarseningScheme,
) -> Options {
  self.values[option_ctype] = scheme.to_int()
  self
}

///|
pub fn Options::set_initial_partitioning_scheme(
  self : Options,
  scheme : InitialPartitioningScheme,
) -> Options {
  self.values[option_iptype] = scheme.to_int()
  self
}

///|
pub fn Options::set_refinement_scheme(
  self : Options,
  scheme : RefinementScheme,
) -> Options {
  self.values[option_rtype] = scheme.to_int()
  self
}

///|
pub fn Options::set_debug_level(self : Options, level : Int) -> Options {
  self.values[option_dbglvl] = level
  self
}

///|
pub fn Options::set_debug_flags(
  self : Options,
  flags : FixedArray[DebugFlag],
) -> Options {
  let mut level = 0
  for flag in flags {
    level = level | flag.to_int()
  }
  self.set_debug_level(level)
}

///|
pub fn Options::set_seed(self : Options, seed : Int) -> Options {
  self.values[option_seed] = seed
  self
}

///|
pub fn Options::set_number_of_cuts(self : Options, ncuts : Int) -> Options {
  self.values[option_ncuts] = ncuts
  self
}

///|
pub fn Options::set_number_of_iterations(
  self : Options,
  niter : Int,
) -> Options {
  self.values[option_niter] = niter
  self
}

///|
pub fn Options::set_number_of_initial_partitions(
  self : Options,
  niparts : Int,
) -> Options {
  self.values[option_niparts] = niparts
  self
}

///|
pub fn Options::set_minimize_connectivity(
  self : Options,
  enabled : Bool,
) -> Options {
  self.values[option_minconn] = if enabled { 1 } else { 0 }
  self
}

///|
pub fn Options::set_contiguous(self : Options, enabled : Bool) -> Options {
  self.values[option_contig] = if enabled { 1 } else { 0 }
  self
}

///|
pub fn Options::set_compress(self : Options, enabled : Bool) -> Options {
  self.values[option_compress] = if enabled { 1 } else { 0 }
  self
}

///|
pub fn Options::set_connected_component_ordering(
  self : Options,
  enabled : Bool,
) -> Options {
  self.values[option_ccorder] = if enabled { 1 } else { 0 }
  self
}

///|
pub fn Options::set_pruning_factor(self : Options, factor : Int) -> Options {
  self.values[option_pfactor] = factor
  self
}

///|
pub fn Options::set_number_of_separators(
  self : Options,
  nseps : Int,
) -> Options {
  self.values[option_nseps] = nseps
  self
}

///|
pub fn Options::set_imbalance_factor(self : Options, factor : Int) -> Options {
  self.values[option_ufactor] = factor
  self
}

///|
pub fn Options::set_drop_edges(self : Options, enabled : Bool) -> Options {
  self.values[option_dropedges] = if enabled { 1 } else { 0 }
  self
}

///|
pub fn Options::set_on_disk(self : Options, enabled : Bool) -> Options {
  self.values[option_ondisk] = if enabled { 1 } else { 0 }
  self
}

///|
pub fn Options::set_no_two_hop(self : Options, enabled : Bool) -> Options {
  self.values[option_no2hop] = if enabled { 1 } else { 0 }
  self
}
