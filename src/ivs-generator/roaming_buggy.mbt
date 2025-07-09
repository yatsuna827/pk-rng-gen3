///|
pub fn generate_ivs_roaming_buggy(lcg_ref : @lcg32.Lcg32Ref) -> @types.IVs {
  let hab = lcg_ref.get_rand() & 0xFF // 下位8bitのみ有効（バグ）
  let scd = lcg_ref.get_rand() & 0x0 // 常に0（バグ）
  @types.IVs::from_code(hab, scd)
}

///|
test "generate_ivs_roaming_buggy should advance correctly" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let _ = generate_ivs_roaming_buggy(lcg_ref)
  assert_eq(lcg_ref.get_index(from=initial_seed), 2)
}

///|
test "should match C# implementation" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let ivs = generate_ivs_roaming_buggy(lcg.to_ref())
  assert_eq(ivs.as_tuple(), (17, 3, 0, 0, 0, 0))
}
