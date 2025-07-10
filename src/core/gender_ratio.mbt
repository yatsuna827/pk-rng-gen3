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
