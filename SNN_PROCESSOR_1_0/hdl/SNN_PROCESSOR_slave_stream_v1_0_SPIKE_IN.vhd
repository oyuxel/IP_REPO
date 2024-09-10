library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SNN_PROCESSOR_slave_stream_v1_0_SPIKE_IN is
	generic (
		-- Users to add parameters here
		CROSSBAR_ROW_WIDTH  : integer := 32;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
    
        MAIN_BUFFER_FULL : in  std_logic;
        MAIN_BUFFER_WREN : out std_logic;
        MAIN_BUFFER_DIN  : out std_logic_vector(CROSSBAR_ROW_WIDTH-1 downto 0);


		-- User ports ends
		-- Do not modify the ports beyond this line

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end SNN_PROCESSOR_slave_stream_v1_0_SPIKE_IN;

architecture arch_imp of SNN_PROCESSOR_slave_stream_v1_0_SPIKE_IN is

    begin   
	
	S_AXIS_TREADY <= not MAIN_BUFFER_FULL;
	MAIN_BUFFER_WREN <= S_AXIS_TVALID;
	MAIN_BUFFER_DIN  <= S_AXIS_TDATA(CROSSBAR_ROW_WIDTH-1 downto 0);
	
end arch_imp;