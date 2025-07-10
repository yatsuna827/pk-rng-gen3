///|
pub fn generate_gender_cute_charm(
  cute_charm_gender : @core.Gender
) -> @core.GeneratorMut[@core.Gender] {
  lcg_ref => {
    if cute_charm_gender == @core.Genderless {
      return @core.Genderless
    }
    if lcg_ref.get_rand(m=3) != 0 {
      cute_charm_gender.reverse()
    } else {
      @core.Genderless
    }
  }
}

///|
test "cute charm does not consume RNG for Genderless charm" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let initial_seed = lcg_ref.seed()
  let _ = generate_gender_cute_charm(@core.Genderless)(lcg_ref)
  assert_eq(lcg_ref.seed(), initial_seed)
}

///|
test "should match C# implementation" {
  let male_test_cases = [
    (0x00000000U, @core.Gender::Genderless),
    (0x00000001U, @core.Female),
    (0x00000002U, @core.Female),
    (0x00000003U, @core.Female),
    (0x00000004U, @core.Female),
    (0x00000005U, @core.Female),
    (0x00000006U, @core.Female),
    (0x00000007U, @core.Gender::Genderless),
    (0x00000008U, @core.Female),
    (0x00000009U, @core.Female),
  ]
  for test_case in male_test_cases {
    let (seed, expected) = test_case
    let lcg = @lcg32.Lcg32(seed)
    let result = generate_gender_cute_charm(@core.Male)(lcg.to_ref())
    assert_eq(result, expected)
  }
  let female_test_cases = [
    (0x00000000U, @core.Gender::Genderless),
    (0x00000001U, @core.Male),
    (0x00000002U, @core.Male),
    (0x00000003U, @core.Male),
    (0x00000004U, @core.Male),
    (0x00000005U, @core.Male),
    (0x00000006U, @core.Male),
    (0x00000007U, @core.Gender::Genderless),
    (0x00000008U, @core.Male),
    (0x00000009U, @core.Male),
  ]
  for test_case in female_test_cases {
    let (seed, expected) = test_case
    let lcg = @lcg32.Lcg32(seed)
    let result = generate_gender_cute_charm(@core.Female)(lcg.to_ref())
    assert_eq(result, expected)
  }
}
