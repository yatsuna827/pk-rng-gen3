// エンカウント判定実装

// エンカウント率計算

///|
fn calculate_encounter_rate(config : EncounterConfig) -> UInt {
  let mut rate = config.base_encounter_rate

  // 自転車補正（RSEのみ）
  if config.riding_bicycle {
    rate = rate * 80 / 100
  }

  // フルート補正
  match config.flute {
    Flute::White => rate = rate * 150 / 100 // 白フルート: +50%
    Flute::Black => rate = rate * 50 / 100 // 黒フルート: -50%
    Flute::None => ()
  }

  // 清めのお札補正
  if config.has_cleanse_tag {
    rate = rate * 2 / 3 // -33%
  }

  // 上限は2880
  if rate > 2880 {
    2880
  } else {
    rate
  }
}

// RSEエンカウント判定（可変版）

///|
pub fn draw_encounter_rse_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  config : EncounterConfig
) -> Bool {
  let encounter_rate = calculate_encounter_rate(config)
  let random = lcg_ref.get_rand(m=2880)
  random < encounter_rate
}

// RSEエンカウント判定（不変版）

///|
pub fn draw_encounter_rse_immut(
  lcg : @lcg32.Lcg32,
  config : EncounterConfig
) -> Bool {
  let lcg_ref = lcg.to_ref()
  draw_encounter_rse_mut(lcg_ref, config)
}

// FRLGエンカウント判定（可変版）

///|
pub fn draw_encounter_frlg_mut(
  _ : @lcg32.Lcg32Ref,
  _ : EncounterConfig
) -> Bool {
  // 現在の実装は未完成で、常にtrueを返す
  true
}

// FRLGエンカウント判定（不変版）

///|
pub fn draw_encounter_frlg_immut(
  lcg : @lcg32.Lcg32,
  config : EncounterConfig
) -> Bool {
  let lcg_ref = lcg.to_ref()
  draw_encounter_frlg_mut(lcg_ref, config)
}

// 強制エンカウント判定（可変版）

///|
pub fn draw_encounter_force_mut(
  _ : @lcg32.Lcg32Ref,
  _ : EncounterConfig
) -> Bool {
  true
}

// 強制エンカウント判定（不変版）

///|
pub fn draw_encounter_force_immut(
  lcg : @lcg32.Lcg32,
  config : EncounterConfig
) -> Bool {
  let lcg_ref = lcg.to_ref()
  draw_encounter_force_mut(lcg_ref, config)
}

// テスト

///|
test "calculate encounter rate" {
  // 基本ケース
  let config = EncounterConfig::{
    base_encounter_rate: 2160,
    riding_bicycle: false,
    flute: Flute::None,
    has_cleanse_tag: false,
  }
  assert_eq(calculate_encounter_rate(config), 2160)

  // 自転車補正
  let config_bike = EncounterConfig::{
    base_encounter_rate: 2160,
    riding_bicycle: true,
    flute: Flute::None,
    has_cleanse_tag: false,
  }
  assert_eq(calculate_encounter_rate(config_bike), 1728) // 2160 * 80 / 100

  // 白フルート補正
  let config_white = EncounterConfig::{
    base_encounter_rate: 2160,
    riding_bicycle: false,
    flute: Flute::White,
    has_cleanse_tag: false,
  }
  assert_eq(calculate_encounter_rate(config_white), 2880) // 2160 * 150 / 100 = 3240 -> 2880 (上限)

  // 黒フルート補正
  let config_black = EncounterConfig::{
    base_encounter_rate: 2160,
    riding_bicycle: false,
    flute: Flute::Black,
    has_cleanse_tag: false,
  }
  assert_eq(calculate_encounter_rate(config_black), 1080) // 2160 * 50 / 100

  // 清めのお札補正
  let config_cleanse = EncounterConfig::{
    base_encounter_rate: 2160,
    riding_bicycle: false,
    flute: Flute::None,
    has_cleanse_tag: true,
  }
  assert_eq(calculate_encounter_rate(config_cleanse), 1440) // 2160 * 2 / 3
}

///|
test "draw encounter rse" {
  let lcg = @lcg32.Lcg32(0)
  let config = EncounterConfig::{
    base_encounter_rate: 2160,
    riding_bicycle: false,
    flute: Flute::None,
    has_cleanse_tag: false,
  }
  let result = draw_encounter_rse_immut(lcg, config)
  let lcg_ref = @lcg32.Lcg32(0).to_ref()
  let result_mut = draw_encounter_rse_mut(lcg_ref, config)
  assert_eq(result, result_mut) // 同じ結果
}

///|
test "draw encounter force" {
  let lcg = @lcg32.Lcg32(0)
  let config = EncounterConfig::{
    base_encounter_rate: 2160,
    riding_bicycle: false,
    flute: Flute::None,
    has_cleanse_tag: false,
  }

  // 強制エンカウントは常にtrue
  let result = draw_encounter_force_immut(lcg, config)
  assert_eq(result, true)
}
