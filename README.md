# flappy_bird

Flappy Bird game on Sipeed Tang Primer 20K FPGA board.

## Key features

* Resolution: 640x480 60 FPS
* Double buffered HDMI video output using two 300 Kbit BSRAMs and GOWIN DVI TX IP core
* 64.125 MHz frequency for [cpu](src/cpu.sv) and [gpu](src/gpu.sv) modules
* Autoplay switch: game plays itself!

## [main](https://github.com/trickybestia/flappy_bird/tree/main) branch

Logic is splitted between [cpu](src/cpu.sv) and [gpu](src/gpu.sv) modules. GPU draws primitives: filled and textured rectangles. CPU sends commands to GPU.

### Model

There is a high-level game model written in Python to debug game logic.

![](doc/images/model.png)

To launch it make sure that you have [pygame](https://pypi.org/project/pygame/) installed and run `python -m model`. Press `SPACE` to make bird fly up.

### Testbenches

Testbenches are located in [tb](tb) folder. To run them install Icarus Verilog and GTKWave and run following commands in [tb](tb) directory.

## Old [single-fsm](https://github.com/trickybestia/flappy_bird/tree/single-fsm) branch

All logic is implemented using single FSM, which renders pixels to framebuffer. Not a good example of SystemVerilog development. 😅

## License

Licensed under [MIT license](LICENSE) only.
