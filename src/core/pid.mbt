///|
pub(all) type PID UInt derive(Eq, Show)

///|
pub fn PID::to_nature(self : PID) -> Nature {
  Nature::from_uint(self.inner() % 25)
}

///|
test "PID to_nature should return correct nature" {
  assert_eq(PID(0U).to_nature(), Nature::Hardy)
  assert_eq(PID(1U).to_nature(), Nature::Lonely)
  assert_eq(PID(24U).to_nature(), Nature::Quirky)
  assert_eq(PID(25U).to_nature(), Nature::Hardy)
  assert_eq(PID(0x12345678).to_nature(), Nature::Gentle)
  assert_eq(PID(0xBEEFCAFE).to_nature(), Nature::Timid)
}

///|
pub fn PID::to_gender(self : PID, ratio : GenderRatio) -> Gender {
  match ratio {
    Genderless => Genderless
    MaleOnly => Male
    FemaleOnly => Female
    _ => if (self.inner() & 0xFFU) < ratio.threshold() { Female } else { Male }
  }
}

///|
test "get_gender_from_pid should extract correct gender" {
  // Male only
  assert_eq(PID(0).to_gender(GenderRatio::MaleOnly), Male)
  assert_eq(PID(0xFF).to_gender(GenderRatio::MaleOnly), Male)

  // Female only  
  assert_eq(PID(0U).to_gender(GenderRatio::FemaleOnly), Female)
  assert_eq(PID(0xFF).to_gender(GenderRatio::FemaleOnly), Female)

  // Genderless
  assert_eq(PID(0U).to_gender(GenderRatio::Genderless), Gender::Genderless)

  // 50:50 ratio (127)
  assert_eq(PID(0x0).to_gender(GenderRatio::Male1Female1), Female)
  assert_eq(PID(0x7E).to_gender(GenderRatio::Male1Female1), Female)
  assert_eq(PID(0x7F).to_gender(GenderRatio::Male1Female1), Male)
  assert_eq(PID(0xFF).to_gender(GenderRatio::Male1Female1), Male)
}

///| 
pub fn PID::to_shiny_type(self : PID, tsv : UInt) -> ShinyType {
  let sv = (self.inner() & 0xFFFFU) ^ (self.inner() >> 16) ^ tsv
  match sv {
    0U => Square
    sv if sv < 8U => Star
    _ => NotShiny
  }
}

///| 
pub fn PID::is_shiny(self : PID, tsv : UInt) -> Bool {
  self.to_shiny_type(tsv) != NotShiny
}

///|
test "get_shiny_type should determine shiny correctly" {
  let pid = PID(0x12345678U)

  // 1234 ^ 5678 = 0x444C
  assert_eq(pid.to_shiny_type(0x444C), Square)

  // 0x444C ^ 7 = 0x444B
  assert_eq(pid.to_shiny_type(0x444B), Star)

  // 0x444C ^ 8 = 0x4444
  assert_eq(pid.to_shiny_type(0x4444), NotShiny)
}

///|
test "is_shiny should detect shiny correctly" {
  let pid = PID(0x12345678U)
  assert_eq(pid.is_shiny(0x444C), true)
  assert_eq(pid.is_shiny(0x4444), false)
}
