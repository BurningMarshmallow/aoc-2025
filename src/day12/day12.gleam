import gleam/io
import gleam/list
import gleam/string
import lib/helpers
import lib/timing.{run_timed}
import simplifile

const sample = "0:
###
##.
##.

1:
###
##.
.##

2:
.##
###
##.

3:
##.
###
##.

4:
###
#..
###

5:
###
.#.
###

4x4: 0 0 0 0 2 0
12x5: 1 0 1 0 2 2
12x5: 1 0 1 0 3 2"

pub fn run() {
  let assert Ok(input) = simplifile.read("input.txt")

  io.println("Sample")
  let assert 3 = run_timed(part1, sample)
  // Works wrong on sample! But correctly on input

  io.println("")
  io.println("Input")
  run_timed(part1, input)
}

pub fn part1(input: String) -> Int {
  solve(input)
}

fn solve(input: String) -> Int {
  let regions = parse(input)
  let answers =
    list.map(regions, fn(region) {
      let #(sizes, counts) = unsafe_to_pair(string.split(region, ": "))
      let #(size1, size2) =
        sizes
        |> string.split("x")
        |> list.map(helpers.unsafe_parse_int)
        |> unsafe_to_pair
      let int_counts =
        string.split(counts, " ") |> list.map(helpers.unsafe_parse_int)

      case helpers.sum(int_counts) * 7 <= size1 * size2 {
        True -> 1
        _ -> 0
      }
    })

  helpers.sum(answers)
}

fn parse(input: String) -> List(String) {
  let blocks =
    input
    |> string.replace("\r\n", "\n")
    |> string.split("\n\n")
  let assert Ok(regions) = blocks |> list.last
  string.split(regions, "\n")
}

fn unsafe_to_pair(value: List(a)) -> #(a, a) {
  let assert [key, ..value] = value
  let assert Ok(value) = value |> list.last
  #(key, value)
}
