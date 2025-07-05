## 実装計画書: `Pokemon3genRNGLibrary` Moonbit移植

### 1. 目的

C#製 `Pokemon3genRNGLibrary` が持つ機能を、Moonbit言語へ移植する。

### 2. 設計方針

本ライブラリは、特定の状態を持つオブジェクトを生成する設計は採用しない。代わりに、独立した機能群を直接組み合わせて利用する、関数型の設計アプローチを基本思想とする。

ライブラリは、責務の異なる二種類の関数を提供する。

#### 2.1. コンポーネント関数 (Component Functions)

-   **役割:** 乱数生成プロセスの各工程に対応する、単一の具体的なアルゴリズムを実装する。
-   **例:** 「標準的な個体値計算法」「プレッシャー特性を考慮したレベル決定法」など。
-   **特性:** 各コンポーネント関数は、他の関数の実装に依存しない、独立した単位として提供される。

#### 2.2. オーケストレーション関数 (Orchestration Functions)

-   **役割:** 複数のコンポーネント関数を、定義済みの順序で実行する高レベルな関数。プロセスの実行手順を定義する責務を持つ。
-   **例:** 「野生ポケモンの生成プロセス」など。
-   **特性:** この関数自体は、具体的な計算ロジックを持たない。実際の計算は、引数として渡されるコンポーネント関数に委譲される。

### 3. 設計の核心

本設計の核心は、オーケストレーション関数に対し、その振る舞いを決定するコンポーネント関数を、実行時に引数として渡す点にある。これは、オブジェクト指向設計における依存性の注入（Dependency Injection）に相当する概念を、高階関数を用いて実現するものである。

この設計により、中間的なオブジェクトを介さず、アプリケーションは利用したい機能を直接組み合わせて、目的の結果を得ることが可能となる。

### 4. 乱数ジェネレータの取り扱い

本設計は、状態を更新しない値型のジェネレータと、状態を更新する参照型のジェネレータが事前に定義されていることを前提とする。

状態の更新を伴う一連の処理において、各関数は引数として参照型のジェネレータを受け取る。これにより、プロセス全体を通じて、乱数ジェネレータの状態が一貫して管理されることを保証する。

### 5. 実装対象一覧

本移植で作成する具体的な関数および型は以下の通りである。

#### 5.1. 基本要素

-   **型定義:**
    -   `PokemonResult`, `IVs`, `Nature`, `Gender` 等。
    -   **`GeneratorFnImmut[T]` (不変ジェネレータ):**
        -   **概念:** ある時点の「ジェネレータの値」を受け取り、「生成結果」と「次のジェネレータの値」をペアで返す、純粋な関数。副作用を持たない。
        -   **用途:** 関数の合成や、単体での安全な利用を想定。
    -   **`GeneratorFnMut[T]` (可変ジェネレータ):**
        -   **概念:** 「ジェネレータへの参照」を受け取り、その内部状態を直接更新し、「生成結果」のみを返す関数。
        -   **用途:** 連続した生成プロセス内での、効率的な状態更新を想定。

#### 5.2. コンポーネント関数（部品）

以下の具体的なアルゴリズムを実装した、独立した関数群を作成する。

-   **基本実装方針:**
    -   全てのコンポーネント関数は、**可変版 (`Mut`)** と**不変版 (`Immut`)** の両方を提供する。
    -   **不変版の実装**: 内部で可変版を呼び出すアダプタとして実装し、コードの重複を避ける。
        - 不変版は`lcg.to_ref()`で可変参照に変換してから可変版を呼び出す
        - 例: `generate_level_standard_immut`は内部で`generate_level_standard_mut`を呼び出す
    -   **可変版の実装**: 実際のアルゴリズムロジックを実装する。
    -   例: `generate_ivs_standard_immut`, `generate_ivs_standard_mut`

-   **実装対象:**
    -   **個体値生成 (IVs):**
        -   `standard`, `middle_interrupted`, `posterior_interrupted`, `prior_interrupt`, `roaming_buggy`
    -   **レベル生成 (Lv):**
        -   `standard`, `pressure`, `null`
    -   **性別生成 (Gender):**
        -   `from_pid`, `cute_charm`, `fixed`
    -   **性格生成 (Nature):**
        -   `standard`, `synchronize`, `emsafari`
    -   **性格値生成 (PID):**
        -   `standard`
    -   **エンカウントおよびスロット生成:**
        -   `draw_encounter`, `generate_slot_standard`

