///|
pub fn version() -> (Int32, Int32, Int32) {
  (metis_version_major(), metis_version_minor(), metis_version_subminor())
}

///|
pub fn native_option_count() -> Int32 {
  metis_native_noptions()
}
