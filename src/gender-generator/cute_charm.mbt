///|
pub fn generate_gender_cute_charm_immut(
  lcg : @lcg32.Lcg32,
  cute_charm_gender : @types.Gender
) -> @types.Gender {
  let lcg_ref = lcg.to_ref()
  generate_gender_cute_charm_mut(lcg_ref, cute_charm_gender)
}

///|
pub fn generate_gender_cute_charm_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  cute_charm_gender : @types.Gender
) -> @types.Gender {
  if cute_charm_gender == @types.Genderless {
    return @types.Genderless
  }
  if lcg_ref.get_rand(m=3) != 0 {
    cute_charm_gender.reverse()
  } else {
    @types.Genderless
  }
}

///|
test "cute charm returns Genderless when RNG result is 0" {
  let lcg_ref = @lcg32.Lcg32(0x00000000U).to_ref()
  let gender = generate_gender_cute_charm_mut(lcg_ref, @types.Male)
  assert_eq(gender, @types.Genderless)
}

///|
test "cute charm returns opposite gender for Male charm" {
  let lcg_ref = @lcg32.Lcg32(0x00000001U).to_ref()
  let gender = generate_gender_cute_charm_mut(lcg_ref, @types.Male)
  assert_eq(gender, @types.Female)
}

///|
test "cute charm returns opposite gender for Female charm" {
  let lcg_ref = @lcg32.Lcg32(0x00000001U).to_ref()
  let gender = generate_gender_cute_charm_mut(lcg_ref, @types.Female)
  assert_eq(gender, @types.Male)
}

///|
test "cute charm does not consume RNG for Genderless charm" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let initial_seed = lcg_ref.seed()
  let gender = generate_gender_cute_charm_mut(lcg_ref, @types.Genderless)
  assert_eq(gender, @types.Genderless)
  assert_eq(lcg_ref.seed(), initial_seed)
}

///|
test "cute charm matches C# implementation" {
  let male_test_cases = [
    (0x00000000U, @types.Gender::Genderless),
    (0x00000001U, @types.Female),
    (0x00000002U, @types.Female),
    (0x00000003U, @types.Female),
    (0x00000004U, @types.Female),
    (0x00000005U, @types.Female),
    (0x00000006U, @types.Female),
    (0x00000007U, @types.Gender::Genderless),
    (0x00000008U, @types.Female),
    (0x00000009U, @types.Female),
  ]
  for test_case in male_test_cases {
    let (seed, expected) = test_case
    let lcg = @lcg32.Lcg32(seed)
    let result = generate_gender_cute_charm_immut(lcg, @types.Male)
    assert_eq(result, expected)
  }
  let female_test_cases = [
    (0x00000000U, @types.Gender::Genderless),
    (0x00000001U, @types.Male),
    (0x00000002U, @types.Male),
    (0x00000003U, @types.Male),
    (0x00000004U, @types.Male),
    (0x00000005U, @types.Male),
    (0x00000006U, @types.Male),
    (0x00000007U, @types.Gender::Genderless),
    (0x00000008U, @types.Male),
    (0x00000009U, @types.Male),
  ]
  for test_case in female_test_cases {
    let (seed, expected) = test_case
    let lcg = @lcg32.Lcg32(seed)
    let result = generate_gender_cute_charm_immut(lcg, @types.Female)
    assert_eq(result, expected)
  }
}
