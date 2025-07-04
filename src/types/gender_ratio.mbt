///| 性別比
pub(all) enum GenderRatio {
  MaleOnly // 0 (0%♀)
  Male7Female1 // 31 (12.5%♀) 
  Male3Female1 // 63 (25%♀)
  Male1Female1 // 127 (50%♀)
  Male1Female3 // 191 (75%♀)
  Male1Female7 // 225 (87.5%♀)
  FemaleOnly // 254 (100%♀)
  Genderless // 255 (性別不明)
} derive(Eq, Show)

///| 性別比の数値を取得
pub fn value(self : GenderRatio) -> UInt {
  match self {
    MaleOnly => 0U
    Male7Female1 => 31U
    Male3Female1 => 63U
    Male1Female1 => 127U
    Male1Female3 => 191U
    Male1Female7 => 225U
    FemaleOnly => 254U
    Genderless => 255U
  }
}
