///|
pub(all) struct IVs {
  h : UInt
  a : UInt
  b : UInt
  c : UInt
  d : UInt
  s : UInt
} derive(Eq, Show)

///|
pub fn IVs::new(
  h : UInt,
  a : UInt,
  b : UInt,
  c : UInt,
  d : UInt,
  s : UInt
) -> IVs {
  { h, a, b, c, d, s }
}

///|
pub fn IVs::from_code(hab : UInt, scd : UInt) -> IVs {
  {
    h: hab & 0x1f,
    a: (hab >> 5) & 0x1f,
    b: (hab >> 10) & 0x1f,
    c: (scd >> 5) & 0x1f,
    d: (scd >> 10) & 0x1f,
    s: scd & 0x1f,
  }
}

///|
pub fn IVs::as_tuple(self : IVs) -> (UInt, UInt, UInt, UInt, UInt, UInt) {
  (self.h, self.a, self.b, self.c, self.d, self.s)
}

///|
pub impl ToJson for IVs with to_json(self) {
  Json::array([
    Json::number(self.h.to_double()),
    Json::number(self.a.to_double()),
    Json::number(self.b.to_double()),
    Json::number(self.c.to_double()),
    Json::number(self.d.to_double()),
    Json::number(self.s.to_double()),
  ])
}
