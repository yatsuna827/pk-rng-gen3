///|
pub fn generate_level_pressure_immut(
  lcg : @lcg32.Lcg32,
  basic_lv : UInt,
  variable_lv : UInt
) -> UInt {
  let lcg_ref = lcg.to_ref()
  generate_level_pressure_mut(lcg_ref, basic_lv, variable_lv)
}

///|
pub fn generate_level_pressure_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  basic_lv : UInt,
  variable_lv : UInt
) -> UInt {
  if variable_lv == 0U {
    panic()
  }
  let rng_val = lcg_ref.get_rand(m=variable_lv)
  let lv = basic_lv + rng_val
  let rng_val2 = lcg_ref.get_rand()
  let lv = if (rng_val2 & 1U) == 0U { basic_lv + variable_lv } else { lv }
  if lv != basic_lv {
    lv - 1U
  } else {
    lv
  }
}

///|
test "should match C# implementation" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let level = generate_level_pressure_immut(lcg, 20U, 5U)
  assert_eq(level, 24U)
}

///|
test "should advance RNG state by two steps" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let level = generate_level_pressure_mut(lcg_ref, 20U, 5U)
  assert_eq(level, 24U)
  assert_eq(lcg_ref.seed(), 0x84EA22A2U)
}

///|
test "should produce same result regardless of interface" {
  let seed = 0x12345678U
  let lcg = @lcg32.Lcg32(seed)
  let level_immut = generate_level_pressure_immut(lcg, 20U, 5U)
  let lcg_ref = @lcg32.Lcg32(seed).to_ref()
  let level_mut = generate_level_pressure_mut(lcg_ref, 20U, 5U)
  assert_eq(level_immut, level_mut)
}

///|
test "panic variable_lv is 0 immut" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let _ = generate_level_pressure_immut(lcg, 50U, 0U)

}

///|
test "panic variable_lv is 0 mut" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let _ = generate_level_pressure_mut(lcg_ref, 50U, 0U)

}

///|
test "should match C# implementation" {
  let test_cases = [
    (0x10000000U, 20U, 5U, 24U),
    (0x22222222U, 20U, 5U, 24U),
    (0x80000000U, 20U, 5U, 24U),
    (0x00000001U, 10U, 1U, 10U),
    (0x12345678U, 10U, 1U, 10U),
  ]
  for test_case in test_cases {
    let (seed, basic, variable, expected) = test_case
    let lcg = @lcg32.Lcg32(seed)
    let level = generate_level_pressure_immut(lcg, basic, variable)
    assert_eq(level, expected)
  }
}

///|
test "should consume exactly two RNG calls for pressure algorithm" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let _level = generate_level_pressure_mut(lcg_ref, 20U, 5U)
  let lcg_ref2 = @lcg32.Lcg32(initial_seed).to_ref()
  lcg_ref2.advance(n=2)
  assert_eq(lcg_ref.seed(), lcg_ref2.seed())
}
