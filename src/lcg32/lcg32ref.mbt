///|
pub(all) type Lcg32Ref Ref[Lcg32]

///|
pub fn Lcg32::to_ref(self : Lcg32) -> Lcg32Ref {
  Lcg32Ref(Ref::new(self))
}

///|
pub fn Lcg32Ref::advance(self : Lcg32Ref, n~ : UInt = 1) -> Unit {
  match n {
    0 => Unit::default()
    1 => self.inner().update(Lcg32::next)
    n => self.inner().update(fn(lcg) { lcg.jump(n) })
  }
}

///|
pub fn Lcg32Ref::back(self : Lcg32Ref, n~ : UInt = 1) -> Unit {
  match n {
    0 => Unit::default()
    1 => self.inner().update(Lcg32::prev)
    n => self.inner().update(fn(lcg) { lcg.jump_back(n) })
  }
}

///|
pub fn Lcg32Ref::seed(self : Lcg32Ref) -> UInt {
  self.inner().val.inner()
}

///|
pub fn Lcg32Ref::to_string(self : Lcg32Ref) -> String {
  self.inner().val.to_string()
}

///|
pub fn Lcg32Ref::get_rand(self : Lcg32Ref, m? : UInt) -> UInt {
  match m {
    None => self..advance().inner().val.inner() >> 16
    Some(n) => (self..advance().inner().val.inner() >> 16) % n
  }
}

///|
pub fn Lcg32Ref::get_rand_f(self : Lcg32Ref) -> Float {
  self.get_rand().to_float() / 65536.0
}

///|
pub fn Lcg32Ref::get_index(self : Lcg32Ref, from~ : UInt = 0) -> UInt {
  self.inner().val.get_index(from~)
}
