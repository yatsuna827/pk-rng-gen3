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
pub impl ToJson for BaseStats with to_json(self) {
  Json::array([
    Json::number(self.h.to_double()),
    Json::number(self.a.to_double()),
    Json::number(self.b.to_double()),
    Json::number(self.c.to_double()),
    Json::number(self.d.to_double()),
    Json::number(self.s.to_double()),
  ])
}

///|
pub impl @json.FromJson for BaseStats with from_json(json, path) {
  guard json is Array(arr) else {
    raise @json.JsonDecodeError((path, "expected array"))
  }
  match arr {
    [
      Json::Number(h),
      Json::Number(a),
      Json::Number(b),
      Json::Number(c),
      Json::Number(d),
      Json::Number(s),
    ] =>
      BaseStats::new(
        h.to_uint(),
        a.to_uint(),
        b.to_uint(),
        c.to_uint(),
        d.to_uint(),
        s.to_uint(),
      )
    _ =>
      raise @json.JsonDecodeError((path, "expected number array of length 6"))
  }
}

///|
test "ToJson should convert BaseStats to [h,a,b,c,d,s] array" {
  let stats = BaseStats::new(100, 80, 90, 70, 85, 95)
  let json = stats.to_json()
  let expected = Json::array([
    Json::number(100),
    Json::number(80),
    Json::number(90),
    Json::number(70),
    Json::number(85),
    Json::number(95),
  ])
  assert_eq(json, expected)
  assert_eq(json.stringify(), "[100,80,90,70,85,95]")
}

///|
test "FromJson should parse [h,a,b,c,d,s] array" {
  let json = Json::array([
    Json::number(100),
    Json::number(80),
    Json::number(90),
    Json::number(70),
    Json::number(85),
    Json::number(95),
  ])
  let stats = (@json.from_json(json) : BaseStats)
  let expected = BaseStats::new(100, 80, 90, 70, 85, 95)
  assert_eq(stats, expected)
}

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
