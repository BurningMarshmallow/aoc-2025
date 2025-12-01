import gleam/int
import gleam/list
import gleam/regexp
import gleam/string
import simplifile

pub fn part1(input: String) -> Int {
  let assert Ok(re) = regexp.from_string("mul\\(\\d+\\,\\d+\\)")
  re
  |> regexp.scan(input)
  |> list.map(fn(r) -> Int {
    let assert Ok(gex) = regexp.from_string("\\d+")
    regexp.scan(gex, r.content)
    |> list.fold(1, fn(acc, curr) {
      let assert Ok(nr) = int.parse(curr.content)
      nr * acc
    })
  })
  |> int.sum
}

pub fn part2(input: String) -> Int {
  let assert Ok(dont_reg) = regexp.from_string("don\\'t\\(\\)")
  let assert Ok(do_reg) = regexp.from_string("do\\(\\)")

  let assert [h, ..t] = regexp.split(dont_reg, input)
  t
  |> list.map(fn(s) {
    case regexp.split(do_reg, s) {
      [_, ..tail] -> part1(string.join(tail, ""))
      _ -> 0
    }
  })
  |> int.sum
  |> int.add(part1(h))
}

pub fn main() {
  let assert Ok(data) = simplifile.read("inputs/test/input.txt")
  data
  |> part1
  |> echo

  data
  |> part2
  |> echo
}
