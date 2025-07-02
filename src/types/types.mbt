///| 個体値（6つの値：H, A, B, C, D, S）
pub(all) type IVs Array[UInt]

///| 性格（0-24の値）
pub(all) type Nature UInt

///| 性別
pub(all) enum Gender {
  Male
  Female
  Genderless
}

///| 生成結果
pub(all) struct PokemonResult {
  ivs : IVs
  nature : Nature
  gender : Gender
  pid : UInt
  level : UInt
  recalc_count : UInt
}

///| IVs作成
pub fn IVs::new(
  h : UInt,
  a : UInt,
  b : UInt,
  c : UInt,
  d : UInt,
  s : UInt
) -> IVs {
  IVs([h, a, b, c, d, s])
}

///| IVs取得
pub fn IVs::get(self : IVs, index : Int) -> UInt {
  self.inner()[index]
}

///| H（HP）個体値
pub fn IVs::h(self : IVs) -> UInt {
  self.get(0)
}

///| A（攻撃）個体値
pub fn IVs::a(self : IVs) -> UInt {
  self.get(1)
}

///| B（防御）個体値
pub fn IVs::b(self : IVs) -> UInt {
  self.get(2)
}

///| C（特攻）個体値
pub fn IVs::c(self : IVs) -> UInt {
  self.get(3)
}

///| D（特防）個体値
pub fn IVs::d(self : IVs) -> UInt {
  self.get(4)
}

///| S（素早さ）個体値
pub fn IVs::s(self : IVs) -> UInt {
  self.get(5)
}

///| Nature作成
pub fn Nature::new(value : UInt) -> Nature {
  Nature(value % 25)
}

///| Nature値取得
pub fn Nature::value(self : Nature) -> UInt {
  self.inner()
}

///| 性格名取得（デバッグ用）
pub fn Nature::name(self : Nature) -> String {
  match self.value() {
    0 => "がんばりや"
    1 => "さみしがり"
    2 => "ゆうかん"
    3 => "いじっぱり"
    4 => "やんちゃ"
    5 => "ずぶとい"
    6 => "すなお"
    7 => "のんき"
    8 => "わんぱく"
    9 => "のうてんき"
    10 => "おくびょう"
    11 => "せっかち"
    12 => "まじめ"
    13 => "ようき"
    14 => "むじゃき"
    15 => "ひかえめ"
    16 => "おっとり"
    17 => "れいせい"
    18 => "てれや"
    19 => "うっかりや"
    20 => "おだやか"
    21 => "おとなしい"
    22 => "なまいき"
    23 => "しんちょう"
    24 => "きまぐれ"
    _ => "不明"
  }
}
