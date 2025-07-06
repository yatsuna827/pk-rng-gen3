///|
pub fn generate_gender_fixed_immut(
  fixed_gender : @types.Gender
) -> @core.Generator[@types.Gender] {
  _ => fixed_gender
}

///|
pub fn generate_gender_fixed_mut(
  fixed_gender : @types.Gender
) -> @core.GeneratorMut[@types.Gender] {
  _ => fixed_gender
}

///|
test "fixed gender returns specified gender" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let gender = generate_gender_fixed_mut(@types.Male)(lcg_ref)
  assert_eq(gender, @types.Male)
}

///|
test "fixed gender returns Female when specified" {
  let lcg_ref = @lcg32.Lcg32(0xABCDEF00U).to_ref()
  let gender = generate_gender_fixed_mut(@types.Female)(lcg_ref)
  assert_eq(gender, @types.Female)
}

///|
test "fixed gender does not consume RNG" {
  let lcg_ref = @lcg32.Lcg32(0x11111111U).to_ref()
  let initial_seed = lcg_ref.seed()
  let _ = generate_gender_fixed_mut(@types.Male)(lcg_ref)
  assert_eq(lcg_ref.seed(), initial_seed)
}
