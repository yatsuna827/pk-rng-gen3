///|
pub fn standard(
  lcg_ref : @lcg32.Lcg32Ref,
  basic_lv : UInt,
  variable_lv : UInt
) -> UInt {
  if variable_lv == 0U {
    panic()
  }
  basic_lv + lcg_ref.get_rand(m=variable_lv)
}

///|
test "should advance RNG state by one step" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let level = standard(lcg_ref, 20U, 5U)
  assert_eq(level, 24U)
  assert_eq(lcg_ref.get_index(from=initial_seed), 1)
}

///|
test "should match C# implementation" {
  let test_cases = [
    (@lcg32.Lcg32(0x00000001U), 10U, 1U, 10U),
    (@lcg32.Lcg32(0x12345678U), 10U, 1U, 10U),
    (@lcg32.Lcg32(0x12345678U), 20U, 5U, 24U),
  ]
  for test_case in test_cases {
    let (lcg, basic, variable, expected) = test_case
    let level = standard(lcg.to_ref(), basic, variable)
    assert_eq(level, expected)
  }
}

///|
test "panic variable_lv is 0" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let _ = standard(lcg_ref, 50U, 0U)

}
