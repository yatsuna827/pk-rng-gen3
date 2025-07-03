///|
pub fn generate_nature_standard_immut(lcg : @lcg32.Lcg32) -> @types.Nature {
  let lcg_ref = lcg.to_ref()
  let nature_value = lcg_ref.get_rand(m=25)
  @types.Nature::from_value(nature_value).unwrap()
}

///|
pub fn generate_nature_standard_mut(lcg_ref : @lcg32.Lcg32Ref) -> @types.Nature {
  let nature_value = lcg_ref.get_rand(m=25)
  @types.Nature::from_value(nature_value).unwrap()
}

///|
test "should advance RNG state by one step" {
  let initial_seed = 0x12345678U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let _nature = generate_nature_standard_mut(lcg_ref)
  let lcg_ref2 = @lcg32.Lcg32(initial_seed).to_ref()
  lcg_ref2.advance()
  assert_eq(lcg_ref.seed(), lcg_ref2.seed())
}

///|
test "should generate deterministic nature from seed" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let nature = generate_nature_standard_immut(lcg)
  assert_eq(nature, @types.Naughty)
}

///|
test "should produce final seed state correctly" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let _nature = generate_nature_standard_mut(lcg_ref)
  assert_eq(lcg_ref.seed(), 0x0B71C18BU)
}

///|
test "should generate different nature from different seed" {
  let lcg = @lcg32.Lcg32(0x00000001U)
  let nature = generate_nature_standard_immut(lcg)
  assert_eq(nature, @types.Jolly)
}

///|
test "immut and mut versions should produce equivalent results" {
  let seed : UInt = 0x00000001U
  let lcg = @lcg32.Lcg32(seed)
  let nature_immut = generate_nature_standard_immut(lcg)
  let lcg_ref = @lcg32.Lcg32(seed).to_ref()
  let nature_mut = generate_nature_standard_mut(lcg_ref)
  assert_eq(nature_immut, nature_mut)
}
