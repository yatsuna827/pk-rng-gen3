///|
pub(all) type HiddenPower (PokeType, UInt) derive(Eq, Show)

///|
pub fn IVs::hidden_power(self : IVs) -> HiddenPower {
  (hidden_power_type(self), hidden_power_power(self))
}

///|
fn hidden_power_power(ivs : IVs) -> UInt {
  let num = ((ivs.h >> 1) & 1) +
    2 * ((ivs.a >> 1) & 1) +
    4 * ((ivs.b >> 1) & 1) +
    8 * ((ivs.s >> 1) & 1) +
    16 * ((ivs.c >> 1) & 1) +
    32 * ((ivs.d >> 1) & 1)
  num * 40 / 63 + 30
}

///|
fn hidden_power_type(ivs : IVs) -> PokeType {
  let num = (ivs.h & 1) +
    2 * (ivs.a & 1) +
    4 * (ivs.b & 1) +
    8 * (ivs.s & 1) +
    16 * (ivs.c & 1) +
    32 * (ivs.d & 1)
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
    (IVs::new(0, 0, 0, 0, 0, 0), HiddenPower((PokeType::Fighting, 30U))),
    (IVs::new(15, 20, 25, 10, 5, 30), HiddenPower((PokeType::Fire, 45U))),
    //
    (IVs::new(31, 2, 31, 30, 31, 30), HiddenPower((PokeType::Fire, 70U))),
    (IVs::new(31, 2, 30, 30, 31, 31), HiddenPower((PokeType::Water, 70U))),
    (IVs::new(31, 2, 31, 30, 31, 31), HiddenPower((PokeType::Grass, 70U))),
    (IVs::new(31, 3, 31, 30, 31, 31), HiddenPower((PokeType::Electric, 70U))),
    (IVs::new(31, 2, 30, 31, 31, 31), HiddenPower((PokeType::Ice, 70U))),
    //
    (IVs::new(31, 31, 30, 30, 30, 30), HiddenPower((PokeType::Fighting, 70U))),
    (IVs::new(31, 31, 30, 30, 30, 31), HiddenPower((PokeType::Poison, 70U))),
    (IVs::new(31, 31, 31, 30, 30, 31), HiddenPower((PokeType::Ground, 70U))),
    (IVs::new(30, 30, 30, 30, 30, 31), HiddenPower((PokeType::Flying, 70U))),
    (IVs::new(31, 2, 31, 31, 31, 30), HiddenPower((PokeType::Psychic, 70U))),
    (IVs::new(31, 31, 31, 31, 30, 30), HiddenPower((PokeType::Bug, 70U))),
    (IVs::new(31, 31, 30, 31, 30, 30), HiddenPower((PokeType::Rock, 70U))),
    (IVs::new(31, 31, 30, 31, 30, 31), HiddenPower((PokeType::Ghost, 70U))),
    (IVs::new(31, 2, 31, 31, 31, 31), HiddenPower((PokeType::Dragon, 70U))),
    (IVs::new(31, 31, 31, 31, 31, 31), HiddenPower((PokeType::Dark, 70U))),
    (IVs::new(31, 31, 31, 31, 30, 31), HiddenPower((PokeType::Steel, 70U))),
  ]
  for test_case in test_cases {
    let (ivs, expected) = test_case
    assert_eq(ivs.hidden_power(), expected)
  }
}
