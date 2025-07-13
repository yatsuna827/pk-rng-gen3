///|
pub fn fixed(fixed_gender : @core.Gender) -> @core.GeneratorMut[@core.Gender] {
  _ => fixed_gender
}

///|
test "fixed gender returns specified gender" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let gender = fixed(@core.Male)(lcg_ref)
  assert_eq(gender, @core.Male)
}

///|
test "fixed gender returns Female when specified" {
  let lcg_ref = @lcg32.Lcg32(0xABCDEF00U).to_ref()
  let gender = fixed(@core.Female)(lcg_ref)
  assert_eq(gender, @core.Female)
}

///|
test "fixed gender does not consume RNG" {
  let lcg_ref = @lcg32.Lcg32(0x11111111U).to_ref()
  let initial_seed = lcg_ref.seed()
  let _ = fixed(@core.Male)(lcg_ref)
  assert_eq(lcg_ref.seed(), initial_seed)
}
