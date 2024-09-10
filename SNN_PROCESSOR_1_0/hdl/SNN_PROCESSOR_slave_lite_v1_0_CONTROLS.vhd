library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.processor_utils.all;

entity SNN_PROCESSOR_slave_lite_v1_0_CONTROLS is
	generic (
		-- Users to add parameters here
        CROSSBAR_ROW_WIDTH  : integer := 32;
        CROSSBAR_COL_WIDTH  : integer := 32;
        SYNAPSE_MEM_DEPTH   : integer := 2048;
        NEURAL_MEM_DEPTH    : integer := 1024;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
		-- Users to add ports here

		-- Users to add ports here
		MAIN_BUFFER_FLUSH                 : out std_logic;                      -- slv_reg4(10)
		AUX_BUFFER_FLUSH                  : out std_logic;                      -- slv_reg4(11)
		OUT_BUFFER_FLUSH                  : out std_logic;                      -- slv_reg4(12)
		WORKMODE                          : out std_logic;                      -- slv_reg4(7)         -- CT/ PS SLAVE
		PROCEED_NEXT                      : out std_logic;                      -- slv_reg4(9)         -- PROCEED NEXT TIMESTEP IN PS SLAVE MODE
        NMC_PMODE_SWITCH                  : out STD_LOGIC                   ;   -- slv_reg4(1)
        SYNAPSE_ROUTE                     : out std_logic;                      -- slv_reg4(3)
        NMC_NPARAM_DATA                   : out STD_LOGIC_VECTOR(15 DOWNTO 0);  -- slv_reg5(31 downto 16)
        NMC_NPARAM_ADDR                   : out STD_LOGIC_VECTOR(9  DOWNTO 0);  -- slv_reg5(9 downto 0)
        NMC_PROG_MEM_PORTA_EN             : out STD_LOGIC;                      -- slv_reg4(4)
        NMC_PROG_MEM_PORTA_WEN            : out STD_LOGIC;                      -- slv_reg4(5)
        LEARN_LUT_DIN                     : out std_logic_vector(7 downto 0);   -- slv_reg6(7 downto 0)
        LEARN_LUT_ADDR                    : out std_logic_vector(7 downto 0);   -- slv_reg6(15 downto 0)
        LEARN_LUT_EN                      : out std_logic;                      -- slv_reg4(6)
        NMC_XNEVER_BASE                   : out std_logic_vector(9 downto 0);   -- slv_reg7(9 downto 0)
        NMC_XNEVER_HIGH                   : out std_logic_vector(9 downto 0);   -- slv_reg7(25 downto 16)

		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic
	);
end SNN_PROCESSOR_slave_lite_v1_0_CONTROLS;

architecture hard_shoulder of SNN_PROCESSOR_slave_lite_v1_0_CONTROLS is


	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 3;

	signal slv_reg0	    :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg1	    :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg2	    :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg3	    :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg4	    :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg5	    :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg6	    :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg7	    :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg8	    :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg9	    :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg10	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg11	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg12	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg13	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg14	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg15	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg_rden	: std_logic;
	signal slv_reg_wren	: std_logic;
	signal reg_data_out	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	: integer;
	signal aw_en	    : std_logic;
	
	constant TOTALPARAMETERMEMORY : integer := CROSSBAR_COL_WIDTH*NEURAL_MEM_DEPTH;
	constant TOTALSYNAPTICMEMORY  : integer := CROSSBAR_COL_WIDTH*SYNAPSE_MEM_DEPTH; 
    constant CROSSBARDIMENSIONS   : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(CROSSBAR_ROW_WIDTH,16))&std_logic_vector(to_unsigned(CROSSBAR_COL_WIDTH,16));
    constant MAXNEURONS           : integer := CROSSBAR_COL_WIDTH*NEURAL_MEM_DEPTH/8;


