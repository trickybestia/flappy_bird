import pygame

from .cpu import Cpu, CpuInputs
from .gpu import Gpu
from .parameters import *
from .spin_clock import SpinClock
from .utils import read_mem

GPU_MEM_PATH = "src/asset_mem.mem"


def main():
    gpu = Gpu(read_mem(GPU_MEM_PATH))
    cpu = Cpu(gpu)

    lose = None

    pygame.init()

    screen = pygame.display.set_mode((HOR_ACTIVE_PIXELS, VER_ACTIVE_PIXELS))

    spin_clock = SpinClock(FPS)

    def on_tick():
        nonlocal lose

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                spin_clock.stop()

                return

        cpu_outputs = cpu.draw_frame(CpuInputs(False))

        if cpu_outputs.lose != lose:
            lose = cpu_outputs.lose

            print(f"lose = {lose}")

        pygame.display.update()

    spin_clock.on_tick = on_tick

    spin_clock.run()

    pygame.quit()


main()
