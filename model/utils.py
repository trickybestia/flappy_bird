from pathlib import Path


def read_mem(path: str) -> list[bool]:
    lines = Path(path).read_text().split()
    values = {"0": False, "1": True}

    return list(map(values.get, lines))
