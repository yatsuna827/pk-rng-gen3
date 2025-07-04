///| 
fn generate_pid_with_conditions_helper(
  lcg_ref : @lcg32.Lcg32Ref,
  required_nature : @types.Nature?,
  required_gender : @types.Gender?,
  gender_ratio : @types.GenderRatio,
  recalc~ : UInt = 0
) -> (@types.PID, UInt) {
  let pid = generate_pid(lcg_ref)
  if required_nature.map_or(true, fn(n) { pid.to_nature() == n }) &&
    required_gender.map_or(true, fn(g) { pid.to_gender(gender_ratio) == g }) {
    (pid, recalc)
  } else {
    generate_pid_with_conditions_helper(
      lcg_ref,
      required_nature,
      required_gender,
      gender_ratio,
      recalc=recalc + 1U,
    )
  }
}

///|
pub fn generate_pid_with_conditions(
  lcg_ref : @lcg32.Lcg32Ref,
  required_nature : @types.Nature?,
  required_gender : @types.Gender?,
  gender_ratio : @types.GenderRatio
) -> (@types.PID, UInt) {
  generate_pid_with_conditions_helper(
    lcg_ref, required_nature, required_gender, gender_ratio,
  )
}

///| 
pub fn generate_pid(lcg_ref : @lcg32.Lcg32Ref) -> @types.PID {
  let low = lcg_ref.get_rand()
  let high = lcg_ref.get_rand()
  low | (high << 16)
}

///|
test "generate_basic_pid should use two RNG calls" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let initial_seed = lcg_ref.seed()
  let pid = generate_pid(lcg_ref)

  // Should advance LCG by 2 calls
  let expected_seed = @lcg32.Lcg32(initial_seed).jump(2U).inner()
  assert_eq(lcg_ref.seed(), expected_seed)

  // PID should be constructed correctly
  let test_lcg = @lcg32.Lcg32(initial_seed)
  let test_lcg_ref = test_lcg.to_ref()
  let low = test_lcg_ref.get_rand()
  let high = test_lcg_ref.get_rand()
  let expected_pid = low | (high << 16)
  assert_eq(pid.inner(), expected_pid)
}
