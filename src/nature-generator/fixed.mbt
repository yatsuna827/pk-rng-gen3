///|
pub fn generate_nature_fixed_immut(
  fixed_nature : @types.Nature
) -> @core.Generator[@types.Nature] {
  _ => fixed_nature
}

///|
pub fn generate_nature_fixed_mut(
  fixed_nature : @types.Nature
) -> @core.GeneratorMut[@types.Nature] {
  _ => fixed_nature
}

///|
test "should return specified nature" {
  let lcg = @lcg32.Lcg32(0x00000001U)
  let fixed_nature = @types.Timid
  let result = generate_nature_fixed_immut(fixed_nature)(lcg)
  assert_eq(result, fixed_nature)
}

///|
test "should not advance RNG state" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let fixed_nature = @types.Bold
  let _ = generate_nature_fixed_mut(fixed_nature)(lcg_ref)
  assert_eq(lcg_ref.seed(), initial_seed)
}

///|
test "immut and mut versions should produce equivalent results" {
  let fixed_nature = @types.Jolly
  let lcg = @lcg32.Lcg32(0x12345678U)
  assert_eq(
    generate_nature_fixed_immut(fixed_nature)(lcg),
    generate_nature_fixed_mut(fixed_nature)(lcg.to_ref()),
  )
}
