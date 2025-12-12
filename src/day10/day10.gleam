import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string
import lib/helpers
import lib/timing.{run_timed}

import simplifile

type Machine {
  Machine(indicator_diagram: String, wirings: List(List(Int)))
}

type State {
  State(node: String, dist: Int)
}

const sample = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"

pub fn run() {
  let assert Ok(input) = simplifile.read("input.txt")

  io.println("Sample")
  let assert 7 = run_timed(part1, sample)

  io.println("")
  io.println("Input")
  run_timed(part1, input)
  run_timed(part2, input)
}

pub fn part1(input: String) -> Int {
  solve(input)
}

pub fn part2(_input: String) -> Int {
  // Solved by Z3 in Python
  16_513
}

fn solve(input: String) -> Int {
  let machines = parse(input)
  let answers = list.map(machines, get_answer)
  helpers.sum(answers)
}

fn binary_to_int(binary: String) -> Int {
  let chars = binary |> string.reverse |> string.to_graphemes
  list.index_map(chars, fn(char, i) {
    case char {
      "1" -> int.bitwise_shift_left(1, i)
      _ -> 0
    }
  })
  |> helpers.sum
}

pub fn to_num(s: String) -> Int {
  binary_to_int(s)
}

pub fn from_num(num: Int, n: Int) -> String {
  let bin = int.to_base2(num)
  let padding = n - string.length(bin)
  string.repeat("0", padding) <> bin
}

pub fn get_neighbours(node: String, rest: List(List(Int))) -> List(String) {
  let n = string.length(node)
  let value = to_num(node)

  rest
  |> list.map(fn(transform) {
    let new_value =
      transform
      |> list.fold(value, fn(acc, i) {
        int.bitwise_exclusive_or(acc, int.bitwise_shift_left(1, n - i - 1))
      })
    from_num(new_value, n)
  })
}

fn bfs(
  queue: List(State),
  visited: Set(String),
  result_num: String,
  machine: Machine,
) -> Int {
  case queue {
    [] -> 1_000_000
    [state, ..rest_queue] -> {
      case state.node == result_num {
        True -> state.dist
        False -> {
          let new_states =
            get_neighbours(state.node, machine.wirings)
            |> list.filter(fn(neighbor) { !set.contains(visited, neighbor) })
            |> list.map(fn(neighbor) { State(neighbor, state.dist + 1) })

          let new_queue = list.append(rest_queue, new_states)
          let new_visited =
            new_queue
            |> list.fold(visited, fn(acc, new_state) {
              set.insert(acc, new_state.node)
            })

          bfs(new_queue, new_visited, result_num, machine)
        }
      }
    }
  }
}

fn get_answer(machine: Machine) -> Int {
  let n = string.length(machine.indicator_diagram)
  let start_node = from_num(0, n)
  let start = [State(start_node, 0)]
  let start_visited = set.from_list([start_node])
  let result_num =
    string.replace(machine.indicator_diagram, "#", "1")
    |> string.replace(".", "0")

  bfs(start, start_visited, result_num, machine)
}

fn parse(input: String) -> List(Machine) {
  let lines = helpers.read_lines(input)
  let machines =
    list.map(lines, fn(line) {
      let assert [indicator_diagram, ..rest] = string.split(line, " ")
      let indicator_diagram = trim_start_end(indicator_diagram)

      let rest = list.take(rest, list.length(rest) - 1)
      let wirings =
        list.map(rest, fn(wiring) {
          let wiring = trim_start_end(wiring)
          string.split(wiring, ",") |> list.map(helpers.unsafe_parse_int)
        })
      Machine(indicator_diagram, wirings)
    })

  machines
}

fn trim_start_end(value: String) -> String {
  value
  |> string.drop_start(1)
  |> string.drop_end(1)
}
