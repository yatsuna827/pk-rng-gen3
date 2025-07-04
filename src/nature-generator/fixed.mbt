///|
pub fn generate_nature_fixed_immut(
  _lcg : @lcg32.Lcg32,
  fixed_nature : @types.Nature
) -> @types.Nature {
  fixed_nature
}

///|
pub fn generate_nature_fixed_mut(
  _lcg_ref : @lcg32.Lcg32Ref,
  fixed_nature : @types.Nature
) -> @types.Nature {
  fixed_nature
}

///|
test "should return specified nature unchanged" {
  let lcg = @lcg32.Lcg32(0x00000001U)
  let fixed_nature = @types.Timid
  let result = generate_nature_fixed_immut(lcg, fixed_nature)
  assert_eq(result, fixed_nature)
}

///|
test "should not advance RNG state" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let fixed_nature = @types.Bold
  let _result = generate_nature_fixed_mut(lcg_ref, fixed_nature)
  assert_eq(lcg_ref.seed(), initial_seed)
}

///|
test "immut and mut versions should produce equivalent results" {
  let seed : UInt = 0x12345678U
  let fixed_nature = @types.Jolly
  let lcg = @lcg32.Lcg32(seed)
  let result_immut = generate_nature_fixed_immut(lcg, fixed_nature)
  let lcg_ref = @lcg32.Lcg32(seed).to_ref()
  let result_mut = generate_nature_fixed_mut(lcg_ref, fixed_nature)
  assert_eq(result_immut, result_mut)
}
