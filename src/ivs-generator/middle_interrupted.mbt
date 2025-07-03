// MiddleInterruptedIVsGenerator (Method4)

///|
pub fn generate_ivs_middle_interrupted_immut(lcg : @lcg32.Lcg32) -> @types.IVs {
  let lcg_ref = lcg.to_ref()
  let hab = lcg_ref.get_rand()
  lcg_ref.advance() // HABとSCDの間で1回進める
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
pub fn generate_ivs_middle_interrupted_mut(
  lcg_ref : @lcg32.Lcg32Ref
) -> @types.IVs {
  let hab = lcg_ref.get_rand()
  lcg_ref.advance() // HABとSCDの間で1回進める
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
test "generate_ivs_middle_interrupted should advance correctly" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()

  // 手動で3回進める（hab + advance + scd）
  lcg_ref.advance()
  lcg_ref.advance()
  lcg_ref.advance()
  let expected = lcg_ref.seed()

  // 改めて同じ初期状態でテスト
  let lcg_ref2 = @lcg32.Lcg32(initial_seed).to_ref()
  let _ivs = generate_ivs_middle_interrupted_mut(lcg_ref2)
  assert_eq(lcg_ref2.seed(), expected)
}

///|
test "middle_interrupted should produce expected values for seed 0x12345678" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let ivs = generate_ivs_middle_interrupted_immut(lcg)
  assert_eq(ivs.h(), 17)
  assert_eq(ivs.a(), 27)
  assert_eq(ivs.b(), 2)
  assert_eq(ivs.c(), 12)
  assert_eq(ivs.d(), 22)
  assert_eq(ivs.s(), 10)
}

///|
test "middle_interrupted final seed should be 0xD98A7B6D" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let _ivs = generate_ivs_middle_interrupted_mut(lcg_ref)
  assert_eq(lcg_ref.seed(), 0xD98A7B6DU)
}

///|
test "middle_interrupted immut and mut versions should produce same result" {
  let seed : UInt = 0x00000001U
  let lcg = @lcg32.Lcg32(seed)
  let ivs_immut = generate_ivs_middle_interrupted_immut(lcg)
  let lcg_ref = @lcg32.Lcg32(seed).to_ref()
  let ivs_mut = generate_ivs_middle_interrupted_mut(lcg_ref)
  assert_eq(ivs_immut.h(), ivs_mut.h())
  assert_eq(ivs_immut.a(), ivs_mut.a())
  assert_eq(ivs_immut.b(), ivs_mut.b())
  assert_eq(ivs_immut.c(), ivs_mut.c())
  assert_eq(ivs_immut.d(), ivs_mut.d())
  assert_eq(ivs_immut.s(), ivs_mut.s())
}
