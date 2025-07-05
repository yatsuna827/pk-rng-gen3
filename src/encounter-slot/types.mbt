///| ビードロ
pub enum Flute {
  White
  Black
} derive(Eq, Show)

///|
struct GBASlot {
  pokemon_id : Int
  min_level : Int
  max_level : Int
} derive(Eq, Show)

///|
pub struct EncounterConfig {
  base_encounter_rate : UInt
  riding_bicycle : Bool
  flute : Flute?
  has_cleanse_tag : Bool
}
