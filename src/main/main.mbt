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
  for s in lcg.iter().take(10) {
    println(g(s.to_ref()).ivs)
  }
}
