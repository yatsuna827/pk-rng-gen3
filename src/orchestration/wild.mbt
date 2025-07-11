///| 
pub fn wild_pokemon(
  encounter_fn~ : @core.GeneratorMut[Bool],
  slot_fn~ : @core.GeneratorMut[@encounter_slot.GBASlot],
  level_fn~ : (@lcg32.Lcg32Ref, UInt, UInt) -> UInt,
  ivs_fn~ : @core.GeneratorMut[@core.IVs],
  nature_fn~ : @core.GeneratorMut[@core.Nature],
  gender_fn~ : @core.GeneratorMut[@core.Gender]? = None
) -> @core.GeneratorMut[(@core.Individual, UInt)?] {
  lcg_ref => {
    if not(encounter_fn(lcg_ref)) {
      return None
    }
    let slot = slot_fn(lcg_ref)
    let level = level_fn(lcg_ref, slot.min_level, slot.variable_lv())
    let gender = gender_fn.map(f => f(lcg_ref))
    let nature = nature_fn(lcg_ref)
    let (pid, recalc_count) = @pid.generate_pid_with_conditions(
      lcg_ref,
      Some(nature),
      gender,
      slot.pokemon.gender_ratio,
    )
    let ivs = ivs_fn(lcg_ref)
    Some((slot.pokemon.individual(level, pid.inner(), ivs), recalc_count))
  }
}

///|
test "wild pokemon generation matches C# implementation" {
  // Em Route110
  let oddish = @core.Species::dummy(43, (@core.Grass, Some(@core.Poison)))
  let poochyena = @core.Species::dummy(261, (@core.Dark, None))
  let windgull = @core.Species::dummy(278, (@core.Water, Some(@core.Flying)))
  let electrike = @core.Species::dummy(309, (@core.Electric, None))
  let plusle = @core.Species::dummy(311, (@core.Electric, None))
  let minun = @core.Species::dummy(312, (@core.Electric, None))
  let gulpin = @core.Species::dummy(316, (@core.Poison, None))
  let slots = [
    @encounter_slot.GBASlot::new(poochyena, 12, 12),
    @encounter_slot.GBASlot::new(electrike, 12, 12),
    @encounter_slot.GBASlot::new(gulpin, 12, 12),
    @encounter_slot.GBASlot::new(electrike, 13, 13),
    @encounter_slot.GBASlot::new(minun, 13, 13),
    @encounter_slot.GBASlot::new(oddish, 13, 13),
    @encounter_slot.GBASlot::new(minun, 13, 13),
    @encounter_slot.GBASlot::new(gulpin, 13, 13),
    @encounter_slot.GBASlot::new(windgull, 12, 12),
    @encounter_slot.GBASlot::new(windgull, 12, 12),
    @encounter_slot.GBASlot::new(plusle, 12, 12),
    @encounter_slot.GBASlot::new(plusle, 13, 13),
  ]
  let generate = wild_pokemon(
    encounter_fn=@roll_encounter.roll_encounter_force,
    slot_fn=@encounter_slot.generate_slot(
      @encounter_slot.EncounterTable::grass(slots),
    ),
    level_fn=@level_generator.standard,
    ivs_fn=@ivs_generator.prior_interrupt,
    nature_fn=@nature_generator.standard,
  )

  // C#実装結果: Seed: 12345678, Pokemon: ラクライ, Lv=12, PID=B22F82C3, Nature=Modest, IVs=[7,25,3,5,9,26]
  let result1 = generate(@lcg32.Lcg32(0x12345678U).to_ref())
  let (pokemon1, _) = result1.unwrap()
  assert_eq(pokemon1.species, electrike)
  assert_eq(pokemon1.lv, 12U)
  assert_eq(pokemon1.pid, 0xB22F82C3U)
  assert_eq(pokemon1.nature(), @core.Nature::Modest)
  assert_eq(pokemon1.ivs.as_tuple(), (26, 5, 9, 14, 4, 26))

  // C#実装結果: Seed: 87654321, Pokemon: ポチエナ, Lv=12, PID=C71E3720, Nature=Lonely, IVs=[10,13,14,19,12,15]
  let result2 = generate(@lcg32.Lcg32(0x87654321U).to_ref())
  let (pokemon2, _) = result2.unwrap()
  assert_eq(pokemon2.species, poochyena)
  assert_eq(pokemon2.lv, 12U)
  assert_eq(pokemon2.pid, 0xC71E3720U)
  assert_eq(pokemon2.nature(), @core.Nature::Lonely)
  assert_eq(pokemon2.ivs.as_tuple(), (15, 19, 12, 30, 22, 26))
}
