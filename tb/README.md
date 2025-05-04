# Testbenches

## Requirements

1. Icarus Verilog.
2. GTKWave.
3. bash or other shell to run commands.

All commands should be run inside current directory.

### Top module ([top_tb.sv](top_tb.sv))

Run Synthesis and Place & Route in GOWIN FPGA DESIGNER, then execute following commands (replace PATH_TO_GOWIN_IDE_ROOT with your value):

```bash
iverilog -g2005-sv -grelative-include -s top_tb -o top_tb.out top_tb.sv ../impl/pnr/flappy_bird.vo PATH_TO_GOWIN_IDE_ROOT/IDE/simlib/gw2a/prim_sim.v && ./top_tb.out
gtkwave top_tb.gtkw
```

### Other modules

#### [bcd_ripple_carry_adder_tb.sv](bcd_ripple_carry_adder_tb.sv)

```bash
iverilog -g2005-sv -grelative-include -s bcd_ripple_carry_adder_tb -o bcd_ripple_carry_adder_tb.out bcd_ripple_carry_adder_tb.sv ../src/{bcd_ripple_carry_adder.sv,bcd_adder.sv} && ./bcd_ripple_carry_adder_tb.out
gtkwave bcd_ripple_carry_adder_tb.gtkw
```

#### [btn_debouncer_tb.sv](btn_debouncer_tb.sv)

```bash
iverilog -g2005-sv -grelative-include -s btn_debouncer_tb -o btn_debouncer_tb.out btn_debouncer_tb.sv ../src/{btn_debouncer.sv,synchronizer.sv} && ./btn_debouncer_tb.out
gtkwave btn_debouncer_tb.gtkw
```

#### [cpu_tb.sv](cpu_tb.sv)

```bash
iverilog -g2005-sv -grelative-include -s cpu_tb -o cpu_tb.out cpu_tb.sv ../src/{cpu.sv,fifo.sv,gpu_op_t.sv,pipes_list.sv,lfsr_rng.sv,bcd_ripple_carry_adder.sv,bcd_adder.sv} && ./cpu_tb.out
gtkwave cpu_tb.gtkw
```

#### [fifo_tb.sv](fifo_tb.sv)

```bash
iverilog -g2005-sv -grelative-include -s fifo_tb -o fifo_tb.out fifo_tb.sv ../src/fifo.sv && ./fifo_tb.out
gtkwave fifo_tb.gtkw
```

#### [frame_renderer_tb](frame_renderer_tb.sv)

```bash
iverilog -g2005-sv -grelative-include -s frame_renderer_tb -o frame_renderer_tb.out frame_renderer_tb.sv ../src/{frame_renderer.sv,cpu.sv,fifo.sv,gpu.sv,pipes_list.sv,lfsr_rng.sv,asset_mem.sv,bcd_ripple_carry_adder.sv,bcd_adder.sv} && ./frame_renderer_tb.out
gtkwave frame_renderer_tb.gtkw
```

#### [gpu_tb.sv](gpu_tb.sv)

```bash
iverilog -g2005-sv -grelative-include -s gpu_tb -o gpu_tb.out gpu_tb.sv ../src/{gpu.sv,gpu_op_t.sv,asset_mem.sv} && ./gpu_tb.out
gtkwave gpu_tb.gtkw
```

#### [pipes_list_tb.sv](pipes_list_tb.sv)

```bash
iverilog -g2005-sv -grelative-include -s pipes_list_tb -o pipes_list_tb.out pipes_list_tb.sv ../src/{fifo.sv,pipes_list.sv} && ./pipes_list_tb.out
gtkwave pipes_list_tb.gtkw
```
