///|
pub(all) enum PokeType {
  Normal
  Fire
  Water
  Grass
  Electric
  Ice
  Fighting
  Poison
  Ground
  Flying
  Psychic
  Bug
  Rock
  Ghost
  Dragon
  Dark
  Steel
} derive(Show, Eq)

///|
pub impl @json.FromJson for PokeType with from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError((path, "expected string"))
  }
  match s {
    "normal" | "NORMAL" | "Normal" | "ノーマル" => Normal
    "fire" | "FIRE" | "Fire" | "ほのお" => Fire
    "water" | "WATER" | "Water" | "みず" => Water
    "grass" | "GRASS" | "Grass" | "くさ" => Grass
    "electric" | "ELECTRIC" | "Electric" | "でんき" => Electric
    "ice" | "ICE" | "Ice" | "こおり" => Ice
    "fighting" | "FIGHTING" | "Fighting" | "かくとう" => Fighting
    "poison" | "POISON" | "Poison" | "どく" => Poison
    "ground" | "GROUND" | "Ground" | "じめん" => Ground
    "flying" | "FLYING" | "Flying" | "ひこう" => Flying
    "psychic" | "PSYCHIC" | "Psychic" | "エスパー" => Psychic
    "bug" | "BUG" | "Bug" | "むし" => Bug
    "rock" | "ROCK" | "Rock" | "いわ" => Rock
    "ghost" | "GHOST" | "Ghost" | "ゴースト" => Ghost
    "dragon" | "DRAGON" | "Dragon" | "ドラゴン" => Dragon
    "dark" | "DARK" | "Dark" | "あく" => Dark
    "steel" | "STEEL" | "Steel" | "はがね" => Steel
    _ => raise @json.JsonDecodeError((path, "expected valid poke type name"))
  }
}

///|
pub impl ToJson for PokeType with to_json(self) {
  match self {
    Normal => Json::string("normal")
    Fire => Json::string("fire")
    Water => Json::string("water")
    Grass => Json::string("grass")
    Electric => Json::string("electric")
    Ice => Json::string("ice")
    Fighting => Json::string("fighting")
    Poison => Json::string("poison")
    Ground => Json::string("ground")
    Flying => Json::string("flying")
    Psychic => Json::string("psychic")
    Bug => Json::string("bug")
    Rock => Json::string("rock")
    Ghost => Json::string("ghost")
    Dragon => Json::string("dragon")
    Dark => Json::string("dark")
    Steel => Json::string("steel")
  }
}

///|
test "ToJson should convert poke type to lowercase string" {
  let poke_type = Fire
  let json = poke_type.to_json()
  assert_eq(json, Json::string("fire"))
}

///|
test "FromJson should parse lowercase poke type names" {
  let json = Json::string("fire")
  let poke_type = (@json.from_json(json) : PokeType)
  assert_eq(poke_type, Fire)
}

///|
test "FromJson should parse uppercase poke type names" {
  let json = Json::string("FIRE")
  let poke_type = (@json.from_json(json) : PokeType)
  assert_eq(poke_type, Fire)
}

///|
test "FromJson should parse title case poke type names" {
  let json = Json::string("Fire")
  let poke_type = (@json.from_json(json) : PokeType)
  assert_eq(poke_type, Fire)
}

///|
test "FromJson should parse Japanese poke type names" {
  let json = Json::string("ほのお")
  let poke_type = (@json.from_json(json) : PokeType)
  assert_eq(poke_type, Fire)
}
