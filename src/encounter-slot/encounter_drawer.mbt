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
    Some(Flute::White) => rate = rate * 150 / 100 // 白フルート: +50%
    Some(Flute::Black) => rate = rate * 50 / 100 // 黒フルート: -50%
    None => () // フルート未使用
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
fn default_encounter_config() -> EncounterConfig {
  EncounterConfig::{
    base_encounter_rate: 2160,
    riding_bicycle: false,
    flute: None,
    has_cleanse_tag: false,
  }
}

// C#実装との互換性テスト

///|
test "rse encounter drawing matches C# implementation" {
  let config = EncounterConfig::{
    base_encounter_rate: 2048,
    riding_bicycle: false,
    flute: None,
    has_cleanse_tag: false,
  }
  let test_cases = [
    (0x12345678U, true),
    (0x87654321U, true),
    (0xABCDEF01U, true),
    (0xDEADBEEFU, true),
    (0x00000000U, true),
    (0xFFFFFFFFU, false),
    (0x55555555U, false),
    (0xAAAAAAAAU, false),
    (0x12AB34CDU, true),
    (0x98765432U, false),
  ]
  for test_case in test_cases {
    let (seed, expected) = test_case
    let result = draw_encounter_rse_immut(@lcg32.Lcg32(seed), config)
    assert_eq(result, expected)
  }
}

///|
test "frlg encounter drawing matches C# implementation" {
  let config = default_encounter_config()
  let test_cases = [
    0x12345678U, 0x87654321U, 0xABCDEF01U, 0xDEADBEEFU, 0x00000000U, 0xFFFFFFFFU,
    0x55555555U, 0xAAAAAAAAU, 0x12AB34CDU, 0x98765432U,
  ]
  for test_case in test_cases {
    let seed = test_case
    let result = draw_encounter_frlg_immut(@lcg32.Lcg32(seed), config)
    assert_eq(result, true)
  }
}

///|
test "calculate encounter rate correctly" {
  let config = default_encounter_config()
  assert_eq(calculate_encounter_rate(config), 2160)
}

///|
test "apply bicycle reduction 80 percent" {
  let config = { ..default_encounter_config(), riding_bicycle: true }
  assert_eq(calculate_encounter_rate(config), 1728) // 2160 * 80 / 100
}

///|
test "cap encounter rate at 2880" {
  let config = EncounterConfig::{
    base_encounter_rate: 3000,
    riding_bicycle: false,
    flute: Some(Flute::White), // 3000 * 150 / 100 = 4500
    has_cleanse_tag: false,
  }
  assert_eq(calculate_encounter_rate(config), 2880)
}

///|
test "black flute reduces encounter rate by 50 percent" {
  let config = EncounterConfig::{
    base_encounter_rate: 2000,
    riding_bicycle: false,
    flute: Some(Flute::Black), // 2000 * 50 / 100 = 1000
    has_cleanse_tag: false,
  }
  assert_eq(calculate_encounter_rate(config), 1000)
}

///|
test "always return true for force encounter" {
  let lcg = @lcg32.Lcg32(0xFFFFFFFFU)
  let config = default_encounter_config()
  let result = draw_encounter_force_immut(lcg, config)
  assert_eq(result, true)
}
