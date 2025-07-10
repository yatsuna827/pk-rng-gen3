///|
pub(all) struct Species {
  dexNo : Int
  name : String
  forme : String?
  bs : BaseStats
  types : (PokeType, PokeType?)
  abilities : (String, String)
  gender_ratio : GenderRatio
}

///|
pub impl Eq for Species with op_equal(self, other) {
  self.dexNo == other.dexNo
}

///|
pub fn Species::individual(
  self : Species,
  lv : UInt,
  pid : PID,
  ivs : IVs
) -> Individual {
  { species: self, lv, pid, ivs }
}

///|
pub(all) struct Individual {
  species : Species
  lv : UInt
  pid : PID
  ivs : IVs
}

///|
pub fn Individual::nature(self : Individual) -> Nature {
  self.pid.to_nature()
}

///|
pub fn Individual::gender(self : Individual) -> Gender {
  self.pid.to_gender(self.species.gender_ratio)
}

///|
pub fn Individual::stats(self : Individual) -> Stats {
  Stats::from(self.species.bs, self.ivs, self.lv, self.nature())
}
