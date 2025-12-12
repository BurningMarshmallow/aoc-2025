import day8/dsu
import day8/vec3.{type V3}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lib/helpers
import lib/timing.{run_timed}
import simplifile

const sample = "162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689"

pub fn run() {
  let assert Ok(input) = simplifile.read("input.txt")

  io.println("Sample")
  let assert 40 = run_timed(part1, sample)
  let assert 25_272 = run_timed(part2, sample)

  io.println("")
  io.println("Input")
  run_timed(part1, input)
  run_timed(part2, input)
}

pub fn part1(input: String) -> Int {
  solve(input).0
}

pub fn part2(input: String) -> Int {
  solve(input).1
}

fn solve(input) {
  let xs = parse(input)
  solve_with_dsu(xs)
}

fn parse(input: String) -> List(V3) {
  let lines = helpers.read_lines(input)
  lines
  |> list.map(fn(line) {
    let assert [x, y, z] =
      line
      |> string.split(",")
      |> list.map(fn(s) { s |> helpers.unsafe_parse_int })
    vec3.V3(x, y, z)
  })
}

pub fn solve_with_dsu(vs) {
  let num_pairs = case list.length(vs) == 20 {
    // Sample input
    True -> 10
    // Real input
    False -> 1000
  }

  // All ordered pairs
  let pairs =
    vs
    |> all_pairs
    |> list.sort(fn(a, b) { compare_distance(a, b) })

  // Merge the closest `num_pairs`
  let merged_components =
    pairs
    |> list.take(num_pairs)
    |> list.fold(dsu.new(vs), fn(acc, p) {
      let #(x, y) = p
      dsu.merge(acc, x, y).0
    })
  // Get component sizes
  let sizes =
    dsu.components(merged_components)
    |> list.map(list.length)
    |> list.sort(int.compare)
    |> list.reverse
    |> list.take(3)
  let product =
    sizes
    |> list.fold(1, int.multiply)

  // Connect remaining pairs
  let last_connected = #(vec3.zero(), vec3.zero())
  let result =
    pairs
    |> list.drop(num_pairs)
    |> list.fold(#(merged_components, last_connected), fn(acc, next_pair) {
      let #(components, _) = acc
      let #(x, y) = next_pair
      let merge_result = dsu.merge(components, x, y)
      case merge_result.1 {
        True -> #(merge_result.0, next_pair)
        False -> #(merge_result.0, acc.1)
      }
    })

  let #(a, b) = result.1
  #(product, a.x * b.x)
}

fn all_pairs(xs: List(a)) -> List(#(a, a)) {
  helpers.generate_index_pairs(xs)
  |> list.map(fn(pair) {
    let #(i, j) = pair
    #(helpers.get_at_index(xs, i), helpers.get_at_index(xs, j))
  })
}

fn compare_distance(p1: #(V3, V3), p2: #(V3, V3)) {
  let #(a1, b1) = p1
  let #(a2, b2) = p2
  let d1 = vec3.distance(a1, b1)
  let d2 = vec3.distance(a2, b2)
  int.compare(d1, d2)
}
