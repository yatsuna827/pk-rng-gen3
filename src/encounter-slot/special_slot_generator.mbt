// 特殊スロット生成器実装

// 静電気・磁力スロット生成（可変版）

///|
fn try_attract_slot_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  attractable_slots : Array[GBASlot]
) -> GBASlot? {
  if (lcg_ref.get_rand() & 1) == 0 { // 50%の確率で発動
    if attractable_slots.length() > 0 {
      let slot = attractable_slots[lcg_ref
        .get_rand(m=attractable_slots.length().reinterpret_as_uint())
        .reinterpret_as_int()]
      Some(slot)
    } else {
      // 対象ポケモンがいない場合は失敗
      lcg_ref.advance() // 失敗時も1回RNGを消費
      None
    }
  } else {
    // 発動しない場合も失敗
    lcg_ref.advance() // 失敗時も1回RNGを消費
    None
  }
}

// 静電気・磁力スロット生成（不変版）

///|
pub fn try_attract_slot_immut(
  lcg : @lcg32.Lcg32,
  attractable_slots : Array[GBASlot]
) -> GBASlot? {
  let lcg_ref = lcg.to_ref()
  try_attract_slot_mut(lcg_ref, attractable_slots)
}

// 大量発生スロット生成（可変版）

///|
fn try_mass_outbreak_slot_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  outbreak_slot : GBASlot
) -> GBASlot? {
  if lcg_ref.get_rand(m=100) < 50 { // 50%の確率
    Some(outbreak_slot)
  } else {
    None // 失敗時はRNG消費なし
  }
}

// 大量発生スロット生成（不変版）

///|
fn try_mass_outbreak_slot_immut(
  lcg : @lcg32.Lcg32,
  outbreak_slot : GBASlot
) -> GBASlot? {
  let lcg_ref = lcg.to_ref()
  try_mass_outbreak_slot_mut(lcg_ref, outbreak_slot)
}

// ダミー特殊スロット生成（可変版）

///|
fn try_dummy_special_slot_mut(lcg_ref : @lcg32.Lcg32Ref) -> GBASlot? {
  lcg_ref.advance() // RNGを1回消費
  None // 常に失敗
}

// NULL特殊スロット生成（可変版）

///|
fn try_null_special_slot_mut(_ : @lcg32.Lcg32Ref) -> GBASlot? {
  None // 何もせず失敗
}

// NULL特殊スロット生成（不変版）

///|
fn try_null_special_slot_immut(lcg : @lcg32.Lcg32) -> (@lcg32.Lcg32, GBASlot?) {
  let lcg_ref = lcg.to_ref()
  let result = try_null_special_slot_mut(lcg_ref)
  (lcg_ref.seed(), result)
}

// 特殊スロット生成器の統合処理（可変版）

///|
fn try_special_slots_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  attract_slots : Array[GBASlot],
  mass_outbreak_slot : GBASlot?,
  has_dummy_special : Bool
) -> GBASlot? {
  // 静電気・磁力処理
  if attract_slots.length() > 0 {
    match try_attract_slot_mut(lcg_ref, attract_slots) {
      Some(slot) => return Some(slot)
      None => ()
    }
  }

  // 大量発生処理
  match mass_outbreak_slot {
    Some(slot) =>
      match try_mass_outbreak_slot_mut(lcg_ref, slot) {
        Some(slot) => return Some(slot)
        None => ()
      }
    None => ()
  }

  // ダミー特殊処理
  if has_dummy_special {
    match try_dummy_special_slot_mut(lcg_ref) {
      Some(slot) => return Some(slot)
      None => ()
    }
  }
  None
}

// 特殊スロット生成器の統合処理（不変版）

///|
fn try_special_slots_immut(
  lcg : @lcg32.Lcg32,
  attract_slots : Array[GBASlot],
  mass_outbreak_slot : GBASlot?,
  has_dummy_special : Bool
) -> (@lcg32.Lcg32, GBASlot?) {
  let lcg_ref = lcg.to_ref()
  let result = try_special_slots_mut(
    lcg_ref, attract_slots, mass_outbreak_slot, has_dummy_special,
  )
  (lcg_ref.seed(), result)
}

// テスト

///|
test "_try_mass_outbreak_slot" {
  let outbreak_slot = GBASlot::{ pokemon_id: 129, min_level: 5, max_level: 40 } // コイキング
  let lcg = @lcg32.Lcg32(0)
  let result = try_mass_outbreak_slot_immut(lcg, outbreak_slot)
  assert_eq(result, Some(outbreak_slot)) // LCGが更新されている
}

///|
test "try_null_special_slot" {
  let lcg = @lcg32.Lcg32(0)
  let (new_lcg, result) = try_null_special_slot_immut(lcg)
  assert_eq(lcg.inner(), new_lcg.inner()) // LCGが更新されていない
  match result {
    None => ()
    _ => panic()
  }
}

///|
test "try_special_slots" {
  let attract_slots = [GBASlot::{ pokemon_id: 25, min_level: 5, max_level: 10 }]
  let mass_outbreak_slot = Some(GBASlot::{
    pokemon_id: 129,
    min_level: 5,
    max_level: 40,
  })
  let lcg = @lcg32.Lcg32(0)
  let (new_lcg, _) = try_special_slots_immut(
    lcg, attract_slots, mass_outbreak_slot, false,
  )
  assert_not_eq(lcg.inner(), new_lcg.inner()) // LCGが更新されている
}
