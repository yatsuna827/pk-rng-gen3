// RoamingBuggyIVsGenerator (徘徊バグ版)

///|
pub fn generate_ivs_roaming_buggy_immut(lcg : @lcg32.Lcg32) -> @types.IVs {
  let lcg_ref = lcg.to_ref()
  let hab = lcg_ref.get_rand() & 0xFF // 下位8bitのみ有効
  let scd = lcg_ref.get_rand() & 0x0 // 常に0（バグ）
  @types.IVs::new(
    hab & 0x1f, // HP: 0-31（正常）
    (hab >> 5) & 0x1f, // Attack: 0-7の範囲（バグ）
    (hab >> 10) & 0x1f, // Defense: 0（バグ）
    (scd >> 5) & 0x1f, // Sp.Atk: 0（バグ）
    (scd >> 10) & 0x1f, // Sp.Def: 0（バグ）
    scd & 0x1f, // Speed: 0（バグ）
  )
}

///|
pub fn generate_ivs_roaming_buggy_mut(lcg_ref : @lcg32.Lcg32Ref) -> @types.IVs {
  let hab = lcg_ref.get_rand() & 0xFF // 下位8bitのみ有効
  let scd = lcg_ref.get_rand() & 0x0 // 常に0（バグ）
  @types.IVs::new(
    hab & 0x1f, // HP: 0-31（正常）
    (hab >> 5) & 0x1f, // Attack: 0-7の範囲（バグ）
    (hab >> 10) & 0x1f, // Defense: 0（バグ）
    (scd >> 5) & 0x1f, // Sp.Atk: 0（バグ）
    (scd >> 10) & 0x1f, // Sp.Def: 0（バグ）
    scd & 0x1f, // Speed: 0（バグ）
  )
}

///|
test "generate_ivs_roaming_buggy should advance correctly" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let _ivs = generate_ivs_roaming_buggy_mut(lcg_ref)
  // 2回のRNG消費（hab + scd）
  assert_eq(lcg_ref.seed(), 0x84EA22A2U)
}

///|
test "roaming_buggy immut and mut versions should produce same result" {
  let seed : UInt = 0x00000001U
  let lcg = @lcg32.Lcg32(seed)
  let ivs_immut = generate_ivs_roaming_buggy_immut(lcg)
  let lcg_ref = @lcg32.Lcg32(seed).to_ref()
  let ivs_mut = generate_ivs_roaming_buggy_mut(lcg_ref)
  assert_eq(ivs_immut.h(), ivs_mut.h())
  assert_eq(ivs_immut.a(), ivs_mut.a())
  assert_eq(ivs_immut.b(), ivs_mut.b())
  assert_eq(ivs_immut.c(), ivs_mut.c())
  assert_eq(ivs_immut.d(), ivs_mut.d())
  assert_eq(ivs_immut.s(), ivs_mut.s())
}

///|
test "roaming_buggy should produce expected values for seed 0x12345678" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let ivs = generate_ivs_roaming_buggy_immut(lcg)
  assert_eq(ivs.h(), 17)
  assert_eq(ivs.a(), 3)
  assert_eq(ivs.b(), 0)
  assert_eq(ivs.c(), 0)
  assert_eq(ivs.d(), 0)
  assert_eq(ivs.s(), 0)
}
