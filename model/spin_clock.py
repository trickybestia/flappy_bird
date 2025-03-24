from typing import Callable
from time import time


class SpinClock:
    on_tick: Callable[[], None]

    _running: bool
    _fps: int

    def __init__(self, fps: int):
        self.on_tick = None

        self._running = False
        self._fps = fps

    def stop(self):
        self._running = False

    def run(self):
        self._running = True

        while self._running:
            next_call_time = time() + 1 / self._fps

            self.on_tick()

            if not self._running:
                break

            while time() < next_call_time:
                pass  # spin wait
