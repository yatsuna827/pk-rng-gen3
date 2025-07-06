///|
fn shuffle(lcg_ref : @lcg32.Lcg32Ref) -> Array[@types.Nature] {
  let list = Array::makei(25, i => @types.Nature::from_value(
    i.reinterpret_as_uint(),
  ))
  for i = 0; i < 25; i = i + 1 {
    for j = i + 1; j < 25; j = j + 1 {
      let swap_check = lcg_ref.get_rand(m=2)
      if swap_check == 1 {
        list.swap(i, j)
      }
    }
  }
  list
}

///|
test "consumes exactly 300 RNG calls during nature shuffling" {
  let initial_seed = 0x00000000U
  let lcg_ref = @lcg32.Lcg32(initial_seed).to_ref()
  let _ = shuffle(lcg_ref)
  assert_eq(lcg_ref.get_index(from=initial_seed), 300)
}

///|
test "preserves all 25 nature values during shuffling process" {
  let lcg_ref = @lcg32.Lcg32(0x00000000U).to_ref()
  let list = shuffle(lcg_ref)
  for i = 0U; i < 25; i = i + 1 {
    assert_eq(list.contains(@types.Nature::from_value(i)), true)
  }
}
