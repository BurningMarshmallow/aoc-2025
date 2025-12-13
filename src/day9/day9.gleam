import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lib/helpers
import lib/timing.{run_timed}
import simplifile

type V {
  V(x: Int, y: Int)
}

const sample = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

pub fn run() {
  let assert Ok(input) = simplifile.read("input.txt")

  io.println("Sample")
  let assert 50 = run_timed(part1, sample)
  let assert 24 = run_timed(part2, sample)

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
  parse(input)
  |> helpers.all_pairs
  |> list.map(get_area)
  |> helpers.max
}

fn parse(input: String) -> List(V) {
  helpers.read_lines(input)
  |> list.map(fn(line) {
    let assert [x, y] =
      string.split(line, ",") |> list.map(helpers.unsafe_parse_int)
    V(x, y)
  })
}

fn get_area(pair: #(V, V)) -> Int {
  let #(p1, p2) = pair
  { int.absolute_value(p1.x - p2.x) + 1 }
  * { int.absolute_value(p1.y - p2.y) + 1 }
}

fn solve_part2(input: String) -> Int {
  let values = parse(input)

  let x_coords =
    values
    |> list.map(fn(value) { value.x })
    |> list.unique
    |> list.sort(int.compare)
  let y_coords =
    values
    |> list.map(fn(value) { value.y })
    |> list.unique
    |> list.sort(int.compare)

  let x_indices = transform_to_indices(x_coords)
  let y_indices = transform_to_indices(y_coords)

  let grid_size_x = 2 * list.length(x_coords) + 4
  let grid_size_y = 2 * list.length(y_coords) + 4

  let grid =
    list.range(0, grid_size_x)
    |> list.map(fn(_) { list.repeat("?", grid_size_y) })
  let grid_with_polygon = fill_all_lines(grid, values, x_indices, y_indices)
  let grid_with_marked_external = flood_fill(grid_with_polygon)

  values
  |> helpers.all_pairs
  |> list.filter(fn(pair) {
    is_internal_area(pair, grid_with_marked_external, x_indices, y_indices)
  })
  |> list.map(get_area)
  |> helpers.max
}

fn transform_to_indices(coords) {
  coords
  |> list.index_map(fn(value, index) { #(value, 2 * index + 2) })
  |> dict.from_list
}

fn fill_all_lines(grid: List(List(String)), points, x_indices, y_indices) {
  let last = list.length(points) - 1

  let grid =
    list.range(0, last - 1)
    |> list.fold(grid, fn(g, i) {
      let p1 = helpers.at(points, i)
      let p2 = helpers.at(points, i + 1)
      fill_line(g, p1, p2, x_indices, y_indices)
    })
  let p_last = helpers.at(points, last)
  let p_first = helpers.at(points, 0)

  fill_line(grid, p_last, p_first, x_indices, y_indices)
}

fn fill_line(grid, p1: V, p2: V, x_indices, y_indices) {
  let min_x = int.min(p1.x, p2.x)
  let max_x = int.max(p1.x, p2.x)
  let min_y = int.min(p1.y, p2.y)
  let max_y = int.max(p1.y, p2.y)

  list.range(
    helpers.unsafe_get(x_indices, min_x),
    helpers.unsafe_get(x_indices, max_x),
  )
  |> list.fold(grid, fn(g1, x) {
    list.range(
      helpers.unsafe_get(y_indices, min_y),
      helpers.unsafe_get(y_indices, max_y),
    )
    |> list.fold(g1, fn(g2, y) { set_cell(g2, x, y, "#") })
  })
}

fn set_cell(grid, x, y, value) {
  let row_to_update = helpers.at(grid, x)
  let updated_row = helpers.update(row_to_update, y, value)
  helpers.update(grid, x, updated_row)
}

fn flood_fill(grid: List(List(String))) {
  let start = V(0, 0)
  let grid = grid |> set_cell(0, 0, ".")
  flood_loop(grid, [start])
}

fn flood_loop(grid: List(List(String)), queue: List(V)) {
  case queue {
    [] -> grid
    [p, ..rest] -> {
      let #(new_grid, new_points) = flood_neighbors(grid, p)

      flood_loop(new_grid, list.append(rest, new_points))
    }
  }
}

fn flood_neighbors(grid: List(List(String)), p: V) {
  let deltas = list.range(-1, 1)

  list.fold(deltas, #(grid, []), fn(acc, dx) {
    list.fold(deltas, acc, fn(acc2, dy) {
      let x = p.x + dx
      let y = p.y + dy

      case in_bounds(grid, x, y) && cell_is_unknown(grid, x, y) {
        True -> {
          let new_grid = set_cell(acc2.0, x, y, ".")
          #(new_grid, list.append(acc2.1, [V(x, y)]))
        }
        False -> {
          acc2
        }
      }
    })
  })
}

fn in_bounds(grid, x, y) {
  x >= 0
  && y >= 0
  && x < list.length(grid)
  && y < list.length(helpers.at(grid, 0))
}

fn cell_is_unknown(grid, x, y) {
  helpers.at(helpers.at(grid, x), y) == "?"
}

fn is_internal_area(pair: #(V, V), marked, x_indices, y_indices) -> Bool {
  let #(p1, p2) = pair
  let min_x = int.min(p1.x, p2.x) |> helpers.unsafe_get(x_indices, _)
  let max_x = int.max(p1.x, p2.x) |> helpers.unsafe_get(x_indices, _)
  let min_y = int.min(p1.y, p2.y) |> helpers.unsafe_get(y_indices, _)
  let max_y = int.max(p1.y, p2.y) |> helpers.unsafe_get(y_indices, _)

  sublist(marked, min_x, max_x + 1)
  |> list.all(fn(row) {
    row |> sublist(min_y, max_y + 1) |> list.all(fn(cell) { cell != "." })
  })
}

fn sublist(value: List(a), i: Int, j: Int) {
  value |> list.drop(i) |> list.take(j - i)
}
