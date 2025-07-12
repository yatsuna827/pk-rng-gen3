///|
pub(all) enum Gender {
  Male
  Female
  Genderless
} derive(Eq, Show)

///|
pub impl ToJson for Gender with to_json(self) {
  match self {
    Male => Json::string("♂")
    Female => Json::string("♀")
    Genderless => Json::string("-")
  }
}

///|
pub impl @json.FromJson for Gender with from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError((path, "expected string"))
  }
  match s {
    "♂" | "M" => Male
    "♀" | "F" => Female
    "-" => Gender::Genderless
    _ => raise @json.JsonDecodeError((path, "expected valid gender symbol"))
  }
}

///|
test "ToJson" {
  let test_cases = [
    (Gender::Male, Json::string("♂")),
    (Gender::Female, Json::string("♀")),
    (Gender::Genderless, Json::string("-")),
  ]
  for test_case in test_cases {
    let (gender, expected) = test_case
    let json = gender.to_json()
    assert_eq(json, expected)
  }
}

///|
test "FromJson" {
  let test_cases = [
    (Json::string("♂"), Gender::Male),
    (Json::string("♀"), Gender::Female),
    (Json::string("-"), Gender::Genderless),
  ]
  for test_case in test_cases {
    let (json, expected) = test_case
    let gender = (@json.from_json(json) : Gender)
    assert_eq(gender, expected)
  }
}

///|
test "FromJson alternative" {
  let test_cases = [
    (Json::string("M"), Gender::Male),
    (Json::string("F"), Gender::Female),
  ]
  for test_case in test_cases {
    let (json, expected) = test_case
    let gender = (@json.from_json(json) : Gender)
    assert_eq(gender, expected)
  }
}

///|
pub fn reverse(self : Gender) -> Gender {
  match self {
    Male => Female
    Female => Male
    Genderless => Genderless
  }
}
