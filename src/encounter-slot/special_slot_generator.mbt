///|
pub fn try_generate_attract(
  lcg_ref : @lcg32.Lcg32Ref,
  attractable_slots : Array[GBASlot]
) -> GBASlot? {
  if (lcg_ref.get_rand() & 1) == 1 || attractable_slots.length() == 0 {
    None
  } else {
    let index = lcg_ref
      .get_rand(m=attractable_slots.length().reinterpret_as_uint())
      .reinterpret_as_int()
    Some(attractable_slots[index])
  }
}

///|
pub fn try_generate_mass_outbreak(
  lcg_ref : @lcg32.Lcg32Ref,
  mass_outbreak_slot : GBASlot
) -> GBASlot? {
  if lcg_ref.get_rand(m=100) < 50 {
    Some(mass_outbreak_slot)
  } else {
    None
  }
}

///|
pub fn try_generate_dummy(lcg_ref : @lcg32.Lcg32Ref) -> GBASlot? {
  lcg_ref.advance()
  None
}

///|
pub fn try_generate_null(_ : @lcg32.Lcg32Ref) -> GBASlot? {
  None
}

///|
test "attract generator matches C# implementation" {
  let attractable_slots = [
    GBASlot::{ pokemon_id: 25, min_level: 5, max_level: 10 },
    GBASlot::{ pokemon_id: 81, min_level: 5, max_level: 10 },
  ]
  let test_cases = [
    (
      0x00000000U,
      Some(GBASlot::{ pokemon_id: 25, min_level: 5, max_level: 10 }),
      0xE97E7B6AU,
    ),
    (
      0x00000001U,
      Some(GBASlot::{ pokemon_id: 81, min_level: 5, max_level: 10 }),
      0xAC2115D3U,
    ),
    (
      0x00000002U,
      Some(GBASlot::{ pokemon_id: 81, min_level: 5, max_level: 10 }),
      0x6EC3B03CU,
    ),
    (0x00000003U, None, 0xC5534BBAU),
    (0x00000004U, None, 0x07199A27U),
    (0x00000005U, None, 0x48DFE894U),
    (0x00000064U, None, 0xB1770307U),
    (
      0x000003E8U,
      Some(GBASlot::{ pokemon_id: 81, min_level: 5, max_level: 10 }),
      0x34A9A592U,
    ),
    (0x12345678U, None, 0x0B71C18BU),
    (
      0x87654321U,
      Some(GBASlot::{ pokemon_id: 25, min_level: 5, max_level: 10 }),
      0xD94ADDF3U,
    ),
  ]
  for test_case in test_cases {
    let (seed, expected_result, expected_final_seed) = test_case
    let lcg_ref = @lcg32.Lcg32(seed).to_ref()
    let result = try_generate_attract(lcg_ref, attractable_slots)
    let final_seed = lcg_ref.seed()
    assert_eq(result, expected_result)
    assert_eq(final_seed, expected_final_seed)
  }
}

///|
test "mass outbreak generator matches C# implementation" {
  let outbreak_slot = GBASlot::{ pokemon_id: 129, min_level: 5, max_level: 36 }
  let test_cases = [
    (0x00000000U, Some(outbreak_slot), 0x00006073U),
    (0x00000001U, Some(outbreak_slot), 0x41C6AEE0U),
    (0x00000002U, None, 0x838CFD4DU),
    (0x00000003U, Some(outbreak_slot), 0xC5534BBAU),
    (0x00000004U, Some(outbreak_slot), 0x07199A27U),
    (0x00000005U, None, 0x48DFE894U),
    (0x00000064U, Some(outbreak_slot), 0xB1770307U),
    (0x000003E8U, None, 0xEEA2BA3BU),
    (0x12345678U, Some(outbreak_slot), 0x0B71C18BU),
    (0x87654321U, Some(outbreak_slot), 0xCD180380U),
  ]
  for test_case in test_cases {
    let (seed, expected_result, expected_final_seed) = test_case
    let lcg_ref = @lcg32.Lcg32(seed).to_ref()
    let result = try_generate_mass_outbreak(lcg_ref, outbreak_slot)
    let final_seed = lcg_ref.seed()
    assert_eq(result, expected_result)
    assert_eq(final_seed, expected_final_seed)
  }
}

///|
test "dummy generator matches C# implementation" {
  let test_cases = [
    (0x00000000U, 0x00006073U),
    (0x00000001U, 0x41C6AEE0U),
    (0x00000002U, 0x838CFD4DU),
    (0x00000003U, 0xC5534BBAU),
    (0x00000004U, 0x07199A27U),
    (0x00000005U, 0x48DFE894U),
    (0x00000064U, 0xB1770307U),
    (0x000003E8U, 0xEEA2BA3BU),
    (0x12345678U, 0x0B71C18BU),
    (0x87654321U, 0xCD180380U),
  ]
  for test_case in test_cases {
    let (seed, expected_final_seed) = test_case
    let lcg_ref = @lcg32.Lcg32(seed).to_ref()
    let result = try_generate_dummy(lcg_ref)
    let final_seed = lcg_ref.seed()
    assert_eq(result, None)
    assert_eq(final_seed, expected_final_seed)
  }
}

///|
test "null generator matches C# implementation" {
  let test_cases = [
    0x00000000U, 0x00000001U, 0x00000002U, 0x00000003U, 0x00000004U, 0x00000005U,
    0x00000064U, 0x000003E8U, 0x12345678U, 0x87654321U,
  ]
  for test_case in test_cases {
    let seed = test_case
    let lcg_ref = @lcg32.Lcg32(seed).to_ref()
    let result = try_generate_null(lcg_ref)
    let final_seed = lcg_ref.seed()
    assert_eq(result, None)
    assert_eq(final_seed, seed)
  }
}
