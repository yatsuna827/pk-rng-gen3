///|
pub type EncounterTable Array[(GBASlot, UInt)]

///|
pub fn EncounterTable::pick(self : EncounterTable, val : UInt) -> GBASlot {
  for pair in self.inner() {
    let (slot, p) = pair
    if val < p {
      break slot
    }
  } else {
    panic()
  }
}

///|
pub fn EncounterTable::grass(arr : Array[GBASlot]) -> EncounterTable {
  guard arr.length() == 12 else { panic() }
  let probabilities : Array[UInt] = [20U, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
  EncounterTable(arr.zip(probabilities.cumsum()))
}

///|
pub fn EncounterTable::surf(arr : Array[GBASlot]) -> EncounterTable {
  guard arr.length() == 5 else { panic() }
  let probabilities : Array[UInt] = [60, 30, 5, 4, 1]
  EncounterTable(arr.zip(probabilities.cumsum()))
}

///|
pub fn EncounterTable::old_rod(arr : Array[GBASlot]) -> EncounterTable {
  guard arr.length() == 2 else { panic() }
  let probabilities : Array[UInt] = [70, 30]
  EncounterTable(arr.zip(probabilities.cumsum()))
}

///|
pub fn EncounterTable::good_rod(arr : Array[GBASlot]) -> EncounterTable {
  guard arr.length() == 3 else { panic() }
  let probabilities : Array[UInt] = [60, 20, 20]
  EncounterTable(arr.zip(probabilities.cumsum()))
}

///|
pub fn EncounterTable::super_rod(arr : Array[GBASlot]) -> EncounterTable {
  guard arr.length() == 5 else { panic() }
  let probabilities : Array[UInt] = [40, 40, 15, 4, 1]
  EncounterTable(arr.zip(probabilities.cumsum()))
}

///|
pub fn EncounterTable::rock_smash(arr : Array[GBASlot]) -> EncounterTable {
  guard arr.length() == 5 else { panic() }
  let probabilities : Array[UInt] = [60, 30, 5, 4, 1]
  EncounterTable(arr.zip(probabilities.cumsum()))
}
