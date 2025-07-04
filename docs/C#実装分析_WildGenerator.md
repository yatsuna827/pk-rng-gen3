# WildGenerator実装分析（オーケストレーション）

## 概要

Pokemon第3世代のRNGライブラリにおける野生ポケモン生成の統合システム。各種コンポーネント（エンカウント、スロット、レベル、性格、性別、個体値）を組み合わせて完全な野生ポケモンを生成する。

## システム構造

### クラス構成

```csharp
public class WildGenerator : IGeneratable<RNGResult<Pokemon.Individual, uint>>
{
    private readonly IEncounterDrawer encounterDrawer;    // エンカウント判定
    private readonly SlotGenerator slotGenerator;        // スロット選択
    private readonly ILvGenerator lvGenerator;           // レベル生成  
    private readonly INatureGenerator natureGenerator;   // 性格生成
    private readonly IGenderGenerator genderGenerator;   // 性別生成
    private readonly IIVsGenerator ivsGenrator;         // 個体値生成
}
```

### 生成引数

```csharp
public class WildGenerationArgument
{
    public FieldAbility FieldAbility { get; set; }      // フィールド特性
    public PokeBlock PokeBlock { get; set; }             // サファリのポロック
    public IIVsGenerator GenerateMethod { get; set; }    // 個体値生成方法
    public bool ForceEncounter { get; set; }            // エンカウント強制
    public bool RidingBicycle { get; set; }             // 自転車使用
    public Flute UsingFlute { get; set; }               // フルート使用
    public bool HasCleanseTag { get; set; }             // 清めのお札所持
}
```

## 生成フロー

### メイン処理

```csharp
public RNGResult<Pokemon.Individual, uint> Generate(uint seed)
{
    var head = seed;  // 初期シード保存
    
    // 1. エンカウント判定
    if (!encounterDrawer.DrawEncounter(ref seed))
        return new RNGResult<Pokemon.Individual, uint>(null, 0u, head, seed);
    
    // 2. スロット選択
    var slot = slotGenerator.GenerateSlot(ref seed);
    
    // 3. ポケモン生成（レベル、性別、性格、PID、個体値）
    var (individual, recalc) = slot.Generate(ref seed, lvGenerator, ivsGenrator, 
                                            natureGenerator, genderGenerator);
    
    return new RNGResult<Pokemon.Individual, uint>(individual, recalc, head, seed);
}
```

### 詳細な生成手順

```
1. エンカウント判定 (encounterDrawer.DrawEncounter)
   ├─ RSE: seed.GetRand(2880) vs エンカウント率
   ├─ FRLG: 常にtrue
   └─ 失敗時: null を返して終了

2. スロット選択 (slotGenerator.GenerateSlot)
   ├─ 特殊スロット処理（静電気、磁力、大量発生等）
   └─ 標準テーブルからの選択

3. ポケモン個体生成 (slot.Generate)
   ├─ レベル生成
   ├─ 性別事前決定（メロメロボディ等）
   ├─ 性格事前決定（シンクロ等）
   ├─ PID生成（性別・性格条件満たすまでリロール）
   └─ 個体値生成
```

## コンポーネント選択ロジック

### GBAMapによる自動選択

```csharp
public WildGenerator(GBAMap map, WildGenerationArgument arg = null)
{
    if (arg == null) arg = new WildGenerationArgument();
    
    encounterDrawer = map.GetEncounterDrawer(arg);
    lvGenerator = map.GetLvGenerator(arg);
    slotGenerator = map.GetSlotGenerator(arg);
    natureGenerator = map.GetNatureGenerator(arg);
    genderGenerator = map.GetGenderGenerator(arg);
    ivsGenrator = arg.GenerateMethod;  // 引数から直接取得
}
```

### 各コンポーネントの選択基準

#### EncounterDrawer選択
```csharp
// ゲームバージョンとエンカウント方法による
if (isRSE)
    return new RSEEncounterDrawer(baseRate, arg);
else if (isFRLG) 
    return new FRLGEncounterDrawer();
else if (arg.ForceEncounter)
    return new ForceEncounterDrawer();
```

#### LvGenerator選択
```csharp
// プレッシャー特性の有無
if (arg.FieldAbility.IsPressure())
    return PressureLvGenerator.GetInstance();
else
    return StandardLvGenerator.GetInstance();
```

#### NatureGenerator選択
```csharp
// マップとフィールド特性による複雑な選択
if (isSafariZone) {
    if (isEmerald)
        return EmSafariNatureGenerator.CreateInstance(arg.PokeBlock, syncNature);
    else
        return HoennSafariNatureGenerator.CreateInstance(arg.PokeBlock);
} else if (arg.FieldAbility.IsSynchronize()) {
    return SynchronizeNatureGenerator.GetInstance(syncNature);
} else {
    return StandardNatureGenerator.GetInstance();
}
```

#### GenderGenerator選択
```csharp
// メロメロボディ特性の有無
if (arg.FieldAbility.IsCuteCharm()) {
    return CuteCharmGenderGenerator.GetInstance(cuteCharmGender);
} else {
    return NullGenderGenerator.GetInstance();  // PID判定に委ねる
}
```

