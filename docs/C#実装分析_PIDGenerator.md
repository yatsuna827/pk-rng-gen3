# PIDGenerator実装分析

## 概要

Pokemon第3世代のRNGライブラリにおけるPID（Personality ID）生成システムの実装を分析。PIDは性格、性別、色違い判定、特殊な形態決定などに使用される32bit値。

## PID生成の基本アルゴリズム

### 標準的な野生ポケモンPID生成

**実装場所**: `GBASlot.cs`

```csharp
// 基本的なPID生成
var pid = seed.GetRand() | (seed.GetRand() << 16);

// 性別・性格チェック付き生成
var recalc = 0u;
for (; !(pid.CheckGender(Pokemon.GenderRatio, gender) && pid.CheckNature(nature)); recalc++)
    pid = seed.GetRand() | (seed.GetRand() << 16);
```

**特徴:**
- 2回のRNG呼び出しで32bit PIDを構成
- 下位16bit: 1回目のGetRand()
- 上位16bit: 2回目のGetRand()
- 性別・性格条件を満たすまでループ（リロール）

### PID構成要素

```
PID = [上位16bit][下位16bit]
    = [2回目のGetRand()][1回目のGetRand()]
```

## PID判定関数群

### 1. 性格判定

**実装**: `Extensions.cs`
```csharp
public static bool CheckNature(this uint pid, Nature fixedNature)
    => fixedNature == Nature.other || (Nature)(pid % 25) == fixedNature;
```

**特徴:**
- PID % 25で性格を決定（0-24 = 25種類の性格）
- `Nature.other`は「任意の性格」を意味

### 2. 性別判定

**実装**: `Extensions.cs`
```csharp
public static bool CheckGender(this uint pid, GenderRatio genderRatio, Gender fixedGender)
{
    if (fixedGender == Gender.Genderless) return true;
    return GetGender(pid, genderRatio) == fixedGender;
}

public static Gender GetGender(uint pid, GenderRatio ratio)
{
    if (ratio == GenderRatio.Genderless) return Gender.Genderless;
    if (ratio == GenderRatio.MaleOnly) return Gender.Male;
    if (ratio == GenderRatio.FemaleOnly) return Gender.Female;
    
    return (pid & 0xFF) < (uint)ratio ? Gender.Female : Gender.Male;
}
```

**特徴:**
- PIDの下位8bit（pid & 0xFF）を性別比と比較
- 下位8bitが性別比未満なら♀、以上なら♂

### 3. 色違い判定

**実装**: `Extensions.cs`
```csharp
public static bool IsShiny(this uint pid, uint tsv)
    => GetShinyType(pid, tsv) != ShinyType.NotShiny;

public static ShinyType GetShinyType(uint pid, uint tsv)
{
    var sv = ((pid & 0xFFFF) ^ (pid >> 16)) ^ tsv;
    return sv switch
    {
        0 => ShinyType.Square,
        < 16 => ShinyType.Star,
        _ => ShinyType.NotShiny
    };
}
```

**アルゴリズム:**
1. PIDの上位16bitと下位16bitをXOR
2. 結果をTSV（Trainer Shiny Value）とXOR
3. 最終結果が0なら四角色違い、1-15なら星色違い、16以上なら通常

## 特殊なPID生成パターン

### 1. Unown形態対応

**実装**: `GBASlot.cs`
```csharp
// Unown専用PID生成（lines 70-75）
// 形態チェック付きでPID生成
// 詳細なアルゴリズムは実装依存
```

### 2. 卵ポケモンPID生成

**実装**: `ProphaseEggGenerator.cs`

#### 標準卵PID
```csharp
public uint GeneratePID(ref uint seed, uint frameCount)
{
    var hid = frameCount.NextSeed() & 0xFFFF0000;  // 上位16bit
    var lid = seed.GetRand(0xFFFE) + 1;            // 下位16bit (1-65534)
    return hid | lid;
}
```

