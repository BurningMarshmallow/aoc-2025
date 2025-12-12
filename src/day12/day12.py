# Written by ChatGPT
import re
from functools import lru_cache

# ============================================================
# Parsing
# ============================================================


def parse_shapes_and_regions(text):
    lines = [x.rstrip("\n") for x in text.strip().split("\n")]
    shapes = {}
    regions = []
    i = 0

    # Parse shapes
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue

        m = re.match(r"^(\d+):$", line)
        if not m:
            break

        idx = int(m.group(1))
        i += 1
        block = []
        while i < len(lines) and (lines[i].startswith("#") or lines[i].startswith(".")):
            block.append(lines[i])
            i += 1
        shapes[idx] = block

    # Parse regions
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue

        size, nums = line.split(":")
        W, H = map(int, size.split("x"))
        counts = list(map(int, nums.split()))
        regions.append((W, H, counts))
        i += 1

    return shapes, regions


# ============================================================
# Geometry helpers
# ============================================================


def shape_cells(grid):
    return [(r, c) for r, row in enumerate(grid) for c, v in enumerate(row) if v == "#"]


def normalize(cells):
    min_r = min(r for r, _ in cells)
    min_c = min(c for _, c in cells)
    return tuple(sorted((r - min_r, c - min_c) for r, c in cells))


def rot_90(cells):
    return [(c, -r) for r, c in cells]


def reflect_h(cells):
    return [(r, -c) for r, c in cells]


def all_orientations(grid):
    base = shape_cells(grid)
    seen = set()
    result = []
    cur = base

    for _ in range(4):
        n = normalize(cur)
        if n not in seen:
            seen.add(n)
            result.append(n)

        f = normalize(reflect_h(cur))
        if f not in seen:
            seen.add(f)
            result.append(f)

        cur = rot_90(cur)

    return result


# ============================================================
# Compact mask key
# ============================================================


def mask_to_bytes(m):
    if m == 0:
        return b"\x00"
    return m.to_bytes((m.bit_length() + 7) // 8, "little")


# ============================================================
# Region solver — no unsafe pruning
# ============================================================


def solve_region(W, H, counts, orient):
    pieces = []
    for s, c in enumerate(counts):
        pieces.extend([s] * c)
    if not pieces:
        return True

    # Area check
    shape_area = {s: len(orient[s][0]) for s in orient}
    if sum(shape_area[s] for s in pieces) > W * H:
        return False

    # Precompute placements per shape
    placements_by_shape = {}
    for s in set(pieces):
        plist = []
        for shp in orient[s]:
            max_r = max(r for r, _ in shp)
            max_c = max(c for _, c in shp)
            h = max_r + 1
            w = max_c + 1
            if h > H or w > W:
                continue

            for r0 in range(H - h + 1):
                rowoff = r0 * W
                for c0 in range(W - w + 1):
                    m = 0
                    base = rowoff + c0
                    for dr, dc in shp:
                        m |= 1 << (base + dr * W + dc)
                    plist.append(m)

        placements_by_shape[s] = plist

    # Order pieces by fewest placements
    order = sorted(
        range(len(pieces)), key=lambda i: len(placements_by_shape[pieces[i]])
    )
    plists = [placements_by_shape[pieces[i]] for i in order]

    total_cells = W * H

    @lru_cache(None)
    def backtrack(mask_bytes, idx):
        mask = int.from_bytes(mask_bytes, "little")

        if idx == len(plists):
            return True

        inv = ~mask & ((1 << total_cells) - 1)
        if inv == 0:
            return False

        # Safe pruning: only require placements to cover at least one empty cell
        cur = plists[idx]
        for pm in cur:
            if pm & mask:
                continue
            if pm & inv == 0:  # placement covers no remaining empty space
                continue

            new_mask = mask | pm
            if backtrack(mask_to_bytes(new_mask), idx + 1):
                return True

        return False

    return backtrack(b"\x00", 0)


def solve_all(text):
    shapes, regions = parse_shapes_and_regions(text)
    orient = {idx: all_orientations(grid) for idx, grid in shapes.items()}

    max_idx = max(shapes.keys())

    ok = 0
    for W, H, counts in regions:
        print("Solved", ok)
        counts = counts + [0] * (max_idx + 1 - len(counts))
        if solve_region(W, H, counts, orient):
            ok += 1
    return ok


def main():
    with open("input.txt") as f:
        data = f.read()
    print(solve_all(data))


if __name__ == "__main__":
    main()
