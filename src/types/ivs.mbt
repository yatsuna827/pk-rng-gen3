///| 個体値（6つの値：H, A, B, C, D, S）
pub(all) type IVs Array[UInt]

///| IVs作成
pub fn IVs::new(
  h : UInt,
  a : UInt,
  b : UInt,
  c : UInt,
  d : UInt,
  s : UInt
) -> IVs {
  IVs([h, a, b, c, d, s])
}

///| IVs取得
pub fn IVs::get(self : IVs, index : Int) -> UInt {
  self.inner()[index]
}

///| H（HP）個体値
pub fn IVs::h(self : IVs) -> UInt {
  self.get(0)
}

///| A（攻撃）個体値
pub fn IVs::a(self : IVs) -> UInt {
  self.get(1)
}

///| B（防御）個体値
pub fn IVs::b(self : IVs) -> UInt {
  self.get(2)
}

///| C（特攻）個体値
pub fn IVs::c(self : IVs) -> UInt {
  self.get(3)
}

///| D（特防）個体値
pub fn IVs::d(self : IVs) -> UInt {
  self.get(4)
}

///| S（素早さ）個体値
pub fn IVs::s(self : IVs) -> UInt {
  self.get(5)
}
