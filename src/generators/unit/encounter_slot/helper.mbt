///|
fn Array::cumsum(self : Array[UInt]) -> Array[UInt] {
  let result = []
  let mut sum = 0U
  for i = 0; i < self.length(); i = i + 1 {
    sum = sum + self[i]
    result.push(sum)
  }
  result
}
