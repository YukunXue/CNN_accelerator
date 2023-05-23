cd ../sim

set testbentch_module=tb_top
set testbentch_file="%testbentch_module%.sv"

set rtl_file="../rtl/*.v"

iverilog -g2012 -o "../build/%testbentch_module%.vvp" %rtl_file%  %testbentch_file%
vvp -n "../build/%testbentch_module%.vvp" -lxt2

set gtkw_file="../build/%testbentch_module%.gtkw"
if exist %gtkw_file% (gtkwave %gtkw_file%) else (gtkwave "../build/%testbentch_module%.vcd")