#### かわらずのいし持ち卵PID
```csharp
// 性格遺伝の場合のPID生成（lines 74-86）
// 特定の性格になるまでPIDを再生成
```

**特徴:**
- 上位16bit: フレームカウントから算出
- 下位16bit: 1-65534の範囲（0とFFFFを除外）
- かわらずのいし使用時は性格条件までリロール

### 3. 大量発生（MassOutbreak）

**実装**: `GBASlot.cs` (lines 100-104)
```csharp
// 大量発生時は通常のPID生成だがレベル生成をスキップ
// PID生成アルゴリズム自体は標準と同じ
```

## RNG消費パターン

### 標準野生ポケモン
```
最小消費: 2回（PID生成1回）
平均消費: 約8-16回（性別・性格リロール込み）
最大消費: 理論上無限（極めて稀）
```

### リロール確率の計算
- **性格条件**: 1/25確率で成功
- **性別条件**: 性別比により変動（12.5%♀なら7/8確率で♂成功）
- **両方の条件**: (1/25) × (性別確率)

### 卵ポケモン
```
標準卵: 1回（GetRand(0xFFFE)のみ）
かわらずのいし: 平均25回（性格条件まで）
```

## MoonBit移植時の注意点

### 1. PID構成の正確性
```moonbit
// 正しいPID構成
let low = lcg_ref.get_rand()
let high = lcg_ref.get_rand()  
let pid = low | (high << 16)
```

### 2. 性格・性別判定関数
```moonbit
fn check_nature(pid: UInt, required_nature: Nature) -> Bool {
  required_nature == Nature::Any || (pid % 25) == required_nature.value()
}

fn get_gender(pid: UInt, ratio: GenderRatio) -> Gender {
  match ratio {
    GenderRatio::Genderless => Gender::Genderless
    GenderRatio::MaleOnly => Gender::Male  
    GenderRatio::FemaleOnly => Gender::Female
    _ => if (pid & 0xFF) < ratio.value() { Gender::Female } else { Gender::Male }
  }
}
```

### 3. 色違い判定
```moonbit
fn get_shiny_type(pid: UInt, tsv: UInt) -> ShinyType {
  let sv = ((pid & 0xFFFF) ^ (pid >> 16)) ^ tsv
  match sv {
    0 => ShinyType::Square
    sv if sv < 16 => ShinyType::Star  
    _ => ShinyType::NotShiny
  }
}
```

### 4. リロール処理
```moonbit
fn generate_pid_with_conditions(
  lcg_ref: Lcg32Ref,
  required_nature: Nature,
  required_gender: Gender,
  gender_ratio: GenderRatio
) -> (UInt, UInt) {  // (pid, recalc_count)
  let mut recalc = 0
  loop {
    let pid = lcg_ref.get_rand() | (lcg_ref.get_rand() << 16)
    if check_nature(pid, required_nature) && 
       check_gender(pid, required_gender, gender_ratio) {
      return (pid, recalc)
    }
    recalc += 1
  }
}
```

### 5. 性別比の定義
```moonbit
enum GenderRatio {
  MaleOnly      // 0 (0%♀)
  Male7Female1  // 31 (12.5%♀) 
  Male3Female1  // 63 (25%♀)
  Male1Female1  // 127 (50%♀)
  Male1Female3  // 191 (75%♀)
  Male1Female7  // 225 (87.5%♀)
  FemaleOnly    // 254 (100%♀)
  Genderless    // 255 (性別不明)
}
```

## PID生成の統合フロー

野生ポケモン生成における完全なフロー:

1. **エンカウント判定**: エンカウント発生の可否
2. **スロット選択**: どのポケモンが出現するか
3. **レベル生成**: プレッシャー特性等の影響
4. **性別事前決定**: メロメロボディ等の特殊処理
5. **性格事前決定**: シンクロ特性等の特殊処理  
6. **PID生成**: 性別・性格条件を満たすまでリロール
7. **個体値生成**: 指定された方法で個体値決定

PIDは野生ポケモン生成の中核を担い、多くのゲーム要素に影響する重要な値。