import day1
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  day1.part1(
    "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82",
  )
  |> should.equal(3)
}

pub fn part2_test() {
  day1.part2(
    "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82",
  )
  |> should.equal(6)
}