#### SlotGenerator構築
```csharp
var specialGenerators = new List<ISpecialSlotGenerator>();

// 静電気・磁力
if (arg.FieldAbility.IsAttract()) {
    specialGenerators.Add(new AttractSlotGenerator(attractType, encounterTable));
}

// 大量発生
if (hasMassOutbreak) {
    specialGenerators.Add(new MassOutBreakSlotGenerator(outbreakSlot));
}

return new SlotGenerator(encounterTable, specialGenerators.ToArray());
```

## RNG消費パターンの管理

### 完全なRNG消費フロー

```
例: エメラルドの草むら、シンクロ＋静電気あり

1. エンカウント判定: 1回
   seed.GetRand(2880)

2. 静電気処理: 2回
   seed.GetRand() & 1 (判定)
   seed.GetRand(対象数) または seed.Advance() (選択/失敗)

3. 標準スロット選択: 1回（静電気失敗時）
   seed.GetRand(100)

4. レベル生成: 1回
   seed.GetRand(variableLv)

5. 性格事前決定: 1-2回
   seed.GetRand() & 1 (シンクロ判定)
   seed.GetRand(25) (シンクロ失敗時)

6. PID生成: 2×N回（Nはリロール回数）
   seed.GetRand() | (seed.GetRand() << 16)
   
7. 個体値生成: 2回
   seed.GetRand() (HAB)
   seed.GetRand() (SCD)

最小合計: 9回、平均合計: 12-20回
```

### リロール回数の追跡

```csharp
// GBASlot.Generate内でリロール回数を記録
var recalc = 0u;
for (; !(pid.CheckGender(Pokemon.GenderRatio, gender) && pid.CheckNature(nature)); recalc++)
    pid = seed.GetRand() | (seed.GetRand() << 16);

// WildGeneratorでリロール回数を返す
return new RNGResult<Pokemon.Individual, uint>(individual, recalc, head, seed);
```

## フィールド特性の詳細

### FieldAbility列挙

```csharp
public enum FieldAbilityType
{
    None,           // 特性なし
    Static,         // 静電気（でんきタイプ誘引）
    MagnetPull,     // 磁力（はがねタイプ誘引）  
    Synchronize,    // シンクロ（性格固定50%）
    CuteCharm,      // メロメロボディ（性別固定67%）
    Pressure,       // プレッシャー（高レベル化）
    Other           // その他
}
```

### 特性の複合効果

```csharp
// 複数特性の同時適用例
var arg = new WildGenerationArgument {
    FieldAbility = FieldAbility.CreateCompound(
        FieldAbilityType.Synchronize,   // シンクロ + 
        FieldAbilityType.Static         // 静電気
    )
};
```

## MoonBit移植時の設計

### 関数型アプローチ

```moonbit
// コンポーネント関数の型定義
type EncounterDrawerFn = (Lcg32Ref) -> Bool
type SlotGeneratorFn = (Lcg32Ref) -> GBASlot  
type LevelGeneratorFn = (Lcg32Ref, UInt, UInt) -> UInt
type NatureGeneratorFn = (Lcg32Ref) -> Nature
type GenderGeneratorFn = (Lcg32Ref) -> Gender
type IVsGeneratorFn = (Lcg32Ref) -> IVs

// オーケストレーション関数
fn create_wild_pokemon_generator(
  encounter_drawer: EncounterDrawerFn,
  slot_generator: SlotGeneratorFn, 
  level_generator: LevelGeneratorFn,
  nature_generator: NatureGeneratorFn,
  gender_generator: GenderGeneratorFn,
  ivs_generator: IVsGeneratorFn
) -> (Lcg32Ref) -> Option[PokemonResult] {
  fn(lcg_ref) {
    // エンカウント判定
    if !encounter_drawer(lcg_ref) { return None }
    
    // スロット選択
    let slot = slot_generator(lcg_ref)
    
    // ポケモン生成
    let level = level_generator(lcg_ref, slot.basic_level, slot.variable_level)
    let pre_gender = gender_generator(lcg_ref)
    let pre_nature = nature_generator(lcg_ref)
    
    // PID生成（リロール含む）
    let (pid, recalc) = generate_pid_with_conditions(
      lcg_ref, pre_nature, pre_gender, slot.gender_ratio
    )
    
    // 個体値生成
    let ivs = ivs_generator(lcg_ref)
    
    Some(PokemonResult {
      ivs, nature: Nature::from_pid(pid), gender: Gender::from_pid(pid, slot.gender_ratio),
      pid, level, recalc_count: recalc
    })
  }
}
```

## 使用例とテストケース

### 基本的な使用例

```csharp
// Route 101の草むら、特殊条件なし
var map = new RSRoute101();
var arg = new WildGenerationArgument {
    GenerateMethod = StandardIVsGenerator.GetInstance()
};
var generator = new WildGenerator(map, arg);

var result = generator.Generate(0x12345678);
// result.Result: 生成されたポケモン個体
// result.RecalcCount: PIDリロール回数  
// result.Head: 初期シード
// result.Tail: 終了後シード
```

### 複雑な条件の例

```csharp
// エメラルドサファリ、ポロック＋シンクロ、Method4
var safariMap = new EmSafariZone();
var arg = new WildGenerationArgument {
    FieldAbility = FieldAbility.CreateSynchronize(Nature.Modest),
    PokeBlock = PokeBlock.CreateSweet(),
    GenerateMethod = MiddleInterruptedIVsGenerator.GetInstance(),
    UsingFlute = Flute.WhiteFlute
};
var generator = new WildGenerator(safariMap, arg);
```
