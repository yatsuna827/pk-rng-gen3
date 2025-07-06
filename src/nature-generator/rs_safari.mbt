///|
pub fn generate_nature_rs_safari_immut(
  pokeblock~ : @types.PokeBlock? = None
) -> @core.Generator[@types.Nature] {
  let generate = generate_nature_rs_safari_mut(pokeblock~)
  lcg => generate(lcg.to_ref())
}

///|
pub fn generate_nature_rs_safari_mut(
  pokeblock~ : @types.PokeBlock? = None
) -> @core.GeneratorMut[@types.Nature] {
  lcg_ref => {
    let rand = lcg_ref.get_rand(m=100)
    match pokeblock {
      None => generate_nature_standard_mut(lcg_ref)
      Some(block) =>
        if rand >= 80 {
          generate_nature_standard_mut(lcg_ref)
        } else {
          let list = shuffle(lcg_ref)
          let idx = list.search_by(n => block.is_liked_by(n)).unwrap()
          list[idx]
        }
    }
  }
}

///|
test "produces same nature regardless of immutable or mutable usage" {
  let pokeblock = Some(@types.PokeBlock::new(@types.Sweet))
  let lcg = @lcg32.Lcg32(0x12345678U)
  assert_eq(
    generate_nature_rs_safari_immut(pokeblock~)(lcg),
    generate_nature_rs_safari_mut(pokeblock~)(lcg.to_ref()),
  )
}

///|
test "C# compatibility" {
  let test_cases = [
    (@lcg32.Lcg32(0x12345678U), None, @types.Lonely, 0x84EA22A2U),
    (
      @lcg32.Lcg32(0x00000000),
      Some(@types.PokeBlock::new(@types.Spicy)),
      @types.Brave,
      0x2578510FU,
    ),
    (
      @lcg32.Lcg32(0x12345678U),
      Some(@types.PokeBlock::new(@types.Spicy)),
      @types.Adamant,
      0x8B6072A7U,
    ),
    (
      @lcg32.Lcg32(0x00000001),
      Some(@types.PokeBlock::new(@types.Sweet)),
      @types.Jolly,
      0x791C0A6CU,
    ),
  ]
  for test_case in test_cases {
    let (lcg, pokeblock, expected_nature, expected_seed) = test_case
    let lcg_ref = lcg.to_ref()
    let result = generate_nature_rs_safari_mut(pokeblock~)(lcg_ref)
    assert_eq(result, expected_nature)
    assert_eq(lcg_ref.seed(), expected_seed)
  }
}
