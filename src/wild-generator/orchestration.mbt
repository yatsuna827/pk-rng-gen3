///| 
pub fn generate_wild_pokemon(
  encounter_fn~ : @core.GeneratorMut[Bool],
  slot_fn~ : @core.GeneratorMut[@encounter_slot.GBASlot],
  level_fn~ : (@lcg32.Lcg32Ref, UInt, UInt) -> UInt,
  ivs_fn~ : @core.GeneratorMut[@core.IVs],
  nature_fn~ : @core.GeneratorMut[@core.Nature],
  gender_fn~ : @core.GeneratorMut[@core.Gender]? = None
) -> @core.GeneratorMut[@core.PokemonResult?] {
  lcg_ref => {
    if not(encounter_fn(lcg_ref)) {
      return None
    }
    let slot = slot_fn(lcg_ref)
    let min_level = slot.min_level.reinterpret_as_uint()
    let max_level = slot.max_level.reinterpret_as_uint()
    let variable_lv = max_level - min_level + 1U
    let level = level_fn(lcg_ref, min_level, variable_lv)
    let gender = gender_fn.map(f => f(lcg_ref))
    let nature = nature_fn(lcg_ref)
    let (pid, recalc_count) = @pid.generate_pid_with_conditions(
      lcg_ref,
      Some(nature),
      gender,
      @core.GenderRatio::Male1Female1,
    )
    let ivs = ivs_fn(lcg_ref)
    Some(@core.PokemonResult::{
      level,
      pid: pid.inner(),
      ivs,
      nature,
      gender: pid.to_gender(@core.GenderRatio::Male1Female1),
      recalc_count,
    })
  }
}

///|
test "wild pokemon generation matches C# implementation" {
  // claude codeくんが110番道路って言って書いてきたけど普通に嘘
  let poochyena = @core.Species::dummy(261, (@core.Dark, None))
  let electrike = @core.Species::dummy(309, (@core.Electric, None))
  let plusle = @core.Species::dummy(311, (@core.Electric, None))
  let minun = @core.Species::dummy(312, (@core.Electric, None))
  let slots = [
    @encounter_slot.GBASlot::new(poochyena, 12, 12),
    @encounter_slot.GBASlot::new(electrike, 12, 12),
    @encounter_slot.GBASlot::new(plusle, 13, 13),
    @encounter_slot.GBASlot::new(minun, 13, 13),
    @encounter_slot.GBASlot::new(electrike, 12, 12),
    @encounter_slot.GBASlot::new(poochyena, 12, 12),
    @encounter_slot.GBASlot::new(plusle, 13, 13),
    @encounter_slot.GBASlot::new(minun, 13, 13),
    @encounter_slot.GBASlot::new(electrike, 12, 12),
    @encounter_slot.GBASlot::new(poochyena, 12, 12),
    @encounter_slot.GBASlot::new(plusle, 13, 13),
    @encounter_slot.GBASlot::new(minun, 13, 13),
  ]
  let generate = generate_wild_pokemon(
    encounter_fn=@roll_encounter.roll_encounter_force,
    slot_fn=@encounter_slot.generate_slot(
      @encounter_slot.EncounterTable::grass(slots),
    ),
    level_fn=@level_generator.generate_level_standard,
    ivs_fn=@ivs_generator.generate_ivs_standard,
    nature_fn=@nature_generator.generate_nature_standard,
  )

  // C#実装結果: Seed: 12345678, Pokemon: ラクライ, Lv=12, PID=B22F82C3, Nature=Modest, IVs=[7,25,3,5,9,26]
  let result1 = generate(@lcg32.Lcg32(0x12345678U).to_ref())
  let pokemon1 = result1.unwrap()
  assert_eq(pokemon1.level, 12U)
  assert_eq(pokemon1.pid, 0xB22F82C3U)
  assert_eq(pokemon1.nature, @core.Nature::Modest)
  assert_eq(pokemon1.ivs.as_tuple(), (7, 25, 3, 5, 9, 26))

  // C#実装結果: Seed: 87654321, Pokemon: ポチエナ, Lv=12, PID=C71E3720, Nature=Lonely, IVs=[10,13,14,19,12,15]
  let result2 = generate(@lcg32.Lcg32(0x87654321U).to_ref())
  let pokemon2 = result2.unwrap()
  assert_eq(pokemon2.level, 12U)
  assert_eq(pokemon2.pid, 0xC71E3720U)
  assert_eq(pokemon2.nature, @core.Nature::Lonely)
  assert_eq(pokemon2.ivs.as_tuple(), (10, 13, 14, 19, 12, 15))
}
