import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import lib/helpers
import lib/timing.{run_timed}
import simplifile

const sample = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"

pub fn run() {
  let assert Ok(input) = simplifile.read("input.txt")

  io.println("Sample")
  let assert 1_227_775_554 = run_timed(part1, sample)
  let assert 4_174_379_265 = run_timed(part2, sample)

  io.println("")
  io.println("Input")
  run_timed(part1, input)
  run_timed(part2, input)
}

pub fn part1(input: String) -> Int {
  solve(input, False)
}

pub fn part2(input: String) -> Int {
  solve(input, True)
}

fn solve(input: String, repeated_many_times: Bool) -> Int {
  let assert Ok(total_num_of_invalid) =
    list.map(string.split(input, ","), fn(range_str) {
      let range = helpers.read_range(range_str)
      let num_of_invalid_in_range =
        range
        |> list.filter(fn(value) {
          case repeated_many_times {
            True -> is_invalid_when_repeated_many_times(value)
            False -> is_invalid(value, 2)
          }
        })
        |> list.reduce(int.add)
      result.unwrap(num_of_invalid_in_range, 0)
    })
    |> list.reduce(int.add)
  total_num_of_invalid
}

fn is_invalid_when_repeated_many_times(id: Int) -> Bool {
  let id_str = int.to_string(id)
  let len = string.length(id_str)
  let range_of_num_of_times = list.range(2, len)
  let has_invalid =
    range_of_num_of_times
    |> list.any(fn(num_of_times) { is_invalid(id, num_of_times) })
  id >= 10 && has_invalid
}

fn is_invalid(id: Int, num_of_times: Int) -> Bool {
  let id_str = int.to_string(id)
  let id_length = string.length(id_str)
  case id_length % num_of_times == 0 {
    True -> {
      let sequence = string.slice(id_str, 0, id_length / num_of_times)
      string.repeat(sequence, num_of_times) == id_str
    }
    False -> False
  }
}
