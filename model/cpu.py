from dataclasses import dataclass

from .gpu import Gpu, GpuOp
from .parameters import *


@dataclass
class CpuInputs:
    btn: bool


@dataclass
class CpuOutputs:
    lose: bool


class Cpu:
    gpu: Gpu
    lose: bool
    bird_y: int

    def __init__(self, gpu: Gpu):
        self.gpu = gpu
        self.lose = False
        self.bird_y = VER_ACTIVE_PIXELS // 2 - BIRD_HEIGHT // 2

    def draw_frame(self, inputs: CpuInputs) -> CpuOutputs:
        self.gpu.draw(
            GpuOp(
                x=0,
                y=0,
                width=HOR_ACTIVE_PIXELS,
                height=VER_ACTIVE_PIXELS,
                color=0,
                mem_en=0,
                mem_addr=0,
                scale=0,
            )
        )
        self.gpu.draw(
            GpuOp(
                BIRD_HOR_OFFSET,
                self.bird_y,
                BIRD_WIDTH,
                BIRD_HEIGHT,
                False,
                True,
                0,
                1,
            )
        )

        return CpuOutputs(self.lose)
