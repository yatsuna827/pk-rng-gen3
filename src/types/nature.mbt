///| 性格
pub(all) enum Nature {
  Hardy // がんばりや (0)
  Lonely // さみしがり (1)
  Brave // ゆうかん (2)
  Adamant // いじっぱり (3)
  Naughty // やんちゃ (4)
  Bold // ずぶとい (5)
  Docile // すなお (6)
  Relaxed // のんき (7)
  Impish // わんぱく (8)
  Lax // のうてんき (9)
  Timid // おくびょう (10)
  Hasty // せっかち (11)
  Serious // まじめ (12)
  Jolly // ようき (13)
  Naive // むじゃき (14)
  Modest // ひかえめ (15)
  Mild // おっとり (16)
  Quiet // れいせい (17)
  Bashful // てれや (18)
  Rash // うっかりや (19)
  Calm // おだやか (20)
  Gentle // おとなしい (21)
  Sassy // なまいき (22)
  Careful // しんちょう (23)
  Quirky // きまぐれ (24)
} derive(Eq, Show)

///| 整数値からNatureを作成（0-24の範囲）
pub fn Nature::from_value(value : UInt) -> Nature {
  match value {
    0 => Hardy
    1 => Lonely
    2 => Brave
    3 => Adamant
    4 => Naughty
    5 => Bold
    6 => Docile
    7 => Relaxed
    8 => Impish
    9 => Lax
    10 => Timid
    11 => Hasty
    12 => Serious
    13 => Jolly
    14 => Naive
    15 => Modest
    16 => Mild
    17 => Quiet
    18 => Bashful
    19 => Rash
    20 => Calm
    21 => Gentle
    22 => Sassy
    23 => Careful
    24 => Quirky
    _ => panic()
  }
}

///| Natureを整数値に変換（0-24）
pub fn Nature::to_value(self : Nature) -> UInt {
  match self {
    Hardy => 0
    Lonely => 1
    Brave => 2
    Adamant => 3
    Naughty => 4
    Bold => 5
    Docile => 6
    Relaxed => 7
    Impish => 8
    Lax => 9
    Timid => 10
    Hasty => 11
    Serious => 12
    Jolly => 13
    Naive => 14
    Modest => 15
    Mild => 16
    Quiet => 17
    Bashful => 18
    Rash => 19
    Calm => 20
    Gentle => 21
    Sassy => 22
    Careful => 23
    Quirky => 24
  }
}

///| 性格名取得（日本語）
pub fn Nature::name_ja(self : Nature) -> String {
  match self {
    Hardy => "がんばりや"
    Lonely => "さみしがり"
    Brave => "ゆうかん"
    Adamant => "いじっぱり"
    Naughty => "やんちゃ"
    Bold => "ずぶとい"
    Docile => "すなお"
    Relaxed => "のんき"
    Impish => "わんぱく"
    Lax => "のうてんき"
    Timid => "おくびょう"
    Hasty => "せっかち"
    Serious => "まじめ"
    Jolly => "ようき"
    Naive => "むじゃき"
    Modest => "ひかえめ"
    Mild => "おっとり"
    Quiet => "れいせい"
    Bashful => "てれや"
    Rash => "うっかりや"
    Calm => "おだやか"
    Gentle => "おとなしい"
    Sassy => "なまいき"
    Careful => "しんちょう"
    Quirky => "きまぐれ"
  }
}
