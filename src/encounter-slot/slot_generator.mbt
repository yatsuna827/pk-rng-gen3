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
test "_select_standard_slot" {
  let slots = [
    GBASlot::{ pokemon_id: 1, min_level: 5, max_level: 10 },
    GBASlot::{ pokemon_id: 2, min_level: 10, max_level: 15 },
    GBASlot::{ pokemon_id: 3, min_level: 15, max_level: 20 },
  ]
  let probabilities : Array[UInt] = [70, 25, 5]
  let lcg_ref = @lcg32.Lcg32(0).to_ref()
  let result = select_standard_slot(lcg_ref, slots, probabilities)
  assert_true(result.pokemon_id >= 1 && result.pokemon_id <= 3)
}

///|
test "_generate_grass_slot" {
  let slots = Array::make(12, GBASlot::{
    pokemon_id: 1,
    min_level: 5,
    max_level: 10,
  })
  for i = 0; i < 12; i = i + 1 {
    slots[i] = GBASlot::{ pokemon_id: i + 1, min_level: 5, max_level: 10 }
  }
  let lcg = @lcg32.Lcg32(0)
  let result = generate_grass_slot_immut(lcg, slots)
  assert_true(result.pokemon_id >= 1 && result.pokemon_id <= 12)
}

///|
test "_generate_surf_slot" {
  let slots = Array::make(5, GBASlot::{
    pokemon_id: 1,
    min_level: 5,
    max_level: 10,
  })
  for i = 0; i < 5; i = i + 1 {
    slots[i] = GBASlot::{ pokemon_id: i + 1, min_level: 5, max_level: 10 }
  }
  let lcg = @lcg32.Lcg32(0)
  let result = generate_surf_slot_immut(lcg, slots)
  assert_true(result.pokemon_id >= 1 && result.pokemon_id <= 5)
}

///|
test "_generate_fishing_slots" {
  let slots2 = [
    GBASlot::{ pokemon_id: 1, min_level: 5, max_level: 10 },
    GBASlot::{ pokemon_id: 2, min_level: 10, max_level: 15 },
  ]
  let slots3 = [
    GBASlot::{ pokemon_id: 1, min_level: 5, max_level: 10 },
    GBASlot::{ pokemon_id: 2, min_level: 10, max_level: 15 },
    GBASlot::{ pokemon_id: 3, min_level: 15, max_level: 20 },
  ]
  let slots5 = Array::make(5, GBASlot::{
    pokemon_id: 1,
    min_level: 5,
    max_level: 10,
  })
  for i = 0; i < 5; i = i + 1 {
    slots5[i] = GBASlot::{ pokemon_id: i + 1, min_level: 5, max_level: 10 }
  }
  let lcg = @lcg32.Lcg32(0)

  // ボロの釣り竿
  let result1 = generate_old_rod_slot_immut(lcg, slots2)
  assert_true(result1.pokemon_id >= 1 && result1.pokemon_id <= 2)

  // いい釣り竿
  let result2 = generate_good_rod_slot_immut(lcg, slots3)
  assert_true(result2.pokemon_id >= 1 && result2.pokemon_id <= 3)

  // すごい釣り竿
  let result3 = generate_super_rod_slot_immut(lcg, slots5)
  assert_true(result3.pokemon_id >= 1 && result3.pokemon_id <= 5)
}
