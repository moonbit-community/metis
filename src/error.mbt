///|
pub(all) suberror MetisError {
  Input
  Memory
  Error
  InvalidGraph
  InvalidMesh
  InvalidOptions
  UnsupportedIndexWidth
} derive(Eq, Hash)

///|
fn raise_status(status : Int) -> Unit raise MetisError {
  match status {
    1 => ()
    -2 => raise Input
    -3 => raise Memory
    -4 => raise Error
    _ => raise Error
  }
}
