let debug_lcg() -> Unit {
  let lcg = @lcg32.Lcg32(0x00000001U)
  let next1 = lcg.next()
  println("LCG(0x00000001).next() = 0x" + @format-hex.to_hex(next1.inner()))
  println("HAB = " + @format-hex.to_hex(next1.inner() >> 16))
  
  let next2 = next1.next()
  println("LCG(" + @format-hex.to_hex(next1.inner()) + ").next() = 0x" + @format-hex.to_hex(next2.inner()))
  println("SCD = " + @format-hex.to_hex(next2.inner() >> 16))
}