// PriorInterruptIVsGenerator (Method2)

///|
pub fn generate_ivs_prior_interrupt_immut(lcg : @lcg32.Lcg32) -> @types.IVs {
  generate_ivs_prior_interrupt_mut(lcg.to_ref())
}

///|
pub fn generate_ivs_prior_interrupt_mut(
  lcg_ref : @lcg32.Lcg32Ref
) -> @types.IVs {
  lcg_ref.advance()
  let hab = lcg_ref.get_rand()
  let scd = lcg_ref.get_rand()
  @types.IVs::from_code(hab, scd)
}

///|
test "generate_ivs_prior_interrupt should advance correctly" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let _ = generate_ivs_prior_interrupt_mut(lcg_ref)
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
    let ivs = generate_ivs_prior_interrupt_immut(lcg)
    assert_eq(ivs.as_tuple(), expected)
  }
}

///|
test "prior_interrupt immut and mut versions should produce same result" {
  let seed : UInt = 0x00000001U
  let lcg = @lcg32.Lcg32(seed)
  let ivs_immut = generate_ivs_prior_interrupt_immut(lcg)
  let lcg_ref = @lcg32.Lcg32(seed).to_ref()
  let ivs_mut = generate_ivs_prior_interrupt_mut(lcg_ref)
  assert_eq(ivs_immut, ivs_mut)
}
