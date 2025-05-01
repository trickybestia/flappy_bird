from dataclasses import dataclass

import pygame.draw
from pygame import Surface

from .parameters import *


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
    screen: Surface
    mem: list[bool]

    def __init__(self, mem: list[bool], screen: Surface):
        self.mem = mem
        self.screen = screen

    def draw(self, op: GpuOp):
        if op.mem_en:
            for rel_x in range(op.width):
                for rel_y in range(op.height):
                    if (
                        not 0 <= op.x + rel_x < HOR_ACTIVE_PIXELS
                        or not 0 <= op.y + rel_y < VER_ACTIVE_PIXELS
                    ):
                        raise ValueError(
                            "gpu primitive coordinates out of bounds"
                        )

                    mem_address = (
                        op.mem_addr
                        + (rel_y >> op.scale) * (op.width >> op.scale)
                        + (rel_x >> op.scale)
                    )
                    color = (
                        (255, 255, 255) if self.mem[mem_address] else (0, 0, 0)
                    )

                    self.screen.set_at((op.x + rel_x, op.y + rel_y), color)
        else:
            if (
                not 0 <= op.x < HOR_ACTIVE_PIXELS
                or not 0 <= op.y < VER_ACTIVE_PIXELS
                or not 0 <= op.x + op.width <= HOR_ACTIVE_PIXELS
                or not 0 <= op.y + op.height <= VER_ACTIVE_PIXELS
            ):
                raise ValueError("gpu primitive coordinates out of bounds")

            pygame.draw.rect(
                self.screen,
                (255, 255, 255) if op.color else (0, 0, 0),
                (op.x, op.y, op.width, op.height),
            )
