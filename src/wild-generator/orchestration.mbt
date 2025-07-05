///| 
pub fn generate_wild_pokemon_mut(
  lcg_ref : @lcg32.Lcg32Ref,
  slots : Array[@encounter_slot.GBASlot],
  encounter_fn : @roll_encounter.RollEncounterMut,
  slot_func : (@lcg32.Lcg32Ref, Array[@encounter_slot.GBASlot]) -> @encounter_slot.GBASlot,
  level_func : (@lcg32.Lcg32Ref, UInt, UInt) -> UInt,
  ivs_func : (@lcg32.Lcg32Ref) -> @types.IVs,
  nature_func : (@lcg32.Lcg32Ref) -> @types.Nature,
  gender_func : (@lcg32.Lcg32Ref) -> @types.Gender
) -> @types.PokemonResult? {
  if not(encounter_fn(lcg_ref)) {
    return None
  }
  let slot = slot_func(lcg_ref, slots)
  let min_level = slot.min_level.reinterpret_as_uint()
  let max_level = slot.max_level.reinterpret_as_uint()
  let variable_lv = max_level - min_level + 1U
  let level = level_func(lcg_ref, min_level, variable_lv)
  let gender = gender_func(lcg_ref)
  let nature = nature_func(lcg_ref)
  let (pid, recalc_count) = @pid.generate_pid_with_conditions(
    lcg_ref,
    Some(nature),
    None,
    @types.GenderRatio::Male1Female1,
  )
  let ivs = ivs_func(lcg_ref)
  Some(@types.PokemonResult::{
    level,
    pid: pid.inner(),
    ivs,
    nature,
    gender,
    recalc_count,
  })
}

///| 
pub fn generate_wild_pokemon_immut(
  lcg : @lcg32.Lcg32,
  slots : Array[@encounter_slot.GBASlot],
  encounter_fn : @roll_encounter.RollEncounterMut,
  slot_func : (@lcg32.Lcg32Ref, Array[@encounter_slot.GBASlot]) -> @encounter_slot.GBASlot,
  level_func : (@lcg32.Lcg32Ref, UInt, UInt) -> UInt,
  ivs_func : (@lcg32.Lcg32Ref) -> @types.IVs,
  nature_func : (@lcg32.Lcg32Ref) -> @types.Nature,
  gender_func : (@lcg32.Lcg32Ref) -> @types.Gender
) -> @types.PokemonResult? {
  let lcg_ref = lcg.to_ref()
  generate_wild_pokemon_mut(
    lcg_ref, slots, encounter_fn, slot_func, level_func, ivs_func, nature_func, gender_func,
  )
}

///|
test "wild pokemon generation matches C# implementation" {
  // C#実装と同じスロット構成（110番道路）
  let slots = [
    @encounter_slot.GBASlot::{ pokemon_id: 261, min_level: 12, max_level: 12 }, // ポチエナ 20%
    @encounter_slot.GBASlot::{ pokemon_id: 309, min_level: 12, max_level: 12 }, // ラクライ 20%  
    @encounter_slot.GBASlot::{ pokemon_id: 311, min_level: 13, max_level: 13 }, // プラスル 10%
    @encounter_slot.GBASlot::{ pokemon_id: 312, min_level: 13, max_level: 13 }, // マイナン 10%
    @encounter_slot.GBASlot::{ pokemon_id: 309, min_level: 12, max_level: 12 }, // ラクライ 10%
    @encounter_slot.GBASlot::{ pokemon_id: 261, min_level: 12, max_level: 12 }, // ポチエナ 10%
    @encounter_slot.GBASlot::{ pokemon_id: 311, min_level: 13, max_level: 13 }, // プラスル 5%
    @encounter_slot.GBASlot::{ pokemon_id: 312, min_level: 13, max_level: 13 }, // マイナン 5%
    @encounter_slot.GBASlot::{ pokemon_id: 309, min_level: 12, max_level: 12 }, // ラクライ 4%
    @encounter_slot.GBASlot::{ pokemon_id: 261, min_level: 12, max_level: 12 }, // ポチエナ 4%
    @encounter_slot.GBASlot::{ pokemon_id: 311, min_level: 13, max_level: 13 }, // プラスル 1%
    @encounter_slot.GBASlot::{ pokemon_id: 312, min_level: 13, max_level: 13 }, // マイナン 1%
  ]

  // C#実装結果: Seed: 12345678, Pokemon: ラクライ, Lv=12, PID=B22F82C3, Nature=Modest, IVs=[7,25,3,5,9,26]
  let result1 = generate_wild_pokemon_immut(
    @lcg32.Lcg32(0x12345678U),
    slots,
    @roll_encounter.roll_encounter_force_mut,
    @encounter_slot.generate_grass_slot_mut,
    @level_generator.generate_level_standard_mut,
    @ivs_generator.generate_ivs_standard_mut,
    @nature_generator.generate_nature_standard_mut,
    @gender_generator.generate_gender_null_mut,
  )
  let pokemon1 = result1.unwrap()
  assert_eq(pokemon1.level, 12U)
  assert_eq(pokemon1.pid, 0xB22F82C3U)
  assert_eq(pokemon1.nature, @types.Nature::Modest)
  assert_eq(pokemon1.ivs.h(), 7U)
  assert_eq(pokemon1.ivs.a(), 25U)
  assert_eq(pokemon1.ivs.b(), 3U)
  assert_eq(pokemon1.ivs.c(), 5U)
  assert_eq(pokemon1.ivs.d(), 9U)
  assert_eq(pokemon1.ivs.s(), 26U)

  // C#実装結果: Seed: 87654321, Pokemon: ポチエナ, Lv=12, PID=C71E3720, Nature=Lonely, IVs=[10,13,14,19,12,15]
  let result2 = generate_wild_pokemon_immut(
    @lcg32.Lcg32(0x87654321U),
    slots,
    @roll_encounter.roll_encounter_force_mut,
    @encounter_slot.generate_grass_slot_mut,
    @level_generator.generate_level_standard_mut,
    @ivs_generator.generate_ivs_standard_mut,
    @nature_generator.generate_nature_standard_mut,
    @gender_generator.generate_gender_null_mut,
  )
  let pokemon2 = result2.unwrap()
  assert_eq(pokemon2.level, 12U)
  assert_eq(pokemon2.pid, 0xC71E3720U)
  assert_eq(pokemon2.nature, @types.Nature::Lonely)
  assert_eq(pokemon2.ivs.h(), 10U)
  assert_eq(pokemon2.ivs.a(), 13U)
  assert_eq(pokemon2.ivs.b(), 14U)
  assert_eq(pokemon2.ivs.c(), 19U)
  assert_eq(pokemon2.ivs.d(), 12U)
  assert_eq(pokemon2.ivs.s(), 15U)
}
