library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPIKE_PROPOGATOR is
    generic(
        DEPTH : integer := 64;   -- FIFO derinliği
        WIDTH : integer := 16    -- FIFO genişliği
    );
    port(
        clk       : in  std_logic;
        rst       : in  std_logic;
        wr_en     : in  std_logic;
        rd_en     : in  std_logic;
        data_in   : in  std_logic_vector(WIDTH-1 downto 0);
        data_out  : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity SPIKE_PROPOGATOR;

architecture ich_tu_dir_weh of SPIKE_PROPOGATOR is
    type memory_type is array (0 to DEPTH-1) of std_logic_vector(WIDTH-1 downto 0);
    signal memory     : memory_type;
    signal wr_pointer : integer range 0 to DEPTH-1 := 0;
    signal rd_pointer : integer range 0 to DEPTH-1 := 0;

    attribute RAM_STYLE : string;
    attribute RAM_STYLE of memory: signal is "block";

    
begin

    -- Write process
    write_process : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                wr_pointer <= 0;
                memory <= (others=>(others=>'0'));
            elsif wr_en = '1' then
                memory(wr_pointer) <= data_in;
                wr_pointer <= (wr_pointer + 1) mod DEPTH;
            end if;
        end if;
    end process;

    -- Continuous data output for FWFT
    data_out <= memory(rd_pointer);  -- data_out her zaman güncel veriyi gösterir

    -- Read process with circular pointer behavior
    read_process : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rd_pointer <= 0;
            else
                if rd_en = '1' then
                    if rd_pointer = wr_pointer-1 then
                        rd_pointer <= 0; -- Read pointer ve write pointer eşitse, veri değişmez
                    else
                        rd_pointer <= (rd_pointer + 1) mod DEPTH;  -- Okuma pointer'ı dairesel olarak ilerler
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture ich_tu_dir_weh;
