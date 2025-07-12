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
pub impl @json.FromJson for Nature with from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError((path, "expected string"))
  }
  match s {
    "hardy" | "HARDY" | "Hardy" | "がんばりや" => Hardy
    "lonely" | "LONELY" | "Lonely" | "さみしがり" => Lonely
    "brave" | "BRAVE" | "Brave" | "ゆうかん" => Brave
    "adamant" | "ADAMANT" | "Adamant" | "いじっぱり" => Adamant
    "naughty" | "NAUGHTY" | "Naughty" | "やんちゃ" => Naughty
    "bold" | "BOLD" | "Bold" | "ずぶとい" => Bold
    "docile" | "DOCILE" | "Docile" | "すなお" => Docile
    "relaxed" | "RELAXED" | "Relaxed" | "のんき" => Relaxed
    "impish" | "IMPISH" | "Impish" | "わんぱく" => Impish
    "lax" | "LAX" | "Lax" | "のうてんき" => Lax
    "timid" | "TIMID" | "Timid" | "おくびょう" => Timid
    "hasty" | "HASTY" | "Hasty" | "せっかち" => Hasty
    "serious" | "SERIOUS" | "Serious" | "まじめ" => Serious
    "jolly" | "JOLLY" | "Jolly" | "ようき" => Jolly
    "naive" | "NAIVE" | "Naive" | "むじゃき" => Naive
    "modest" | "MODEST" | "Modest" | "ひかえめ" => Modest
    "mild" | "MILD" | "Mild" | "おっとり" => Mild
    "quiet" | "QUIET" | "Quiet" | "れいせい" => Quiet
    "bashful" | "BASHFUL" | "Bashful" | "てれや" => Bashful
    "rash" | "RASH" | "Rash" | "うっかりや" => Rash
    "calm" | "CALM" | "Calm" | "おだやか" => Calm
    "gentle" | "GENTLE" | "Gentle" | "おとなしい" => Gentle
    "sassy" | "SASSY" | "Sassy" | "なまいき" => Sassy
    "careful" | "CAREFUL" | "Careful" | "しんちょう" => Careful
    "quirky" | "QUIRKY" | "Quirky" | "きまぐれ" => Quirky
    _ => raise @json.JsonDecodeError((path, "expected valid nature name"))
  }
}

///|
pub impl ToJson for Nature with to_json(self) {
  match self {
    Hardy => Json::string("hardy")
    Lonely => Json::string("lonely")
    Brave => Json::string("brave")
    Adamant => Json::string("adamant")
    Naughty => Json::string("naughty")
    Bold => Json::string("bold")
    Docile => Json::string("docile")
    Relaxed => Json::string("relaxed")
    Impish => Json::string("impish")
    Lax => Json::string("lax")
    Timid => Json::string("timid")
    Hasty => Json::string("hasty")
    Serious => Json::string("serious")
    Jolly => Json::string("jolly")
    Naive => Json::string("naive")
    Modest => Json::string("modest")
    Mild => Json::string("mild")
    Quiet => Json::string("quiet")
    Bashful => Json::string("bashful")
    Rash => Json::string("rash")
    Calm => Json::string("calm")
    Gentle => Json::string("gentle")
    Sassy => Json::string("sassy")
    Careful => Json::string("careful")
    Quirky => Json::string("quirky")
  }
}

///|
pub fn Nature::from_uint(value : UInt) -> Nature {
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

///|
test "ToJson should convert nature to lowercase string" {
  let nature = Hardy
  let json = nature.to_json()
  assert_eq(json, Json::string("hardy"))
}

///|
test "FromJson should parse lowercase nature names" {
  let json = Json::string("hardy")
  let nature = (@json.from_json(json) : Nature)
  assert_eq(nature, Hardy)
}

///|
test "FromJson should parse uppercase nature names" {
  let json = Json::string("HARDY")
  let nature = (@json.from_json(json) : Nature)
  assert_eq(nature, Hardy)
}

///|
test "FromJson should parse Japanese nature names" {
  let json = Json::string("がんばりや")
  let nature = (@json.from_json(json) : Nature)
  assert_eq(nature, Hardy)
}

///|
test "FromJson should parse title case nature names" {
  let json = Json::string("Hardy")
  let nature = (@json.from_json(json) : Nature)
  assert_eq(nature, Hardy)
}
