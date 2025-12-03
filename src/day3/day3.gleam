import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import lib/helpers
import lib/timing.{run_timed}
import simplifile

const sample = "987654321111111
811111111111119
234234234234278
818181911112111"

pub fn run() {
  let assert Ok(input) = simplifile.read("input.txt")

  io.println("Sample")
  let assert 357 = run_timed(part1, sample)
  let assert 3_121_910_778_619 = run_timed(part2, sample)
  io.println("")
  io.println("Input")
  run_timed(part1, input)
  run_timed(part2, input)
}

pub fn part1(input: String) -> Int {
  solve_by_brute_part1(input)
}

pub fn part2(input: String) -> Int {
  solve(input, 12)
}

fn solve_by_brute_part1(input: String) -> Int {
  let lines = helpers.read_lines(input)
  helpers.sum_with_transform(lines, get_max_jolts_by_brute)
}

fn get_max_jolts_by_brute(line: String) -> Int {
  string.to_graphemes(line)
  |> list.map(helpers.unsafe_parse_int)
  |> pairs
  |> list.max(int.compare)
  |> result.unwrap(0)
}

fn pairs(values: List(Int)) -> List(Int) {
  case values {
    [] -> []
    [_] -> []
    [x, ..rest] -> {
      let head_pairs = list.map(rest, fn(y) { 10 * x + y })
      list.append(head_pairs, pairs(rest))
    }
  }
}

fn solve(input: String, length: Int) -> Int {
  let lines = helpers.read_lines(input)

  helpers.sum_with_transform(lines, fn(line) {
    let max_jolts_str = get_max_jolts(string.to_graphemes(line), length)
    let max_jolts = helpers.unsafe_parse_int(max_jolts_str)
    max_jolts
  })
}

fn get_max_jolts(line: List(String), num_of_digits) -> String {
  use <- bool.guard(list.is_empty(line) || num_of_digits == 0, "")
  let possible_digits = list.take(line, list.length(line) - num_of_digits + 1)
  let assert Ok(next_digit) = list.max(possible_digits, string.compare)
  let assert Ok(pos) = helpers.find_index(line, next_digit)
  next_digit <> get_max_jolts(list.drop(line, pos + 1), num_of_digits - 1)
}
