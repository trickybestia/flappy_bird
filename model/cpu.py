from dataclasses import dataclass
from random import randint

from .gpu import Gpu, GpuOp
from .parameters import *
from .utils import check_rectangles_intersection


@dataclass
class CpuInputs:
    btn: bool
    autoplay: bool


@dataclass
class CpuOutputs:
    lose: bool


@dataclass
class Pipe:
    x: int
    y: int


class Cpu:
    gpu: Gpu
    lose: bool
    score: int
    bird_y: int
    pipes: list[Pipe]

    def __init__(self, gpu: Gpu):
        self.gpu = gpu
        self.lose = False
        self.score = 0
        self.bird_y = VER_ACTIVE_PIXELS // 2 - BIRD_HEIGHT // 2
        self.pipes = []

    def draw_frame(self, inputs: CpuInputs) -> CpuOutputs:
        self._draw_background()

        if not self.lose:
            self._move_bird(inputs)
            self._move_pipes()
            self._check_collision()

        self._draw_bird()
        self._draw_pipes()
        self._draw_score_background()
        self._draw_score()

        return CpuOutputs(self.lose)

    def _draw_background(self):
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

    def _move_bird(self, inputs: CpuInputs):
        closest_pipe_y = (
            self.pipes[0].y
            if len(self.pipes) != 0
            else VER_ACTIVE_PIXELS / 2 - BIRD_HEIGHT / 2
        )
        autoplay_btn = (
            self.bird_y + BIRD_HEIGHT / 2 > closest_pipe_y + PIPE_VER_GAP / 2
        )

        if inputs.btn or (inputs.autoplay and autoplay_btn):
            if self.bird_y <= 2:
                self.lose = True
            else:
                self.bird_y -= 3
        else:
            pixels_above_bird = VER_ACTIVE_PIXELS - self.bird_y - BIRD_HEIGHT

            if pixels_above_bird <= 2:
                self.lose = 1
            else:
                self.bird_y += 3

    def _move_pipes(self):
        for pipe in self.pipes:
            pipe.x -= 1

        if (
            len(self.pipes) == 0
            or HOR_ACTIVE_PIXELS - self.pipes[-1].x - PIPE_WIDTH >= PIPE_HOR_GAP
        ):
            pipe_y = randint(1, VER_ACTIVE_PIXELS - PIPE_VER_GAP - 1)

            self.pipes.append(Pipe(HOR_ACTIVE_PIXELS - 1, pipe_y))

    def _check_collision(self):
        for pipe in self.pipes:
            if check_rectangles_intersection(
                BIRD_HOR_OFFSET,
                self.bird_y,
                BIRD_WIDTH,
                BIRD_HEIGHT,
                pipe.x,
                0,
                PIPE_WIDTH,
                pipe.y,
            ) or check_rectangles_intersection(
                BIRD_HOR_OFFSET,
                self.bird_y,
                BIRD_WIDTH,
                BIRD_HEIGHT,
                pipe.x,
                pipe.y + PIPE_VER_GAP,
                PIPE_WIDTH,
                VER_ACTIVE_PIXELS - pipe.y - PIPE_VER_GAP,
            ):
                self.lose = True

                return

    def _draw_bird(self):
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

    def _draw_pipes(self):
        i = 0

        while i < len(self.pipes):
            pipe = self.pipes[i]

            start_x = max(pipe.x, 0)
            end_x = min(
                pipe.x + PIPE_WIDTH, HOR_ACTIVE_PIXELS
            )  # right x bound of pipe rectangle, exclusive

            if end_x <= 0:
                del self.pipes[i]

                self.score += 1

                continue

            self.gpu.draw(
                GpuOp(start_x, 0, end_x - start_x, pipe.y, True, False, 0, 0)
            )
            self.gpu.draw(
                GpuOp(
                    start_x,
                    pipe.y + PIPE_VER_GAP,
                    end_x - start_x,
                    VER_ACTIVE_PIXELS - pipe.y - PIPE_VER_GAP,
                    True,
                    False,
                    0,
                    0,
                )
            )

            i += 1

    def _draw_score_background(self):
        self.gpu.draw(
            GpuOp(
                HOR_ACTIVE_PIXELS
                - 2 * SCORE_HOR_OFFSET
                - SCORE_DIGIT_WIDTH
                - (SCORE_HOR_GAP + SCORE_DIGIT_WIDTH) * (SCORE_DIGITS - 1),
                0,
                SCORE_DIGITS * SCORE_DIGIT_WIDTH
                + SCORE_HOR_GAP * (SCORE_DIGITS - 1)
                + 2 * SCORE_HOR_OFFSET,
                SCORE_DIGIT_HEIGHT + 2 * SCORE_VER_OFFSET,
                False,
                False,
                0,
                0,
            )
        )

    def _draw_score(self):
        score = self.score

        for i in range(SCORE_DIGITS):
            digit = score % 10
            score //= 10

            self._draw_digit(
                HOR_ACTIVE_PIXELS
                - SCORE_HOR_OFFSET
                - SCORE_DIGIT_WIDTH
                - (SCORE_HOR_GAP + SCORE_DIGIT_WIDTH) * i,
                SCORE_VER_OFFSET,
                digit,
            )

    def _draw_digit(self, x: int, y: int, value: int):
        self.gpu.draw(
            GpuOp(
                x,
                y,
                SCORE_DIGIT_WIDTH,
                SCORE_DIGIT_HEIGHT,
                False,
                True,
                ASSET_MEM_DIGITS_START + ASSET_MEM_DIGITS_STEP * value,
                3,
            )
        )
