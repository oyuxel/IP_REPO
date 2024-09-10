# Runtime Tcl commands to interact with - SNN_PROCESSOR

# Sourcing design address info tcl
set bd_path [get_property DIRECTORY [current_project]]/[current_project].srcs/[current_fileset]/bd
source ${bd_path}/SNN_PROCESSOR_include.tcl

# jtag axi master interface hardware name, change as per your design.
set jtag_axi_master hw_axi_1
set ec 0

# hw test script
# Delete all previous axis transactions
if { [llength [get_hw_axi_txns -quiet]] } {
	delete_hw_axi_txn [get_hw_axi_txns -quiet]
}


# Test all lite slaves.
set wdata_1 abcd1234

# Test: CONTROLS
# Create a write transaction at controls_addr address
create_hw_axi_txn w_controls_addr [get_hw_axis $jtag_axi_master] -type write -address $controls_addr -data $wdata_1
# Create a read transaction at controls_addr address
create_hw_axi_txn r_controls_addr [get_hw_axis $jtag_axi_master] -type read -address $controls_addr
# Initiate transactions
run_hw_axi r_controls_addr
run_hw_axi w_controls_addr
run_hw_axi r_controls_addr
set rdata_tmp [get_property DATA [get_hw_axi_txn r_controls_addr]]
# Compare read data
if { $rdata_tmp == $wdata_1 } {
	puts "Data comparison test pass for - CONTROLS"
} else {
	puts "Data comparison test fail for - CONTROLS, expected-$wdata_1 actual-$rdata_tmp"
	inc ec
}

# Test: SYNAPSES
# Create a write transaction at synapses_addr address
create_hw_axi_txn w_synapses_addr [get_hw_axis $jtag_axi_master] -type write -address $synapses_addr -data $wdata_1
# Create a read transaction at synapses_addr address
create_hw_axi_txn r_synapses_addr [get_hw_axis $jtag_axi_master] -type read -address $synapses_addr
# Initiate transactions
run_hw_axi r_synapses_addr
run_hw_axi w_synapses_addr
run_hw_axi r_synapses_addr
set rdata_tmp [get_property DATA [get_hw_axi_txn r_synapses_addr]]
# Compare read data
if { $rdata_tmp == $wdata_1 } {
	puts "Data comparison test pass for - SYNAPSES"
} else {
	puts "Data comparison test fail for - SYNAPSES, expected-$wdata_1 actual-$rdata_tmp"
	inc ec
}

# Test: PARAMSPACE
# Create a write transaction at paramspace_addr address
create_hw_axi_txn w_paramspace_addr [get_hw_axis $jtag_axi_master] -type write -address $paramspace_addr -data $wdata_1
# Create a read transaction at paramspace_addr address
create_hw_axi_txn r_paramspace_addr [get_hw_axis $jtag_axi_master] -type read -address $paramspace_addr
# Initiate transactions
run_hw_axi r_paramspace_addr
run_hw_axi w_paramspace_addr
run_hw_axi r_paramspace_addr
set rdata_tmp [get_property DATA [get_hw_axi_txn r_paramspace_addr]]
# Compare read data
if { $rdata_tmp == $wdata_1 } {
	puts "Data comparison test pass for - PARAMSPACE"
} else {
	puts "Data comparison test fail for - PARAMSPACE, expected-$wdata_1 actual-$rdata_tmp"
	inc ec
}

# Check error flag
if { $ec == 0 } {
	 puts "PTGEN_TEST: PASSED!" 
} else {
	 puts "PTGEN_TEST: FAILED!" 
}

