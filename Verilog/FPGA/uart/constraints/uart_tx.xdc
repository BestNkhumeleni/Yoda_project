set_property PACKAGE_PIN D4 [get_ports o_tx]
set_property IOSTANDARD LVCMOS33 [get_ports o_tx]
set_property PACKAGE_PIN H17 [get_ports o_active]
set_property PACKAGE_PIN K15 [get_ports o_done]
set_property IOSTANDARD LVCMOS33 [get_ports o_active]
set_property IOSTANDARD LVCMOS33 [get_ports o_done]
set_property IOSTANDARD LVCMOS33 [get_ports i_data_avial]
set_property PACKAGE_PIN E3 [get_ports clk]
set_property PACKAGE_PIN T8 [get_ports i_data_avial]
set_property PACKAGE_PIN J15 [get_ports {i_data_byte[0]}]
set_property PACKAGE_PIN L16 [get_ports {i_data_byte[1]}]
set_property PACKAGE_PIN M13 [get_ports {i_data_byte[2]}]
set_property PACKAGE_PIN R15 [get_ports {i_data_byte[3]}]
set_property PACKAGE_PIN R17 [get_ports {i_data_byte[4]}]
set_property PACKAGE_PIN T18 [get_ports {i_data_byte[5]}]
set_property PACKAGE_PIN U18 [get_ports {i_data_byte[6]}]
set_property PACKAGE_PIN R13 [get_ports {i_data_byte[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_byte[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_byte[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_byte[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_byte[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_byte[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_byte[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_byte[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_data_byte[0]}]

create_clock -period 10.000 -name clk -waveform {0.000 5.000} clk
