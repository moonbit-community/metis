///|
pub fn version() -> (Int, Int, Int) {
  (metis_version_major(), metis_version_minor(), metis_version_subminor())
}

///|
pub fn native_option_count() -> Int {
  metis_native_noptions()
}
