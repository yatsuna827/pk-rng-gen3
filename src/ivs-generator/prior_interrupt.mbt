///|
pub fn generate_ivs_prior_interrupt(lcg_ref : @lcg32.Lcg32Ref) -> @types.IVs {
  lcg_ref.advance()
  let hab = lcg_ref.get_rand()
  let scd = lcg_ref.get_rand()
  @types.IVs::from_code(hab, scd)
}

///|
test "generate_ivs_prior_interrupt should advance correctly" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let _ = generate_ivs_prior_interrupt(lcg_ref)
  assert_eq(lcg_ref.get_index(from=initial_seed), 3)
}

///|
test "should match C# implementation" {
  let test_cases : Array[(@lcg32.Lcg32, (UInt, UInt, UInt, UInt, UInt, UInt))] = [
    (@lcg32.Lcg32(0x00000001U), (1, 1, 11, 23, 20, 14)),
    (@lcg32.Lcg32(0x12345678U), (10, 7, 1, 12, 22, 10)),
  ]
  for test_case in test_cases {
    let (lcg, expected) = test_case
    let ivs = generate_ivs_prior_interrupt(lcg.to_ref())
    assert_eq(ivs.as_tuple(), expected)
  }
}
