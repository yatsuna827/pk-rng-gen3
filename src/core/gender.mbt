///| 性別
pub(all) enum Gender {
  Male
  Female
  Genderless
} derive(Eq, Show)

///| 性別の逆転（メロメロボディ用）
pub fn reverse(self : Gender) -> Gender {
  match self {
    Male => Female
    Female => Male
    Genderless => Genderless
  }
}
