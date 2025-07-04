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
        panic()
      }
  }
}

///|
test "generates standard nature when no pokeblock is used" {
  let lcg = @lcg32.Lcg32(0x12345678U)
  let result = generate_nature_hoenn_safari_immut(lcg, None)
  assert_eq(result, @types.Lonely)
}

///|
test "generates spicy-preferred nature when spicy pokeblock is used with favorable seed" {
  let lcg_ref = @lcg32.Lcg32(0x00000000U).to_ref()
  let spicy_block = @types.PokeBlock::new(@types.Spicy)
  let result = generate_nature_hoenn_safari_mut(lcg_ref, Some(spicy_block))
  assert_eq(result, @types.Brave)
}

///|
test "generates standard nature when pokeblock effect does not activate" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let spicy_block = @types.PokeBlock::new(@types.Spicy)
  let result = generate_nature_hoenn_safari_mut(lcg_ref, Some(spicy_block))
  assert_eq(result, @types.Adamant)
}

///|
test "generates sweet-preferred nature when sweet pokeblock is used" {
  let lcg_ref = @lcg32.Lcg32(0x00000001U).to_ref()
  let sweet_block = @types.PokeBlock::new(@types.Sweet)
  let result = generate_nature_hoenn_safari_mut(lcg_ref, Some(sweet_block))
  assert_eq(result, @types.Jolly)
}

///|
test "produces same nature regardless of immutable or mutable usage" {
  let seed : UInt = 0x12345678U
  let pokeblock = Some(@types.PokeBlock::new(@types.Sweet))
  let lcg = @lcg32.Lcg32(seed)
  let result_immut = generate_nature_hoenn_safari_immut(lcg, pokeblock)
  let lcg_ref = @lcg32.Lcg32(seed).to_ref()
  let result_mut = generate_nature_hoenn_safari_mut(lcg_ref, pokeblock)
  assert_eq(result_immut, result_mut)
}

///|
test "advances RNG state correctly when spicy pokeblock activates" {
  let lcg_ref = @lcg32.Lcg32(0x00000000U).to_ref()
  let spicy_block = @types.PokeBlock::new(@types.Spicy)
  let _ = generate_nature_hoenn_safari_mut(lcg_ref, Some(spicy_block))
  assert_eq(lcg_ref.seed(), 0x2578510FU)
}

///|
test "advances RNG state correctly when pokeblock does not activate" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let spicy_block = @types.PokeBlock::new(@types.Spicy)
  let _ = generate_nature_hoenn_safari_mut(lcg_ref, Some(spicy_block))
  assert_eq(lcg_ref.seed(), 0x8B6072A7U)
}

///|
test "advances RNG state correctly when sweet pokeblock activates" {
  let lcg_ref = @lcg32.Lcg32(0x00000001U).to_ref()
  let sweet_block = @types.PokeBlock::new(@types.Sweet)
  let _ = generate_nature_hoenn_safari_mut(lcg_ref, Some(sweet_block))
  assert_eq(lcg_ref.seed(), 0x791C0A6CU)
}

///|
pub fn generate_nature_em_safari_immut(
  lcg : @lcg32.Lcg32,
  pokeblock : @types.PokeBlock?,
  sync_nature : @types.Nature
) -> @types.Nature {
  let lcg_ref = lcg.to_ref()
  generate_nature_em_safari_mut(lcg_ref, pokeblock, sync_nature)
}

///|
pub fn generate_nature_em_safari_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  pokeblock : @types.PokeBlock?,
  sync_nature : @types.Nature
) -> @types.Nature {
  let trigger_check = lcg_ref.get_rand(m=100)
  match pokeblock {
    None => generate_nature_synchronize_mut(lcg_ref, sync_nature)
    Some(block) =>
      if trigger_check >= 80 {
        generate_nature_synchronize_mut(lcg_ref, sync_nature)
      } else {
        let list = shuffle(lcg_ref)
        for i = 0; i < 25; i = i + 1 {
          let nature_value = list[i]
          let nature = @types.Nature::from_value(nature_value).unwrap()
          if block.is_liked_by(nature) {
            return nature
          }
        }
        panic()
      }
  }
}

///|
test "generates synchronized nature when no pokeblock is used in emerald safari" {
  let lcg = @lcg32.Lcg32(0x00000000U)
  let sync_nature = @types.Timid
  let result = generate_nature_em_safari_immut(lcg, None, sync_nature)
  assert_eq(result, @types.Timid)
}

///|
test "generates synchronized nature when pokeblock effect does not activate in emerald safari" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let spicy_block = @types.PokeBlock::new(@types.Spicy)
  let sync_nature = @types.Brave
  let result = generate_nature_em_safari_mut(
    lcg_ref,
    Some(spicy_block),
    sync_nature,
  )
  assert_eq(result, @types.Adamant)
}

///|
test "generates spicy-preferred nature when spicy pokeblock activates in emerald safari" {
  let lcg_ref = @lcg32.Lcg32(0x00000000U).to_ref()
  let spicy_block = @types.PokeBlock::new(@types.Spicy)
  let sync_nature = @types.Brave
  let result = generate_nature_em_safari_mut(
    lcg_ref,
    Some(spicy_block),
    sync_nature,
  )
  assert_eq(result, @types.Brave)
}

