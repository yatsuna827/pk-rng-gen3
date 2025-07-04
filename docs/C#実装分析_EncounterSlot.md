# EncounterとSlot生成実装分析

## 概要

Pokemon第3世代のRNGライブラリにおけるエンカウント判定とスロット選択システムの実装を分析。野生ポケモンとの遭遇が発生するかの判定と、どのポケモンが出現するかの選択処理。

## システム構造

```
Wild Pokemon Encounter Flow:
1. Encounter Drawing (遭遇判定) ← このドキュメントの対象
2. Slot Generation (スロット選択) ← このドキュメントの対象
3. Pokemon Generation (個体生成)
```

## 1. Encounter Drawing（エンカウント判定）

### インターフェース

```csharp
public interface IEncounterDrawer
{
    bool DrawEncounter(ref uint seed);
}
```

### 実装種類

#### 1.1. RSEEncounterDrawer（ルビー・サファイア・エメラルド）

**アルゴリズム:**
```csharp
public bool DrawEncounter(ref uint seed)
{
    var encounterRate = CalculateEncounterRate();
    return seed.GetRand(2880) < encounterRate;
}
```

**特徴:**
- 0-2879の範囲でランダム値を生成（2880通り）
- エンカウント率が閾値として機能
- 各種補正が適用されたエンカウント率と比較

**エンカウント率の計算:**
```csharp
private uint CalculateEncounterRate()
{
    var rate = baseEncounterRate;  // 基本エンカウント率
    
    // 自転車補正（RSEのみ）
    if (ridingBicycle) rate = rate * 80 / 100;
    
    // フルート補正
    switch (flute) {
        case Flute.WhiteFlute: rate = rate * 150 / 100; break;  // 白フルート: +50%
        case Flute.BlackFlute: rate = rate * 50 / 100; break;   // 黒フルート: -50%
    }
    
    // 清めのお札補正
    if (hasCleanseTag) rate = rate * 2 / 3;  // -33%
    
    return Math.Min(rate, 2880);  // 上限は2880
}
```

#### 1.2. FRLGEncounterDrawer（ファイアレッド・リーフグリーン）

**実装:**
```csharp
public bool DrawEncounter(ref uint seed) => true;  // 常にtrue
```

**注意:** 現在の実装は未完成で、常にエンカウントが発生する。実際のFRLGの仕様調査が必要。

#### 1.3. ForceEncounterDrawer（強制エンカウント）

**実装:**
```csharp
public bool DrawEncounter(ref uint seed) => true;  // 常にtrue
```

**用途:**
- 釣り（必ずエンカウント）
- 強制エンカウントイベント
- テスト用途

## 2. Slot Generation（スロット選択）

### システム構造

```csharp
public class SlotGenerator
{
    private readonly ISpecialSlotGenerator[] specialGenerators;
    private readonly GBASlot[] standardTable;
}
```

### 2.1. メインアルゴリズム

```csharp
public GBASlot GenerateSlot(ref uint seed)
{
    // 特殊スロット処理を順番に試行
    foreach (var generator in specialGenerators)
    {
        if (generator.TryGenerate(ref seed, out var specialSlot))
            return specialSlot;
    }
    
    // 標準テーブルから選択
    return SelectFromStandardTable(ref seed);
}
```

### 2.2. 特殊スロット生成器

#### AttractSlotGenerator（静電気・磁力）

**アルゴリズム:**
```csharp
public bool TryGenerate(ref uint seed, out GBASlot slot)
{
    if ((seed.GetRand() & 1) == 0)  // 50%の確率で発動
    {
        var attractableSlots = GetAttractableSlots();  // 対象タイプのポケモン
        if (attractableSlots.Length > 0)
        {
            slot = attractableSlots[seed.GetRand(attractableSlots.Length)];
            return true;
        }
    }
    
    // 失敗時は1回RNGを消費してfalse
    seed.Advance();
    slot = null;
    return false;
}
```

**特徴:**
- 50%確率で特定タイプのポケモンを引き寄せ
- 対象ポケモンがいない場合は無効化
- 失敗時もRNGを1回消費（重要）

#### MassOutBreakSlotGenerator（大量発生）

**アルゴリズム:**
```csharp
public bool TryGenerate(ref uint seed, out GBASlot slot)
{
    if (seed.GetRand(100) < 50)  // 50%の確率
    {
        slot = massOutbreakSlot;  // 大量発生ポケモン
        return true;
    }
    
    slot = null;
    return false;
}
```

**特徴:**
- 50%確率で大量発生ポケモンが出現
- フィーバス等の特殊エンカウントで使用
- 失敗時はRNG消費なし

#### DummySpecialSlotGenerator

**アルゴリズム:**
```csharp
public bool TryGenerate(ref uint seed, out GBASlot slot)
{
    seed.Advance();  // RNGを1回消費
    slot = null;
    return false;    // 常に失敗
}
```

