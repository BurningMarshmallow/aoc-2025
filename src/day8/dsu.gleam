import gleam/dict.{type Dict}
import gleam/list
import gleam/result

pub type Dsu(a) {
  Dsu(parent: Dict(a, a), size: Dict(a, Int))
}

pub fn new(xs: List(a)) -> Dsu(a) {
  let parent =
    xs
    |> list.fold(dict.new(), fn(acc, value) { dict.insert(acc, value, value) })

  let size =
    xs |> list.fold(dict.new(), fn(acc, value) { dict.insert(acc, value, 1) })

  Dsu(parent, size)
}

fn find(dsu: Dsu(a), x: a) -> #(Dsu(a), a) {
  let Dsu(parent, _) = dsu

  case dict.get(parent, x) {
    Ok(p) if p == x -> #(dsu, x)

    Ok(p) -> {
      let #(dsu2, root) = find(dsu, p)
      let Dsu(parent2, size2) = dsu2
      let parent3 = dict.insert(parent2, x, root)
      #(Dsu(parent3, size2), root)
    }

    _ -> #(dsu, x)
  }
}

pub fn merge(dsu: Dsu(a), x: a, y: a) -> #(Dsu(a), Bool) {
  let #(dsu2, rx) = find(dsu, x)
  let #(dsu3, ry) = find(dsu2, y)

  case rx == ry {
    True -> #(dsu3, False)

    False -> {
      let Dsu(parent, size) = dsu3
      let sx = dict.get(size, rx) |> result.unwrap(1)
      let sy = dict.get(size, ry) |> result.unwrap(1)

      // union by size
      case sx >= sy {
        True -> {
          let parent2 = dict.insert(parent, ry, rx)
          let size2 = dict.insert(size, rx, sx + sy)
          #(Dsu(parent2, size2), True)
        }

        False -> {
          let parent2 = dict.insert(parent, rx, ry)
          let size2 = dict.insert(size, ry, sx + sy)
          #(Dsu(parent2, size2), True)
        }
      }
    }
  }
}

// Produce a list of components as lists
pub fn components(dsu: Dsu(a)) -> List(List(a)) {
  let Dsu(parent, _) = dsu
  let items = dict.keys(parent)

  items
  |> list.map(fn(x) {
    let #(_, r) = find(dsu, x)
    #(x, r)
  })
  |> group_by_root
}

fn group_by_root(pairs: List(#(a, a))) -> List(List(a)) {
  pairs
  |> list.fold(dict.new(), fn(acc, pair) {
    let #(x, root) = pair
    let xs = dict.get(acc, root) |> result.unwrap([])
    dict.insert(acc, root, [x, ..xs])
  })
  |> dict.values
}