begin

	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	    <= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RDATA	    <= axi_rdata;
	S_AXI_RRESP	    <= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;

	slv_reg0 <= std_logic_vector(to_unsigned(TOTALPARAMETERMEMORY,32));
	slv_reg1 <= std_logic_vector(to_unsigned(TOTALSYNAPTICMEMORY,32));
	slv_reg2 <= CROSSBARDIMENSIONS;
	slv_reg3 <= std_logic_vector(to_unsigned(MAXNEURONS,32));

    NMC_PMODE_SWITCH         <= slv_reg4(1)            ; -- Default := "0"
    SYNAPSE_ROUTE            <= slv_reg4(3)            ; -- Default := "0"
    NMC_PROG_MEM_PORTA_EN    <= slv_reg4(4)            ; -- Default := '0';
    NMC_PROG_MEM_PORTA_WEN   <= slv_reg4(5)            ; -- Default := '0';
    LEARN_LUT_EN             <= slv_reg4(6)            ; -- Default := '0';
    WORKMODE                 <= slv_reg4(7)            ; -- Default := '0';
    PROCEED_NEXT             <= slv_reg4(9)            ; -- Default := '0';

    NMC_NPARAM_DATA          <= slv_reg5(31 downto 16) ; -- Default := "00"
    NMC_NPARAM_ADDR          <= slv_reg5(9 downto 0)   ; -- Default := "00"
    
    NMC_XNEVER_BASE          <= slv_reg7(9 downto 0)   ; -- Default := x"00"
    NMC_XNEVER_HIGH          <= slv_reg7(25 downto 16) ; -- Default := x"00"
    
    LEARN_LUT_DIN            <= slv_reg6(7 downto 0)   ; -- Default := x"00"
    LEARN_LUT_ADDR           <= slv_reg6(15 downto 8)  ; -- Default := x"00"
    
    MAIN_BUFFER_FLUSH       <=   slv_reg4(10) ;
	AUX_BUFFER_FLUSH        <=   slv_reg4(11) ; 
	OUT_BUFFER_FLUSH        <=   slv_reg4(12) ;
        
	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awready <= '0';
	      aw_en <= '1';
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	           axi_awready <= '1';
	           aw_en <= '0';
	        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
	           aw_en <= '1';
	           axi_awready <= '0';
	      else
	        axi_awready <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awaddr <= (others => '0');
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        axi_awaddr <= S_AXI_AWADDR;
	      end if;
	    end if;
	  end if;                   
	end process; 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_wready <= '0';
	    else
	      if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then    
	          axi_wready <= '1';
	      else
	        axi_wready <= '0';
	      end if;
	    end if;
	  end if;
	end process; 

	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

	process (S_AXI_ACLK)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then

	      slv_reg4 <= (others => '0');
	      slv_reg5 <= (others => '0');
	      slv_reg6 <= (others => '0');
	      slv_reg7 <= (others => '0');
	      slv_reg8 <= (others => '0');
	      --slv_reg9 <= (others => '0');
	      --slv_reg10 <= (others => '0');
	      --slv_reg11 <= (others => '0');
	      --slv_reg12 <= (others => '0');
	      --slv_reg13 <= (others => '0');
	      --slv_reg14 <= (others => '0');
	      --slv_reg15 <= (others => '0');
	    else
	      loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	      if (slv_reg_wren = '1') then
	        case loc_addr is

	          when b"0100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 4
	                slv_reg4(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"0101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 5
	                slv_reg5(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"0110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                slv_reg6(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"0111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 7
	                slv_reg7(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"1000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 8
	                slv_reg8(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
--	          when b"1001" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 9
--	                slv_reg9(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"1010" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 10
--	                slv_reg10(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"1011" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 11
--	                slv_reg11(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"1100" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 12
--	                slv_reg12(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"1101" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 13
--	                slv_reg13(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"1110" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 14
--	                slv_reg14(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"1111" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 15
--	                slv_reg15(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
	          when others =>
	            slv_reg4 <= slv_reg4;
	            slv_reg5 <= slv_reg5;
	            slv_reg6 <= slv_reg6;
	            slv_reg7 <= slv_reg7;
	            slv_reg8 <= slv_reg8;
	            --slv_reg9 <= slv_reg9;
	            --slv_reg10 <= slv_reg10;
	            --slv_reg11 <= slv_reg11;
	            --slv_reg12 <= slv_reg12;
	            --slv_reg13 <= slv_reg13;
	            --slv_reg14 <= slv_reg14;
	            --slv_reg15 <= slv_reg15;
	        end case;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement write response logic generation
	-- The write response and response valid signals are asserted by the slave 
	-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	-- This marks the acceptance of address and indicates the status of 
	-- write transaction.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_bvalid  <= '0';
	      axi_bresp   <= "00"; --need to work more on the responses
	    else
	      if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
	        axi_bvalid <= '1';
	        axi_bresp  <= "00"; 
	      elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
	        axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arready generation
	-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
	-- S_AXI_ARVALID is asserted. axi_awready is 
	-- de-asserted when reset (active low) is asserted. 
	-- The read address is also latched when S_AXI_ARVALID is 
	-- asserted. axi_araddr is reset to zero on reset assertion.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_arready <= '0';
	      axi_araddr  <= (others => '1');
	    else
	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
	        -- indicates that the slave has acceped the valid read address
	        axi_arready <= '1';
	        -- Read Address latching 
	        axi_araddr  <= S_AXI_ARADDR;           
	      else
	        axi_arready <= '0';
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arvalid generation
	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	-- data are available on the axi_rdata bus at this instance. The 
	-- assertion of axi_rvalid marks the validity of read data on the 
	-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
	-- cleared to zero on reset (active low).  
	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    if S_AXI_ARESETN = '0' then
	      axi_rvalid <= '0';
	      axi_rresp  <= "00";
	    else
	      if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
	        -- Valid read data is available at the read data bus
	        axi_rvalid <= '1';
	        axi_rresp  <= "00"; -- 'OKAY' response
	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
	        -- Read data is accepted by the master
	        axi_rvalid <= '0';
	      end if;            
	    end if;
	  end if;
	end process;

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.
	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

	process (slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, slv_reg5, slv_reg6, slv_reg7, slv_reg8, slv_reg9, slv_reg10, slv_reg11, slv_reg12, slv_reg13, slv_reg14, slv_reg15, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	begin
	    -- Address decoding for reading registers
	    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	    case loc_addr is
	      when b"0000" =>
	        reg_data_out <= slv_reg0;
	      when b"0001" =>
	        reg_data_out <= slv_reg1;
	      when b"0010" =>
	        reg_data_out <= slv_reg2;
	      when b"0011" =>
	        reg_data_out <= slv_reg3;
	      when b"0100" =>
	        reg_data_out <= slv_reg4;
	      when b"0101" =>
	        reg_data_out <= slv_reg5;
	      when b"0110" =>
	        reg_data_out <= slv_reg6;
	      when b"0111" =>
	        reg_data_out <= slv_reg7;
	      when b"1000" =>
	        reg_data_out <= slv_reg8;
	      --when b"1001" =>
	      --  reg_data_out <= slv_reg9;
	      --when b"1010" =>
	      --  reg_data_out <= slv_reg10;
	      --when b"1011" =>
	      --  reg_data_out <= slv_reg11;
	      --when b"1100" =>
	      --  reg_data_out <= slv_reg12;
	      --when b"1101" =>
	      --  reg_data_out <= slv_reg13;
	      --when b"1110" =>
	      --  reg_data_out <= slv_reg14;
	      --when b"1111" =>
	      --  reg_data_out <= slv_reg15;
	      when others =>
	        reg_data_out  <= (others => '0');
	    end case;
	end process; 

	-- Output register or memory read data
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      axi_rdata  <= (others => '0');
	    else
	      if (slv_reg_rden = '1') then
	        -- When there is a valid read address (S_AXI_ARVALID) with 
	        -- acceptance of read address by the slave (axi_arready), 
	        -- output the read dada 
	        -- Read address mux
	          axi_rdata <= reg_data_out;     -- register read data
	      end if;   
	    end if;
	  end if;
	end process;


	-- Add user logic here

	-- User logic ends

end hard_shoulder;

























--
--
--
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--
--entity SNN_PROCESSOR_slave_lite_v1_0_CONTROLS is
--	generic (
--		-- Users to add parameters here
--        CROSSBAR_ROW_WIDTH  : integer := 32;
--        CROSSBAR_COL_WIDTH  : integer := 32;
--        SYNAPSE_MEM_DEPTH   : integer := 2048;
--        NEURAL_MEM_DEPTH    : integer := 1024;
--		-- User parameters ends
--		-- Do not modify the parameters beyond this line
--
--		-- Width of S_AXI data bus
--		C_S_AXI_DATA_WIDTH	: integer	:= 32;
--		-- Width of S_AXI address bus
--		C_S_AXI_ADDR_WIDTH	: integer	:= 6
--	);
--	port (
--		-- Users to add ports here
--
--		-- Users to add ports here
--		MAIN_BUFFER_FLUSH                 : out std_logic;                      -- slv_reg4(10)
--		AUX_BUFFER_FLUSH                  : out std_logic;                      -- slv_reg4(11)
--		OUT_BUFFER_FLUSH                  : out std_logic;                      -- slv_reg4(12)
--		WORKMODE                          : out std_logic;                      -- slv_reg4(7)         -- CT/ PS SLAVE
--		PROCEED_NEXT                      : out std_logic;                      -- slv_reg4(9)         -- PROCEED NEXT TIMESTEP IN PS SLAVE MODE
--        NMC_PMODE_SWITCH                  : out STD_LOGIC_VECTOR(1 DOWNTO 0);   -- slv_reg4(1 downto 0)
--        SYNAPSE_ROUTE                     : out std_logic_vector(1 downto 0);   -- slv_reg4(3 downto 2)
--        NMC_NPARAM_DATA                   : out STD_LOGIC_VECTOR(15 DOWNTO 0);  -- slv_reg5(31 downto 16)
--        NMC_NPARAM_ADDR                   : out STD_LOGIC_VECTOR(9  DOWNTO 0);  -- slv_reg5(9 downto 0)
--        NMC_PROG_MEM_PORTA_EN             : out STD_LOGIC;                      -- slv_reg4(4)
--        NMC_PROG_MEM_PORTA_WEN            : out STD_LOGIC;                      -- slv_reg4(5)
--        LEARN_LUT_DIN                     : out std_logic_vector(7 downto 0);   -- slv_reg6(7 downto 0)
--        LEARN_LUT_ADDR                    : out std_logic_vector(7 downto 0);   -- slv_reg6(15 downto 0)
--        LEARN_LUT_EN                      : out std_logic;                      -- slv_reg4(6)
--        NMC_XNEVER_BASE                   : out std_logic_vector(9 downto 0);   -- slv_reg7(9 downto 0)
--        NMC_XNEVER_HIGH                   : out std_logic_vector(9 downto 0);   -- slv_reg7(25 downto 16)
--        TIMESTEP_UPDATE_CYCLES            : out std_logic_vector(15 downto 0);  -- slv_reg4(31 downto 16)   
--        SPIKE_OUT_RDCOUNT                 : out std_logic_vector(15 downto 0);  -- slv-reg8(15 downto 0)
--        READSPIKES                        : out std_logic;                      -- slv_reg8(27)
--        SPIKE_OUT_TRANSFER_DELAY          : out std_logic_vector(9 downto 0);   -- slv_reg8(25 downto 16)
--
--		-- User ports ends
--		-- Do not modify the ports beyond this line
--
--		-- Global Clock Signal
--		S_AXI_ACLK	: in std_logic;
--		-- Global Reset Signal. This Signal is Active LOW
--		S_AXI_ARESETN	: in std_logic;
--		-- Write address (issued by master, acceped by Slave)
--		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
--		-- Write channel Protection type. This signal indicates the
--    		-- privilege and security level of the transaction, and whether
--    		-- the transaction is a data access or an instruction access.
--		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
--		-- Write address valid. This signal indicates that the master signaling
--    		-- valid write address and control information.
--		S_AXI_AWVALID	: in std_logic;
--		-- Write address ready. This signal indicates that the slave is ready
--    		-- to accept an address and associated control signals.
--		S_AXI_AWREADY	: out std_logic;
--		-- Write data (issued by master, acceped by Slave) 
--		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--		-- Write strobes. This signal indicates which byte lanes hold
--    		-- valid data. There is one write strobe bit for each eight
--    		-- bits of the write data bus.    
--		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
--		-- Write valid. This signal indicates that valid write
--    		-- data and strobes are available.
--		S_AXI_WVALID	: in std_logic;
--		-- Write ready. This signal indicates that the slave
--    		-- can accept the write data.
--		S_AXI_WREADY	: out std_logic;
--		-- Write response. This signal indicates the status
--    		-- of the write transaction.
--		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
--		-- Write response valid. This signal indicates that the channel
--    		-- is signaling a valid write response.
--		S_AXI_BVALID	: out std_logic;
--		-- Response ready. This signal indicates that the master
--    		-- can accept a write response.
--		S_AXI_BREADY	: in std_logic;
--		-- Read address (issued by master, acceped by Slave)
--		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
--		-- Protection type. This signal indicates the privilege
--    		-- and security level of the transaction, and whether the
--    		-- transaction is a data access or an instruction access.
--		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
--		-- Read address valid. This signal indicates that the channel
--    		-- is signaling valid read address and control information.
--		S_AXI_ARVALID	: in std_logic;
--		-- Read address ready. This signal indicates that the slave is
--    		-- ready to accept an address and associated control signals.
--		S_AXI_ARREADY	: out std_logic;
--		-- Read data (issued by slave)
--		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--		-- Read response. This signal indicates the status of the
--    		-- read transfer.
--		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
--		-- Read valid. This signal indicates that the channel is
--    		-- signaling the required read data.
--		S_AXI_RVALID	: out std_logic;
--		-- Read ready. This signal indicates that the master can
--    		-- accept the read data and response information.
--		S_AXI_RREADY	: in std_logic
--	);
--end SNN_PROCESSOR_slave_lite_v1_0_CONTROLS;
--
--architecture arch_imp of SNN_PROCESSOR_slave_lite_v1_0_CONTROLS is
--
--	-- AXI4LITE signals
--	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
--	signal axi_awready	: std_logic;
--	signal axi_wready	: std_logic;
--	signal axi_bresp	: std_logic_vector(1 downto 0);
--	signal axi_bvalid	: std_logic;
--	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
--	signal axi_arready	: std_logic;
--	signal axi_rresp	: std_logic_vector(1 downto 0);
--	signal axi_rvalid	: std_logic;
--
--	-- Example-specific design signals
--	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
--	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
--	-- ADDR_LSB = 2 for 32 bits (n downto 2)
--	-- ADDR_LSB = 3 for 64 bits (n downto 3)
--	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
--	constant OPT_MEM_ADDR_BITS : integer := 3;
--	------------------------------------------------
--	---- Signals for user logic register space example
--	--------------------------------------------------
--	---- Number of Slave Registers 16
--	signal slv_reg0	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg1	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg2	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg3	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg4	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg5	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg6	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg7	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg8	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg9	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg10	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg11	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg12	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg13	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg14	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg15	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal byte_index	: integer;
--
--	 signal mem_logic  : std_logic_vector(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
--
--	 --State machine local parameters
--	constant Idle : std_logic_vector(1 downto 0) := "00";
--	constant Raddr: std_logic_vector(1 downto 0) := "10";
--	constant Rdata: std_logic_vector(1 downto 0) := "11";
--	constant Waddr: std_logic_vector(1 downto 0) := "10";
--	constant Wdata: std_logic_vector(1 downto 0) := "11";
--	 --State machine variables
--	signal state_read : std_logic_vector(1 downto 0);
--	signal state_write: std_logic_vector(1 downto 0); 
--	
--    constant TOTALPARAMETERMEMORY : integer := CROSSBAR_COL_WIDTH*NEURAL_MEM_DEPTH;
--	constant TOTALSYNAPTICMEMORY  : integer := CROSSBAR_COL_WIDTH*SYNAPSE_MEM_DEPTH; 
--    constant CROSSBARDIMENSIONS   : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(CROSSBAR_ROW_WIDTH,16))&std_logic_vector(to_unsigned(CROSSBAR_COL_WIDTH,16));
--    constant MAXNEURONS           : integer := CROSSBAR_COL_WIDTH*NEURAL_MEM_DEPTH/8;
--
--	
--	
--begin
--
--	slv_reg0 <= std_logic_vector(to_unsigned(TOTALPARAMETERMEMORY,32));
--	slv_reg1 <= std_logic_vector(to_unsigned(TOTALSYNAPTICMEMORY,32));
--	slv_reg2 <= CROSSBARDIMENSIONS;
--	slv_reg3 <= std_logic_vector(to_unsigned(MAXNEURONS,32));
--
--    NMC_PMODE_SWITCH         <= slv_reg4(1 downto 0)   ; -- Default := "00"
--    SYNAPSE_ROUTE            <= slv_reg4(3 downto 2)   ; -- Default := "00"
--    NMC_PROG_MEM_PORTA_EN    <= slv_reg4(4)            ; -- Default := '0';
--    NMC_PROG_MEM_PORTA_WEN   <= slv_reg4(5)            ; -- Default := '0';
--    LEARN_LUT_EN             <= slv_reg4(6)            ; -- Default := '0';
--    WORKMODE                 <= slv_reg4(7)            ; -- Default := '0';
--    PROCEED_NEXT             <= slv_reg4(9)            ; -- Default := '0';
--    TIMESTEP_UPDATE_CYCLES   <= slv_reg4(31 downto 16) ; -- Default := x"0000"; 
--
--    NMC_NPARAM_DATA          <= slv_reg5(31 downto 16) ; -- Default := "00"
--    NMC_NPARAM_ADDR          <= slv_reg5(9 downto 0)   ; -- Default := "00"
--    
--    NMC_XNEVER_BASE          <= slv_reg7(9 downto 0)   ; -- Default := x"00"
--    NMC_XNEVER_HIGH          <= slv_reg7(25 downto 16) ; -- Default := x"00"
--    
--    LEARN_LUT_DIN            <= slv_reg6(7 downto 0)   ; -- Default := x"00"
--    LEARN_LUT_ADDR           <= slv_reg6(15 downto 8)  ; -- Default := x"00"
--    
--    SPIKE_OUT_RDCOUNT        <= slv_reg8(15 downto 0)  ; -- Default := x"0000"; 
--    READSPIKES               <= slv_reg8(27)           ; -- Default := '0';
--    SPIKE_OUT_TRANSFER_DELAY <= slv_reg8(25 downto 16) ; -- Default := x"0000"; 
--
--
--
--	-- I/O Connections assignments
--
--	S_AXI_AWREADY	<= axi_awready;
--	S_AXI_WREADY	<= axi_wready;
--	S_AXI_BRESP	<= axi_bresp;
--	S_AXI_BVALID	<= axi_bvalid;
--	S_AXI_ARREADY	<= axi_arready;
--	S_AXI_RRESP	<= axi_rresp;
--	S_AXI_RVALID	<= axi_rvalid;
--	    mem_logic     <= S_AXI_AWADDR(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB) when (S_AXI_AWVALID = '1') else axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
--
--	-- Implement Write state machine
--	-- Outstanding write transactions are not supported by the slave i.e., master should assert bready to receive response on or before it starts sending the new transaction
--	 process (S_AXI_ACLK)                                       
--	   begin                                       
--	     if rising_edge(S_AXI_ACLK) then                                       
--	        if S_AXI_ARESETN = '0' then                                       
--	          --asserting initial values to all 0's during reset                                       
--	          axi_awready <= '0';                                       
--	          axi_wready <= '0';                                       
--	          axi_bvalid <= '0';                                       
--	          axi_bresp <= (others => '0');                                       
--	          state_write <= Idle;                                       
--	        else                                       
--	          case (state_write) is                                       
--	             when Idle =>		--Initial state inidicating reset is done and ready to receive read/write transactions                                       
--	               if (S_AXI_ARESETN = '1') then                                       
--	                 axi_awready <= '1';                                       
--	                 axi_wready <= '1';                                       
--	                 state_write <= Waddr;                                       
--	               else state_write <= state_write;                                       
--	               end if;                                       
--	             when Waddr =>		--At this state, slave is ready to receive address along with corresponding control signals and first data packet. Response valid is also handled at this state                                       
--	               if (S_AXI_AWVALID = '1' and axi_awready = '1') then                                       
--	                 axi_awaddr <= S_AXI_AWADDR;                                       
--	                 if (S_AXI_WVALID = '1') then                                       
--	                   axi_awready <= '1';                                       
--	                   state_write <= Waddr;                                       
--	                   axi_bvalid <= '1';                                       
--	                 else                                       
--	                   axi_awready <= '0';                                       
--	                   state_write <= Wdata;                                       
--	                   if (S_AXI_BREADY = '1' and axi_bvalid = '1') then                                       
--	                     axi_bvalid <= '0';                                       
--	                   end if;                                       
--	                 end if;                                       
--	               else                                        
--	                 state_write <= state_write;                                       
--	                 if (S_AXI_BREADY = '1' and axi_bvalid = '1') then                                       
--	                   axi_bvalid <= '0';                                       
--	                 end if;                                       
--	               end if;                                       
--	             when Wdata =>		--At this state, slave is ready to receive the data packets until the number of transfers is equal to burst length                                       
--	               if (S_AXI_WVALID = '1') then                                       
--	                 state_write <= Waddr;                                       
--	                 axi_bvalid <= '1';                                       
--	                 axi_awready <= '1';                                       
--	               else                                       
--	                 state_write <= state_write;                                       
--	                 if (S_AXI_BREADY ='1' and axi_bvalid = '1') then                                       
--	                   axi_bvalid <= '0';                                       
--	                 end if;                                       
--	               end if;                                       
--	             when others =>      --reserved                                       
--	               axi_awready <= '0';                                       
--	               axi_wready <= '0';                                       
--	               axi_bvalid <= '0';                                       
--	           end case;                                       
--	        end if;                                       
--	      end if;                                                
--	 end process;                                       
--	-- Implement memory mapped register select and write logic generation
--	-- The write data is accepted and written to memory mapped registers when
--	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
--	-- select byte enables of slave registers while writing.
--	-- These registers are cleared when reset (active low) is applied.
--	-- Slave register write enable is asserted when valid address and data are available
--	-- and the slave is ready to accept the write address and write data.
--	
--
--	process (S_AXI_ACLK)
--	begin
--	  if rising_edge(S_AXI_ACLK) then 
--	    if S_AXI_ARESETN = '0' then
--	      --slv_reg0 <= (others => '0');
--	      --slv_reg1 <= (others => '0');
--	      --slv_reg2 <= (others => '0');
--	      --slv_reg3 <= (others => '0');
--	      slv_reg4 <= (others => '0');
--	      slv_reg5 <= (others => '0');
--	      slv_reg6 <= (others => '0');
--	      slv_reg7 <= (others => '0');
--	      slv_reg8 <= (others => '0');
--	      --slv_reg9 <= (others => '0');
--	      --slv_reg10 <= (others => '0');
--	      --slv_reg11 <= (others => '0');
--	      --slv_reg12 <= (others => '0');
--	      --slv_reg13 <= (others => '0');
--	      --slv_reg14 <= (others => '0');
--	      --slv_reg15 <= (others => '0');
--	    else
--	      if (S_AXI_WVALID = '1') then
--	          case (mem_logic) is
--	          when b"0000" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 0
--	                slv_reg0(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"0001" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 1
--	                slv_reg1(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"0010" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 2
--	                slv_reg2(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"0011" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 3
--	                slv_reg3(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"0100" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 4
--	                slv_reg4(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"0101" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 5
--	                slv_reg5(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"0110" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 6
--	                slv_reg6(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"0111" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 7
--	                slv_reg7(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
--	          when b"1000" =>
--	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--	                -- Respective byte enables are asserted as per write strobes                   
--	                -- slave registor 8
--	                slv_reg8(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--	              end if;
--	            end loop;
----	          when b"1001" =>
----	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
----	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
----	                -- Respective byte enables are asserted as per write strobes                   
----	                -- slave registor 9
----	                slv_reg9(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
----	              end if;
----	            end loop;
----	          when b"1010" =>
----	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
----	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
----	                -- Respective byte enables are asserted as per write strobes                   
----	                -- slave registor 10
----	                slv_reg10(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
----	              end if;
----	            end loop;
----	          when b"1011" =>
----	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
----	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
----	                -- Respective byte enables are asserted as per write strobes                   
----	                -- slave registor 11
----	                slv_reg11(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
----	              end if;
----	            end loop;
----	          when b"1100" =>
----	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
----	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
----	                -- Respective byte enables are asserted as per write strobes                   
----	                -- slave registor 12
----	                slv_reg12(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
----	              end if;
----	            end loop;
----	          when b"1101" =>
----	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
----	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
----	                -- Respective byte enables are asserted as per write strobes                   
----	                -- slave registor 13
----	                slv_reg13(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
----	              end if;
----	            end loop;
----	          when b"1110" =>
----	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
----	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
----	                -- Respective byte enables are asserted as per write strobes                   
----	                -- slave registor 14
----	                slv_reg14(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
----	              end if;
----	            end loop;
----	          when b"1111" =>
----	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
----	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
----	                -- Respective byte enables are asserted as per write strobes                   
----	                -- slave registor 15
----	                slv_reg15(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
----	              end if;
----	            end loop;
--	          when others =>
--	            --slv_reg0 <= slv_reg0;
--	            --slv_reg1 <= slv_reg1;
--	            --slv_reg2 <= slv_reg2;
--	            --slv_reg3 <= slv_reg3;
--	            slv_reg4 <= slv_reg4;
--	            slv_reg5 <= slv_reg5;
--	            slv_reg6 <= slv_reg6;
--	            slv_reg7 <= slv_reg7;
--	            slv_reg8 <= slv_reg8;
--	            --slv_reg9 <= slv_reg9;
--	            --slv_reg10 <= slv_reg10;
--	            --slv_reg11 <= slv_reg11;
--	            --slv_reg12 <= slv_reg12;
--	            --slv_reg13 <= slv_reg13;
--	            --slv_reg14 <= slv_reg14;
--	            --slv_reg15 <= slv_reg15;
--	        end case;
--	      end if;
--	    end if;
--	  end if;                   
--	end process; 
--
--	-- Implement read state machine
--	 process (S_AXI_ACLK)                                          
--	   begin                                          
--	     if rising_edge(S_AXI_ACLK) then                                           
--	        if S_AXI_ARESETN = '0' then                                          
--	          --asserting initial values to all 0's during reset                                          
--	          axi_arready <= '0';                                          
--	          axi_rvalid <= '0';                                          
--	          axi_rresp <= (others => '0');                                          
--	          state_read <= Idle;                                          
--	        else                                          
--	          case (state_read) is                                          
--	            when Idle =>		--Initial state inidicating reset is done and ready to receive read/write transactions                                          
--	                if (S_AXI_ARESETN = '1') then                                          
--	                  axi_arready <= '1';                                          
--	                  state_read <= Raddr;                                          
--	                else state_read <= state_read;                                          
--	                end if;                                          
--	            when Raddr =>		--At this state, slave is ready to receive address along with corresponding control signals                                          
--	                if (S_AXI_ARVALID = '1' and axi_arready = '1') then                                          
--	                  state_read <= Rdata;                                          
--	                  axi_rvalid <= '1';                                          
--	                  axi_arready <= '0';                                          
--	                  axi_araddr <= S_AXI_ARADDR;                                          
--	                else                                          
--	                  state_read <= state_read;                                          
--	                end if;                                          
--	            when Rdata =>		--At this state, slave is ready to send the data packets until the number of transfers is equal to burst length                                          
--	                if (axi_rvalid = '1' and S_AXI_RREADY = '1') then                                          
--	                  axi_rvalid <= '0';                                          
--	                  axi_arready <= '1';                                          
--	                  state_read <= Raddr;                                          
--	                else                                          
--	                  state_read <= state_read;                                          
--	                end if;                                          
--	            when others =>      --reserved                                          
--	                axi_arready <= '0';                                          
--	                axi_rvalid <= '0';                                          
--	           end case;                                          
--	         end if;                                          
--	       end if;                                                   
--	  end process;                                          
--	-- Implement memory mapped register select and read logic generation
--	 S_AXI_RDATA <= slv_reg0 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "00") else 
--	 slv_reg1 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "01") else 
--	 slv_reg2 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "10") else
--	 slv_reg3 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "11") else
--	 (others => '0');
--
--	-- Add user logic here
--
--	-- User logic ends
--
-- end arch_imp;
--
--