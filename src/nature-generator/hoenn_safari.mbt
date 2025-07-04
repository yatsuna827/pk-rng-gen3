///|
pub fn generate_nature_hoenn_safari_immut(
  lcg : @lcg32.Lcg32,
  pokeblock : @types.PokeBlock?
) -> @types.Nature {
  let lcg_ref = lcg.to_ref()
  generate_nature_hoenn_safari_mut(lcg_ref, pokeblock)
}

///|
pub fn generate_nature_hoenn_safari_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  pokeblock : @types.PokeBlock?
) -> @types.Nature {
  let trigger_check = lcg_ref.get_rand(m=100)
  match pokeblock {
    None => generate_nature_standard_mut(lcg_ref)
    Some(block) =>
      if trigger_check >= 80 {
        generate_nature_standard_mut(lcg_ref)
      } else {
        let list = shuffle(lcg_ref)
        for i = 0; i < 25; i = i + 1 {
          let nature_value = list[i]
          let nature = @types.Nature::from_value(nature_value).unwrap()
          if block.is_liked_by(nature) {
            return nature
          }
        }

        // 見つからない場合（理論上は起きない）は最初の性格を返す
        @types.Nature::from_value(list[0]).unwrap()
      }
  }
}

///|
fn shuffle(lcg_ref : @lcg32.Lcg32Ref) -> Array[UInt] {
  let list = Array::makei(25, fn(i) { i.reinterpret_as_uint() })
  for i = 0; i < 25; i = i + 1 {
    for j = i + 1; j < 25; j = j + 1 {
      let swap_check = lcg_ref.get_rand(m=2)
      if swap_check == 1 {
        let temp = list[i]
        list[i] = list[j]
        list[j] = temp
      }
    }
  }
  list
}

///|
test "shuffle function should consume 300 RNG calls" {
  let lcg_ref = @lcg32.Lcg32(0x00000000U).to_ref()
  let initial_seed = lcg_ref.seed()
  let _list = shuffle(lcg_ref)
  let final_seed = lcg_ref.seed()
  let verification_lcg = @lcg32.Lcg32(initial_seed)
  let expected_seed = verification_lcg.jump(300).inner()
  assert_eq(final_seed, expected_seed)
}

///|
test "shuffle function should produce deterministic results" {
  let lcg_ref1 = @lcg32.Lcg32(0x12345678U).to_ref()
  let lcg_ref2 = @lcg32.Lcg32(0x12345678U).to_ref()
  let list1 = shuffle(lcg_ref1)
  let list2 = shuffle(lcg_ref2)
  assert_eq(list1, list2)
}

///|
test "shuffle function should contain all 25 natures" {
  let lcg_ref = @lcg32.Lcg32(0x00000000U).to_ref()
  let list = shuffle(lcg_ref)
  for i = 0; i < 25; i = i + 1 {
    let target = i.reinterpret_as_uint()
    let mut found = false
    for j = 0; j < 25; j = j + 1 {
      if list[j] == target {
        found = true
        break
      }
    }
    assert_eq(found, true)
  }
}

///|
test "should fallback to standard when no pokeblock" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let result = generate_nature_hoenn_safari_immut(lcg, None)
  assert_eq(result, @types.Lonely)
}

///|
test "should trigger pokeblock processing with seed 0x00000000" {
  let lcg_ref = @lcg32.Lcg32(0x00000000U).to_ref()
  let spicy_block = @types.PokeBlock::new(@types.Spicy)
  let result = generate_nature_hoenn_safari_mut(lcg_ref, Some(spicy_block))
  assert_eq(result, @types.Brave)
  assert_eq(lcg_ref.seed(), 0x2578510FU)
}

///|
test "should fallback to standard when trigger check fails" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let spicy_block = @types.PokeBlock::new(@types.Spicy)
  let result = generate_nature_hoenn_safari_mut(lcg_ref, Some(spicy_block))
  assert_eq(result, @types.Adamant)
  assert_eq(lcg_ref.seed(), 0x8B6072A7U)
}

///|
test "should work with different pokeblock flavors" {
  let lcg_ref = @lcg32.Lcg32(0x00000001U).to_ref()
  let sweet_block = @types.PokeBlock::new(@types.Sweet)
  let result = generate_nature_hoenn_safari_mut(lcg_ref, Some(sweet_block))
  assert_eq(result, @types.Jolly)
  assert_eq(lcg_ref.seed(), 0x791C0A6CU)
}

///|
test "immut and mut versions should produce equivalent results" {
  let seed : UInt = 0x12345678U
  let pokeblock = Some(@types.PokeBlock::new(@types.Sweet))
  let lcg = @lcg32.Lcg32(seed)
  let result_immut = generate_nature_hoenn_safari_immut(lcg, pokeblock)
  let lcg_ref = @lcg32.Lcg32(seed).to_ref()
  let result_mut = generate_nature_hoenn_safari_mut(lcg_ref, pokeblock)
  assert_eq(result_immut, result_mut)
}
