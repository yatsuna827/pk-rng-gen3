///|
pub(all) type Lcg32 UInt

///|
const MUL_CONST : UInt = 0x41c64e6d

///|
const ADD_CONST : UInt = 0x6073

///|
const REV_MUL_CONST : UInt = 0xEEB9EB65

///|
const REV_ADD_CONST : UInt = 0xA3561A1

///|
pub fn Lcg32::next(self : Lcg32) -> Lcg32 {
  self.inner() * MUL_CONST + ADD_CONST
}

///|
pub fn Lcg32::prev(self : Lcg32) -> Lcg32 {
  self.inner() * REV_MUL_CONST + REV_ADD_CONST
}

///|
priv struct Booster {
  a_t : Array[UInt]
  b_t : Array[UInt]
  ar_t : Array[UInt]
  br_t : Array[UInt]
}

///|
let cache : Ref[Booster?] = Ref::new(None)

///|
fn setup() -> Booster {
  let a_t : Array[UInt] = Array::new(capacity=32)
  let b_t : Array[UInt] = Array::new(capacity=32)
  let ar_t : Array[UInt] = Array::new(capacity=32)
  let br_t : Array[UInt] = Array::new(capacity=32)
  let one : UInt = 1
  a_t.push(MUL_CONST)
  b_t.push(ADD_CONST)
  ar_t.push(REV_MUL_CONST)
  br_t.push(REV_ADD_CONST)
  for i = 1; i < 32; i = i + 1 {
    a_t.push(a_t[i - 1] * a_t[i - 1])
    b_t.push(b_t[i - 1] * (one + a_t[i - 1]))
    ar_t.push(ar_t[i - 1] * ar_t[i - 1])
    br_t.push(br_t[i - 1] * (one + ar_t[i - 1]))
  }
  let booster = { a_t, b_t, ar_t, br_t }
  cache.val = Some(booster)
  booster
}

///|
pub fn Lcg32::jump(self : Lcg32, n : UInt) -> Lcg32 {
  let mut seed = self.inner()
  let { a_t, b_t, .. } = cache.val.unwrap_or_else(setup)
  let mut i = 0
  let mut n = n
  while n > 0 {
    if (n & 1) == 1 {
      seed = seed * a_t[i] + b_t[i]
    }
    i = i + 1
    n = n >> 1
  }
  Lcg32(seed)
}

///|
pub fn Lcg32::jump_back(self : Lcg32, n : UInt) -> Lcg32 {
  let mut seed = self.inner()
  let { ar_t, br_t, .. } = cache.val.unwrap_or_else(setup)
  let mut i = 0
  let mut n = n
  while n > 0 {
    if (n & 1) == 1 {
      seed = seed * ar_t[i] + br_t[i]
    }
    i = i + 1
    n = n >> 1
  }
  Lcg32(seed)
}

///|
pub fn Lcg32::iter(self : Lcg32) -> Iter[Lcg32] {
  let lcg = self.to_ref()
  Iter::new(visit => while true {
    guard visit(lcg.val) is IterContinue else { break IterEnd }
    lcg.advance()
  } else {
    IterEnd
  })
}

///|
pub fn Lcg32::to_string(self : Lcg32) -> String {
  self.inner().to_string(radix=16).to_upper().pad_start(8, '0')
}

///|
test "lcg32 string" {
  inspect(Lcg32(0).to_string(), content="00000000")
  inspect(Lcg32(0xFFFFFFFF).to_string(), content="FFFFFFFF")
  inspect(Lcg32(0xCAFFEE).to_string(), content="00CAFFEE")
}

///|
fn get_index_from_zero(seed : UInt) -> UInt {
  let mut a = MUL_CONST
  let mut b = ADD_CONST
  let mut result : UInt = 0
  let mut seed = seed * a + b
  let mut mask : UInt = 1
  for i = 0; i < 32; i = i + 1 {
    if (seed & mask) == 0 {
      result = result | mask
    } else {
      seed = seed * a + b
    }
    b = (a + 1) * b
    a = a * a
    mask = mask << 1
  }
  result
}

///|
fn get_index_from_base(seed : UInt, from : UInt) -> UInt {
  let mut a = MUL_CONST
  let mut b = ADD_CONST
  let mut result : UInt = 0
  let mut seed = seed * a + b
  let mut mask : UInt = 1
  for i = 0; i < 32; i = i + 1 {
    if ((seed ^ from) & mask) == 0 {
      result = result | mask
    } else {
      seed = seed * a + b
    }
    b = (a + 1) * b
    a = a * a
    mask = mask << 1
  }
  result
}

///|
pub fn Lcg32::get_index(self : Lcg32, from~ : UInt = 0) -> UInt {
  if from == 0 {
    get_index_from_zero(self.inner())
  } else {
    get_index_from_base(self.inner(), from)
  }
}

///|
test "jump" {
  let lcg = Lcg32(0x08270827)
  assert_eq(lcg.next().next().next().inner(), lcg.jump(3).inner())
  assert_eq(lcg.prev().prev().prev().inner(), lcg.jump_back(3).inner())
}

///|
test "prev" {
  let lcg = Lcg32(0xBEEFFACE)
  assert_eq(lcg.next().prev().inner(), lcg.inner())
  assert_eq(lcg.prev().next().inner(), lcg.inner())
}
