///|
pub fn standard(lcg_ref : @lcg32.Lcg32Ref) -> @core.IVs {
  let hab = lcg_ref.get_rand()
  let scd = lcg_ref.get_rand()
  @core.IVs::from_code(hab, scd)
}

///|
test "standard should advance LCG state correctly" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let _ = standard(lcg_ref)
  assert_eq(lcg_ref.get_index(from=initial_seed), 2)
}

///|
test "should match C# implementation" {
  let test_cases : Array[(@lcg32.Lcg32, (UInt, UInt, UInt, UInt, UInt, UInt))] = [
    (@lcg32.Lcg32(0x00000001U), (6, 14, 16, 1, 11, 1)),
    (@lcg32.Lcg32(0x12345678U), (17, 27, 2, 7, 1, 10)),
  ]
  for test_case in test_cases {
    let (lcg, expected) = test_case
    let ivs = standard(lcg.to_ref())
    assert_eq(ivs.as_tuple(), expected)
  }
}
