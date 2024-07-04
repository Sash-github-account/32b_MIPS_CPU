create_clock -name clk -period "10MHz" [get_ports clk]


set_false_path -from [get_ports rst_n] -to *
set_false_path -from * -to [get_ports memread_ctrl]
set_false_path -from * -to [get_ports LED_o[*]]