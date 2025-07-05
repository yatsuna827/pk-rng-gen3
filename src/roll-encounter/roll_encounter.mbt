///|
pub fn roll_encounter_rse_mut(
  base_encounter_rate : UInt,
  option~ : EncounterOption? = None
) -> @core.GeneratorMut[Bool] {
  lcg_ref => {
    let encounter_rate = compute_encounter_rate(base_encounter_rate, option~)
    let random = lcg_ref.get_rand(m=2880)
    random < encounter_rate
  }
}

///|
pub fn roll_encounter_rse_immut(
  base_encounter_rate : UInt,
  option~ : EncounterOption? = None
) -> @core.Generator[Bool] {
  lcg => roll_encounter_rse_mut(base_encounter_rate, option~)(lcg.to_ref())
}

///|
pub fn roll_encounter_force_mut(_ : @lcg32.Lcg32Ref) -> Bool {
  true
}

///|
pub fn roll_encounter_force_immut(_ : @lcg32.Lcg32) -> Bool {
  true
}

///|
test "rse encounter drawing matches C# implementation" {
  let test_cases = [
    (0x12345678U, true),
    (0x87654321U, true),
    (0xABCDEF01U, true),
    (0xDEADBEEFU, true),
    (0x00000000U, true),
    (0xFFFFFFFFU, false),
    (0x55555555U, false),
    (0xAAAAAAAAU, false),
    (0x12AB34CDU, true),
    (0x98765432U, false),
  ]
  for test_case in test_cases {
    let (seed, expected) = test_case
    let result = roll_encounter_rse_immut(2048)(@lcg32.Lcg32(seed))
    assert_eq(result, expected)
  }
}

///|
test "always return true for force encounter" {
  let lcg = @lcg32.Lcg32(0xFFFFFFFFU)
  let result = roll_encounter_force_immut(lcg)
  assert_eq(result, true)
}
