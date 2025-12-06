import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import lib/helpers
import lib/timing.{run_timed}
import simplifile

type State {
  State(total: Int, problem_result: Int, op: String)
}

const sample = "123 328  51 64
 45 64  387 23
  6 98  215 314
*   +   *   +  "

pub fn run() {
  let assert Ok(input) = simplifile.read("input.txt")

  io.println("Sample")
  let assert 4_277_556 = run_timed(part1, sample)
  let assert 3_263_827 = run_timed(part2, sample)
  io.println("")
  io.println("Input")
  run_timed(part1, input)
  run_timed(part2, input)
}

pub fn part1(input: String) -> Int {
  solve(input)
}

pub fn part2(input: String) -> Int {
  solve_part2(input)
}

fn solve(input: String) -> Int {
  let values = parse_part1(input)
  helpers.sum(list.map(values, solve_problem))
}

fn solve_problem(problem: List(String)) -> Int {
  let assert [op, ..values] = list.reverse(problem)
  let rest = list.map(values, helpers.unsafe_parse_int)
  case op {
    "*" -> helpers.mul(rest)
    "+" -> helpers.sum(rest)
    _ -> panic as "Unknown operator"
  }
}

fn parse_part1(input: String) {
  helpers.read_lines(input)
  |> list.map(fn(line) {
    list.filter(string.split(line, " "), fn(x) { !string.is_empty(x) })
  })
  |> list.transpose
}

fn solve_part2(input: String) -> Int {
  let values = parse_part2(input)

  list.fold(values, State(0, 0, "?"), fn(acc, column) {
    let last_char = result.unwrap(list.last(column), "?")
    case last_char {
      "*" -> State(acc.total, read_int_from_column(column), "*")
      "+" -> State(acc.total, read_int_from_column(column), "+")
      _ ->
        case list.all(column, fn(x) { x == " " }) {
          True -> {
            State(acc.total + acc.problem_result, 0, "?")
          }
          False ->
            case acc.op {
              "*" ->
                State(
                  acc.total,
                  acc.problem_result * read_int_from_column(column),
                  acc.op,
                )
              "+" ->
                State(
                  acc.total,
                  acc.problem_result + read_int_from_column(column),
                  acc.op,
                )
              _ -> panic as "No operator in acc"
            }
        }
    }
  }).total
}

fn parse_part2(input: String) {
  helpers.read_lines(input)
  |> normalize
  |> list.map(string.to_graphemes)
  |> list.transpose
}

// Normalize the input lines by padding them with spaces to the maximum length + 1
// 12
// 4
// *
// ->
// 12.
// 4..
// *..
fn normalize(lines: List(String)) -> List(String) {
  let max_line_length =
    list.map(lines, string.length) |> list.max(int.compare) |> result.unwrap(-1)
  let lines =
    list.map(lines, fn(line) {
      line <> string.repeat(" ", max_line_length - string.length(line) + 1)
    })
  lines
}

fn read_int_from_column(column: List(String)) {
  column
  |> fn(column) { list.take(column, list.length(column) - 1) }
  |> list.reduce(fn(acc, str) { acc <> str })
  |> result.unwrap("")
  |> helpers.unsafe_parse_int
}
