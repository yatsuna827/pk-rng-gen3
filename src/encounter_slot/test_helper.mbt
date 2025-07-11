///|
fn @core.Species::dummy(dexNo : Int) -> @core.Species {
  {
    dexNo,
    abilities: ("", ""),
    name: "",
    forme: None,
    bs: @core.BaseStats::new(100, 100, 100, 100, 100, 100),
    types: (Normal, None),
    gender_ratio: Male1Female1,
  }
}
