///|
pub fn generate_nature_synchronize_immut(
  sync_nature : @types.Nature
) -> @core.Generator[@types.Nature] {
  lcg => generate_nature_synchronize_mut(sync_nature)(lcg.to_ref())
}

///|
pub fn generate_nature_synchronize_mut(
  sync_nature : @types.Nature
) -> @core.GeneratorMut[@types.Nature] {
  lcg_ref => if lcg_ref.get_rand(m=2) == 0 {
    sync_nature
  } else {
    generate_nature_standard_mut(lcg_ref)
  }
}

///|
test "should match C# implementation" {
  let generate = generate_nature_synchronize_immut(@types.Modest)
  let test_cases = [
    (@lcg32.Lcg32(0x00000000U), @types.Modest),
    (@lcg32.Lcg32(0x00000001U), @types.Modest),
    (@lcg32.Lcg32(0x12345678U), @types.Lonely),
  ]
  for test_case in test_cases {
    let (lcg, expected) = test_case
    let result = generate(lcg)
    assert_eq(result, expected)
  }
}

///|
test "immut and mut versions should produce equivalent results" {
  let sync_nature = @types.Modest
  let lcg = @lcg32.Lcg32(0x12345678U)
  assert_eq(
    generate_nature_synchronize_immut(sync_nature)(lcg),
    generate_nature_synchronize_mut(sync_nature)(lcg.to_ref()),
  )
}
