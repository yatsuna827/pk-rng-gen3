///|
fn main {
  let lcg = @lcg32.Lcg32(0xbeefface)
  let dex = @pokedex.Pokedex::new()
  let g = @orchestration.static_symbol(
    slot=@slot.GBASlot::new(
      dex.find_pokemon("ラティオス").unwrap(),
      50,
      50,
    ),
    ivs_fn=@ivs.standard,
  )
  let result = g(lcg.to_ref())
  println(result)
}
