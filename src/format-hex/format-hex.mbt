///|
fn hex_digit(d : Int) -> Char {
  if d < 10 {
    Int::unsafe_to_char('0'.to_int() + d)
  } else {
    Int::unsafe_to_char('a'.to_int() + (d - 10))
  }
}

///|
pub fn to_hex(num : UInt) -> String {
  if num == 0 {
    return "0"
  }
  let str = loop (num, "") {
    (0, acc) => break acc
    (n, acc) =>
      continue (n >> 4, [hex_digit((n & 0xF).reinterpret_as_int()), ..acc])
  }
  str
}

///|
test "to_hex" {
  assert_eq(to_hex(0), "0")
  assert_eq(to_hex(0xFFFFFFFF), "ffffffff")
  assert_eq(to_hex(0x12345678), "12345678")
  assert_eq(to_hex(0xABCDEF), "abcdef")
}
