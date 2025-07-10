///| ポロックの味
pub(all) enum PokeBlockFlavor {
  Spicy // 辛い
  Dry // 渋い  
  Sweet // 甘い
  Bitter // 苦い
  Sour // 酸っぱい
} derive(Eq, Show)

///| ポロック
pub(all) struct PokeBlock {
  flavor : PokeBlockFlavor
} derive(Eq, Show)

///| ポロック作成
pub fn PokeBlock::new(flavor : PokeBlockFlavor) -> PokeBlock {
  { flavor, }
}

///|
pub fn PokeBlock::is_liked_by(self : PokeBlock, nature : Nature) -> Bool {
  match self.flavor {
    Spicy =>
      match nature {
        Lonely | Brave | Adamant | Naughty => true
        _ => false
      }
    Sour =>
      match nature {
        Bold | Relaxed | Impish | Lax => true
        _ => false
      }
    Sweet =>
      match nature {
        Timid | Hasty | Jolly | Naive => true
        _ => false
      }
    Dry =>
      match nature {
        Modest | Mild | Quiet | Rash => true
        _ => false
      }
    Bitter =>
      match nature {
        Calm | Gentle | Sassy | Careful => true
        _ => false
      }
  }
}