#### 5.3. オーケストレーション関数（組み立て役）

-   `create_wild_pokemon_generator`:
    -   この関数は、内部で効率的に処理を行うため、引数として**可変版 (`Mut`)** のコンポーネント関数群を受け取る。
    -   戻り値として、野生ポケモンを生成する設定済みの**可変ジェネレータ (`GeneratorFnMut[PokemonResult]`)** を返す。

#### 5.4. ユーティリティ関数

-   `to_mutable_generator[T]`:
    -   **役割:** 不変ジェネレータ (`GeneratorFnImmut`) を、可変ジェネレータ (`GeneratorFnMut`) に変換するアダプタ関数。
    -   **用途:** アプリケーション側が、ライブラリが提供する純粋な不変コンポーネント関数を、`create_wild_pokemon_generator` が要求する可変版に適合させるために利用する。

### 6. 検証

C#版ライブラリと同一の初期シードおよび条件を与えた際に、全ての出力結果が完全に一致することを保証するテストスイートを構築する。

### 7. C#実装分析ドキュメント

移植作業の参考として、C#版ライブラリの詳細分析結果を`docs/`ディレクトリに整理済み：

- **`C#実装分析_IVsGenerator.md`** - 個体値生成の5種類の実装方法
- **`C#実装分析_NatureGenerator.md`** - 性格生成（標準、シンクロ、サファリ等）
- **`C#実装分析_GenderGenerator.md`** - 性別生成（メロメロボディ、固定等）
- **`C#実装分析_LevelGenerator.md`** - レベル生成（標準、プレッシャー等）
- **`C#実装分析_PIDGenerator.md`** - PID生成（性格値、色違い判定等）
- **`C#実装分析_EncounterSlot.md`** - エンカウント・スロット選択システム
- **`C#実装分析_WildGenerator.md`** - 全体統合システム（オーケストレーション）

各ドキュメントには、アルゴリズム詳細、RNG消費パターン、MoonBit移植時の注意点が記載されている。

## 実装進捗

### 完了項目

#### 基本型定義 (`src/types/`)
- ✅ IVs型（HABCDS表記対応）
- ✅ Nature型（性格、0-24の値）
- ✅ Gender型（性別）
- ✅ PokemonResult型（生成結果）

#### LCG32実装 (`src/lcg32/`)
- ✅ 不変版・可変版LCG32実装
- ✅ ジャンプ機能（高速前進・後退）
- ✅ 完全なテストスイート

#### IVsGenerator群 (`src/ivs-generator/`)
- ✅ StandardIVsGenerator（standard.mbt）
- ✅ PriorInterruptIVsGenerator（prior_interrupt.mbt）
- ✅ MiddleInterruptedIVsGenerator（middle_interrupted.mbt）
- ✅ PosteriorInterruptedIVsGenerator（posterior_interrupted.mbt）
- ✅ RoamingBuggyIVsGenerator（roaming_buggy.mbt）
- ✅ 各実装で不変版・可変版の両方対応
- ✅ 全22テスト通過
- ✅ ファイル分割によるモジュール整理
- ✅ C#実装結果を用いた互換性テスト追加

#### NatureGenerator群 (`src/nature-generator/`)
- ✅ StandardNatureGenerator（standard.mbt）
- ✅ SynchronizeNatureGenerator（synchronize.mbt）
- ✅ FixedNatureGenerator（fixed.mbt）
- ✅ HoennSafariNatureGenerator（hoenn_safari.mbt）
- ✅ EmSafariNatureGenerator（hoenn_safari.mbt）
- ✅ 不変版・可変版の両方対応
- ✅ C#実装結果を用いた互換性テスト追加
- ✅ t-wada TDD基準でテストレビュー完了

#### ポロックシステム (`src/types/pokeblock.mbt`)
- ✅ PokeBlockFlavor enum（Spicy, Dry, Sweet, Bitter, Sour）
- ✅ PokeBlock struct
- ✅ 性格とポロック味の関連付けロジック

