# NatureGenerator実装分析

## 概要

Pokemon第3世代のRNGライブラリにおける性格決定システムの実装を分析。標準生成からサファリゾーンの複雑な処理まで対応。

## インターフェース構造

```csharp
public interface INatureGenerator
{
    Nature GenerateFixedNature(ref uint seed);
}
```

## 実装一覧

### 1. StandardNatureGenerator

**アルゴリズム:**
```csharp
public Nature GenerateFixedNature(ref uint seed) => (Nature)seed.GetRand(25);
```

**特徴:**
- 最もシンプルな性格決定
- 0-24の値を生成して性格に変換
- 全ての性格が等確率（4%）

### 2. SynchronizeNatureGenerator（シンクロ）

**アルゴリズム:**
```csharp
public Nature GenerateFixedNature(ref uint seed) => 
    (seed.GetRand() & 1) == 0 ? syncNature : defaultGenerator.GenerateFixedNature(ref seed);
```

**特徴:**
- 50%の確率でシンクロ性格が発動
- 失敗時は標準生成にフォールバック
- シンクロ性格ごとにインスタンスがキャッシュされている

**実装パターン:**
- 25個の性格用インスタンス + 1個のStandard用インスタンス
- ファクトリーメソッドで適切なインスタンスを取得

### 3. HoennSafariNatureGenerator（ホウエンサファリ・ポロック）

**アルゴリズム:**
```csharp
public Nature GenerateFixedNature(ref uint seed)
{
    // 80%の確率で標準処理、20%でポロック処理
    if (seed.GetRand(100) >= 80 || pokeBlock.IsTasteless()) 
        return Default(ref seed);

    // 25種類の性格リストを作成
    var natureList = [0,1,2,...,24の性格];
    
    // バブルソートのような処理で順序をランダム化
    for (int i = 0; i < 25; i++) {
        for (int j = i + 1; j < 25; j++) {
            if ((seed.GetRand() & 1) == 1)
                swap(natureList[i], natureList[j]);
        }
    }
    
    // ポロックが好きな性格を最初に見つけたものを返す
    return natureList.Find(x => pokeBlock.IsLikedBy(x));
}
```

**特徴:**
- 20%の確率でポロック処理が発動
- ポロックがない場合は標準処理
- 複雑なシャッフル処理により味の好みを反映
- **RNG消費量**: 1回（判定） + 300回（シャッフル） = 301回のRNG消費

### 4. EmSafariNatureGenerator（エメラルドサファリ・ポロック+シンクロ）

**アルゴリズム:**
```csharp
// HoennSafariNatureGeneratorを継承
private protected override Nature Default(ref uint seed) => 
    this.defaultGenerator.GenerateFixedNature(ref seed);
```

**特徴:**
- HoennSafariNatureGeneratorの機能を継承
- 標準処理部分でSynchronizeNatureGeneratorを使用
- ポロック処理とシンクロ処理の組み合わせ

**処理フロー:**
1. 20%でポロック処理 → シャッフル後に味の好みで決定
2. 80%で「シンクロ処理」 → 50%でシンクロ性格、50%で標準生成

### 5. FixedNatureGenerator（性格固定）

**アルゴリズム:**
```csharp
public Nature GenerateFixedNature(ref uint seed) => fixedNature;
```

**特徴:**
- RNGを消費せずに固定性格を返す
- 固定エンカウント等で使用
- `Nature.other`が指定された場合はNullNatureGeneratorを返す

### 6. NullNatureGenerator（性格生成なし）

**アルゴリズム:**
```csharp
public Nature GenerateFixedNature(ref uint seed) => Nature.other;
```

**特徴:**
- RNGを消費せずに無効値を返す
- 性格が後で別途決定される場合に使用

## ポロック（PokeBlock）システム

サファリゾーンで使用するポロックによる性格影響システム:

### 味の分類
- **辛い（Spicy）**: がんばりや、さみしがり、ゆうかん、いじっぱり、やんちゃ
- **渋い（Dry）**: ずぶとい、すなお、のんき、わんぱく、のうてんき  
- **甘い（Sweet）**: ひかえめ、おっとり、れいせい、てれや、うっかりや
- **苦い（Bitter）**: おくびょう、せっかち、まじめ、ようき、むじゃき
- **酸っぱい（Sour）**: おだやか、おとなしい、なまいき、しんちょう、きまぐれ

### ポロックの効果
- 特定の味を持つポロックを設置すると、その味を好む性格が出やすくなる
- 20%の確率で発動
- 300回のシャッフル処理により、好みの性格が上位に来やすくなる

## MoonBit移植時の注意点

### 1. RNG消費量の厳密管理
- StandardNatureGenerator: 1回
- SynchronizeNatureGenerator: 1回（シンクロ判定） + 0-1回（失敗時の標準生成）
- HoennSafariNatureGenerator: 301回（20%発動時）または1回（80%標準時）

### 2. シャッフルアルゴリズムの正確性
サファリのシャッフル処理は以下のパターン:
```
for i in 0..24:
    for j in (i+1)..24:
        if random_bit == 1:
            swap(list[i], list[j])
```
この処理により**300回**のRNG消費が発生（25×24/2 = 300回の比較）

### 3. 性格値の範囲
- 性格は0-24の値（25種類）
- `Nature.other`は25（無効値）

### 4. インスタンス管理
- C#版はシングルトンパターンを使用
- MoonBit版では関数型アプローチで対応

## 使用場面

- **StandardNatureGenerator**: 通常の野生ポケモン
- **SynchronizeNatureGenerator**: シンクロ特性持ちが先頭の時
- **HoennSafariNatureGenerator**: RSサファリゾーン（ポロック使用）
- **EmSafariNatureGenerator**: エメラルドサファリゾーン（ポロック+シンクロ）
- **FixedNatureGenerator**: 固定エンカウント
- **NullNatureGenerator**: 性格を後で決定する場合