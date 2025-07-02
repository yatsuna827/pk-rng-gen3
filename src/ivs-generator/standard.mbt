///|
pub fn generate_ivs_standard_immut(lcg : @lcg32.Lcg32) -> @types.IVs {
  let lcg_ref = lcg.to_ref()
  let hab = lcg_ref.get_rand()
  let scd = lcg_ref.get_rand()
  @types.IVs::new(
    hab & 0x1f,
    (hab >> 5) & 0x1f,
    (hab >> 10) & 0x1f,
    (scd >> 5) & 0x1f,
    (scd >> 10) & 0x1f,
    scd & 0x1f,
  )
}

///|
pub fn generate_ivs_standard_mut(lcg_ref : @lcg32.Lcg32Ref) -> @types.IVs {
  let hab = lcg_ref.get_rand()
  let scd = lcg_ref.get_rand()
  @types.IVs::new(
    hab & 0x1f,
    (hab >> 5) & 0x1f,
    (hab >> 10) & 0x1f,
    (scd >> 5) & 0x1f,
    (scd >> 10) & 0x1f,
    scd & 0x1f,
  )
}

///|
test "generate_ivs_standard_mut should advance LCG state correctly" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let _ivs = generate_ivs_standard_mut(lcg_ref)
  assert_eq(lcg_ref.seed(), 0x84EA22A2U)
}

///|
test "should produce expected values for known seed" {
  let lcg = @lcg32.Lcg32(0x00000001U)
  let ivs = generate_ivs_standard_immut(lcg)
  assert_eq(ivs.h(), 6)
  assert_eq(ivs.a(), 14)
  assert_eq(ivs.b(), 16)
  assert_eq(ivs.c(), 1)
  assert_eq(ivs.d(), 11)
  assert_eq(ivs.s(), 1)
}

///|
test "immut and mut versions should produce same result" {
  let seed : UInt = 0x00000001U
  let lcg = @lcg32.Lcg32(seed)
  let ivs_immut = generate_ivs_standard_immut(lcg)
  let lcg_ref = @lcg32.Lcg32(seed).to_ref()
  let ivs_mut = generate_ivs_standard_mut(lcg_ref)
  assert_eq(ivs_immut.h(), ivs_mut.h())
  assert_eq(ivs_immut.a(), ivs_mut.a())
  assert_eq(ivs_immut.b(), ivs_mut.b())
  assert_eq(ivs_immut.c(), ivs_mut.c())
  assert_eq(ivs_immut.d(), ivs_mut.d())
  assert_eq(ivs_immut.s(), ivs_mut.s())
}
