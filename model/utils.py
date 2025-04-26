from pathlib import Path


def read_mem(path: str) -> list[bool]:
    lines = Path(path).read_text().split()
    values = {"0": False, "1": True}

    return list(map(values.get, lines))


def check_rectangles_intersection(x1, y1, w1, h1, x2, y2, w2, h2) -> bool:
    return x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and y1 + h1 > y2
