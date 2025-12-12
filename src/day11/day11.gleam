import gleam/bool
import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import lib/helpers
import lib/timing.{run_timed}
import simplifile

const sample = "aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out"

const sample_2 = "svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out"

pub fn run() {
  let assert Ok(input) = simplifile.read("input.txt")

  io.println("Sample")
  let assert 5 = run_timed(part1, sample)
  let assert 2 = run_timed(part2, sample_2)

  io.println("")
  io.println("Input")
  run_timed(part1, input)
  run_timed(part2, input)
}

pub fn part1(input: String) -> Int {
  let graph = build_graph(input)
  solve_part1(graph)
}

pub fn part2(input: String) -> Int {
  let graph = build_graph(input)
  solve_part2(graph)
}

fn build_graph(input: String) -> dict.Dict(String, List(String)) {
  let graph =
    list.fold(helpers.read_lines(input), dict.new(), fn(acc, line) {
      let assert [v, neighbours] = string.split(line, ": ")
      dict.insert(acc, v, neighbours |> string.split(" "))
    })
  graph
}

fn solve_part1(graph: dict.Dict(String, List(String))) -> Int {
  count_of_paths(graph, ["you"])
}

fn count_of_paths(
  graph: dict.Dict(String, List(String)),
  queue: List(String),
) -> Int {
  case list.length(queue) {
    0 -> 0
    _ -> {
      let assert [node, ..rest] = queue
      case node {
        "out" -> 1
        _ -> {
          let assert Ok(neighbours) = graph |> dict.get(node)
          helpers.sum_with_transform(neighbours, fn(node) {
            count_of_paths(graph, [node, ..rest])
          })
        }
      }
    }
  }
}

fn solve_part2(graph) -> Int {
  count_of_paths_with_memo(graph, "svr", False, False, dict.new()).0
}

fn count_of_paths_with_memo(graph, node, dac, fft, memo) {
  use <- bool.lazy_guard(node == "out", fn() {
    case dac && fft {
      True -> #(1, memo)
      False -> #(0, memo)
    }
  })

  let key = build_key(node, dac, fft)
  use <- bool.lazy_guard(memo |> dict.has_key(key), fn() {
    let memo_value = memo |> dict.get(key) |> result.unwrap(0)
    #(memo_value, memo)
  })

  let neighbours = graph |> dict.get(node) |> result.unwrap([])
  let dac = dac || node == "dac"
  let fft = fft || node == "fft"
  list.fold(neighbours, #(0, memo), fn(acc, neighbour) {
    let #(neighbour_counts, new_memo) =
      count_of_paths_with_memo(graph, neighbour, dac, fft, acc.1)
    #(
      acc.0 + neighbour_counts,
      new_memo
        |> dict.insert(build_key(neighbour, dac, fft), neighbour_counts),
    )
  })
}

fn build_key(node: String, dac: Bool, fft: Bool) -> String {
  node <> bool_to_str(dac) <> bool_to_str(fft)
}

fn bool_to_str(value: Bool) -> String {
  case value {
    True -> "true"
    False -> "false"
  }
}
