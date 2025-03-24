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

    def __init__(self, gpu: Gpu):
        self.gpu = gpu
        self.lose = False

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

        return CpuOutputs(self.lose)
