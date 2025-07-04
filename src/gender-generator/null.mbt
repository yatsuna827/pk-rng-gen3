///|
pub fn generate_gender_null_immut(_ : @lcg32.Lcg32) -> @types.Gender {
  @types.Genderless
}

///|
pub fn generate_gender_null_mut(_ : @lcg32.Lcg32Ref) -> @types.Gender {
  @types.Genderless
}

///|
test "null generator always returns Genderless" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let gender = generate_gender_null_mut(lcg_ref)
  assert_eq(gender, @types.Genderless)
}

///|
test "null generator does not consume RNG" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let initial_seed = lcg_ref.seed()
  let _ = generate_gender_null_mut(lcg_ref)
  assert_eq(lcg_ref.seed(), initial_seed)
}
