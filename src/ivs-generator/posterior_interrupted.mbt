///|
pub fn generate_ivs_posterior_interrupted(
  lcg_ref : @lcg32.Lcg32Ref
) -> @types.IVs {
  let hab = lcg_ref.get_rand()
  let scd = lcg_ref.get_rand()
  lcg_ref.advance()
  @types.IVs::from_code(hab, scd)
}

///|
test "generate_ivs_posterior_interrupted should advance correctly" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let _ivs = generate_ivs_posterior_interrupted(lcg_ref)
  assert_eq(lcg_ref.get_index(from=initial_seed), 3)
}

///|
test "should match C# implementation" {
  let test_cases : Array[(@lcg32.Lcg32, (UInt, UInt, UInt, UInt, UInt, UInt))] = [
    (@lcg32.Lcg32(0x00000001U), (6, 14, 16, 1, 11, 1)),
    (@lcg32.Lcg32(0x12345678U), (17, 27, 2, 7, 1, 10)),
  ]
  for test_case in test_cases {
    let (lcg, expected) = test_case
    let ivs = generate_ivs_posterior_interrupted(lcg.to_ref())
    assert_eq(ivs.as_tuple(), expected)
  }
}
