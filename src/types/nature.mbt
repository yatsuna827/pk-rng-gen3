///|
pub(all) enum Nature {
  Hardy
  Lonely
  Brave
  Adamant
  Naughty
  Bold
  Docile
  Relaxed
  Impish
  Lax
  Timid
  Hasty
  Serious
  Jolly
  Naive
  Modest
  Mild
  Quiet
  Bashful
  Rash
  Calm
  Gentle
  Sassy
  Careful
  Quirky
} derive(Eq, Show)

///|
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

///|
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
