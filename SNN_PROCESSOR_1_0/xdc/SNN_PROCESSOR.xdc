set_false_path -from [get_clocks CORE_CLOCK] -to [get_clocks controls_aclk]
set_false_path -from [get_clocks controls_aclk] -to [get_clocks CORE_CLOCK]

set_false_path -from [get_clocks CORE_CLOCK] -to [get_clocks paramspace_aclk]
set_false_path -from [get_clocks paramspace_aclk] -to [get_clocks CORE_CLOCK]

set_false_path -from [get_clocks CORE_CLOCK] -to [get_clocks spike_in_aclk]
set_false_path -from [get_clocks spike_in_aclk] -to [get_clocks CORE_CLOCK]

set_false_path -from [get_clocks CORE_CLOCK] -to [get_clocks spike_out_aclk]
set_false_path -from [get_clocks spike_out_aclk] -to [get_clocks CORE_CLOCK]
