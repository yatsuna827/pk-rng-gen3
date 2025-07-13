///| 
pub fn static_symbol(
  slot~ : @encounter_slot.GBASlot,
  ivs_fn~ : @core.GeneratorMut[@core.IVs]
) -> @core.GeneratorMut[@core.Individual] {
  lcg_ref => {
    let level = slot.min_level
    let pid = @pid.generate_pid(lcg_ref)
    let ivs = ivs_fn(lcg_ref)
    slot.pokemon.individual(level, pid.inner(), ivs)
  }
}
