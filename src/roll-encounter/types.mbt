///| ビードロ
pub(all) enum Flute {
  White
  Black
} derive(Eq, Show)

///|
pub struct EncounterOption {
  riding_bicycle : Bool
  flute : Flute?
  has_cleanse_tag : Bool
}

///|
pub fn EncounterOption::new(
  riding_bicycle~ : Bool = false,
  has_cleanse_tag~ : Bool = false,
  flute~ : Flute? = None
) -> EncounterOption {
  { riding_bicycle, flute, has_cleanse_tag }
}

///|
pub typealias (@lcg32.Lcg32) -> Bool as RollEncounterImmut

///|
pub typealias (@lcg32.Lcg32Ref) -> Bool as RollEncounterMut
