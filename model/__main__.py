import pygame

from .cpu import Cpu, CpuInputs
from .gpu import Gpu
from .parameters import *
from .spin_timer import SpinTimer
from .utils import read_mem

GPU_MEM_PATH = "src/asset_mem.mem"


def main():
    pygame.init()

    screen = pygame.display.set_mode(
        (HOR_ACTIVE_PIXELS, VER_ACTIVE_PIXELS), vsync=1
    )

    gpu = Gpu(read_mem(GPU_MEM_PATH), screen)
    cpu = Cpu(gpu)

    lose = None
    btn = False
    autoplay = True

    timer = SpinTimer(FPS)

    def on_tick():
        nonlocal lose, btn, autoplay

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                timer.stop()

                return
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_SPACE:
                    btn = True
                elif event.key == pygame.K_a:
                    autoplay = not autoplay
            elif event.type == pygame.KEYUP:
                if event.key == pygame.K_SPACE:
                    btn = False

        cpu_outputs = cpu.draw_frame(CpuInputs(btn, autoplay))

        if cpu_outputs.lose != lose:
            lose = cpu_outputs.lose

            print(f"lose = {lose}")

        pygame.display.update()

    timer.on_tick = on_tick

    timer.run()

    pygame.quit()


main()
