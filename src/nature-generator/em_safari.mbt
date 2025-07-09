///|
pub fn generate_nature_em_safari_immut(
  sync_nature~ : @types.Nature? = None,
  pokeblock~ : @types.PokeBlock? = None
) -> @core.Generator[@types.Nature] {
  lcg => generate_nature_em_safari_mut(sync_nature~, pokeblock~)(lcg.to_ref())
}

///|
pub fn generate_nature_em_safari_mut(
  sync_nature~ : @types.Nature? = None,
  pokeblock~ : @types.PokeBlock? = None
) -> @core.GeneratorMut[@types.Nature] {
  let fallback = match sync_nature {
    Some(sync_nature) => generate_nature_synchronize_mut(sync_nature)
    None => generate_nature_standard_mut
  }
  lcg_ref => {
    let rand = lcg_ref.get_rand(m=100)
    match pokeblock {
      None => fallback(lcg_ref)
      Some(block) =>
        if rand >= 80 {
          fallback(lcg_ref)
        } else {
          for n in shuffle(lcg_ref) {
            if block.is_liked_by(n) {
              break n
            }
          } else {
            panic()
          }
        }
    }
  }
}

///|
test "EmSafari: C# compatibility - Test 1: Sync=Brave, Block=Spicy" {
  let pokeblock = Some(@types.PokeBlock::new(@types.Spicy))
  let sync_nature = Some(@types.Brave)
  let generate = generate_nature_em_safari_immut(pokeblock~, sync_nature~)
  let test_cases = [
    (@lcg32.Lcg32(0x00000000), @types.Brave),
    (@lcg32.Lcg32(0x00000001), @types.Lonely),
    (@lcg32.Lcg32(0x00000002), @types.Naughty),
    (@lcg32.Lcg32(0x00000003), @types.Adamant),
    (@lcg32.Lcg32(0x00000004), @types.Naughty),
    (@lcg32.Lcg32(0x12345678), @types.Adamant),
    (@lcg32.Lcg32(0x87654321), @types.Lonely),
    (@lcg32.Lcg32(0xABCDEF01), @types.Adamant),
    (@lcg32.Lcg32(0xDEADBEEF), @types.Naughty),
  ]
  for test_case in test_cases {
    let (lcg, expected) = test_case
    let result = generate(lcg)
    assert_eq(result, expected)
  }
}

///|
test "EmSafari: C# compatibility - Test 2: Sync=Timid, Block=Tasteless" {
  let sync_nature = Some(@types.Timid)
  let generate = generate_nature_em_safari_immut(sync_nature~)
  //

  let test_cases = [
    (@lcg32.Lcg32(0x00000000), @types.Timid),
    (@lcg32.Lcg32(0x00000001), @types.Careful),
    (@lcg32.Lcg32(0x00000002), @types.Docile),
    (@lcg32.Lcg32(0x00000003), @types.Timid),
    (@lcg32.Lcg32(0x00000004), @types.Timid),
  ]
  for test_case in test_cases {
    let (lcg, expected) = test_case
    let result = generate(lcg)
    assert_eq(result, expected)
  }
}

///|
test "EmSafari: C# compatibility - Test 3: Sync=Modest, Block=Sweet" {
  let pokeblock = Some(@types.PokeBlock::new(@types.Sweet))
  let sync_nature = Some(@types.Modest)
  let generate = generate_nature_em_safari_immut(pokeblock~, sync_nature~)
  let test_cases = [
    (@lcg32.Lcg32(0x00000000), @types.Hasty),
    (@lcg32.Lcg32(0x00000001), @types.Jolly),
    (@lcg32.Lcg32(0x00000002), @types.Naive),
    (@lcg32.Lcg32(0x00000003), @types.Hasty),
    (@lcg32.Lcg32(0x00000004), @types.Naive),
  ]
  for test_case in test_cases {
    let (lcg, expected) = test_case
    let result = generate(lcg)
    assert_eq(result, expected)
  }
}
