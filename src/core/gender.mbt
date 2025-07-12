///|
pub(all) enum Gender {
  Male
  Female
  Genderless
} derive(Eq, Show)

///|
pub fn reverse(self : Gender) -> Gender {
  match self {
    Male => Female
    Female => Male
    Genderless => Genderless
  }
}
