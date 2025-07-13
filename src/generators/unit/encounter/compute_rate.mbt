///|
fn compute_encounter_rate(
  base_encounter_rate : UInt,
  option~ : EncounterOption? = None
) -> UInt {
  let rate = match option {
    Some(opt) => {
      let mut rate = base_encounter_rate
      if opt.riding_bicycle {
        rate = rate * 80 / 100
      }
      match opt.flute {
        Some(Flute::White) => rate = rate * 150 / 100
        Some(Flute::Black) => rate = rate * 50 / 100
        None => ()
      }
      if opt.has_cleanse_tag {
        rate = rate * 2 / 3
      }
      rate
    }
    None => base_encounter_rate
  }
  @cmp.minimum(2880, rate)
}

///|
test "calculate encounter rate correctly" {
  assert_eq(compute_encounter_rate(2160), 2160)
}

///|
test "apply bicycle reduction 80 percent" {
  assert_eq(
    compute_encounter_rate(
      2160,
      option=Some(EncounterOption::new(riding_bicycle=true)),
    ),
    // 2160 * 80 / 100
    1728,
  )
}

///|
test "black flute reduces encounter rate by 50 percent" {
  assert_eq(
    compute_encounter_rate(
      2000,
      option=Some(EncounterOption::new(flute=Some(Flute::Black))),
    ),
    1000,
  )
}

///|
test "white flute increases encounter rate by 50 percent" {
  assert_eq(
    compute_encounter_rate(
      1000,
      option=Some(EncounterOption::new(flute=Some(Flute::White))),
    ),
    1500,
  )
}

///|
test "cap encounter rate at 2880" {
  assert_eq(compute_encounter_rate(3000), 2880)
  // 2000 * 1.5 = 3000 > 2880
  assert_eq(
    compute_encounter_rate(
      2000,
      option=Some(EncounterOption::new(flute=Some(Flute::White))),
    ),
    2880,
  )
}
