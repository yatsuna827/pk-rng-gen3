///| 性別比
pub(all) enum GenderRatio {
  MaleOnly
  Male7Female1
  Male3Female1
  Male1Female1
  Male1Female3
  Male1Female7
  FemaleOnly
  Genderless
} derive(Eq, Show)

///|
pub impl ToJson for GenderRatio with to_json(self) {
  match self {
    MaleOnly => Json::string("M")
    Male7Female1 => Json::string("M7F1")
    Male3Female1 => Json::string("M3F1")
    Male1Female1 => Json::string("M1F1")
    Male1Female3 => Json::string("M1F3")
    Male1Female7 => Json::string("M1F7")
    FemaleOnly => Json::string("F")
    Genderless => Json::string("-")
  }
}

///|
pub impl @json.FromJson for GenderRatio with from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError((path, "expected string"))
  }
  match s {
    "M" | "maleonly" => MaleOnly
    "M7F1" => Male7Female1
    "M3F1" => Male3Female1
    "M1F1" => Male1Female1
    "M1F3" => Male1Female3
    "M1F7" => Male1Female7
    "F" | "femaleonly" => FemaleOnly
    "-" | "genderless" => Genderless
    _ => raise @json.JsonDecodeError((path, "expected valid gender ratio"))
  }
}

///|
test "ToJson should convert gender ratio to M1F1 format" {
  let ratio = Male1Female1
  let json = ratio.to_json()
  assert_eq(json, Json::string("M1F1"))
}

///|
test "ToJson should convert MaleOnly to M" {
  let ratio = MaleOnly
  let json = ratio.to_json()
  assert_eq(json, Json::string("M"))
}

///|
test "ToJson should convert FemaleOnly to F" {
  let ratio = FemaleOnly
  let json = ratio.to_json()
  assert_eq(json, Json::string("F"))
}

///|
test "ToJson should convert Genderless to -" {
  let ratio = GenderRatio::Genderless
  let json = ratio.to_json()
  assert_eq(json, Json::string("-"))
}

///|
test "FromJson should parse M1F1 format" {
  let json = Json::string("M1F1")
  let ratio = (@json.from_json(json) : GenderRatio)
  assert_eq(ratio, Male1Female1)
}

///|
test "FromJson should parse special cases" {
  let json_male = Json::string("M")
  let ratio_male = (@json.from_json(json_male) : GenderRatio)
  assert_eq(ratio_male, MaleOnly)
  let json_female = Json::string("F")
  let ratio_female = (@json.from_json(json_female) : GenderRatio)
  assert_eq(ratio_female, FemaleOnly)
  let json_genderless = Json::string("-")
  let ratio_genderless = (@json.from_json(json_genderless) : GenderRatio)
  assert_eq(ratio_genderless, Genderless)
}

///|
test "FromJson should parse alternative formats" {
  let json_maleonly = Json::string("maleonly")
  let ratio_maleonly = (@json.from_json(json_maleonly) : GenderRatio)
  assert_eq(ratio_maleonly, MaleOnly)
  let json_femaleonly = Json::string("femaleonly")
  let ratio_femaleonly = (@json.from_json(json_femaleonly) : GenderRatio)
  assert_eq(ratio_femaleonly, FemaleOnly)
  let json_genderless_alt = Json::string("genderless")
  let ratio_genderless_alt = (@json.from_json(json_genderless_alt) : GenderRatio)
  assert_eq(ratio_genderless_alt, Genderless)
}

///| 
pub fn threshold(self : GenderRatio) -> UInt {
  match self {
    MaleOnly => 0
    Male7Female1 => 0x1F
    Male3Female1 => 0x3F
    Male1Female1 => 0x7F
    Male1Female3 => 0xBF
    Male1Female7 => 0xE1
    FemaleOnly => 0x100
    Genderless => 0x12C
  }
}
