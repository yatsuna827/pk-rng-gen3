///|
pub(all) struct GBASlot {
  pokemon : @core.Species
  min_level : Int
  max_level : Int
} derive(Eq, Show)

///|
pub fn GBASlot::new(
  pokemon : @core.Species,
  min_level : Int,
  max_level : Int
) -> GBASlot {
  { pokemon, min_level, max_level }
}
