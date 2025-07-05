///|
fn compute_encounter_rate(
  base_encounter_rate : UInt,
  option~ : EncounterOption? = None
) -> UInt {
  let rate = match option {
    Some(opt) => {
      let mut rate = base_encounter_rate
      if opt.riding_bicycle {
        rate = rate * 80 / 100
      }
      match opt.flute {
        Some(Flute::White) => rate = rate * 150 / 100
        Some(Flute::Black) => rate = rate * 50 / 100
        None => ()
      }
      if opt.has_cleanse_tag {
        rate = rate * 2 / 3
      }
      rate
    }
    None => base_encounter_rate
  }
  @math.minimum(2880, rate)
}

///|
test "calculate encounter rate correctly" {
  assert_eq(compute_encounter_rate(2160), 2160)
}

///|
test "apply bicycle reduction 80 percent" {
  assert_eq(
    compute_encounter_rate(
      2160,
      option=Some(EncounterOption::new(riding_bicycle=true)),
    ),
    // 2160 * 80 / 100
    1728,
  )
}

///|
test "black flute reduces encounter rate by 50 percent" {
  assert_eq(
    compute_encounter_rate(
      2000,
      option=Some(EncounterOption::new(flute=Some(Flute::Black))),
    ),
    1000,
  )
}

///|
test "white flute increases encounter rate by 50 percent" {
  assert_eq(
    compute_encounter_rate(
      1000,
      option=Some(EncounterOption::new(flute=Some(Flute::White))),
    ),
    1500,
  )
}

///|
test "cap encounter rate at 2880" {
  assert_eq(compute_encounter_rate(3000), 2880)
  // 2000 * 1.5 = 3000 > 2880
  assert_eq(
    compute_encounter_rate(
      2000,
      option=Some(EncounterOption::new(flute=Some(Flute::White))),
    ),
    2880,
  )
}

///|
pub fn draw_encounter_rse_mut(
  base_encounter_rate : UInt,
  option~ : EncounterOption? = None
) -> EncounterDrawerMut {
  lcg_ref => {
    let encounter_rate = compute_encounter_rate(base_encounter_rate, option~)
    let random = lcg_ref.get_rand(m=2880)
    random < encounter_rate
  }
}

///|
pub fn draw_encounter_rse_immut(
  base_encounter_rate : UInt,
  option~ : EncounterOption? = None
) -> EncounterDrawerImmut {
  lcg => draw_encounter_rse_mut(base_encounter_rate, option~)(lcg.to_ref())
}

///|
pub fn draw_encounter_force_mut(_ : @lcg32.Lcg32Ref) -> Bool {
  true
}

///|
pub fn draw_encounter_force_immut(_ : @lcg32.Lcg32) -> Bool {
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
    let result = draw_encounter_rse_immut(2048)(@lcg32.Lcg32(seed))
    assert_eq(result, expected)
  }
}

///|
test "always return true for force encounter" {
  let lcg = @lcg32.Lcg32(0xFFFFFFFFU)
  let result = draw_encounter_force_immut(lcg)
  assert_eq(result, true)
}
