import gleam/int
import gleam/list
import gleam/string
import simplifile

type State {
  State(current: Int, clicks: Int)
}

const sample = "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82"

pub fn run() {
  let assert Ok(data) = simplifile.read("input.txt")
  let assert 3 = part1(sample)
  let assert 6 = part2(sample)

  data
  |> part1
  |> echo

  data
  |> part2
  |> echo
}

pub fn part1(input: String) -> Int {
  solve(input, basic_method)
}

pub fn part2(input: String) -> Int {
  solve(input, method0x434c49434b)
}

fn solve(input: String, method: fn(Int, State) -> Int) -> Int {
  let init_state = State(50, 0)
  let formatted_input = string.replace(input, "\r\n", "\n")

  list.fold(string.split(formatted_input, "\n"), init_state, fn(acc, line) {
    let assert Ok(direction) = string.first(line)
    let assert Ok(turn) = int.parse(string.drop_start(line, 1))

    let result = case direction {
      "L" -> acc.current - turn
      "R" -> acc.current + turn
      _ -> panic as "Unknown symbol"
    }

    State(result % 100, acc.clicks + method(result, acc))
  }).clicks
}

fn basic_method(result: Int, _: State) -> Int {
  case result % 100 == 0 {
    True -> 1
    False -> 0
  }
}

fn method0x434c49434b(result: Int, acc: State) -> Int {
  int.absolute_value(result)
  / 100
  + case result == 0 || sign(result * acc.current) < 0 {
    True -> 1
    False -> 0
  }
}

fn sign(value) {
  case value > 0 {
    True -> 1
    False ->
      case value < 0 {
        True -> -1
        False -> 0
      }
  }
}
