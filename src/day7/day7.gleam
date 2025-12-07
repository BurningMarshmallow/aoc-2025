import gleam/bool
import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import lib/helpers
import lib/timing.{run_timed}
import simplifile

const sample = ".......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
..............."

type V {
  V(x: Int, y: Int)
}

type State {
  State(x: Int, y: Int, timelines: Int)
}

pub fn run() {
  let assert Ok(input) = simplifile.read("input.txt")

  io.println("Sample")
  let assert 21 = run_timed(part1, sample)
  let assert 40 = run_timed(part2, sample)

  io.println("")
  io.println("Input")
  run_timed(part1, input)
  run_timed(part2, input)
}

pub fn part1(input: String) -> Int {
  solve(input, simulate_part1)
}

pub fn part2(input: String) -> Int {
  solve(input, simulate_part2)
}

fn solve(input, simulate_fn) {
  let lines = parse(input)
  let first_line = list.first(lines) |> result.unwrap([])
  let assert Ok(start) = helpers.find_index(first_line, "S")

  simulate_fn([State(0, start, 1)], lines, 1)
}

fn parse(input: String) {
  list.map(helpers.read_lines(input), string.to_graphemes)
}

fn simulate_part1(curr, lines: List(List(String)), i) -> Int {
  let next = list.map(curr, fn(state) { get_next(state, lines) })
  let split_times = next |> list.count(fn(value) { list.length(value) == 2 })
  let next_flattened = next |> list.flatten
  let next_merged = merge_states(next_flattened)

  case i == list.length(lines) {
    True -> split_times
    False -> split_times + simulate_part1(next_merged, lines, i + 1)
  }
}

fn simulate_part2(curr: List(State), lines: List(List(String)), i) -> Int {
  let next = list.flat_map(curr, fn(state) { get_next(state, lines) })
  let next_merged = merge_states(next)

  case i == list.length(lines) {
    True -> next_merged |> list.map(fn(w) { w.timelines }) |> helpers.sum
    False -> simulate_part2(next_merged, lines, i + 1)
  }
}

fn get_next(curr: State, lines: List(List(String))) -> List(State) {
  use <- bool.guard(is_outside_of_grid(curr, lines), [])
  let char = helpers.get_at_index_2d(lines, curr.x, curr.y)
  case char {
    "^" -> [
      State(curr.x + 1, curr.y + 1, curr.timelines),
      State(curr.x + 1, curr.y - 1, curr.timelines),
    ]
    _ -> [State(curr.x + 1, curr.y, curr.timelines)]
  }
}

fn is_outside_of_grid(curr: State, grid: List(List(String))) -> Bool {
  let first_line = list.first(grid) |> result.unwrap([])
  let n = list.length(grid)
  let m = list.length(first_line)

  curr.x < 0 || curr.x >= n || curr.y < 0 || curr.y >= m
}

fn merge_states(next: List(State)) -> List(State) {
  dict.to_list(list.group(next, fn(v) { V(v.x, v.y) }))
  |> list.map(fn(kvp) {
    State({ kvp.0 }.x, { kvp.0 }.y, kvp.1 |> sum_by_timelines)
  })
}

fn sum_by_timelines(states: List(State)) -> Int {
  states
  |> list.map(fn(state) { state.timelines })
  |> helpers.sum
}
