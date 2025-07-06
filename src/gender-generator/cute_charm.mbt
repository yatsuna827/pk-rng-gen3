///|
pub fn generate_gender_cute_charm_immut(
  cute_charm_gender : @types.Gender
) -> @core.Generator[@types.Gender] {
  lcg => generate_gender_cute_charm_mut(cute_charm_gender)(lcg.to_ref())
}

///|
pub fn generate_gender_cute_charm_mut(
  cute_charm_gender : @types.Gender
) -> @core.GeneratorMut[@types.Gender] {
  lcg_ref => {
    if cute_charm_gender == @types.Genderless {
      return @types.Genderless
    }
    if lcg_ref.get_rand(m=3) != 0 {
      cute_charm_gender.reverse()
    } else {
      @types.Genderless
    }
  }
}

///|
test "cute charm does not consume RNG for Genderless charm" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let initial_seed = lcg_ref.seed()
  let _ = generate_gender_cute_charm_mut(@types.Genderless)(lcg_ref)
  assert_eq(lcg_ref.seed(), initial_seed)
}

///|
test "should match C# implementation" {
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
    let result = generate_gender_cute_charm_immut(@types.Male)(lcg)
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
    let result = generate_gender_cute_charm_immut(@types.Female)(lcg)
    assert_eq(result, expected)
  }
}
