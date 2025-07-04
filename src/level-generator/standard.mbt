///|
pub fn generate_level_standard_immut(
  lcg : @lcg32.Lcg32,
  basic_lv : UInt,
  variable_lv : UInt
) -> UInt {
  let lcg_ref = lcg.to_ref()
  generate_level_standard_mut(lcg_ref, basic_lv, variable_lv)
}

///|
pub fn generate_level_standard_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  basic_lv : UInt,
  variable_lv : UInt
) -> UInt {
  if variable_lv == 0U {
    panic()
  }
  let rng_val = lcg_ref.get_rand(m=variable_lv)
  basic_lv + rng_val
}

///|
test "should match C# implementation output" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let level = generate_level_standard_immut(lcg, 20U, 5U)
  assert_eq(level, 24U)
}

///|
test "should advance RNG state by one step" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let level = generate_level_standard_mut(lcg_ref, 20U, 5U)
  assert_eq(level, 24U)
  assert_eq(lcg_ref.seed(), 0x0B71C18BU)
}

///|
test "should produce same result regardless of interface" {
  let seed = 0x12345678U
  let lcg = @lcg32.Lcg32(seed)
  let level_immut = generate_level_standard_immut(lcg, 20U, 5U)
  let lcg_ref = @lcg32.Lcg32(seed).to_ref()
  let level_mut = generate_level_standard_mut(lcg_ref, 20U, 5U)
  assert_eq(level_immut, level_mut)
}

///|
test "should match C# implementation" {
  let test_cases = [(0x00000001U, 10U, 1U, 10U), (0x12345678U, 10U, 1U, 10U)]
  for test_case in test_cases {
    let (seed, basic, variable, expected) = test_case
    let lcg = @lcg32.Lcg32(seed)
    let level = generate_level_standard_immut(lcg, basic, variable)
    assert_eq(level, expected)
  }
}

///|
test "panic variable_lv is 0 immut" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let _ = generate_level_standard_immut(lcg, 50U, 0U)

}

///|
test "panic variable_lv is 0 mut" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let _ = generate_level_standard_mut(lcg_ref, 50U, 0U)

}
