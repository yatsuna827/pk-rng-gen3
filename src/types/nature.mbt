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
pub fn Nature::from_value(value : UInt) -> Nature? {
  match value {
    0 => Some(Hardy)
    1 => Some(Lonely)
    2 => Some(Brave)
    3 => Some(Adamant)
    4 => Some(Naughty)
    5 => Some(Bold)
    6 => Some(Docile)
    7 => Some(Relaxed)
    8 => Some(Impish)
    9 => Some(Lax)
    10 => Some(Timid)
    11 => Some(Hasty)
    12 => Some(Serious)
    13 => Some(Jolly)
    14 => Some(Naive)
    15 => Some(Modest)
    16 => Some(Mild)
    17 => Some(Quiet)
    18 => Some(Bashful)
    19 => Some(Rash)
    20 => Some(Calm)
    21 => Some(Gentle)
    22 => Some(Sassy)
    23 => Some(Careful)
    24 => Some(Quirky)
    _ => None
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
