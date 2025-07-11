///|
pub struct Pokedex {
  priv name_map : Map[String, @core.Species]
  priv unique_map : Map[String, @core.Species]
  priv forme_map : Map[String, Array[String]]
}

///|
pub fn Pokedex::new() -> Pokedex {
  let name_map = Map::new()
  let unique_map = Map::new()
  let forme_map = Map::new()
  let data = get_pokemon_data()
  for pokemon in data {
    if !name_map.contains(pokemon.name) {
      name_map.set(pokemon.name, pokemon)
    }
    match pokemon.forme {
      Some(forme) => {
        unique_map.set("\{pokemon.name}#\{forme}", pokemon)
        if !forme_map.contains(pokemon.name) {
          forme_map[pokemon.name] = []
        }
        forme_map.get(pokemon.name).unwrap().push(forme)
      }
      None => unique_map.set(pokemon.name, pokemon)
    }
  }
  { name_map, unique_map, forme_map }
}

///|
pub fn Pokedex::find_pokemon(
  self : Pokedex,
  name : String,
  forme~ : String? = None
) -> @core.Species? {
  match forme {
    Some(forme) =>
      if forme == "" {
        self.name_map.get(name)
      } else {
        self.unique_map.get("\{name}#\{forme}")
      }
    None => self.name_map.get(name)
  }
}

///|
pub fn Pokedex::get_unique_pokemon_list(
  self : Pokedex
) -> ArrayView[@core.Species] {
  let arr = self.name_map.values().to_array()
  arr.sort_by_key(p => p.dexNo)
  arr
}

///|
pub fn Pokedex::get_formes(self : Pokedex, name : String) -> Array[String] {
  self.forme_map.get(name).unwrap_or_default()
}

///|
test "pokedex" {
  let dex = Pokedex::new()
  assert_eq(dex.find_pokemon("ヌオー").unwrap().name, "ヌオー")
  let unown_z = dex.find_pokemon("アンノーン", forme=Some("Z")).unwrap()
  assert_eq(unown_z.name, "アンノーン")
  assert_eq(unown_z.forme.unwrap(), "Z")
  assert_eq(dex.get_formes("デオキシス").length(), 4)
}
