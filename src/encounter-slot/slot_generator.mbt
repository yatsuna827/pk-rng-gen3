// スロット選択システム実装

// 確率分布テーブル

///|
let grass_probabilities : Array[UInt] = [
  20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1,
]

///|
let surf_probabilities : Array[UInt] = [60, 30, 5, 4, 1]

///|
let old_rod_probabilities : Array[UInt] = [70, 30]

///|
let good_rod_probabilities : Array[UInt] = [60, 20, 20]

///|
let super_rod_probabilities : Array[UInt] = [40, 40, 15, 4, 1]

///|
let rock_smash_probabilities : Array[UInt] = [60, 30, 5, 4, 1] // 水上と同じ

// 標準テーブルからスロット選択

///|
pub fn select_standard_slot(
  lcg_ref : @lcg32.Lcg32Ref,
  slots : Array[GBASlot],
  probabilities : Array[UInt]
) -> GBASlot {
  let random = lcg_ref.get_rand(m=100)
  let mut cumulative = 0U
  for i = 0; i < probabilities.length(); i = i + 1 {
    cumulative = cumulative + probabilities[i]
    if random < cumulative {
      return slots[i]
    }
  }

  // フォールバック（理論上は到達しない）
  slots[slots.length() - 1]
}

// 草むらスロット選択（可変版）

///|
pub fn generate_grass_slot_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  slots : Array[GBASlot]
) -> GBASlot {
  select_standard_slot(lcg_ref, slots, grass_probabilities)
}

// 草むらスロット選択（不変版）

///|
pub fn generate_grass_slot_immut(
  lcg : @lcg32.Lcg32,
  slots : Array[GBASlot]
) -> GBASlot {
  let lcg_ref = lcg.to_ref()
  generate_grass_slot_mut(lcg_ref, slots)
}

// 水上スロット選択（可変版）

///|
pub fn generate_surf_slot_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  slots : Array[GBASlot]
) -> GBASlot {
  select_standard_slot(lcg_ref, slots, surf_probabilities)
}

// 水上スロット選択（不変版）

///|
pub fn generate_surf_slot_immut(
  lcg : @lcg32.Lcg32,
  slots : Array[GBASlot]
) -> GBASlot {
  let lcg_ref = lcg.to_ref()
  generate_surf_slot_mut(lcg_ref, slots)
}

// ボロの釣り竿スロット選択（可変版）

///|
pub fn generate_old_rod_slot_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  slots : Array[GBASlot]
) -> GBASlot {
  select_standard_slot(lcg_ref, slots, old_rod_probabilities)
}

// ボロの釣り竿スロット選択（不変版）

///|
pub fn generate_old_rod_slot_immut(
  lcg : @lcg32.Lcg32,
  slots : Array[GBASlot]
) -> GBASlot {
  let lcg_ref = lcg.to_ref()
  generate_old_rod_slot_mut(lcg_ref, slots)
}

// いい釣り竿スロット選択（可変版）

///|
pub fn generate_good_rod_slot_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  slots : Array[GBASlot]
) -> GBASlot {
  select_standard_slot(lcg_ref, slots, good_rod_probabilities)
}

// いい釣り竿スロット選択（不変版）

///|
pub fn generate_good_rod_slot_immut(
  lcg : @lcg32.Lcg32,
  slots : Array[GBASlot]
) -> GBASlot {
  let lcg_ref = lcg.to_ref()
  generate_good_rod_slot_mut(lcg_ref, slots)
}

// すごい釣り竿スロット選択（可変版）

///|
pub fn generate_super_rod_slot_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  slots : Array[GBASlot]
) -> GBASlot {
  select_standard_slot(lcg_ref, slots, super_rod_probabilities)
}

// すごい釣り竿スロット選択（不変版）

///|
pub fn generate_super_rod_slot_immut(
  lcg : @lcg32.Lcg32,
  slots : Array[GBASlot]
) -> GBASlot {
  let lcg_ref = lcg.to_ref()
  generate_super_rod_slot_mut(lcg_ref, slots)
}

// 岩砕きスロット選択（可変版）

///|
pub fn generate_rock_smash_slot_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  slots : Array[GBASlot]
) -> GBASlot {
  select_standard_slot(lcg_ref, slots, rock_smash_probabilities)
}

// 岩砕きスロット選択（不変版）

///|
pub fn generate_rock_smash_slot_immut(
  lcg : @lcg32.Lcg32,
  slots : Array[GBASlot]
) -> GBASlot {
  let lcg_ref = lcg.to_ref()
  generate_rock_smash_slot_mut(lcg_ref, slots)
}

// テスト

///|
fn create_test_slots(count : Int) -> Array[GBASlot] {
  let slots = Array::make(count, GBASlot::{
    pokemon_id: 1,
    min_level: 5,
    max_level: 10,
  })
  for i = 0; i < count; i = i + 1 {
    slots[i] = GBASlot::{ pokemon_id: i + 1, min_level: 5, max_level: 10 }
  }
  slots
}

// C#実装との互換性テスト

///|
test "grass slot selection matches C# implementation" {
  let slots = create_test_slots(12)
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
    let result = generate_grass_slot_immut(@lcg32.Lcg32(seed), slots)
    assert_eq(result.pokemon_id, expected_slot_index + 1) // pokemon_idは1ベース
  }
}

///|
test "surf slot selection matches C# implementation" {
  let slots = create_test_slots(5)
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
    let result = generate_surf_slot_immut(@lcg32.Lcg32(seed), slots)
    assert_eq(result.pokemon_id, expected_slot_index + 1)
  }
}

///|
test "old rod slot selection matches C# implementation" {
  let slots = create_test_slots(2)
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
    let result = generate_old_rod_slot_immut(@lcg32.Lcg32(seed), slots)
    assert_eq(result.pokemon_id, expected_slot_index + 1)
  }
}

///|
test "good rod slot selection matches C# implementation" {
  let slots = create_test_slots(3)
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
    let result = generate_good_rod_slot_immut(@lcg32.Lcg32(seed), slots)
    assert_eq(result.pokemon_id, expected_slot_index + 1)
  }
}

///|
test "super rod slot selection matches C# implementation" {
  let slots = create_test_slots(5)
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
    let result = generate_super_rod_slot_immut(@lcg32.Lcg32(seed), slots)
    assert_eq(result.pokemon_id, expected_slot_index + 1)
  }
}

///|
test "rock smash slot selection matches C# implementation" {
  let slots = create_test_slots(5)
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
    let result = generate_rock_smash_slot_immut(@lcg32.Lcg32(seed), slots)
    assert_eq(result.pokemon_id, expected_slot_index + 1)
  }
}

///|
