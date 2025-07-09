///|
pub(all) type HiddenPower (PokeType, UInt)

///|
pub fn IVs::hidden_power(self : IVs) -> HiddenPower {
  HiddenPower(hidden_power_type(self), hidden_power_power(self))
}

///|
fn hidden_power_power(ivs : IVs) -> UInt {
  let num = ((self.h >> 1) & 1) +
    2 * ((self.a >> 1) & 1) +
    4 * ((self.b >> 1) & 1) +
    8 * ((self.s >> 1) & 1) +
    16 * ((self.c >> 1) & 1) +
    32 * ((self.d >> 1) & 1)
  num * 40 / 63 + 30
}

///|
fn hidden_power_type(ivs : IVs) -> PokeType {
  let num = (self.h & 1) +
    2 * (self.a & 1) +
    4 * (self.b & 1) +
    8 * (self.s & 1) +
    16 * (self.c & 1) +
    32 * (self.d & 1)
  let index = num * 15 / 63
  match index {
    0 => PokeType::Fighting
    1 => PokeType::Flying
    2 => PokeType::Poison
    3 => PokeType::Ground
    4 => PokeType::Rock
    5 => PokeType::Bug
    6 => PokeType::Ghost
    7 => PokeType::Steel
    8 => PokeType::Fire
    9 => PokeType::Water
    10 => PokeType::Grass
    11 => PokeType::Electric
    12 => PokeType::Psychic
    13 => PokeType::Ice
    14 => PokeType::Dragon
    15 => PokeType::Dark
    _ => panic()
  }
}

///|
test "should match C# implementation" {
  let test_cases = [
    (IVs::new(31, 31, 31, 31, 31, 31), HiddenPower(PokeType::Dark, 70U)),
    (IVs::new(0, 0, 0, 0, 0, 0), HiddenPower(PokeType::Fighting, 30U)),
    (IVs::new(15, 20, 25, 10, 5, 30), HiddenPower(PokeType::Fire, 45U)),
    (IVs::new(31, 2, 31, 31, 31, 31), HiddenPower(PokeType::Ice, 70U)),
    (IVs::new(31, 2, 31, 30, 31, 30), HiddenPower(PokeType::Fire, 70U)),
  ]
  for test_case in test_cases {
    let (ivs, expected) = test_case
    let (expected_power, expected_type) = expected
    assert_eq(power, expected_power)
    assert_eq(type_, expected_type)
  }
}
