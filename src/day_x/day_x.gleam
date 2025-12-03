//// Template module dayX

import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import lib/timing.{run_timed}

// import simplifile

const sample = "1 2"

pub fn run() {
  // let assert Ok(input) = simplifile.read("input.txt")

  io.println("Sample")
  let assert 2 = run_timed(part1, sample)
  // let assert 4_174_379_265 = run_timed(part2, sample)

  // io.println("")
  // io.println("Input")
  // run_timed(part1, input)
  // run_timed(part2, input)
}

pub fn part1(input: String) -> Int {
  solve(input)
}

pub fn part2(input: String) -> Int {
  solve(input)
}

fn solve(input: String) -> Int {
  let values = parse(input)
  echo values
  list.length(values)
}

fn parse(input: String) -> List(Int) {
  list.map(string.split(input, " "), int.parse)
  |> list.map(fn(x) { result.unwrap(x, 0) })
}
