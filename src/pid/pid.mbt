
///| PIDから性格を抽出
pub fn get_nature_from_pid(pid : UInt) -> @types.Nature {
  let nature_value = pid % 25U
  @types.Nature::from_value(nature_value).unwrap()
}

///| PIDが指定された性格かどうかチェック
pub fn check_nature(pid : UInt, required_nature : @types.Nature?) -> Bool {
  match required_nature {
    None => true // 任意の性格
    Some(nature) => get_nature_from_pid(pid) == nature
  }
}

///| PIDから性別を抽出
pub fn get_gender_from_pid(
  pid : UInt,
  ratio : @types.GenderRatio
) -> @types.Gender {
  match ratio {
    @types.Genderless => @types.Genderless
    @types.MaleOnly => @types.Male
    @types.FemaleOnly => @types.Female
    _ => if (pid & 0xFFU) < ratio.value() { @types.Female } else { @types.Male }
  }
}

///| PIDが指定された性別かどうかチェック
pub fn check_gender(
  pid : UInt,
  required_gender : @types.Gender?,
  ratio : @types.GenderRatio
) -> Bool {
  match required_gender {
    None => true // 任意の性別
    Some(gender) => get_gender_from_pid(pid, ratio) == gender
  }
}

///| PIDの色違いタイプを判定
pub fn get_shiny_type(pid : UInt, tsv : UInt) -> @types.ShinyType {
  let sv = (pid & 0xFFFFU) ^ (pid >> 16) ^ tsv
  match sv {
    0U => @types.Square
    sv if sv < 16U => @types.Star
    _ => @types.NotShiny
  }
}

///| PIDが色違いかどうかチェック
pub fn is_shiny(pid : UInt, tsv : UInt) -> Bool {
  get_shiny_type(pid, tsv) != @types.NotShiny
}

///| 条件を満たすPIDを生成（リロール処理付き）
fn generate_pid_with_conditions_helper(
  lcg_ref : @lcg32.Lcg32Ref,
  required_nature : @types.Nature?,
  required_gender : @types.Gender?,
  gender_ratio : @types.GenderRatio,
  recalc : UInt
) -> (UInt, UInt) {
  let low = lcg_ref.get_rand()
  let high = lcg_ref.get_rand()
  let pid = low | (high << 16)
  if check_nature(pid, required_nature) &&
    check_gender(pid, required_gender, gender_ratio) {
    (pid, recalc)
  } else {
    generate_pid_with_conditions_helper(
      lcg_ref,
      required_nature,
      required_gender,
      gender_ratio,
      recalc + 1U,
    )
  }
}

///|
pub fn generate_pid_with_conditions(
  lcg_ref : @lcg32.Lcg32Ref,
  required_nature : @types.Nature?,
  required_gender : @types.Gender?,
  gender_ratio : @types.GenderRatio
) -> (UInt, UInt) { // (pid, recalc_count)
  generate_pid_with_conditions_helper(
    lcg_ref, required_nature, required_gender, gender_ratio, 0U,
  )
}

///| 基本的なPID生成（条件なし）
pub fn generate_basic_pid(lcg_ref : @lcg32.Lcg32Ref) -> UInt {
  let low = lcg_ref.get_rand()
  let high = lcg_ref.get_rand()
  low | (high << 16)
}

// テスト

///|
test "get_nature_from_pid should extract correct nature" {
  assert_eq(get_nature_from_pid(0U), @types.Hardy) // 0 % 25 = 0
  assert_eq(get_nature_from_pid(25U), @types.Hardy) // 25 % 25 = 0
  assert_eq(get_nature_from_pid(1U), @types.Lonely) // 1 % 25 = 1
  assert_eq(get_nature_from_pid(24U), @types.Quirky) // 24 % 25 = 24
}

///|
test "check_nature should validate nature correctly" {
  assert_eq(check_nature(0U, None), true) // Any nature
  assert_eq(check_nature(0U, Some(@types.Hardy)), true)
  assert_eq(check_nature(0U, Some(@types.Lonely)), false)
  assert_eq(check_nature(1U, Some(@types.Lonely)), true)
}

///|
test "get_gender_from_pid should extract correct gender" {
  // Male only
  assert_eq(get_gender_from_pid(0U, @types.GenderRatio::MaleOnly), @types.Male)
  assert_eq(
    get_gender_from_pid(255U, @types.GenderRatio::MaleOnly),
    @types.Male,
  )

  // Female only  
  assert_eq(
    get_gender_from_pid(0U, @types.GenderRatio::FemaleOnly),
    @types.Female,
  )
  assert_eq(
    get_gender_from_pid(255U, @types.GenderRatio::FemaleOnly),
    @types.Female,
  )

  // Genderless
  assert_eq(
    get_gender_from_pid(0U, @types.GenderRatio::Genderless),
    @types.Gender::Genderless,
  )

  // 50:50 ratio (127)
  assert_eq(
    get_gender_from_pid(126U, @types.GenderRatio::Male1Female1),
    @types.Female,
  ) // 126 < 127
  assert_eq(
    get_gender_from_pid(127U, @types.GenderRatio::Male1Female1),
    @types.Male,
  ) // 127 >= 127
}

///|
test "check_gender should validate gender correctly" {
  assert_eq(check_gender(0U, None, @types.GenderRatio::Male1Female1), true) // Any gender
  assert_eq(
    check_gender(126U, Some(@types.Female), @types.GenderRatio::Male1Female1),
    true,
  )
  assert_eq(
    check_gender(127U, Some(@types.Female), @types.GenderRatio::Male1Female1),
    false,
  )
  assert_eq(
    check_gender(127U, Some(@types.Male), @types.GenderRatio::Male1Female1),
    true,
  )
}

///|
test "get_shiny_type should determine shiny correctly" {
  // Square shiny (SV = 0)
  let pid1 = 0x12345678U
  let tsv1 = 0x1234U ^ 0x5678U // Makes SV = 0
  assert_eq(get_shiny_type(pid1, tsv1), @types.Square)

  // Star shiny (SV = 1-15)
  let tsv2 = 0x1234U ^ 0x5678U ^ 1U // Makes SV = 1
  assert_eq(get_shiny_type(pid1, tsv2), @types.Star)

  // Not shiny (SV >= 16)
  let tsv3 = 0x1234U ^ 0x5678U ^ 16U // Makes SV = 16
  assert_eq(get_shiny_type(pid1, tsv3), @types.NotShiny)
}

///|
test "is_shiny should detect shiny correctly" {
  let pid = 0x12345678U
  let shiny_tsv = 0x1234U ^ 0x5678U
  let not_shiny_tsv = 0x1234U ^ 0x5678U ^ 16U // Square shiny
  // Not shiny
  assert_eq(is_shiny(pid, shiny_tsv), true)
  assert_eq(is_shiny(pid, not_shiny_tsv), false)
}

///|
test "generate_basic_pid should use two RNG calls" {
  let lcg_ref = @lcg32.Lcg32(0x12345678U).to_ref()
  let initial_seed = lcg_ref.seed()
  let pid = generate_basic_pid(lcg_ref)

  // Should advance LCG by 2 calls
  let expected_seed = @lcg32.Lcg32(initial_seed).jump(2U).inner()
  assert_eq(lcg_ref.seed(), expected_seed)

  // PID should be constructed correctly
  let test_lcg = @lcg32.Lcg32(initial_seed)
  let test_lcg_ref = test_lcg.to_ref()
  let low = test_lcg_ref.get_rand()
  let high = test_lcg_ref.get_rand()
  let expected_pid = low | (high << 16)
  assert_eq(pid, expected_pid)
}