///|
test "generates sweet-preferred nature when sweet pokeblock activates in emerald safari" {
  let lcg_ref = @lcg32.Lcg32(0x00000001U).to_ref()
  let sweet_block = @types.PokeBlock::new(@types.Sweet)
  let sync_nature = @types.Modest
  let result = generate_nature_em_safari_mut(
    lcg_ref,
    Some(sweet_block),
    sync_nature,
  )
  assert_eq(result, @types.Jolly)
}

///|
test "produces same nature regardless of immutable or mutable usage in emerald safari" {
  let seed : UInt = 0x12345678U
  let pokeblock = Some(@types.PokeBlock::new(@types.Sweet))
  let sync_nature = @types.Modest
  let lcg = @lcg32.Lcg32(seed)
  let result_immut = generate_nature_em_safari_immut(
    lcg, pokeblock, sync_nature,
  )
  let lcg_ref = @lcg32.Lcg32(seed).to_ref()
  let result_mut = generate_nature_em_safari_mut(
    lcg_ref, pokeblock, sync_nature,
  )
  assert_eq(result_immut, result_mut)
}

///|
test "EmSafari: C# compatibility - Test 1: Sync=Brave, Block=Spicy" {
  let spicy_block = @types.PokeBlock::new(@types.Spicy)
  let sync_nature = @types.Brave
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(0),
    Some(spicy_block),
    sync_nature,
  )
  assert_eq(result, @types.Brave)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(1),
    Some(spicy_block),
    sync_nature,
  )
  assert_eq(result, @types.Lonely)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(2),
    Some(spicy_block),
    sync_nature,
  )
  assert_eq(result, @types.Naughty)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(3),
    Some(spicy_block),
    sync_nature,
  )
  assert_eq(result, @types.Adamant)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(4),
    Some(spicy_block),
    sync_nature,
  )
  assert_eq(result, @types.Naughty)
}

///|
test "EmSafari: C# compatibility - Test 2: Sync=Timid, Block=Tasteless" {
  let sync_nature = @types.Timid
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(0),
    None,
    sync_nature,
  )
  assert_eq(result, @types.Timid)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(1),
    None,
    sync_nature,
  )
  assert_eq(result, @types.Careful)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(2),
    None,
    sync_nature,
  )
  assert_eq(result, @types.Docile)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(3),
    None,
    sync_nature,
  )
  assert_eq(result, @types.Timid)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(4),
    None,
    sync_nature,
  )
  assert_eq(result, @types.Timid)
}

///|
test "EmSafari: C# compatibility - Test 3: Sync=Modest, Block=Sweet" {
  let sweet_block = @types.PokeBlock::new(@types.Sweet)
  let sync_nature = @types.Modest
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(0),
    Some(sweet_block),
    sync_nature,
  )
  assert_eq(result, @types.Hasty)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(1),
    Some(sweet_block),
    sync_nature,
  )
  assert_eq(result, @types.Jolly)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(2),
    Some(sweet_block),
    sync_nature,
  )
  assert_eq(result, @types.Naive)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(3),
    Some(sweet_block),
    sync_nature,
  )
  assert_eq(result, @types.Hasty)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(4),
    Some(sweet_block),
    sync_nature,
  )
  assert_eq(result, @types.Naive)
}

///|
test "EmSafari: C# compatibility - Test 4: Detailed analysis for specific seeds" {
  let spicy_block = @types.PokeBlock::new(@types.Spicy)
  let sync_nature = @types.Brave
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(0x12345678),
    Some(spicy_block),
    sync_nature,
  )
  assert_eq(result, @types.Adamant)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(0x87654321),
    Some(spicy_block),
    sync_nature,
  )
  assert_eq(result, @types.Lonely)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(0xABCDEF01),
    Some(spicy_block),
    sync_nature,
  )
  assert_eq(result, @types.Adamant)
  let result = generate_nature_em_safari_immut(
    @lcg32.Lcg32(0xDEADBEEF),
    Some(spicy_block),
    sync_nature,
  )
  assert_eq(result, @types.Naughty)
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
test "consumes exactly 300 RNG calls during nature shuffling" {
  let lcg_ref = @lcg32.Lcg32(0x00000000U).to_ref()
  let initial_seed = lcg_ref.seed()
  let _list = shuffle(lcg_ref)
  let final_seed = lcg_ref.seed()
  let verification_lcg = @lcg32.Lcg32(initial_seed)
  let expected_seed = verification_lcg.jump(300).inner()
  assert_eq(final_seed, expected_seed)
}

///|
test "produces identical shuffled order given same initial seed" {
  let lcg_ref1 = @lcg32.Lcg32(0x12345678U).to_ref()
  let lcg_ref2 = @lcg32.Lcg32(0x12345678U).to_ref()
  let list1 = shuffle(lcg_ref1)
  let list2 = shuffle(lcg_ref2)
  assert_eq(list1, list2)
}

///|
test "preserves all 25 nature values during shuffling process" {
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
