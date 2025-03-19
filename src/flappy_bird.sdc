//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11 
//Created Time: 2025-03-19 20:27:05
create_clock -name clk_27M -period 37.037 -waveform {0 18.518} [get_ports {clk_27M}]
set_false_path -from [get_clocks {clk_27M}] -to [get_regs {*btn_synchronizer_clk_*/sync*}] 
