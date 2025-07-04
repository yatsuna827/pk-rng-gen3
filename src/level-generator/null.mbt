///|
pub fn generate_level_null_immut(
  _lcg : @lcg32.Lcg32,
  basic_lv : UInt,
  _variable_lv : UInt
) -> UInt {
  basic_lv
}

///|
pub fn generate_level_null_mut(
  _lcg_ref : @lcg32.Lcg32Ref,
  basic_lv : UInt,
  _variable_lv : UInt
) -> UInt {
  basic_lv
}

///|
test "should always return basic_lv without RNG consumption" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let level = generate_level_null_immut(lcg, 25U, 10U)
  assert_eq(level, 25U)
}

///|
test "should not advance RNG state" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let level = generate_level_null_mut(lcg_ref, 25U, 10U)
  assert_eq(level, 25U)
  assert_eq(lcg_ref.seed(), initial_seed)
}

///|
test "should work consistently between immut and mut" {
  let seed = 0x12345678U
  let lcg = @lcg32.Lcg32(seed)
  let level_immut = generate_level_null_immut(lcg, 33U, 7U)
  let lcg_ref = @lcg32.Lcg32(seed).to_ref()
  let level_mut = generate_level_null_mut(lcg_ref, 33U, 7U)
  assert_eq(level_immut, level_mut)
}

///|
test "should ignore variable_lv parameter completely" {
  let test_cases = [(15U, 0U), (15U, 1U), (15U, 999U), (42U, 0U), (42U, 100U)]
  for test_case in test_cases {
    let (basic_lv, variable_lv) = test_case
    let lcg = @lcg32.Lcg32(0x12345678U)
    let level = generate_level_null_immut(lcg, basic_lv, variable_lv)
    assert_eq(level, basic_lv)
  }
}