**用途:**
- 特殊条件はあるが対象ポケモンがいない場合
- RNG消費パターンを合わせるため

#### NullSpecialSlotGenerator

**アルゴリズム:**
```csharp
public bool TryGenerate(ref uint seed, out GBASlot slot)
{
    slot = null;
    return false;  // 何もせず失敗
}
```

**用途:**
- 特殊条件が一切ない場合
- RNG消費なし

### 2.3. 標準テーブル選択

#### エンカウント方法別の確率分布

**草むら（12スロット）:**
```
スロット | 確率 | 累積確率
---------|------|----------
0        | 20%  | 20%
1        | 20%  | 40%
2        | 10%  | 50%
3        | 10%  | 60%
4        | 10%  | 70%
5        | 10%  | 80%
6        | 5%   | 85%
7        | 5%   | 90%
8        | 4%   | 94%
9        | 4%   | 98%
10       | 1%   | 99%
11       | 1%   | 100%
```

**水上（5スロット）:**
```
スロット | 確率
---------|------
0        | 60%
1        | 30%
2        | 5%
3        | 4%
4        | 1%
```

**釣り:**
- **ボロの釣り竿（2スロット）**: 70%, 30%
- **いい釣り竿（3スロット）**: 60%, 20%, 20%
- **すごい釣り竿（5スロット）**: 40%, 40%, 15%, 4%, 1%

**岩砕き（5スロット）:**
- 水上と同じ分布

#### 選択アルゴリズム

```csharp
private GBASlot SelectFromStandardTable(ref uint seed)
{
    var random = seed.GetRand(100);  // 0-99の値
    var cumulative = 0;
    
    for (int i = 0; i < slots.Length; i++)
    {
        cumulative += slotProbabilities[i];
        if (random < cumulative)
            return slots[i];
    }
    
    return slots[slots.Length - 1];
}
```

## 3. RNG消費パターン

### エンカウント判定
- **RSE**: 1回（seed.GetRand(2880)）
- **FRLG**: 0回（常にtrue）
- **強制**: 0回（常にtrue）

### スロット選択
- **特殊スロット成功**: 1-2回（種類による）
- **特殊スロット失敗**: 0-1回（種類による）
- **標準テーブル**: 1回

### 具体例（静電気あり草むら）

```
1. エンカウント判定: seed.GetRand(2880) → 1回消費
2. 静電気判定: seed.GetRand() & 1 → 2回消費
   - 成功時: でんきタイプから選択 → seed.GetRand(対象数) → 3回消費
   - 失敗時: seed.Advance() → 3回消費
3. 失敗時の標準選択: seed.GetRand(100) → 4回消費

合計: 成功時3回、失敗時4回のRNG消費
```

## 4. MoonBit移植時の注意点

### 4.1. エンカウント率計算
```moonbit
fn calculate_encounter_rate(
  base_rate: UInt,
  riding_bicycle: Bool,
  flute: Flute,
  has_cleanse_tag: Bool
) -> UInt {
  let mut rate = base_rate
  
  if riding_bicycle { rate = rate * 80 / 100 }
  
  match flute {
    Flute::White => rate = rate * 150 / 100
    Flute::Black => rate = rate * 50 / 100
    _ => ()
  }
  
  if has_cleanse_tag { rate = rate * 2 / 3 }
  
  min(rate, 2880)
}
```

### 4.2. 特殊スロット処理
```moonbit
fn try_special_slots(
  lcg_ref: Lcg32Ref,
  generators: Array[SpecialSlotGenerator]
) -> Option[GBASlot] {
  for generator in generators {
    match generator.try_generate(lcg_ref) {
      Some(slot) => return Some(slot)
      None => continue
    }
  }
  None
}
```

### 4.3. 確率分布テーブル
```moonbit
let grass_probabilities = [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
let surf_probabilities = [60, 30, 5, 4, 1]

fn select_standard_slot(lcg_ref: Lcg32Ref, probabilities: Array[Int]) -> Int {
  let random = lcg_ref.get_rand(100)
  let mut cumulative = 0
  
  for (i, prob) in probabilities.iter().enumerate() {
    cumulative += prob
    if random < cumulative { return i }
  }
  
  probabilities.length() - 1
}
```

## 5. 使用場面とバリエーション

### 草むらエンカウント
- 基本エンカウント率: マップ固有値
- 特殊効果: 静電気、磁力、大量発生
- 補正: 自転車、フルート、清めのお札

### 水上エンカウント  
- 基本エンカウント率: 通常100%（補正で変動）
- 特殊効果: 静電気、磁力は無効
- スロット分布: 草むらと異なる

### 釣りエンカウント
- エンカウント判定: 常に成功（ForceEncounterDrawer）
- 釣り竿別のスロット分布
- 特殊効果: 静電気、磁力は無効

### 岩砕きエンカウント
- エンカウント判定: 通常の計算式
- スロット分布: 水上と同じ
- 特殊効果: 静電気、磁力は有効
