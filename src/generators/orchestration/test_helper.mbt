///|
fn @core.Species::dummy(
  dexNo : Int,
  types : (@core.PokeType, @core.PokeType?)
) -> @core.Species {
  {
    dexNo,
    abilities: ("", ""),
    name: "",
    forme: None,
    bs: @core.BaseStats::new(100, 100, 100, 100, 100, 100),
    types,
    gender_ratio: Male1Female1,
  }
}
