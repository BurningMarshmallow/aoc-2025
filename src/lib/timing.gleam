import gleam/erlang/charlist.{type Charlist}
import gleam/float
import gleam/int

@external(erlang, "timer", "tc")
pub fn timed(fun: fn() -> a) -> #(Int, a)

@external(erlang, "io_lib", "format")
fn do_format(format: String, data: List(a)) -> Charlist

pub fn format_execution_time(execution_time: Int) -> String {
  let #(divisor, precision, unit) = case execution_time {
    t if t > 1_000_000 -> #(1_000_000.0, 3, " s")
    t if t > 1000 -> #(1000.0, 3, " ms")
    _ -> #(1.0, 0, " µs")
  }
  format_float(int.to_float(execution_time) /. divisor, precision) <> unit
}

fn format_float(input: Float, precision: Int) -> String {
  case precision {
    p if p >= 1 ->
      do_format("~." <> int.to_string(precision) <> "f", [input])
      |> charlist.to_string
    _ -> float.truncate(input) |> int.to_string
  }
}
