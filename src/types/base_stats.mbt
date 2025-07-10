///|
pub(all) struct BaseStats {
  h : UInt
  a : UInt
  b : UInt
  c : UInt
  d : UInt
  s : UInt
} derive(Eq, Show)

///|
pub fn BaseStats::new(
  h : UInt,
  a : UInt,
  b : UInt,
  c : UInt,
  d : UInt,
  s : UInt
) -> BaseStats {
  { h, a, b, c, d, s }
}

///|
pub fn BaseStats::as_tuple(
  self : BaseStats
) -> (UInt, UInt, UInt, UInt, UInt, UInt) {
  (self.h, self.a, self.b, self.c, self.d, self.s)
}
