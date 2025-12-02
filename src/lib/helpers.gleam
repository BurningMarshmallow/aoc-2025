import gleam/int
import gleam/list
import gleam/string

pub fn read_range(value: String) -> List(Int) {
  let #(start, end) = case
    string.split(value, "-")
    |> list.filter_map(int.parse)
  {
    [start, end] -> #(start, end)
    _ -> panic as "Invalid range"
  }
  list.range(start, end)
}
