///| 色違いタイプ
pub(all) enum ShinyType {
  NotShiny // 通常
  Star // 星色違い（SV値1-15）
  Square // 四角色違い（SV値0）
} derive(Eq, Show)
