from dataclasses import dataclass


@dataclass
class GpuOp:
    x: int
    y: int
    width: int
    height: int
    color: bool
    mem_en: bool
    mem_addr: int
    scale: int


class Gpu:
    mem: list[bool]

    def __init__(self, mem: list[bool]):
        self.mem = mem

    def draw(self, op: GpuOp): ...
