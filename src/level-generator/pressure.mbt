///|
pub fn generate_level_pressure(
  lcg_ref : @lcg32.Lcg32Ref,
  basic_lv : UInt,
  variable_lv : UInt
) -> UInt {
  if variable_lv == 0U {
    panic()
  }
  let mut lv = basic_lv + lcg_ref.get_rand(m=variable_lv)
  if lcg_ref.get_rand(m=2) == 0U {
    lv = basic_lv + variable_lv
  }
  if lv != basic_lv {
    lv = lv - 1U
  }
  lv
}

///|
test "should advance RNG state by two steps" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let level = generate_level_pressure(lcg_ref, 20U, 5U)
  assert_eq(level, 24U)
  assert_eq(lcg_ref.get_index(from=initial_seed), 2)
}

///|
test "panic variable_lv is 0" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let _ = generate_level_pressure(lcg.to_ref(), 50U, 0U)

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
    let level = generate_level_pressure(lcg.to_ref(), basic, variable)
    assert_eq(level, expected)
  }
}
