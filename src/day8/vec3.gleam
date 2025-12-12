pub type V3 {
  V3(x: Int, y: Int, z: Int)
}

pub fn distance(a: V3, b: V3) -> Int {
  let dx = a.x - b.x
  let dy = a.y - b.y
  let dz = a.z - b.z
  dx * dx + dy * dy + dz * dz
}

pub fn zero() -> V3 {
  V3(0, 0, 0)
}
