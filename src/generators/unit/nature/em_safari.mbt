///|
pub fn safari_em(
  sync_nature~ : @core.Nature? = None,
  pokeblock~ : @core.PokeBlock? = None
) -> @core.GeneratorMut[@core.Nature] {
  let fallback = match sync_nature {
    Some(sync_nature) => synchronize(sync_nature)
    None => standard
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
  let pokeblock = Some(@core.PokeBlock::new(@core.Spicy))
  let sync_nature = Some(@core.Brave)
  let generate = safari_em(pokeblock~, sync_nature~)
  let test_cases = [
    (@lcg32.Lcg32(0x00000000), @core.Brave),
    (@lcg32.Lcg32(0x00000001), @core.Lonely),
    (@lcg32.Lcg32(0x00000002), @core.Naughty),
    (@lcg32.Lcg32(0x00000003), @core.Adamant),
    (@lcg32.Lcg32(0x00000004), @core.Naughty),
    (@lcg32.Lcg32(0x12345678), @core.Adamant),
    (@lcg32.Lcg32(0x87654321), @core.Lonely),
    (@lcg32.Lcg32(0xABCDEF01), @core.Adamant),
    (@lcg32.Lcg32(0xDEADBEEF), @core.Naughty),
  ]
  for test_case in test_cases {
    let (lcg, expected) = test_case
    let result = generate(lcg.to_ref())
    assert_eq(result, expected)
  }
}

///|
test "EmSafari: C# compatibility - Test 2: Sync=Timid, Block=Tasteless" {
  let sync_nature = Some(@core.Timid)
  let generate = safari_em(sync_nature~)
  //

  let test_cases = [
    (@lcg32.Lcg32(0x00000000), @core.Timid),
    (@lcg32.Lcg32(0x00000001), @core.Careful),
    (@lcg32.Lcg32(0x00000002), @core.Docile),
    (@lcg32.Lcg32(0x00000003), @core.Timid),
    (@lcg32.Lcg32(0x00000004), @core.Timid),
  ]
  for test_case in test_cases {
    let (lcg, expected) = test_case
    let result = generate(lcg.to_ref())
    assert_eq(result, expected)
  }
}

///|
test "EmSafari: C# compatibility - Test 3: Sync=Modest, Block=Sweet" {
  let pokeblock = Some(@core.PokeBlock::new(@core.Sweet))
  let sync_nature = Some(@core.Modest)
  let generate = safari_em(pokeblock~, sync_nature~)
  let test_cases = [
    (@lcg32.Lcg32(0x00000000), @core.Hasty),
    (@lcg32.Lcg32(0x00000001), @core.Jolly),
    (@lcg32.Lcg32(0x00000002), @core.Naive),
    (@lcg32.Lcg32(0x00000003), @core.Hasty),
    (@lcg32.Lcg32(0x00000004), @core.Naive),
  ]
  for test_case in test_cases {
    let (lcg, expected) = test_case
    let result = generate(lcg.to_ref())
    assert_eq(result, expected)
  }
}
