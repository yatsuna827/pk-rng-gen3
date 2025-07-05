// RoamingBuggyIVsGenerator (徘徊バグ版)

///|
pub fn generate_ivs_roaming_buggy_immut(lcg : @lcg32.Lcg32) -> @types.IVs {
  generate_ivs_roaming_buggy_mut(lcg.to_ref())
}

///|
pub fn generate_ivs_roaming_buggy_mut(lcg_ref : @lcg32.Lcg32Ref) -> @types.IVs {
  let hab = lcg_ref.get_rand() & 0xFF // 下位8bitのみ有効（バグ）
  let scd = lcg_ref.get_rand() & 0x0 // 常に0（バグ）
  @types.IVs::from_code(hab, scd)
}

///|
test "generate_ivs_roaming_buggy should advance correctly" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let _ = generate_ivs_roaming_buggy_mut(lcg_ref)
  assert_eq(lcg_ref.get_index(from=initial_seed), 2)
}

///|
test "should match C# implementation" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let ivs = generate_ivs_roaming_buggy_immut(lcg)
  assert_eq(ivs.as_tuple(), (17, 3, 0, 0, 0, 0))
}

///|
test "roaming_buggy immut and mut versions should produce same result" {
  let lcg = @lcg32.Lcg32(0x00000001U)
  assert_eq(
    generate_ivs_roaming_buggy_immut(lcg),
    generate_ivs_roaming_buggy_mut(lcg.to_ref()),
  )
}
