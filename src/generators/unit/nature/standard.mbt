///|
pub fn standard(lcg_ref : @lcg32.Lcg32Ref) -> @core.Nature {
  let nature_value = lcg_ref.get_rand(m=25)
  @core.Nature::from_uint(nature_value)
}

///|
test "should match C# implementation" {
  let test_cases = [
    (@lcg32.Lcg32(0x00000001U), @core.Jolly),
    (@lcg32.Lcg32(0x12345678U), @core.Naughty),
  ]
  for test_case in test_cases {
    let (lcg, expected) = test_case
    let nature = standard(lcg.to_ref())
    assert_eq(nature, expected)
  }
}
