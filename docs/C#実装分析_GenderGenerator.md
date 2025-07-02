# GenderGenerator実装分析

## 概要

Pokemon第3世代のRNGライブラリにおける性別決定システムの実装を分析。通常の性別比による判定からメロメロボディ特性の効果まで対応。

## インターフェース構造

```csharp
public interface IGenderGenerator
{
    Gender GenerateGender(ref uint seed);
}
```

## 実装一覧

### 1. 標準的な性別生成（実装なし）

**注意**: 標準的な性別生成は、実際にはPIDから決定される。
- PIDの下位8bitを性別比と比較
- `(pid & 0xFF) < genderRatio` で性別を判定
- IGenderGeneratorは特殊な性別決定処理にのみ使用

### 2. CuteCharmGenderGenerator（メロメロボディ特性）

**アルゴリズム:**
```csharp
public Gender GenerateGender(ref uint seed) => 
    seed.GetRand(3) != 0 ? fixedGender : Gender.Genderless;
```

**特徴:**
- 2/3の確率（約66.7%）で特定性別が出現
- 1/3の確率で性別不明（実質的には通常判定にフォールバック）
- メロメロボディ持ちの性別とは**逆の性別**が出やすくなる

**実装詳細:**
```csharp
// メロメロボディ持ちが♂の場合 → ♀が出やすくなる
// メロメロボディ持ちが♀の場合 → ♂が出やすくなる
private CuteCharmGenderGenerator(Gender cuteCharmPokeGender) => 
    fixedGender = cuteCharmPokeGender.Reverse();
```

**インスタンス管理:**
```csharp
private static readonly IGenderGenerator[] instances = new IGenderGenerator[]
{
    new CuteCharmGenderGenerator(Gender.Male),    // ♂持ち→♀優遇
    new CuteCharmGenderGenerator(Gender.Female),  // ♀持ち→♂優遇  
    NullGenderGenerator.GetInstance()             // 性別不明持ち→効果なし
};
```

### 3. FixedGenderGenerator（性別固定）

**アルゴリズム:**
```csharp
public Gender GenerateGender(ref uint seed) => fixedGender;
```

**特徴:**
- RNGを消費せずに固定性別を返す
- 性別固定のポケモン（化石ポケモン、伝説等）で使用
- 性別不明が指定された場合はNullGenderGeneratorを返す

**インスタンス管理:**
```csharp
private static readonly IGenderGenerator[] instances = new IGenderGenerator[]
{
    new FixedGenderGenerator(Gender.Male),      // ♂固定
    new FixedGenderGenerator(Gender.Female),    // ♀固定
    NullGenderGenerator.GetInstance()           // 性別不明
};
```

### 4. NullGenderGenerator（性別生成なし）

**アルゴリズム:**
```csharp
public Gender GenerateGender(ref uint seed) => Gender.Genderless;
```

**特徴:**
- RNGを消費せずに性別不明を返す
- 性別が通常のPID判定で決まる場合に使用
- 「何もしない」ことを明示的に表現

## 性別判定の仕組み

### 通常の性別判定（PIDベース）

```csharp
public static Gender GetGender(uint pid, GenderRatio ratio)
{
    if (ratio == GenderRatio.Genderless) return Gender.Genderless;
    if (ratio == GenderRatio.MaleOnly) return Gender.Male;
    if (ratio == GenderRatio.FemaleOnly) return Gender.Female;
    
    return (pid & 0xFF) < (uint)ratio ? Gender.Female : Gender.Male;
}
```

### 性別比の値

```csharp
public enum GenderRatio : uint
{
    MaleOnly = 0,        // ♂のみ（0%♀）
    Male7Female1 = 31,   // ♂7:♀1（12.5%♀）
    Male3Female1 = 63,   // ♂3:♀1（25%♀）  
    Male1Female1 = 127,  // ♂1:♀1（50%♀）
    Male1Female3 = 191,  // ♂1:♀3（75%♀）
    Male1Female7 = 225,  // ♂1:♀7（87.5%♀）
    FemaleOnly = 254,    // ♀のみ（100%♀）
    Genderless = 255     // 性別不明
}
```

## RNG消費パターン

### 1. メロメロボディありの場合
```
1. CuteCharmGenderGenerator.GenerateGender(): 1回のRNG消費
   - 2/3確率で固定性別
   - 1/3確率で性別不明（→通常のPID判定へ）

2. 通常のPID判定は別途実行される
```

### 2. 性別固定の場合
```
FixedGenderGenerator.GenerateGender(): RNG消費なし
通常のPID判定もスキップ
```

### 3. 通常の場合
```
NullGenderGenerator.GenerateGender(): RNG消費なし
通常のPID判定で性別決定
```

## 特性効果の優先順位

1. **性別固定ポケモン**: IGenderGeneratorの結果が最優先
2. **メロメロボディ**: 2/3確率で特定性別、1/3確率で通常判定
3. **通常判定**: PIDの下位8bitと性別比で判定

## MoonBit移植時の注意点

### 1. 性別の逆転処理
```csharp
// C#版の拡張メソッド
public static Gender Reverse(this Gender gender)
{
    return gender switch
    {
        Gender.Male => Gender.Female,
        Gender.Female => Gender.Male,
        _ => Gender.Genderless
    };
}
```

### 2. メロメロボディの確率
- `seed.GetRand(3) != 0`は**2/3確率**でtrue
- 0が出る確率は1/3、1または2が出る確率は2/3

### 3. 性別不明の扱い
- `Gender.Genderless`が返された場合は通常のPID判定を行う
- 完全に性別生成をスキップする場合との区別が重要

### 4. インスタンス管理
- C#版はファクトリーパターンで性別ごとにインスタンスをキャッシュ
- MoonBit版では関数型アプローチで実装

## 使用場面

- **CuteCharmGenderGenerator**: メロメロボディ持ちが先頭の時
- **FixedGenderGenerator**: 性別固定ポケモン（化石、伝説等）
- **NullGenderGenerator**: 通常の野生ポケモン（PID判定に委ねる）

## PIDとの関係

IGenderGeneratorは**PID生成前**に性別を決定する特殊な処理。通常はPID生成時に性別も同時に決まるが、特定の状況では事前に性別を確定させる必要がある。

この仕組みにより、メロメロボディや性別固定といった特殊な性別決定ルールを統一的に扱える。