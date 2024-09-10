library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.processor_utils.all;
use work.crossbar_utils.all;

entity Synapse_Dout_Mux is
	Generic (
		CROSSBAR_COL_WIDTH  : integer := 32
		);
    Port ( 
        SYNAPSE_MEM_SELECT   : in  std_logic_vector(clogb2(CROSSBAR_COL_WIDTH)-1 downto 0);
        SYNAPSE_MEM_DOUT     : in  SYNAPTICMEMDATA(0 to CROSSBAR_COL_WIDTH-1);
        MUXDOUT              : out std_logic_vector(15 downto 0)
        );
end Synapse_Dout_Mux;

architecture Behavioral of Synapse_Dout_Mux is

begin

        MUXDOUT <= SYNAPSE_MEM_DOUT(to_integer(unsigned(SYNAPSE_MEM_SELECT)));

end Behavioral;
