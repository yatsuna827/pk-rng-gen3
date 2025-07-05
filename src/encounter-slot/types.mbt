// エンカウント関連の基本型定義

// フルートの種類

///|
pub enum Flute {
  None
  White // 白フルート: エンカウント率+50%
  Black // 黒フルート: エンカウント率-50%
}

// GBAスロット情報

///|
struct GBASlot {
  pokemon_id : Int
  min_level : Int
  max_level : Int
} derive(Eq, Show)

// エンカウント設定

///|
struct EncounterConfig {
  base_encounter_rate : UInt
  riding_bicycle : Bool
  flute : Flute
  has_cleanse_tag : Bool
}

// テスト用の基本構造体

///|
test "basic types" {
  let slot = GBASlot::{ pokemon_id: 1, min_level: 5, max_level: 10 }
  assert_eq(slot.pokemon_id, 1)
  assert_eq(slot.min_level, 5)
  assert_eq(slot.max_level, 10)
  let config = EncounterConfig::{
    base_encounter_rate: 2160,
    riding_bicycle: false,
    flute: Flute::None,
    has_cleanse_tag: false,
  }
  assert_eq(config.base_encounter_rate, 2160)
  assert_eq(config.riding_bicycle, false)
}
