from pathlib import Path


def read_mem(path: str) -> list[bool]:
    lines = Path(path).read_text().split()

    return list(map(bool, lines))
