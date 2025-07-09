///|
pub fn generate_nature_synchronize(
  sync_nature : @types.Nature
) -> @core.GeneratorMut[@types.Nature] {
  lcg_ref => if lcg_ref.get_rand(m=2) == 0 {
    sync_nature
  } else {
    generate_nature_standard(lcg_ref)
  }
}

///|
test "should match C# implementation" {
  let generate = generate_nature_synchronize(@types.Modest)
  let test_cases = [
    (@lcg32.Lcg32(0x00000000U), @types.Modest),
    (@lcg32.Lcg32(0x00000001U), @types.Modest),
    (@lcg32.Lcg32(0x12345678U), @types.Lonely),
  ]
  for test_case in test_cases {
    let (lcg, expected) = test_case
    let result = generate(lcg.to_ref())
    assert_eq(result, expected)
  }
}
