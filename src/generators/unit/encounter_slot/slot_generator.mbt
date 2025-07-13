///|
pub fn generate_slot(table : EncounterTable) -> @core.GeneratorMut[GBASlot] {
  lcg_ref => table.pick(lcg_ref.get_rand(m=100))
}

///|
fn create_test_slots(count : Int) -> Array[GBASlot] {
  Array::makei(count, i => GBASlot::{
    pokemon: @core.Species::dummy(i),
    min_level: 5,
    max_level: 10,
  })
}

///|
test "grass slot selection matches C# implementation" {
  let slots = create_test_slots(12)
  let table = EncounterTable::grass(slots)
  let generate = generate_slot(table)
  let test_cases = [
    (0x12345678U, 1),
    (0x87654321U, 0),
    (0xABCDEF01U, 1),
    (0xDEADBEEFU, 4),
    (0x00000000U, 0),
    (0xFFFFFFFFU, 10),
    (0x55555555U, 1),
    (0xAAAAAAAAU, 0),
    (0x12AB34CDU, 1),
    (0x98765432U, 6),
  ]
  for test_case in test_cases {
    let (seed, expected_slot_index) = test_case
    let result = generate(@lcg32.Lcg32(seed).to_ref())
    assert_eq(result, slots[expected_slot_index])
  }
}

///|
test "surf slot selection matches C# implementation" {
  let slots = create_test_slots(5)
  let table = EncounterTable::surf(slots)
  let generate = generate_slot(table)
  let test_cases = [
    (0x12345678U, 0),
    (0x87654321U, 0),
    (0xABCDEF01U, 0),
    (0xDEADBEEFU, 1),
    (0x00000000U, 0),
    (0xFFFFFFFFU, 3),
    (0x55555555U, 0),
    (0xAAAAAAAAU, 0),
    (0x12AB34CDU, 0),
    (0x98765432U, 1),
  ]
  for test_case in test_cases {
    let (seed, expected_slot_index) = test_case
    let result = generate(@lcg32.Lcg32(seed).to_ref())
    assert_eq(result, slots[expected_slot_index])
  }
}

///|
test "old rod slot selection matches C# implementation" {
  let slots = create_test_slots(2)
  let table = EncounterTable::old_rod(slots)
  let generate = generate_slot(table)
  let test_cases = [
    (0x12345678U, 0),
    (0x87654321U, 0),
    (0xABCDEF01U, 0),
    (0xDEADBEEFU, 0),
    (0x00000000U, 0),
    (0xFFFFFFFFU, 1),
    (0x55555555U, 0),
    (0xAAAAAAAAU, 0),
    (0x12AB34CDU, 0),
    (0x98765432U, 1),
  ]
  for test_case in test_cases {
    let (seed, expected_slot_index) = test_case
    let result = generate(@lcg32.Lcg32(seed).to_ref())
    assert_eq(result, slots[expected_slot_index])
  }
}

///|
test "good rod slot selection matches C# implementation" {
  let slots = create_test_slots(3)
  let table = EncounterTable::good_rod(slots)
  let generate = generate_slot(table)
  let test_cases = [
    (0x12345678U, 0),
    (0x87654321U, 0),
    (0xABCDEF01U, 0),
    (0xDEADBEEFU, 1),
    (0x00000000U, 0),
    (0xFFFFFFFFU, 2),
    (0x55555555U, 0),
    (0xAAAAAAAAU, 0),
    (0x12AB34CDU, 0),
    (0x98765432U, 2),
  ]
  for test_case in test_cases {
    let (seed, expected_slot_index) = test_case
    let result = generate(@lcg32.Lcg32(seed).to_ref())
    assert_eq(result, slots[expected_slot_index])
  }
}

///|
test "super rod slot selection matches C# implementation" {
  let slots = create_test_slots(5)
  let table = EncounterTable::super_rod(slots)
  let generate = generate_slot(table)
  let test_cases = [
    (0x12345678U, 0),
    (0x87654321U, 0),
    (0xABCDEF01U, 0),
    (0xDEADBEEFU, 1),
    (0x00000000U, 0),
    (0xFFFFFFFFU, 3),
    (0x55555555U, 0),
    (0xAAAAAAAAU, 0),
    (0x12AB34CDU, 0),
    (0x98765432U, 2),
  ]
  for test_case in test_cases {
    let (seed, expected_slot_index) = test_case
    let result = generate(@lcg32.Lcg32(seed).to_ref())
    assert_eq(result, slots[expected_slot_index])
  }
}

///|
test "rock smash slot selection matches C# implementation" {
  let slots = create_test_slots(5)
  let table = EncounterTable::rock_smash(slots)
  let generate = generate_slot(table)
  let test_cases = [
    (0x12345678U, 0),
    (0x87654321U, 0),
    (0xABCDEF01U, 0),
    (0xDEADBEEFU, 1),
    (0x00000000U, 0),
    (0xFFFFFFFFU, 3),
    (0x55555555U, 0),
    (0xAAAAAAAAU, 0),
    (0x12AB34CDU, 0),
    (0x98765432U, 1),
  ]
  for test_case in test_cases {
    let (seed, expected_slot_index) = test_case
    let result = generate(@lcg32.Lcg32(seed).to_ref())
    assert_eq(result, slots[expected_slot_index])
  }
}
