// PosteriorInterruptedIVsGenerator (Method3)

///|
pub fn generate_ivs_posterior_interrupted_immut(
  lcg : @lcg32.Lcg32
) -> @types.IVs {
  generate_ivs_posterior_interrupted_mut(lcg.to_ref())
}

///|
pub fn generate_ivs_posterior_interrupted_mut(
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
  let _ivs = generate_ivs_posterior_interrupted_mut(lcg_ref)
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
    let ivs = generate_ivs_posterior_interrupted_immut(lcg)
    assert_eq(ivs.as_tuple(), expected)
  }
}

///|
test "posterior_interrupted immut and mut versions should produce same result" {
  let lcg = @lcg32.Lcg32(0x00000001U)
  assert_eq(
    generate_ivs_posterior_interrupted_immut(lcg),
    generate_ivs_posterior_interrupted_mut(lcg.to_ref()),
  )
}