#### 開発プロセス改善
- ✅ C#実装結果取得手順の確立（csharp-tests/ディレクトリ）
- ✅ テストコードのセルフレビュー基準明確化
- ✅ 1つずつ実装・確認を取る開発フロー確立
- ✅ 結果ファイル用空ファイル作成を手順書に追加
- ✅ csharp-testsディレクトリの効率的な管理手順確立
- ✅ 開発ワークフロー（fmt/check/test）をCLAUDE.mdに明文化
- ✅ Claude Codeカスタムコマンド（/t-wada, /poyo）追加

#### NatureGenerator群 (`src/nature-generator/`)
- ✅ StandardNatureGenerator（standard.mbt）
- ✅ SynchronizeNatureGenerator（synchronize.mbt）
- ✅ FixedNatureGenerator（fixed.mbt）
- ✅ HoennSafariNatureGenerator（hoenn_safari.mbt）
- ✅ EmSafariNatureGenerator（hoenn_safari.mbt）
- ✅ 不変版・可変版の両方対応
- ✅ C#実装結果を用いた互換性テスト追加
- ✅ t-wada TDD基準でテストレビュー完了
- ✅ PokeBlock味分類のC#動的ロジック互換性確保
- ✅ HoennSafariとEmSafariのファイル統合

#### 重要な修正事項
- ✅ PokeBlockの味分類をC#実装の動的計算ロジックに合わせて修正
- ✅ 無補正性格（Hardy, Docile, Serious, Bashful, Quirky）は一切の味を好まない仕様を完全実装
- ✅ シャッフル関数の独立化とテスト可能性向上
- ✅ テストファーストでの品質保証
- ✅ 理論上起きない状況をpanicに変更
- ✅ デバッグファイル削除とコード品質改善

#### GenderGenerator群 (`src/gender-generator/`)
- ✅ NullGenderGenerator（null.mbt）
- ✅ FixedGenderGenerator（fixed.mbt）
- ✅ CuteCharmGenderGenerator（cute_charm.mbt）
- ✅ 不変版・可変版の両方対応
- ✅ Gender型にreverse()メソッド追加（メロメロボディ用）
- ✅ C#実装結果を用いた互換性テスト追加
- ✅ t-wada TDD基準でテストレビュー完了

#### PIDモジュール (`src/pid/`)
- ✅ PID分析・抽出機能（pid.mbt）
- ✅ 性格抽出（get_nature_from_pid）
- ✅ 性別抽出（get_gender_from_pid）
- ✅ 色違い判定（get_shiny_type, is_shiny）
- ✅ 条件付きPID生成（generate_pid_with_conditions）
- ✅ 基本PID生成（generate_basic_pid）
- ✅ 新しい型定義（GenderRatio, ShinyType）
- ✅ 包括的テストスイート（90テスト全通過）

#### EncounterSlot群 (`src/encounter-slot/`)
- ✅ エンカウント判定基本型定義（types.mbt）
- ✅ RSEEncounterDrawer実装（encounter_drawer.mbt）
- ✅ FRLGEncounterDrawer実装（encounter_drawer.mbt）
- ✅ ForceEncounterDrawer実装（encounter_drawer.mbt）
- ✅ スロット選択システム実装（slot_generator.mbt）
- ✅ 特殊スロット生成器実装（special_slot_generator.mbt）
- ✅ C#実装結果を用いた互換性テスト
- ✅ t-wada TDD基準でのテストレビュー・修正完了
- ✅ Flute型の正しい設計修正（Option型使用）
- ✅ 意味のないテストの削除とテスト品質向上

#### WildGenerator群 (`src/wild-generator/`)
- ✅ オーケストレーション関数実装（orchestration.mbt）
- ✅ 野生ポケモン生成システム統合
- ✅ 関数型アプローチによる設計
- ✅ 不変版から可変版へのアダプタ関数

### 現在の状況
全主要モジュール実装完了：IVsGenerator群（5種類）、NatureGenerator群（5種類）、LevelGenerator群（3種類）、GenderGenerator群（3種類）、PIDモジュール、EncounterSlot群、WildGeneratorオーケストレーション。基本的な実装とテストは完了。

### 次のステップ
1. **最高優先度**: slot_generatorのcreate_test_slots関数とテストを修正（偽陽性テストの解消）
2. **高優先度**: 統合テストの拡充
3. **中優先度**: ドキュメント整備
4. **将来の改善**: GBASlotにポケモンタイプ情報を追加し、Attract系特性用のスロットフィルタリング機能を実装
