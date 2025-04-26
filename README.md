# 🚧W.I.P.🚧 flappy_bird

Flappy Bird game on Sipeed Tang Primer 20K FPGA board.

## [main](https://github.com/trickybestia/flappy_bird/tree/main) branch

It contains work in progress implementation with logic splitted between [cpu module](https://github.com/trickybestia/flappy_bird/blob/main/src/cpu.sv) and [gpu module](https://github.com/trickybestia/flappy_bird/blob/main/src/gpu.sv). GPU draws primitives: filled and textured rectangles. CPU sends commands to GPU. CPU is still in development so now it is nothing more than a simple fsm.

There is a high-level game model written in Python to debug game logic.

![](doc/images/model.png)

To launch it make sure that you have [pygame](https://pypi.org/project/pygame/) installed and run `python -m model`. Press `SPACE` to make bird fly up.

## Old [single-fsm](https://github.com/trickybestia/flappy_bird/tree/single-fsm) branch

All logic is implemented using single fsm, which renders pixels to framebuffer. Not a good example of SystemVerilog development. 😅

## License

Licensed under [MIT license](LICENSE) only.
