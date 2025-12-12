import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub type Interval {
  Interval(start: Int, end: Int)
}

pub fn unsafe_parse_int(value: String) -> Int {
  let value = string.trim(value)
  let assert Ok(int_value) = int.parse(value)
  int_value
}

pub fn read_lines(input: String) -> List(String) {
  string.split(string.replace(input, "\r\n", "\n"), "\n")
}

pub fn get_grid(input: String) -> List(List(#(Int, Int, String))) {
  let lines = read_lines(input)
  list.index_map(lines, fn(row, row_idx) {
    list.index_map(string.split(row, ""), fn(value, col_idx) {
      #(row_idx, col_idx, value)
    })
  })
}

pub fn sum(values: List(Int)) -> Int {
  values |> list.fold(0, int.add)
}

pub fn mul(values: List(Int)) -> Int {
  values |> list.fold(1, int.multiply)
}

pub fn sum_with_transform(values: List(a), transform: fn(a) -> Int) -> Int {
  values
  |> list.map(transform)
  |> list.reduce(int.add)
  |> result.unwrap(0)
}

pub fn find_index(value: List(a), target: a) -> Result(Int, Nil) {
  value
  |> list.index_map(fn(elem, index) { #(index, elem) })
  |> list.find(fn(x) { pair.second(x) == target })
  |> result.map(pair.first)
}

pub fn get_at_index(list: List(a), index: Int) -> a {
  let assert Ok(value) =
    list.drop(list, index)
    |> list.first
  value
}

pub fn get_at_index_list(list: List(List(String)), index: Int) -> List(String) {
  list.drop(list, index)
  |> list.first
  |> result.unwrap([])
}

pub fn get_at_index_2d(list: List(List(String)), i: Int, j: Int) -> String {
  get_at_index_list(list, i)
  |> get_at_index(j)
}

pub fn generate_index_pairs(arr: List(a)) -> List(#(Int, Int)) {
  let indices = list.range(0, list.length(arr) - 1)

  list.flat_map(indices, fn(i) {
    list.map(list.drop(indices, i + 1), fn(j) { #(i, j) })
  })
}

pub fn read_range(value: String) -> List(Int) {
  let assert [start, end] =
    string.split(value, "-")
    |> list.filter_map(int.parse)

  list.range(start, end)
}
