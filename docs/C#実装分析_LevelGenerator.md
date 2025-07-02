# LevelGenerator実装分析

## 概要

Pokemon第3世代のRNGライブラリにおけるレベル決定システムの実装を分析。通常のレベル幅決定からプレッシャー特性の効果まで対応。

## インターフェース構造

```csharp
public interface ILvGenerator
{
    uint GenerateLv(ref uint seed, uint basicLv, uint variableLv);
}
```

**パラメータ説明:**
- `basicLv`: 最低レベル（エンカウントテーブルで定義）
- `variableLv`: レベル幅（最高レベル = basicLv + variableLv）

## 実装一覧

### 1. StandardLvGenerator（標準レベル生成）

**アルゴリズム:**
```csharp
public uint GenerateLv(ref uint seed, uint basicLv, uint variableLv)
    => basicLv + seed.GetRand(variableLv);
```

**特徴:**
- 最もシンプルなレベル決定
- `basicLv`から`basicLv + variableLv - 1`の範囲で等確率
- 1回のRNG消費

**例:**
- basicLv=20, variableLv=5 → Lv20-24の範囲（各20%確率）

### 2. PressureLvGenerator（プレッシャー特性）

**アルゴリズム:**
```csharp
public uint GenerateLv(ref uint seed, uint basicLv, uint variableLv)
{
    var lv = basicLv + seed.GetRand(variableLv);  // 基本レベル決定
    
    if ((seed.GetRand() & 1) == 0)               // 50%の確率で
        lv = basicLv + variableLv;               // 最高レベルに変更
    
    if (lv != basicLv)                           // 最低レベルでなければ
        lv--;                                    // 1レベル下げる
        
    return lv;
}
```

**特徴:**
- **2回のRNG消費**（レベル決定 + プレッシャー判定）
- 50%の確率で最高レベル、50%で通常処理
- 最低レベル以外は最終的に-1される

**効果例:**
- basicLv=20, variableLv=5の場合:
  - 50%確率: Lv24（最高レベル-1）
  - 50%確率: Lv19-23（通常範囲-1、ただしLv19は変化なし）

**処理フロー:**
```
1. 通常レベル決定: Lv20-24（等確率）
2. プレッシャー判定:
   - 50%確率 → 最高レベル(Lv25)に変更
   - 50%確率 → そのまま
3. 最低レベル以外は-1:
   - Lv20 → Lv20（最低レベルなので変化なし）
   - Lv21-25 → Lv20-24
```

### 3. NullLvGenerator（レベル生成なし）

**アルゴリズム:**
```csharp
public uint GenerateLv(ref uint seed, uint basicLv, uint variableLv)
    => basicLv;
```

**特徴:**
- RNGを消費せずに最低レベルを返す
- レベル固定のエンカウント等で使用
- variableLvパラメータは無視される

## プレッシャー特性の詳細分析

### 実装の意図
プレッシャー特性は「野生ポケモンのレベルが高くなりやすい」効果を持つ。

### アルゴリズムの解釈
1. **基本レベル決定**: 通常通りランダムにレベルを決定
2. **プレッシャー判定**: 50%の確率で最高レベルに押し上げ
3. **調整処理**: 最低レベル以外を-1して全体を下方調整

### 結果の確率分布

basicLv=20, variableLv=5の場合の最終確率:

| 最終レベル | 確率 | 経路 |
|------------|------|------|
| Lv20 | 60% | 通常Lv20(10%) + 通常Lv21→Lv20(10%) + プレッシャーLv25→Lv24→...なし |
| Lv21 | 10% | 通常Lv22→Lv21 |
| Lv22 | 10% | 通常Lv23→Lv22 |
| Lv23 | 10% | 通常Lv24→Lv23 |
| Lv24 | 60% | プレッシャーLv25→Lv24(50%) + 通常Lv25→Lv24(10%) |

**実際の効果**: 最高レベル(Lv24)の出現確率が60%に上昇

## RNG消費パターン

### StandardLvGenerator
```
seed.GetRand(variableLv) → 1回のRNG消費
```

### PressureLvGenerator  
```
seed.GetRand(variableLv) → 1回目（レベル決定）
seed.GetRand() & 1       → 2回目（プレッシャー判定）
合計2回のRNG消費
```

### NullLvGenerator
```
RNG消費なし
```

## MoonBit移植時の注意点

### 1. プレッシャーのアルゴリズム
```
let pressure_level_gen(seed_ref, basic_lv, variable_lv) = {
  let lv = basic_lv + seed_ref.get_rand(variable_lv)  // 1回目
  let lv = if (seed_ref.get_rand() & 1) == 0 {        // 2回目
    basic_lv + variable_lv  // 最高レベル
  } else {
    lv  // そのまま
  }
  if lv != basic_lv {
    lv - 1  // 最低レベル以外は-1
  } else {
    lv  // 最低レベルはそのまま
  }
}
```

### 2. RNG消費の順序
プレッシャー処理は必ず**2回**のRNG消費が発生する点に注意。判定結果に関わらず両方のRNG呼び出しが実行される。

### 3. レベル範囲の検証
- 入力検証: `variableLv`が0の場合の動作
- 出力検証: 結果が想定範囲内に収まることの確認

### 4. 特性の適用条件
- プレッシャー特性は先頭ポケモンが持っている場合に発動
- 複数のプレッシャー持ちがいても効果は重複しない

## エンカウントテーブルでの使用例

### 通常エンカウント
```
Route 101 草むら:
- Zigzagoon: Lv2-3 (basicLv=2, variableLv=2)
- Poochyena: Lv2-3 (basicLv=2, variableLv=2)
```

### プレッシャー適用時
```
Route 101 草むら（プレッシャー）:
- Zigzagoon: Lv2(60%), Lv3(40%)  
- Poochyena: Lv2(60%), Lv3(40%)
```

## 使用場面

- **StandardLvGenerator**: 通常の野生ポケモンエンカウント
- **PressureLvGenerator**: プレッシャー特性持ちが先頭の時
- **NullLvGenerator**: レベル固定のエンカウント（滅多に使用されない）

プレッシャー特性により、高レベルポケモンの出現率を大幅に向上させることができ、経験値稼ぎや高個体値狙いに有効。