# IVsGenerator実装分析

## 概要

Pokemon第3世代のRNGライブラリにおける個体値生成システムの実装を分析。5つの異なる生成方法が実装されている。

## インターフェース構造

```csharp
// 基本インターフェース
public interface IIVsGenerator
{
    uint[] GenerateIVs(ref uint seed);
}

// 抽象基底クラス（4つのMethodクラス用）
public abstract class GenerateMethod : IIVsGenerator
{
    public string LegacyName { get; }
    public abstract uint[] GenerateIVs(ref uint seed);
}
```

## 実装一覧

### 1. StandardIVsGenerator (Method1)

**アルゴリズム:**
```csharp
var HAB = seed.GetRand();  // HP, Attack, Defense用の16bit値
var SCD = seed.GetRand();  // Speed, Sp.Atk, Sp.Def用の16bit値

// 各個体値を5bit(0-31)で抽出
return new uint[6] {
    HAB & 0x1f,           // HP
    (HAB >> 5) & 0x1f,    // Attack  
    (HAB >> 10) & 0x1f,   // Defense
    (SCD >> 5) & 0x1f,    // Sp.Atk
    (SCD >> 10) & 0x1f,   // Sp.Def
    SCD & 0x1f            // Speed
};
```

**特徴:**
- 最も標準的な個体値生成方法
- 2回のRNG呼び出しで6つの個体値を決定
- 既にMoonBit版で実装済み

### 2. PriorInterruptIVsGenerator (Method2)

**アルゴリズム:**
```csharp
seed.Advance();           // 1回進める
var HAB = seed.GetRand(); // HP, Attack, Defense
var SCD = seed.GetRand(); // Speed, Sp.Atk, Sp.Def
// 以下Standard版と同じ抽出処理
```

**特徴:**
- 生成前に1回RNGを進める
- フレーム割り込みによる個体値ずれを再現

### 3. MiddleInterruptedIVsGenerator (Method4)

**アルゴリズム:**
```csharp
var HAB = seed.GetRand(); // HP, Attack, Defense
seed.Advance();           // HABとSCDの間で1回進める
var SCD = seed.GetRand(); // Speed, Sp.Atk, Sp.Def
// 以下Standard版と同じ抽出処理
```

**特徴:**
- HAB取得後、SCD取得前に1回RNGを進める
- 中間割り込みによる個体値ずれを再現

### 4. PosteriorInterruptedIVsGenerator (Method3)

**アルゴリズム:**
```csharp
var HAB = seed.GetRand(); // HP, Attack, Defense
var SCD = seed.GetRand(); // Speed, Sp.Atk, Sp.Def
seed.Advance();           // SCD取得後に1回進める
// 以下Standard版と同じ抽出処理
```

**特徴:**
- 両方取得後に1回RNGを進める
- 後方割り込みによる個体値ずれを再現

### 5. RoamingBuggyIVsGenerator（徘徊バグ版）

**アルゴリズム:**
```csharp
// 本来は32bitを読むべき箇所で8bitしか読まないバグ
var HAB = seed.GetRand() & 0xFF;  // 下位8bitのみ有効
var SCD = seed.GetRand() & 0x0;   // 常に0（バグ）

return new uint[6] {
    HAB & 0x1f,           // HP: 0-31（正常）
    (HAB >> 5) & 0x1f,    // Attack: 0-7の範囲（バグ）
    (HAB >> 10) & 0x1f,   // Defense: 0（バグ）
    (SCD >> 5) & 0x1f,    // Sp.Atk: 0（バグ）
    (SCD >> 10) & 0x1f,   // Sp.Def: 0（バグ）
    SCD & 0x1f            // Speed: 0（バグ）
};
```

**特徴:**
- 徘徊ポケモン（ラティオス等）のバグ実装
- HPは正常、攻撃は0-7、他は全て0になる
- ゲーム実機のバグを忠実に再現

## 個体値配列の順序

全ての実装で個体値は以下の順序で格納:
1. HP (H)
2. Attack (A) 
3. Defense (B)
4. Sp.Attack (C)
5. Sp.Defense (D)
6. Speed (S)

## MoonBit移植時の注意点

1. **RNG状態管理**: C#版は`ref uint seed`で状態を更新するが、MoonBit版では不変版と可変版を分離
2. **バグ実装の忠実再現**: RoamingBuggyGeneratorのバグは意図的なものなので正確に移植が必要
3. **テスト**: 各Method間での結果の違いを確認するテストが重要
4. **命名**: C#版のMethod1-4ではなく、機能に基づいた命名を使用

## 用途

- **Standard**: 通常の野生ポケモン
- **Prior/Middle/Posterior**: 特定の状況での割り込み処理
- **RoamingBuggy**: 徘徊ポケモンのバグ再現

各種類は特定のゲーム状況や条件下で使い分けられる。