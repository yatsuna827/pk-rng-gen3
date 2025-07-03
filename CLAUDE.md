# CLAUDE.md

- 絵文字は使用禁止
- t-wadaの推奨する方法でTDDを実践すること
- テストは実装と同じファイルに書くこと
- タスク完了前に必ずフォーマットとテストを実行すること
- C#実装の実行結果が必要な場合は、リストにまとめてユーザーに依頼すること
- 後方互換性のためと言って古いコードを残してはいけない

## C#実装の結果取得手順

MoonBitテストの期待値として元のC#実装の結果が必要な場合：

1. `csharp-tests/`ディレクトリにテストスクリプト（.csx）を作成
2. 結果ファイル用の空ファイル（`<script_name>_result.txt`）を作成
3. ユーザーに以下の手順で実行を依頼：
   ```bash
   cd original/Pokemon3genRNGLirary
   dotnet build
   cd ../csharp-tests
   dotnet script <script_name>.csx > <script_name>_result.txt
   ```
4. ユーザーが`<script_name>_result.txt`の内容を提供
5. 出力結果をMoonBitテストの期待値として使用
6. 使用後はスクリプトと結果ファイルを削除

## プロジェクト概要

これは`Pokemon3genRNGLibrary`のMoonBit移植版です。元のC#ライブラリはポケモン第3世代の乱数生成を行うライブラリです。このプロジェクトは、ポケモンルビー・サファイア・エメラルド・ファイアレッド・リーフグリーンで使用される野生ポケモンエンカウント、個体値、性格、その他のゲームプレイメカニクスを生成するRNGアルゴリズムを実装しています。

**オリジナル実装**: `original/` ディレクトリに元のC#実装が含まれています。移植作業時の参考として使用してください。

## ビルドコマンド

- `moon build` - プロジェクトをビルド
- `moon test` - 全テストを実行
- `moon check` - ビルドなしで型チェック
- `moon fmt` - ソースコードをフォーマット
- `moon clean` - targetディレクトリを削除
- `moon run` - メインパッケージを実行
