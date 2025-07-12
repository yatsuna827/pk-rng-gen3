///|
pub(all) struct Stats {
  h : UInt
  a : UInt
  b : UInt
  c : UInt
  d : UInt
  s : UInt
} derive(Eq, Show)

///|
pub fn Stats::new(
  h : UInt,
  a : UInt,
  b : UInt,
  c : UInt,
  d : UInt,
  s : UInt
) -> Stats {
  { h, a, b, c, d, s }
}

///|
pub fn Stats::as_tuple(self : Stats) -> (UInt, UInt, UInt, UInt, UInt, UInt) {
  (self.h, self.a, self.b, self.c, self.d, self.s)
}

///|
pub fn Stats::from(
  bs : BaseStats,
  ivs : IVs,
  lv : UInt,
  nature : Nature
) -> Stats {
  let h = (bs.h * 2 + ivs.h) * lv / 100 + lv + 10
  let base_a = (bs.a * 2 + ivs.a) * lv / 100 + 5
  let base_b = (bs.b * 2 + ivs.b) * lv / 100 + 5
  let base_c = (bs.c * 2 + ivs.c) * lv / 100 + 5
  let base_d = (bs.d * 2 + ivs.d) * lv / 100 + 5
  let base_s = (bs.s * 2 + ivs.s) * lv / 100 + 5
  let (a_mod, b_mod, c_mod, d_mod, s_mod) = nature.modifier()
  let a = base_a * a_mod / 100
  let b = base_b * b_mod / 100
  let c = base_c * c_mod / 100
  let d = base_d * d_mod / 100
  let s = base_s * s_mod / 100
  { h, a, b, c, d, s }
}

///|
fn Nature::modifier(self : Nature) -> (UInt, UInt, UInt, UInt, UInt) {
  match self {
    Hardy => (100, 100, 100, 100, 100)
    Lonely => (110, 90, 100, 100, 100)
    Brave => (110, 100, 100, 100, 90)
    Adamant => (110, 100, 90, 100, 100)
    Naughty => (110, 100, 100, 90, 100)
    Bold => (90, 110, 100, 100, 100)
    Docile => (100, 100, 100, 100, 100)
    Relaxed => (100, 110, 100, 100, 90)
    Impish => (100, 110, 90, 100, 100)
    Lax => (100, 110, 100, 90, 100)
    Timid => (90, 100, 100, 100, 110)
    Hasty => (100, 90, 100, 100, 110)
    Serious => (100, 100, 100, 100, 100)
    Jolly => (100, 100, 90, 100, 110)
    Naive => (100, 100, 100, 90, 110)
    Modest => (90, 100, 110, 100, 100)
    Mild => (100, 90, 110, 100, 100)
    Quiet => (100, 100, 110, 100, 90)
    Bashful => (100, 100, 100, 100, 100)
    Rash => (100, 100, 110, 90, 100)
    Calm => (90, 100, 100, 110, 100)
    Gentle => (100, 90, 100, 110, 100)
    Sassy => (100, 100, 90, 110, 100)
    Careful => (100, 100, 100, 110, 90)
    Quirky => (100, 100, 100, 100, 100)
  }
}

///|
test "should match the actual in-game stats" {
  let test_cases = [
    (
      BaseStats::new(80, 90, 80, 130, 110, 110),
      IVs::new(31, 7, 31, 31, 31, 31),
      50U,
      Nature::Timid,
      Stats::new(155, 88, 100, 150, 130, 143),
    ),
    (
      BaseStats::new(90, 90, 85, 125, 90, 100),
      IVs::new(31, 31, 31, 31, 31, 30),
      50U,
      Nature::Modest,
      Stats::new(165, 99, 105, 159, 110, 120),
    ),
    (
      BaseStats::new(250, 5, 5, 35, 105, 50),
      IVs::new(31, 0, 31, 31, 31, 31),
      5U,
      Nature::Bold,
      Stats::new(41, 4, 7, 10, 17, 11),
    ),
    (
      BaseStats::new(90, 95, 85, 55, 65, 70),
      IVs::new(31, 31, 31, 31, 31, 31),
      100U,
      Nature::Adamant,
      Stats::new(321, 248, 206, 131, 166, 176),
    ),
  ]
  for test_case in test_cases {
    let (bs, ivs, lv, nature, expected) = test_case
    let actual = Stats::from(bs, ivs, lv, nature)
    assert_eq(actual, expected)
  }
}

///|
test "should truncate the stat before applying the nature modifier" {
  let bs = BaseStats::new(20, 10, 230, 10, 230, 5)
  let ivs = IVs::new(0, 9, 0, 0, 0, 0)
  let result = Stats::from(bs, ivs, 50, Adamant)

  // (10 * 2 + 9) * 50 / 100 + 5 = 19.5
  // floor(19.5) * 1.1 = 19 * 1.1 = 20.9
  // 19.5 * 1.1 = 21.45
  assert_eq(result.a, 20)
}

///|
pub impl ToJson for Stats with to_json(self) {
  Json::array([
    Json::number(self.h.to_double()),
    Json::number(self.a.to_double()),
    Json::number(self.b.to_double()),
    Json::number(self.c.to_double()),
    Json::number(self.d.to_double()),
    Json::number(self.s.to_double()),
  ])
}
