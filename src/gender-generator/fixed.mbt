///|
pub fn generate_gender_fixed_immut(
  lcg : @lcg32.Lcg32,
  fixed_gender : @types.Gender
) -> @types.Gender {
  fixed_gender
}

///|
pub fn generate_gender_fixed_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  fixed_gender : @types.Gender
) -> @types.Gender {
  fixed_gender
}

///|
test "fixed gender returns specified gender" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let gender = generate_gender_fixed_mut(lcg_ref, @types.Male)
  assert_eq(gender, @types.Male)
}

///|
test "fixed gender returns Female when specified" {
  let lcg_ref = @lcg32.Lcg32(0xABCDEF00U).to_ref()
  let gender = generate_gender_fixed_mut(lcg_ref, @types.Female)
  assert_eq(gender, @types.Female)
}

///|
test "fixed gender does not consume RNG" {
  let lcg_ref = @lcg32.Lcg32(0x11111111U).to_ref()
  let initial_seed = lcg_ref.seed()
  let gender = generate_gender_fixed_mut(lcg_ref, @types.Male)
  assert_eq(lcg_ref.seed(), initial_seed)
}
