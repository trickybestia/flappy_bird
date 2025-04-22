# 🚧W.I.P.🚧 flappy_bird

Flappy Bird game on Sipeed Tang Primer 20K FPGA board.

## Branches

### [single-fsm](https://github.com/trickybestia/flappy_bird/tree/single-fsm)
It just works. All logic is implemented using single fsm, which renders pixels to framebuffer. Not a good example of SystemVerilog development. 😅

### [main](https://github.com/trickybestia/flappy_bird/tree/main)
It contains work in progress implementation with logic splitted between [cpu module](https://github.com/trickybestia/flappy_bird/blob/main/src/cpu.sv) and [gpu module](https://github.com/trickybestia/flappy_bird/blob/main/src/gpu.sv). GPU draws primitives: filled and textured rectangles. CPU sends commands to GPU. CPU is still in development so now it is nothing more than a simple fsm.

## License

Licensed under [MIT license](LICENSE) only.
