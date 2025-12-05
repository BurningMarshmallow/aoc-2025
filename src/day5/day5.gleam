import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lib/helpers.{type Interval, Interval}
import lib/timing.{run_timed}
import simplifile

const sample = "3-5
10-14
16-20
12-18

1
5
8
11
17
32"

pub fn run() {
  let assert Ok(input) = simplifile.read("input.txt")

  io.println("Sample")
  let assert 3 = run_timed(part1, sample)
  let assert 14 = run_timed(part2, sample)
  io.println("")
  io.println("Input")
  run_timed(part1, input)
  run_timed(part2, input)
}

pub fn part1(input: String) -> Int {
  let #(ranges, ingridients) = parse(input)
  list.count(ingridients, is_fresh(_, ranges))
}

pub fn part2(input: String) -> Int {
  let #(ranges, _) = parse(input)
  length_union(ranges)
}

fn parse(input: String) {
  let input = input |> string.replace("\r\n", "\n")
  let assert [ranges, ingridients] = string.split(input, "\n\n")

  let ranges =
    list.map(string.split(ranges, "\n"), fn(x) {
      let assert [start, end] = string.split(x, "-")
      Interval(
        helpers.unsafe_parse_int(start),
        helpers.unsafe_parse_int(end) + 1,
      )
    })

  let ingridients =
    list.map(string.split(ingridients, "\n"), helpers.unsafe_parse_int)
  #(ranges, ingridients)
}

fn is_fresh(ingridient: Int, intervals: List(Interval)) -> Bool {
  list.any(intervals, fn(interval) {
    ingridient >= interval.start && ingridient <= interval.end
  })
}

fn length_union(intervals: List(Interval)) -> Int {
  let events: List(#(Int, Bool)) =
    intervals
    |> list.flat_map(fn(interval) {
      [
        #(interval.start, False),
        #(interval.end, True),
      ]
    })
    |> list.sort(by: fn(a, b) { int.compare(a.0, b.0) })

  case events {
    [] -> 0
    [first, ..] -> {
      let #(total, _, _) =
        list.fold(over: events, from: #(0, first.0, 0), with: fn(acc, event) {
          let #(result, previous_position, counter) = acc
          let #(current_position, is_end) = event

          let new_result = case
            counter > 0 && current_position > previous_position
          {
            True -> result + { current_position - previous_position }
            False -> result
          }

          let new_counter = case is_end {
            True -> counter - 1
            False -> counter + 1
          }

          #(new_result, current_position, new_counter)
        })

      total
    }
  }
}
