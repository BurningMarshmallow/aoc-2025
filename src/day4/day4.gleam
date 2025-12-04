import gleam/bool
import gleam/io
import gleam/list
import gleam/set.{type Set}
import lib/helpers
import lib/timing.{run_timed}
import simplifile

const sample = "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."

type V {
  V(x: Int, y: Int)
}

pub fn run() {
  let assert Ok(input) = simplifile.read("input.txt")
  io.println("Sample")
  let assert 13 = run_timed(part1, sample)
  let assert 43 = run_timed(part2, sample)

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

fn solve(input: String, multiple_times: Bool) -> Int {
  let grid = helpers.get_grid(input)
  let rolls =
    grid
    |> list.flatten
    |> list.filter(fn(cell) { cell.2 == "@" })
    |> list.map(fn(cell) { V(cell.0, cell.1) })
    |> set.from_list

  case multiple_times {
    False -> get_total_num_of_rolls_to_delete(rolls)
    True -> get_total_num_of_rolls_to_delete_multiple(rolls)
  }
}

fn get_total_num_of_rolls_to_delete(rolls: Set(V)) -> Int {
  set.size(get_rolls_to_delete(rolls))
}

fn get_total_num_of_rolls_to_delete_multiple(rolls: Set(V)) -> Int {
  let rolls_to_delete = get_rolls_to_delete(rolls)
  let num_of_rolls_to_delete = set.size(rolls_to_delete)
  use <- bool.guard(num_of_rolls_to_delete == 0, 0)

  let new_rolls = set.difference(rolls, rolls_to_delete)
  num_of_rolls_to_delete + get_total_num_of_rolls_to_delete_multiple(new_rolls)
}

fn get_rolls_to_delete(rolls: Set(V)) -> Set(V) {
  set.filter(rolls, fn(roll) { need_delete_roll(rolls, roll) })
}

fn need_delete_roll(rolls: Set(V), roll: V) -> Bool {
  list.length(neighbour_rolls_8(rolls, roll)) < 4
}

fn neighbour_rolls_8(rolls: Set(V), roll: V) -> List(V) {
  list.range(-1, 1)
  |> list.map(fn(x) {
    list.range(-1, 1)
    |> list.filter(fn(y) {
      let new_roll = V(roll.x + x, roll.y + y)
      { x != 0 || y != 0 } && set.contains(rolls, new_roll)
    })
    |> list.map(fn(y) { V(x, y) })
  })
  |> list.flatten
}
