///| 
fn generate_pid_with_conditions_helper(
  lcg_ref : @lcg32.Lcg32Ref,
  required_nature : @types.Nature?,
  required_gender : @types.Gender?,
  gender_ratio : @types.GenderRatio,
  recalc~ : UInt = 0
) -> (@types.PID, UInt) {
  let pid = generate_pid(lcg_ref)
  let nature_match = required_nature.map_or(true, fn(n) { pid.to_nature() == n })
  let gender_match = if gender_ratio == @types.GenderRatio::Genderless {
    true // 性別なしポケモンは性別制約を無視
  } else {
    required_gender.map_or(true, fn(g) { pid.to_gender(gender_ratio) == g })
  }
  if nature_match && gender_match {
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

///|
test "generate_pid_with_conditions should generate PID matching required nature" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let required_nature = @types.Nature::Hardy
  let (pid, _) = generate_pid_with_conditions(
    lcg_ref,
    Some(required_nature),
    None,
    @types.GenderRatio::Genderless,
  )

  assert_eq(pid.to_nature(), required_nature)
}

///|
test "generate_pid_with_conditions should generate PID matching required gender" {
  let lcg_ref = @lcg32.Lcg32(0x87654321U).to_ref()
  let required_gender = @types.Gender::Female
  let gender_ratio = @types.GenderRatio::Male1Female1
  let (pid, _) = generate_pid_with_conditions(
    lcg_ref,
    None,
    Some(required_gender),
    gender_ratio,
  )

  assert_eq(pid.to_gender(gender_ratio), required_gender)
}

///|
test "generate_pid_with_conditions should generate PID matching both nature and gender" {
  let lcg_ref = @lcg32.Lcg32(0xABCDEF01U).to_ref()
  let required_nature = @types.Nature::Modest
  let required_gender = @types.Gender::Male
  let gender_ratio = @types.GenderRatio::Male1Female1
  let (pid, _) = generate_pid_with_conditions(
    lcg_ref,
    Some(required_nature),
    Some(required_gender),
    gender_ratio,
  )

  // Generated PID should match both nature and gender
  assert_eq(pid.to_nature(), required_nature)
  assert_eq(pid.to_gender(gender_ratio), required_gender)
}

///|
test "generate_pid_with_conditions should work with no constraints" {
  let lcg = @lcg32.Lcg32(0xDEADBEEFU)
  let (pid, _) = generate_pid_with_conditions(
    lcg.to_ref(),
    None,
    None,
    @types.GenderRatio::Genderless,
  )

  assert_eq(pid.inner(), generate_pid(lcg.to_ref()).inner())
}

///|
test "generate_pid_with_conditions should handle genderless pokemon" {
  let lcg_ref = @lcg32.Lcg32(0x55555555U).to_ref()
  let required_nature = @types.Nature::Timid
  let (pid, _) = generate_pid_with_conditions(
    lcg_ref,
    Some(required_nature),
    None,
    @types.GenderRatio::Genderless,
  )

  assert_eq(pid.to_nature(), required_nature)

  // Gender should always be genderless for genderless species
  assert_eq(
    pid.to_gender(@types.GenderRatio::Genderless),
    @types.Gender::Genderless,
  )
}
