///|
pub(all) struct GBASlot {
  pokemon : @core.Species
  min_level : UInt
  max_level : UInt
} derive(Eq, Show)

///|
pub fn GBASlot::new(
  pokemon : @core.Species,
  min_level : UInt,
  max_level : UInt
) -> GBASlot {
  { pokemon, min_level, max_level }
}

///|
pub fn GBASlot::variable_lv(self : GBASlot) -> UInt {
  self.max_level - self.min_level + 1U
}
