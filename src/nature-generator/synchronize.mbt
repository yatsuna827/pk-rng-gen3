///|
pub fn generate_nature_synchronize_immut(
  lcg : @lcg32.Lcg32,
  sync_nature : @types.Nature
) -> @types.Nature {
  let lcg_ref = lcg.to_ref()
  let sync_check = lcg_ref.get_rand(m=2)
  if sync_check == 0 {
    sync_nature
  } else {
    generate_nature_standard_mut(lcg_ref)
  }
}

///|
pub fn generate_nature_synchronize_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  sync_nature : @types.Nature
) -> @types.Nature {
  let sync_check = lcg_ref.get_rand(m=2)
  if sync_check == 0 {
    sync_nature
  } else {
    generate_nature_standard_mut(lcg_ref)
  }
}

///|
test "should return specified nature when sync activates" {
  let lcg = @lcg32.Lcg32(0x00000000U)
  let sync_nature = @types.Modest
  let result = generate_nature_synchronize_immut(lcg, sync_nature)
  assert_eq(result, sync_nature)
}

///|
test "should return specified nature when sync activates with different seed" {
  let lcg = @lcg32.Lcg32(0x00000001U)
  let sync_nature = @types.Adamant
  let result = generate_nature_synchronize_immut(lcg, sync_nature)
  assert_eq(result, sync_nature)
}

///|
test "should fallback to standard generation when sync fails" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let sync_nature = @types.Modest
  let result = generate_nature_synchronize_immut(lcg, sync_nature)
  assert_eq(result, @types.Lonely)
}

///|
test "should advance RNG state correctly when sync activates" {
  let lcg_ref = @lcg32.Lcg32(0x00000000U).to_ref()
  let sync_nature = @types.Modest
  let _result = generate_nature_synchronize_mut(lcg_ref, sync_nature)
  assert_eq(lcg_ref.seed(), 0x00006073U)
}

///|
test "should advance RNG state correctly when sync fails" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let sync_nature = @types.Modest
  let _result = generate_nature_synchronize_mut(lcg_ref, sync_nature)
  assert_eq(lcg_ref.seed(), 0x84EA22A2U)
}

///|
test "immut and mut versions should produce equivalent results" {
  let seed : UInt = 0x12345678U
  let sync_nature = @types.Modest
  let lcg = @lcg32.Lcg32(seed)
  let result_immut = generate_nature_synchronize_immut(lcg, sync_nature)
  let lcg_ref = @lcg32.Lcg32(seed).to_ref()
  let result_mut = generate_nature_synchronize_mut(lcg_ref, sync_nature)
  assert_eq(result_immut, result_mut)
}
