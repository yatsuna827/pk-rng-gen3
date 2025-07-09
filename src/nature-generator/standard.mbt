///|
pub fn generate_nature_standard(lcg_ref : @lcg32.Lcg32Ref) -> @types.Nature {
  let nature_value = lcg_ref.get_rand(m=25)
  @types.Nature::from_value(nature_value)
}

///|
test "should match C# implementation" {
  let test_cases = [
    (@lcg32.Lcg32(0x00000001U), @types.Jolly),
    (@lcg32.Lcg32(0x12345678U), @types.Naughty),
  ]
  for test_case in test_cases {
    let (lcg, expected) = test_case
    let nature = generate_nature_standard(lcg.to_ref())
    assert_eq(nature, expected)
  }
}
