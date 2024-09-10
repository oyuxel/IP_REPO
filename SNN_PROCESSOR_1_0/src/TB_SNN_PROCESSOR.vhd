library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity TB_SNN_PROCESSOR is
	generic (
		-- Users to add parameters here
            CROSSBAR_MATRIX_DIMENSIONS : integer := 32;
            SYNAPSE_MEM_DEPTH  : integer := 4096;
            NEURAL_MEM_DEPTH   : integer := 2048;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Parameters of Axi Slave Bus Interface CONTROLS
		--MAX_NEURONS	: integer	:= 0;
		--MAX_SYNAPSE : integer	:= 0;
        TESTBENCH_NEURON_COUNT      : integer := 128;
        TESTBENCH_SYNAPSES_PER_NEURONS : integer := 128;
		-- Parameters of Axi Slave Bus Interface CONTROLS
		C_CONTROLS_DATA_WIDTH	: integer	:= 32;
		C_CONTROLS_ADDR_WIDTH	: integer	:= 6;

		-- Parameters of Axi Slave Bus Interface PARAMSPACE
		C_PARAMSPACE_DATA_WIDTH	: integer	:= 32;
		C_PARAMSPACE_ADDR_WIDTH	: integer	:= 5;

		-- Parameters of Axi Slave Bus Interface SYNAPSES
		C_SYNAPSES_DATA_WIDTH	: integer	:= 32;
		C_SYNAPSES_ADDR_WIDTH	: integer	:= 5;

		-- Parameters of Axi Slave Bus Interface SPIKE_IN
		C_SPIKE_IN_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface SPIKE_OUT
		C_SPIKE_OUT_TDATA_WIDTH	: integer	:= 32;
		C_SPIKE_OUT_START_COUNT	: integer	:= 32
	);
end TB_SNN_PROCESSOR;

architecture ivory of TB_SNN_PROCESSOR is
component SNN_PROCESSOR is
	generic (
		-- Users to add parameters here
            CROSSBAR_MATRIX_DIMENSIONS : integer := 24;
            SYNAPSE_MEM_DEPTH  : integer := 4096;
            NEURAL_MEM_DEPTH   : integer := 2048;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Parameters of Axi Slave Bus Interface CONTROLS
		--MAX_NEURONS	: integer	:= 0;
		--MAX_SYNAPSE : integer	:= 0;


		-- Parameters of Axi Slave Bus Interface CONTROLS
		C_CONTROLS_DATA_WIDTH	: integer	:= 32;
		C_CONTROLS_ADDR_WIDTH	: integer	:= 6;

		-- Parameters of Axi Slave Bus Interface PARAMSPACE
		C_PARAMSPACE_DATA_WIDTH	: integer	:= 32;
		C_PARAMSPACE_ADDR_WIDTH	: integer	:= 5;

		-- Parameters of Axi Slave Bus Interface SYNAPSES
		C_SYNAPSES_DATA_WIDTH	: integer	:= 32;
		C_SYNAPSES_ADDR_WIDTH	: integer	:= 5;

		-- Parameters of Axi Slave Bus Interface SPIKE_IN
		C_SPIKE_IN_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface SPIKE_OUT
		C_SPIKE_OUT_TDATA_WIDTH	: integer	:= 32;
		C_SPIKE_OUT_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here
        CORE_CLOCK             : in  std_logic;
        CORE_RESET             : in  std_logic;
        core_math_error        : out std_logic;
        core_memory_violation  : out std_logic;
        input_buffer_full    : out std_logic;
        output_buffer_full     : out std_logic;
        event_presence         : out std_logic;
        global_timestep_update : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface CONTROLS
		controls_aclk	: in std_logic;
		controls_aresetn	: in std_logic;
		controls_awaddr	: in std_logic_vector(C_CONTROLS_ADDR_WIDTH-1 downto 0);
		controls_awprot	: in std_logic_vector(2 downto 0);
		controls_awvalid	: in std_logic;
		controls_awready	: out std_logic;
		controls_wdata	: in std_logic_vector(C_CONTROLS_DATA_WIDTH-1 downto 0);
		controls_wstrb	: in std_logic_vector((C_CONTROLS_DATA_WIDTH/8)-1 downto 0);
		controls_wvalid	: in std_logic;
		controls_wready	: out std_logic;
		controls_bresp	: out std_logic_vector(1 downto 0);
		controls_bvalid	: out std_logic;
		controls_bready	: in std_logic;
		controls_araddr	: in std_logic_vector(C_CONTROLS_ADDR_WIDTH-1 downto 0);
		controls_arprot	: in std_logic_vector(2 downto 0);
		controls_arvalid	: in std_logic;
		controls_arready	: out std_logic;
		controls_rdata	: out std_logic_vector(C_CONTROLS_DATA_WIDTH-1 downto 0);
		controls_rresp	: out std_logic_vector(1 downto 0);
		controls_rvalid	: out std_logic;
		controls_rready	: in std_logic;

		-- Ports of Axi Slave Bus Interface PARAMSPACE
		paramspace_aclk	: in std_logic;
		paramspace_aresetn	: in std_logic;
		paramspace_awaddr	: in std_logic_vector(C_PARAMSPACE_ADDR_WIDTH-1 downto 0);
		paramspace_awprot	: in std_logic_vector(2 downto 0);
		paramspace_awvalid	: in std_logic;
		paramspace_awready	: out std_logic;
		paramspace_wdata	: in std_logic_vector(C_PARAMSPACE_DATA_WIDTH-1 downto 0);
		paramspace_wstrb	: in std_logic_vector((C_PARAMSPACE_DATA_WIDTH/8)-1 downto 0);
		paramspace_wvalid	: in std_logic;
		paramspace_wready	: out std_logic;
		paramspace_bresp	: out std_logic_vector(1 downto 0);
		paramspace_bvalid	: out std_logic;
		paramspace_bready	: in std_logic;
		paramspace_araddr	: in std_logic_vector(C_PARAMSPACE_ADDR_WIDTH-1 downto 0);
		paramspace_arprot	: in std_logic_vector(2 downto 0);
		paramspace_arvalid	: in std_logic;
		paramspace_arready	: out std_logic;
		paramspace_rdata	: out std_logic_vector(C_PARAMSPACE_DATA_WIDTH-1 downto 0);
		paramspace_rresp	: out std_logic_vector(1 downto 0);
		paramspace_rvalid	: out std_logic;
		paramspace_rready	: in std_logic;

		-- Ports of Axi Slave Bus Interface SYNAPSES
		synapses_aclk	: in std_logic;
		synapses_aresetn	: in std_logic;
		synapses_awaddr	: in std_logic_vector(C_SYNAPSES_ADDR_WIDTH-1 downto 0);
		synapses_awprot	: in std_logic_vector(2 downto 0);
		synapses_awvalid	: in std_logic;
		synapses_awready	: out std_logic;
		synapses_wdata	: in std_logic_vector(C_SYNAPSES_DATA_WIDTH-1 downto 0);
		synapses_wstrb	: in std_logic_vector((C_SYNAPSES_DATA_WIDTH/8)-1 downto 0);
		synapses_wvalid	: in std_logic;
		synapses_wready	: out std_logic;
		synapses_bresp	: out std_logic_vector(1 downto 0);
		synapses_bvalid	: out std_logic;
		synapses_bready	: in std_logic;
		synapses_araddr	: in std_logic_vector(C_SYNAPSES_ADDR_WIDTH-1 downto 0);
		synapses_arprot	: in std_logic_vector(2 downto 0);
		synapses_arvalid	: in std_logic;
		synapses_arready	: out std_logic;
		synapses_rdata	: out std_logic_vector(C_SYNAPSES_DATA_WIDTH-1 downto 0);
		synapses_rresp	: out std_logic_vector(1 downto 0);
		synapses_rvalid	: out std_logic;
		synapses_rready	: in std_logic;

		-- Ports of Axi Slave Bus Interface SPIKE_IN
		spike_in_aclk	: in std_logic;
		spike_in_aresetn	: in std_logic;
		spike_in_tready	: out std_logic;
		spike_in_tdata	: in std_logic_vector(C_SPIKE_IN_TDATA_WIDTH-1 downto 0);
		spike_in_tstrb	: in std_logic_vector((C_SPIKE_IN_TDATA_WIDTH/8)-1 downto 0);
		spike_in_tlast	: in std_logic;
		spike_in_tvalid	: in std_logic;

		-- Ports of Axi Master Bus Interface SPIKE_OUT
		spike_out_aclk	: in std_logic;
		spike_out_aresetn	: in std_logic;
		spike_out_tvalid	: out std_logic;
		spike_out_tdata	: out std_logic_vector(C_SPIKE_OUT_TDATA_WIDTH-1 downto 0);
		spike_out_tstrb	: out std_logic_vector((C_SPIKE_OUT_TDATA_WIDTH/8)-1 downto 0);
		spike_out_tlast	: out std_logic;
		spike_out_tready	: in std_logic
	);
end component SNN_PROCESSOR;


constant CROSSBAR_ROW_WIDTH : integer := CROSSBAR_MATRIX_DIMENSIONS;
constant CROSSBAR_COL_WIDTH : integer := CROSSBAR_MATRIX_DIMENSIONS;

           signal CORE_CLOCK             : std_logic := '1';
           signal CORE_RESET             : std_logic := '0';
           signal core_math_error        : std_logic;
           signal core_memory_violation  : std_logic;
           signal primary_buffer_full    : std_logic;
           signal aux_buffer_full        : std_logic;
           signal output_buffer_full     : std_logic;
           signal event_presence         : std_logic;
           signal global_timestep_update : std_logic;
    	   signal controls_aclk	         : std_logic := '1';
    	   signal controls_aresetn	     : std_logic := '0';
    	   signal controls_awaddr	     : std_logic_vector(5 downto 0) := (others=>'0');
    	   signal controls_awprot	     : std_logic_vector(2 downto 0) := (others=>'0');
    	   signal controls_awvalid	     : std_logic := '0';
    	   signal controls_awready	     : std_logic;
    	   signal controls_wdata	     : std_logic_vector(31 downto 0);
    	   signal controls_wstrb	     : std_logic_vector(3 downto 0) := (others=>'1');
    	   signal controls_wvalid	     : std_logic := '0';
    	   signal controls_wready	     : std_logic;
    	   signal controls_bresp	     : std_logic_vector(1 downto 0);
    	   signal controls_bvalid	     : std_logic;
    	   signal controls_bready	     : std_logic:= '0';
    	   signal controls_araddr	     : std_logic_vector(5 downto 0) := (others=>'0');
    	   signal controls_arprot	     : std_logic_vector(2 downto 0) := (others=>'0');
    	   signal controls_arvalid	     : std_logic:= '0';
    	   signal controls_arready	     : std_logic;
    	   signal controls_rdata	     : std_logic_vector(31 downto 0);
    	   signal controls_rresp	     : std_logic_vector(1 downto 0);
    	   signal controls_rvalid	     : std_logic;
    	   signal controls_rready	     : std_logic := '0';
    	   
    	   signal paramspace_aclk	     : std_logic := '1';
    	   signal paramspace_aresetn	 : std_logic := '0';
    	   signal paramspace_awaddr	     : std_logic_vector(4 downto 0):= (others=>'0');
    	   signal paramspace_awprot	     : std_logic_vector(2 downto 0):= (others=>'0');
    	   signal paramspace_awvalid	 : std_logic := '0';
    	   signal paramspace_awready	 : std_logic;
    	   signal paramspace_wdata	     : std_logic_vector(31 downto 0):= (others=>'0');
    	   signal paramspace_wstrb	     : std_logic_vector(3 downto 0):= (others=>'1');
    	   signal paramspace_wvalid	     : std_logic := '0';
    	   signal paramspace_wready	     : std_logic;
    	   signal paramspace_bresp	     : std_logic_vector(1 downto 0);
    	   signal paramspace_bvalid	     : std_logic;
    	   signal paramspace_bready	     : std_logic := '0';
    	   signal paramspace_araddr	     : std_logic_vector(4 downto 0):= (others=>'0');
    	   signal paramspace_arprot	     : std_logic_vector(2 downto 0):= (others=>'0');
    	   signal paramspace_arvalid	 : std_logic := '0';
    	   signal paramspace_arready	 : std_logic;
    	   signal paramspace_rdata	     : std_logic_vector(31 downto 0);
    	   signal paramspace_rresp	     : std_logic_vector(1 downto 0);
    	   signal paramspace_rvalid	     : std_logic;
    	   signal paramspace_rready	     : std_logic := '0';
    	   signal synapses_aclk	         : std_logic := '1';
    	   signal synapses_aresetn	     : std_logic := '0';
    	   signal synapses_awaddr	     : std_logic_vector(4 downto 0):= (others=>'0');
    	   signal synapses_awprot	     : std_logic_vector(2 downto 0):= (others=>'0');
    	   signal synapses_awvalid	     : std_logic := '0';
    	   signal synapses_awready	     : std_logic;
    	   signal synapses_wdata	     : std_logic_vector(31 downto 0):= (others=>'0');
    	   signal synapses_wstrb	     : std_logic_vector(3 downto 0):= (others=>'1');
    	   signal synapses_wvalid	     : std_logic := '0';
    	   signal synapses_wready	     : std_logic;
    	   signal synapses_bresp	     : std_logic_vector(1 downto 0);
    	   signal synapses_bvalid        : std_logic;
    	   signal synapses_bready        : std_logic := '0';
    	   signal synapses_araddr        : std_logic_vector(4 downto 0):= (others=>'0');
    	   signal synapses_arprot	     : std_logic_vector(2 downto 0):= (others=>'0');
    	   signal synapses_arvalid	     : std_logic := '0';
    	   signal synapses_arready	     : std_logic;
    	   signal synapses_rdata	     : std_logic_vector(31 downto 0);
    	   signal synapses_rresp	     : std_logic_vector(1 downto 0);
    	   signal synapses_rvalid	     : std_logic;
    	   signal synapses_rready	     : std_logic := '0';
    	   signal spike_in_aclk	         : std_logic := '1';
    	   signal spike_in_aresetn	     : std_logic := '0';
    	   signal spike_in_tready	     : std_logic;
    	   signal spike_in_tdata	     : std_logic_vector(C_SPIKE_IN_TDATA_WIDTH-1 downto 0):= (others=>'0');
    	   signal spike_in_tstrb	     : std_logic_vector((C_SPIKE_IN_TDATA_WIDTH/8)-1 downto 0):= (others=>'0');
    	   signal spike_in_tlast	     : std_logic := '0';
    	   signal spike_in_tvalid	     : std_logic := '0';
    	   signal spike_out_aclk	     : std_logic := '1';
    	   signal spike_out_aresetn	     : std_logic := '0';
    	   signal spike_out_tvalid	     : std_logic;
    	   signal spike_out_tdata        : std_logic_vector(C_SPIKE_OUT_TDATA_WIDTH-1 downto 0);
    	   signal spike_out_tstrb        : std_logic_vector((C_SPIKE_OUT_TDATA_WIDTH/8)-1 downto 0);
    	   signal spike_out_tlast        : std_logic;
    	   signal spike_out_tready	     : std_logic := '0';
    	   constant CLKPERIOD100         : time      := 10 ns;
    	   
    	       signal lfsr_reg : std_logic_vector(CROSSBAR_MATRIX_DIMENSIONS-1 downto 0) := (others => '1'); -- Başlangıç değeri 1 (hepsi '1')
               signal feedback : std_logic;
    	   
    	   type TESTBENCH_STATES is (STARTING,LEARNING_TABLE_PASS,NMC_PROGRAMMING_DATA_PASS,SYNAPSE_PASS,NEURONS_PASS,HARDWARE_IS_WORKING);
    	   signal TESTBENCH_STATE : TESTBENCH_STATES;
    	   
    	function clogb2( depth : natural) return integer is
        variable temp    : integer := depth;
        variable ret_val : integer := 0;
        begin
            while temp > 1 loop
                ret_val := ret_val + 1;
                temp    := temp / 2;
            end loop;
            return ret_val;
        end function;

        signal CONTROLS_REG : std_logic_vector(31 downto 0);
                
        signal TOTAL_PARAMETER_MEMORY : std_logic_vector(31 downto 0);
	    signal TOTAL_SYNAPTIC_MEMORY  : std_logic_vector(31 downto 0);
        signal CROSSBAR_DIMENSIONS    : std_logic_vector(31 downto 0);
        signal MAX_NUMBER_OF_NEURONS  : std_logic_vector(31 downto 0);
       
        
       type ENABLE_SIGNALS is array (0 to CROSSBAR_COL_WIDTH-1) of std_logic_vector(CROSSBAR_COL_WIDTH-1 downto 0);

       function ENABLE_INDEX_GENERATOR(MEMCNT: integer) return ENABLE_SIGNALS is
            variable mindex   : integer := MEMCNT;
            variable i        : integer := 0;
            variable outarray : ENABLE_SIGNALS;
            variable startval : std_logic_vector(CROSSBAR_COL_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(1,CROSSBAR_COL_WIDTH));           
            begin         
                while i < mindex loop   
                    outarray(i) := startval;
                    startval(CROSSBAR_COL_WIDTH-1 downto 1)  := startval(CROSSBAR_COL_WIDTH-2 downto 0);
                    startval(0) := '0';
                    i := i + 1;               
                end loop;  
            return outarray;
       end function;
           
       constant ENABLE_SIGNAL    : ENABLE_SIGNALS := ENABLE_INDEX_GENERATOR(CROSSBAR_COL_WIDTH);
      
            constant SYNLOW                          : std_logic_vector(3 downto 0) := "0001";
            constant SSSDSYNHIGH                     : std_logic_vector(3 downto 0) := "0010";
            constant REFPLST                         : std_logic_vector(3 downto 0) := "0011";
            constant PFLOWSYNQ                       : std_logic_vector(3 downto 0) := "0100";
            constant ULEARNPARAMS                    : std_logic_vector(3 downto 0) := "0101";
            constant NPADDRDATA                      : std_logic_vector(3 downto 0) := "0110";
            constant ENDFLOW                         : std_logic_vector(3 downto 0) := "0111";
                 

begin

        feedback <= lfsr_reg(31) xor lfsr_reg(21) xor lfsr_reg(1) xor lfsr_reg(0);  -- Maksimal polinom: x^32 + x^22 + x^2 + x^1 + 1
        
        process(spike_in_aclk)
        begin
            if rising_edge(spike_in_aclk) then
                -- LFSR kaydırma işlemi: Feedback ve kaydırma işlemi
                lfsr_reg <= feedback & lfsr_reg(31 downto 1);
            end if;
        end process;
    

        spike_in_aclk   <= not spike_in_aclk   after CLKPERIOD100/2;
        spike_out_aclk  <= not spike_out_aclk  after CLKPERIOD100/2;
        synapses_aclk   <= not synapses_aclk   after CLKPERIOD100/2;
        paramspace_aclk <= not paramspace_aclk after CLKPERIOD100/2;
        controls_aclk   <= not controls_aclk   after CLKPERIOD100/2;
        CORE_CLOCK      <= not CORE_CLOCK      after CLKPERIOD100/2;

        process
   
        variable NMC_NPARAM_DATA  : STD_LOGIC_VECTOR(15 DOWNTO 0);  -- slv_reg5(31 downto 16)
        variable NMC_NPARAM_ADDR  : STD_LOGIC_VECTOR(9  DOWNTO 0);  -- slv_reg5(9 downto 0)
       
        variable LEARN_LUT_DIN    : std_logic_vector(7 downto 0);   -- slv_reg6(7 downto 0)
        variable LEARN_LUT_ADDR   : std_logic_vector(7 downto 0);   -- slv_reg6(15 downto 0)

        variable NMC_XNEVER_BASE  : std_logic_vector(9 downto 0);   -- slv_reg7(9 downto 0)
        variable NMC_XNEVER_HIGH  : std_logic_vector(9 downto 0);   -- slv_reg7(25 downto 16)
          
        variable SYNAPSE          : std_logic_vector(7 downto 0);
        variable TIMESTAMP        : std_logic_vector(7 downto 0);
        variable SYNAPSE_ADDR     : std_logic_vector(31 downto 0);
        
        variable SYNAPSE_MEM_EN   : std_logic_vector(CROSSBAR_COL_WIDTH-1 downto 0);   
        variable SYNAPSE_MEM_WREN : std_logic_vector(CROSSBAR_COL_WIDTH-1 downto 0); 
         
        variable SELECT_SYNAPSE_RAM : std_logic_vector(CROSSBAR_COL_WIDTH-1 downto 0); 
        
        variable NMC_NMEM_ADDR      : std_logic_vector(31 downto 0);
        variable NMC_NMEM_DIN       : std_logic_vector(31 downto 0);
        	
        variable NMC_MEM_EN   : std_logic_vector(CROSSBAR_COL_WIDTH-1 downto 0);   
        variable NMC_MEM_WREN : std_logic_vector(CROSSBAR_COL_WIDTH-1 downto 0); 
        
        variable SELECT_PARAM_RAM   : std_logic_vector(CROSSBAR_COL_WIDTH-1 downto 0); 

         
            procedure Controls_Write(
                                     wraddr : in std_logic_vector(5 downto 0);
                                     wrdata : in std_logic_vector(31 downto 0)) is 
            begin 
                controls_awaddr <= wraddr;
                controls_wdata  <= wrdata;
                controls_awprot <= (others=>'0');
                controls_awvalid <= '1';
                controls_wvalid <= '1';
                wait until (controls_awready and controls_wready) = '1';
                controls_bready <= '1';
                wait until controls_bvalid = '1';
                controls_awvalid <= '0';
                controls_wvalid <= '0';
                wait until controls_bvalid = '0';
                controls_bready <= '0';
                controls_awaddr <= (others=>'0');
                controls_wdata  <= (others=>'0');
            end procedure Controls_Write;
            
            procedure Controls_Read(
                                     rdaddr : in std_logic_vector(5 downto 0);
                                     signal rddata : out std_logic_vector(31 downto 0)) is 
            begin 
                controls_araddr  <= rdaddr;
                controls_arvalid <= '1';
                controls_rready  <= '1';
                wait until controls_arready = '1';
                wait for CLKPERIOD100;
                controls_arvalid <= '0';
                wait until controls_rvalid = '1';
                rddata <= controls_rdata;
                wait for CLKPERIOD100;
                controls_rready  <= '0';
                controls_araddr  <= (others=>'0');
            end procedure Controls_Read;
 
            procedure Paramspace_Write(
                                     wraddr : in std_logic_vector(4 downto 0);
                                     wrdata : in std_logic_vector(31 downto 0)) is 
            begin 
                paramspace_awaddr <= wraddr;
                paramspace_wdata  <= wrdata;
                paramspace_awprot <= (others=>'0');
                paramspace_awvalid <= '1';
                paramspace_wvalid <= '1';
                wait until (paramspace_awready and paramspace_wready) = '1';
                paramspace_bready <= '1';
                wait until paramspace_bvalid = '1';
                paramspace_awvalid <= '0';
                paramspace_wvalid <= '0';
                wait until paramspace_bvalid = '0';
                paramspace_bready <= '0';
                paramspace_awaddr <= (others=>'0');
                paramspace_wdata  <= (others=>'0');
            end procedure Paramspace_Write; 
            
            procedure Paramspace_Read(
                                     rdaddr : in std_logic_vector(4 downto 0);
                                     signal rddata : out std_logic_vector(31 downto 0)) is 
            begin 
                paramspace_araddr  <= rdaddr;
                paramspace_arvalid <= '1';
                paramspace_rready  <= '1';
                wait until paramspace_arready = '1';
                wait for CLKPERIOD100;
                paramspace_arvalid <= '0';
                wait until paramspace_rvalid = '1';
                rddata <= paramspace_rdata;
                wait for CLKPERIOD100;
                paramspace_rready  <= '0';
                paramspace_araddr  <= (others=>'0');
            end procedure Paramspace_Read;
 
            procedure Synapses_Write(
                                     wraddr : in std_logic_vector(4 downto 0);
                                     wrdata : in std_logic_vector(31 downto 0)) is 
            begin 
                synapses_awaddr <= wraddr;
                synapses_wdata  <= wrdata;
                synapses_awprot <= (others=>'0');
                synapses_awvalid <= '1';
                synapses_wvalid <= '1';
                wait until (synapses_awready and synapses_wready) = '1';
                synapses_bready <= '1';
                wait until synapses_bvalid = '1';
                synapses_awvalid <= '0';
                synapses_wvalid <= '0';
                wait until synapses_bvalid = '0';
                synapses_bready <= '0';
                synapses_awaddr <= (others=>'0');
                synapses_wdata  <= (others=>'0');
            end procedure Synapses_Write; 
            
            procedure Synapses_Read(
                                     rdaddr : in std_logic_vector(4 downto 0);
                                     signal rddata : out std_logic_vector(31 downto 0)) is 
            begin 
                synapses_araddr  <= rdaddr;
                synapses_arvalid <= '1';
                synapses_rready  <= '1';
                wait until synapses_arready = '1';
                wait for CLKPERIOD100;
                synapses_arvalid <= '0';
                wait until synapses_rvalid = '1';
                rddata <= synapses_rdata;
                wait for CLKPERIOD100;
                synapses_rready  <= '0';
                synapses_araddr  <= (others=>'0');
            end procedure Synapses_Read;  
        begin
        
        wait for 10*CLKPERIOD100;
        
        controls_aresetn    <= '1';
        paramspace_aresetn  <= '1';
        synapses_aresetn    <= '1';
        CORE_RESET          <= '1';
        
        wait for 10*CLKPERIOD100;

        TESTBENCH_STATE <= STARTING;

        Controls_Read(B"0000_00",TOTAL_PARAMETER_MEMORY);       
        wait for CLKPERIOD100;
        Controls_Read(B"0001_00",TOTAL_SYNAPTIC_MEMORY);       
        wait for CLKPERIOD100;
        Controls_Read(B"0010_00",CROSSBAR_DIMENSIONS);       
        wait for CLKPERIOD100;
        Controls_Read(B"0011_00",MAX_NUMBER_OF_NEURONS);       
        wait for CLKPERIOD100;        

      TESTBENCH_STATE <= NMC_PROGRAMMING_DATA_PASS;
                
    ----------------- NMC PROGRAM DATA PASS --------------------------------
      Controls_Write(B"0100_00",B"00000000000000000000000000_11_00_10");  -- NMC MEMORY EXTERNAL ACCESS
    NMC_NPARAM_DATA := "0011001000000000"; --getacc,x1  (LOAD I to x1)
    NMC_NPARAM_ADDR := std_logic_vector(to_unsigned(542,NMC_NPARAM_ADDR'length));  
      Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
      wait for CLKPERIOD100;

    NMC_NPARAM_DATA := "0110000000000000"; --clracc     (CLEAR ACC)
    NMC_NPARAM_ADDR := std_logic_vector(to_unsigned(543,NMC_NPARAM_ADDR'length)); 
        Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;   
    NMC_NPARAM_DATA := "0001000000110111"; --lw,x2,44   (LOAD v)
    NMC_NPARAM_ADDR := std_logic_vector(to_unsigned(544,NMC_NPARAM_ADDR'length)); 
        Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0001010000101100"; --lw,x3,45   (LOAD h)
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(545,NMC_NPARAM_ADDR'length)); 
        Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0001011000101101"; --lw,x4,46   (LOAD u)
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(546,NMC_NPARAM_ADDR'length)); 
        Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0001100000101110"; --lw,x5,47   (LOAD 140)
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(547,NMC_NPARAM_ADDR'length)); 
        Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0001101000101111"; --fmac,x2,x0 (ACC <= v)
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(548,NMC_NPARAM_ADDR'length)); 
        Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000010000"; --fmac,x1,x3 (ACC <= v + I*h)
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(549,NMC_NPARAM_ADDR'length)); 
        Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000001011"; --smac,x4,x3 (ACC <= v + I*h - h*u)
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(550,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0101000000100011"; --fmac,x5,x3 (ACC <= 140*h - h*u + I*h + v )
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(551,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000101011"; --getacc,x6  ( x6 = 140*h - h*u + I*h + v )
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(552,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0011110000000000"; --clracc
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(553,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0110000000000000"; --fmac,x3,x2 (ACC <= h*v )
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(554,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000011010"; --getacc,x7  ( x7 = h*v )
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(555,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0011111000000000"; --clracc
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(556,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0110000000000000"; --lw,x5,48   (LOAD 5)
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(557,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0001101000110000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(558,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000111101";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(559,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000110000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(560,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0011110000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(561,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0110000000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(562,NMC_NPARAM_ADDR'length)); 
           Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0001101000110001";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(563,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000111101";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(564,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0011111000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(565,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0110000000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(566,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000111010";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(567,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000110000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(568,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0011110000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(569,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0110000000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(570,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0001111000110101";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(571,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0111000000110111";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(572,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "1010000000011010";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(573,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0010110000101100";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(574,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0001101000110011";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(575,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0001110000110100";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(576,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000101110";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(577,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0011111000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(578,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0110000000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(579,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000010011";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(580,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0011001000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(581,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0110000000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(582,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000001111";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(583,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000100000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(584,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0011001000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(585,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0110000000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(586,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000011101";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(587,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0011111000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(588,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0110000000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(589,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000111100";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(590,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0011111000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(591,NMC_NPARAM_ADDR'length)); 
            Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0110000000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(592,NMC_NPARAM_ADDR'length)); 
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0100000000000001";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(593,NMC_NPARAM_ADDR'length)); 
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0101000000000111";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(594,NMC_NPARAM_ADDR'length)); 
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0011111000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(595,NMC_NPARAM_ADDR'length)); 
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0110000000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(596,NMC_NPARAM_ADDR'length)); 
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "0010111000101110";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(597,NMC_NPARAM_ADDR'length)); 
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    wait for CLKPERIOD100;
    NMC_NPARAM_DATA  := "1101000000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(598,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100;
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := "1011000000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(599,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100;
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := "0001111000110010";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(600,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100;
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := "0010111000101100";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(601,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100;
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := "0100000000000100";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(602,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100;
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := "0001010000110110";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(603,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100;
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := "0100000000010000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(604,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100;
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := "0011111000000000";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(605,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100;
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := "0010111000101110";
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(606,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100;
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA := "1101000000000000";
    NMC_NPARAM_ADDR := std_logic_vector(to_unsigned(607,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100;
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA := X"2E66";  -- h
    NMC_NPARAM_ADDR := std_logic_vector(to_unsigned(768+45,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100; 
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := X"5860";  -- 140
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(768+47,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100; 
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := X"251E";  -- a
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(768+51,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100; 
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := X"4F80";  -- threshold
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(768+53,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100; 
                Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := X"3266";  -- b
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(768+52,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100; 
    Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := X"4000";  -- d
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(768+54,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100; 
    Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA := X"3C00";  -- FP16 1.0
    NMC_NPARAM_ADDR := std_logic_vector(to_unsigned(768+55,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100; 
    Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA := X"D240";  -- c
    NMC_NPARAM_ADDR := std_logic_vector(to_unsigned(768+50,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100; 
    Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA  := X"291E";  -- 0.04
    NMC_NPARAM_ADDR  := std_logic_vector(to_unsigned(768+49,NMC_NPARAM_ADDR'length)); 
    wait for CLKPERIOD100; 
    Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
    NMC_NPARAM_DATA := X"4500";  -- 5
    NMC_NPARAM_ADDR := std_logic_vector(to_unsigned(768+48,NMC_NPARAM_ADDR'length)); 
    Controls_Write(B"0101_00",NMC_NPARAM_DATA&"000000"&NMC_NPARAM_ADDR);
      wait for CLKPERIOD100;
      Controls_Write(B"0100_00",B"00000000000000000000000000_00_00_00");   -- PARAM MEM --> BRIDGE <--> NMC MEMORY

    NMC_XNEVER_BASE   := std_logic_vector(to_unsigned(768,NMC_XNEVER_BASE'length));
    NMC_XNEVER_HIGH   := std_logic_vector(to_unsigned(1023,NMC_XNEVER_HIGH'length));
    Controls_Write(B"0111_00",B"000000"&NMC_XNEVER_HIGH&B"000000"&NMC_XNEVER_BASE);   -- NMC_XN_LOW & NMC_XN_HIGH

   
           TESTBENCH_STATE <= LEARNING_TABLE_PASS;

   
   Controls_Write(B"0100_00",B"00000000_00000000_00000000_01000000");

   for i in 127 downto 0 loop
   
        LEARN_LUT_DIN   := std_logic_vector(to_unsigned(i,LEARN_LUT_DIN'length));
        LEARN_LUT_ADDR  := std_logic_vector(to_unsigned(127-i,LEARN_LUT_ADDR'length));
        
        Controls_Write(B"0110_00",X"0000"&LEARN_LUT_ADDR&LEARN_LUT_DIN);
        wait for CLKPERIOD100;
   
   end loop;
   
   for i in 255 downto 128 loop
   
        LEARN_LUT_DIN   := std_logic_vector(to_unsigned(127-i,LEARN_LUT_DIN'length));
        LEARN_LUT_ADDR  := std_logic_vector(to_unsigned(i,LEARN_LUT_ADDR'length));
        Controls_Write(B"0110_00",X"0000"&LEARN_LUT_ADDR&LEARN_LUT_DIN);
        wait for CLKPERIOD100;
   
   end loop;
   
           TESTBENCH_STATE <= SYNAPSE_PASS;

   
   Controls_Write(B"0100_00",X"00000000");
   Controls_Write(B"0100_00",B"00000000000000000000000000_00_10_00");
       
    for m in 0 to CROSSBAR_COL_WIDTH-1 loop   
    
        SELECT_SYNAPSE_RAM := std_logic_vector(to_unsigned(m,32));
        
        Synapses_Write(B"101_00",SELECT_SYNAPSE_RAM);     
        
        for k in 0 to 5 loop

            for i in 0 to TESTBENCH_SYNAPSES_PER_NEURONS-1 loop
                           
                SYNAPSE      := std_logic_vector(to_unsigned(  i,8));
                TIMESTAMP    := std_logic_vector(to_unsigned(  i,8));
                SYNAPSE_ADDR := std_logic_vector(to_unsigned(i+k*TESTBENCH_SYNAPSES_PER_NEURONS,32));
                
                Synapses_Write(B"000_00",SYNAPSE_ADDR);     
                Synapses_Write(B"001_00",X"0000"&SYNAPSE&TIMESTAMP);
                  
                SYNAPSE_MEM_EN    := ENABLE_SIGNAL(m);           
                SYNAPSE_MEM_WREN  := ENABLE_SIGNAL(m); 
                
                Synapses_Write(B"011_00",SYNAPSE_MEM_EN);     
                Synapses_Write(B"100_00",SYNAPSE_MEM_WREN);     
                
                Synapses_Write(B"011_00",X"00000000");     
                Synapses_Write(B"100_00",X"00000000"); 
    
                wait for CLKPERIOD100; 
                 
            end loop;
            
        end loop;
        
    end loop;
    
        Synapses_Write(B"011_00",X"00000000");     
        Synapses_Write(B"100_00",X"00000000");     
        
        Controls_Write(B"0100_00",B"00000000000000000000000000_00_00_00");

        
          TESTBENCH_STATE <= NEURONS_PASS;

  
  
    for j in 0 to CROSSBAR_COL_WIDTH-1 loop

        SELECT_PARAM_RAM  := std_logic_vector(to_unsigned(j,32));       
        Paramspace_Write(B"101_00",SELECT_PARAM_RAM);  
        
        for k in 0 to TESTBENCH_NEURON_COUNT/CROSSBAR_COL_WIDTH-1 loop

            NMC_NMEM_DIN(31 downto 28)  := SYNLOW;
            NMC_NMEM_DIN(27 downto 16)  := (others=>'0');
            NMC_NMEM_DIN(15 downto  0)  := std_logic_vector(to_unsigned(0+128*k,16));
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(0+k*8,NMC_NMEM_ADDR'length));
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);   	
            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
            
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
        
            NMC_NMEM_DIN(31 downto 28)  := SSSDSYNHIGH  ;
            NMC_NMEM_DIN(27 downto 22)  := (others=>'0');
            NMC_NMEM_DIN(21)            := '0'  ;
            NMC_NMEM_DIN(20)            := '0'  ;
            NMC_NMEM_DIN(19)            := '1'  ;
            NMC_NMEM_DIN(18)            := '0'  ;
            NMC_NMEM_DIN(17)            := '0'  ;
            NMC_NMEM_DIN(16)            := '1'  ;
            NMC_NMEM_DIN(15 downto 0)   := std_logic_vector(to_unsigned(128*k+127,16)) ;
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(1+k*8,NMC_NMEM_ADDR'length));    
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);  
            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
        
            NMC_NMEM_DIN(31 downto 28)  := REFPLST          ;
            NMC_NMEM_DIN(27 downto 16)  := (others=>'0');
            NMC_NMEM_DIN(15 downto  8)  := (others=>'0');
            NMC_NMEM_DIN(7 downto   0)  := std_logic_vector(to_unsigned(32+k,8));   
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(2+k*8,NMC_NMEM_ADDR'length));
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);      
              
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
        
            NMC_NMEM_DIN(31 downto 28)  := PFLOWSYNQ    ;
            NMC_NMEM_DIN(27 downto 26)  := (others=>'0');
            NMC_NMEM_DIN(25 downto 16)  := std_logic_vector(to_unsigned(542,10))    ;
            NMC_NMEM_DIN(15 downto  0)  := X"2004"      ;
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(3+k*8,NMC_NMEM_ADDR'length));  
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);  
            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
          
            NMC_NMEM_DIN(31 downto 28)  := ULEARNPARAMS ;
            NMC_NMEM_DIN(27)            := '0'     ;
            NMC_NMEM_DIN(26)            := '0'     ;
            NMC_NMEM_DIN(25)            := '0'     ;
            NMC_NMEM_DIN(24)            := '0'     ;
            NMC_NMEM_DIN(23 downto 16)  := std_logic_vector(to_signed(127,8)) ;
            NMC_NMEM_DIN(15 downto  8)  := std_logic_vector(to_signed(-128,8)) ;
            NMC_NMEM_DIN(7  downto  0)  := std_logic_vector(to_signed(-12,8)) ;
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(4+k*8,NMC_NMEM_ADDR'length));
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);           
            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
        
            NMC_NMEM_DIN(31 downto 28)  := NPADDRDATA   ;
            NMC_NMEM_DIN(27 downto 26)  := (others=>'0')   ;
            NMC_NMEM_DIN(25 downto 16)  := std_logic_vector(to_unsigned(768+44,10))   ;
            NMC_NMEM_DIN(15 downto  0)  := X"0000"  ;     
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(5+k*8,NMC_NMEM_ADDR'length));    
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);  
            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);  
            
            NMC_NMEM_DIN(31 downto 28)  := NPADDRDATA   ;
            NMC_NMEM_DIN(27 downto 26)  := (others=>'0')   ;
            NMC_NMEM_DIN(25 downto 16)  := std_logic_vector(to_unsigned(768+46,10))   ;
            NMC_NMEM_DIN(15 downto  0)  := X"0000" ;
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(6+k*8,NMC_NMEM_ADDR'length));
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);    
            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000");  
        
            NMC_NMEM_DIN(31 downto 28)  := ENDFLOW      ;
            NMC_NMEM_DIN(27 downto 16)  := (others=>'0')      ;
            NMC_NMEM_DIN(15 downto  0)  := X"0001"      ;
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(7+k*8,NMC_NMEM_ADDR'length));
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);  
                            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
        
        end loop;
        
     end loop;
     
     
    for j in 0 to CROSSBAR_COL_WIDTH-1 loop

        SELECT_PARAM_RAM  := std_logic_vector(to_unsigned(j,32));       
        Paramspace_Write(B"101_00",SELECT_PARAM_RAM);  
        
        for k in 0 to 64/CROSSBAR_COL_WIDTH-1 loop

            NMC_NMEM_DIN(31 downto 28)  := SYNLOW;
            NMC_NMEM_DIN(27 downto 16)  := (others=>'0');
            NMC_NMEM_DIN(15 downto  0)  := std_logic_vector(to_unsigned(0+128*k,16));
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(32+k*8,NMC_NMEM_ADDR'length));
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);   	
            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
            
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
        
        
                            --    RFM                       <= douta(16);  -- READ FROM MAIN
                            --    RFP0                      <= douta(17);  -- READ FROM PROPOGATOR 0
                            --    RFP1                      <= douta(18);  -- READ FROM PROPOGATOR 1
                            --    WTP0                      <= douta(19);  -- WRITE TO PROPOGATOR 0
                            --    WTP1                      <= douta(20);  -- WRITE TO PROPOGATOR 1
                            --    WTO                       <= douta(21);  -- WRITE TO OUT 
        
        
        
            NMC_NMEM_DIN(31 downto 28)  := SSSDSYNHIGH  ;
            NMC_NMEM_DIN(27 downto 22)  := (others=>'0');
            NMC_NMEM_DIN(21)            := '1'  ;
            NMC_NMEM_DIN(20)            := '0'  ;
            NMC_NMEM_DIN(19)            := '0'  ;
            NMC_NMEM_DIN(18)            := '0'  ;
            NMC_NMEM_DIN(17)            := '1'  ;
            NMC_NMEM_DIN(16)            := '0'  ;
            NMC_NMEM_DIN(15 downto 0)   := std_logic_vector(to_unsigned(128*k+127,16)) ;
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(33+k*8,NMC_NMEM_ADDR'length));    
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);  
            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
        
            NMC_NMEM_DIN(31 downto 28)  := REFPLST          ;
            NMC_NMEM_DIN(27 downto 16)  := (others=>'0');
            NMC_NMEM_DIN(15 downto  8)  := (others=>'0');
            NMC_NMEM_DIN(7 downto   0)  := std_logic_vector(to_unsigned(32+k,8));   
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(34+k*8,NMC_NMEM_ADDR'length));
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);      
              
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
        
            NMC_NMEM_DIN(31 downto 28)  := PFLOWSYNQ    ;
            NMC_NMEM_DIN(27 downto 26)  := (others=>'0');
            NMC_NMEM_DIN(25 downto 16)  := std_logic_vector(to_unsigned(542,10))    ;
            NMC_NMEM_DIN(15 downto  0)  := X"2004"      ;
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(35+k*8,NMC_NMEM_ADDR'length));  
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);  
            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
          
            NMC_NMEM_DIN(31 downto 28)  := ULEARNPARAMS ;
            NMC_NMEM_DIN(27)            := '0'     ;
            NMC_NMEM_DIN(26)            := '0'     ;
            NMC_NMEM_DIN(25)            := '0'     ;
            NMC_NMEM_DIN(24)            := '0'     ;
            NMC_NMEM_DIN(23 downto 16)  := std_logic_vector(to_signed(127,8)) ;
            NMC_NMEM_DIN(15 downto  8)  := std_logic_vector(to_signed(-128,8)) ;
            NMC_NMEM_DIN(7  downto  0)  := std_logic_vector(to_signed(-12,8)) ;
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(36+k*8,NMC_NMEM_ADDR'length));
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);           
            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
        
            NMC_NMEM_DIN(31 downto 28)  := NPADDRDATA   ;
            NMC_NMEM_DIN(27 downto 26)  := (others=>'0')   ;
            NMC_NMEM_DIN(25 downto 16)  := std_logic_vector(to_unsigned(768+44,10))   ;
            NMC_NMEM_DIN(15 downto  0)  := X"0000"  ;     
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(37+k*8,NMC_NMEM_ADDR'length));    
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);  
            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);  
            
            NMC_NMEM_DIN(31 downto 28)  := NPADDRDATA   ;
            NMC_NMEM_DIN(27 downto 26)  := (others=>'0')   ;
            NMC_NMEM_DIN(25 downto 16)  := std_logic_vector(to_unsigned(768+46,10))   ;
            NMC_NMEM_DIN(15 downto  0)  := X"0000" ;
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(38+k*8,NMC_NMEM_ADDR'length));
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);    
            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000");  
        
            NMC_NMEM_DIN(31 downto 28)  := ENDFLOW      ;
            NMC_NMEM_DIN(27 downto 16)  := (others=>'0')      ;
            NMC_NMEM_DIN(15 downto  0)  := X"0002"      ;
            NMC_NMEM_ADDR               := std_logic_vector(to_unsigned(39+k*8,NMC_NMEM_ADDR'length));
            Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
            Paramspace_Write(B"001_00",NMC_NMEM_DIN);  
                            
            NMC_MEM_EN   := ENABLE_SIGNAL(j); 
            NMC_MEM_WREN := ENABLE_SIGNAL(j); 
                
            Paramspace_Write(B"011_00",NMC_MEM_EN); 
            Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
            Paramspace_Write(B"011_00",X"00000000");     
            Paramspace_Write(B"100_00",X"00000000"); 
        
        end loop;
        
     end loop;


     for j in 0 to CROSSBAR_COL_WIDTH-1 loop

         SELECT_PARAM_RAM  := std_logic_vector(to_unsigned(j,32));       
         Paramspace_Write(B"101_00",SELECT_PARAM_RAM);  
     
     
         --NMC_NMEM_ADDR              := std_logic_vector(to_unsigned(48,NMC_NMEM_ADDR'length));
         --NMC_NMEM_DIN(31 downto 28) := ENDFLOW;
         --NMC_NMEM_DIN(27 downto 16) := (others=>'0');
         --NMC_NMEM_DIN(15  downto 0) := X"0002";
         --
         --Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
         --Paramspace_Write(B"001_00",NMC_NMEM_DIN);  
         --                
         --NMC_MEM_EN   := ENABLE_SIGNAL(j); 
         --NMC_MEM_WREN := ENABLE_SIGNAL(j); 
         --    
         --Paramspace_Write(B"011_00",NMC_MEM_EN); 
         --Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
         --Paramspace_Write(B"011_00",X"00000000");     
         --Paramspace_Write(B"100_00",X"00000000"); 
         
         NMC_NMEM_ADDR              := std_logic_vector(to_unsigned(48,NMC_NMEM_ADDR'length));
         NMC_NMEM_DIN(31 downto 28) := ENDFLOW;
         NMC_NMEM_DIN(27 downto 16) := (others=>'0');
         NMC_NMEM_DIN(15  downto 0) := X"0003";
         
         Paramspace_Write(B"000_00",NMC_NMEM_ADDR); 
         Paramspace_Write(B"001_00",NMC_NMEM_DIN);  
                         
         NMC_MEM_EN   := ENABLE_SIGNAL(j); 
         NMC_MEM_WREN := ENABLE_SIGNAL(j); 
             
         Paramspace_Write(B"011_00",NMC_MEM_EN); 
         Paramspace_Write(B"100_00",NMC_MEM_WREN);                          
         Paramspace_Write(B"011_00",X"00000000");     
         Paramspace_Write(B"100_00",X"00000000"); 
     
     
     end loop;
            
        CORE_RESET          <= '0';

     wait for 100*CLKPERIOD100;
     
		spike_in_tstrb	       <= (others=>'1');
		spike_in_tdata         <=  (others=>'0');
		wait for CLKPERIOD100;
	
		for i in 0 to 4*159 loop -- SPIKES FOR 10 TIMESTEPS
		
		  spike_in_tvalid	       <= '1';
		  
              spike_in_tdata(CROSSBAR_MATRIX_DIMENSIONS-1 downto 0)         <= lfsr_reg;
          
          wait for CLKPERIOD100;
     
        end loop;
        spike_in_tdata         <=  (others=>'0');
        spike_in_tvalid	       <= '0';

          wait for 10*CLKPERIOD100;

         
    TESTBENCH_STATE <= HARDWARE_IS_WORKING;

       
        
       -- WORKMODE                          : out std_logic;                      -- slv_reg4(7)         -- CT/ PS SLAVE
       -- PROCEED_NEXT                      : out std_logic;                      -- slv_reg4(9)         -- PROCEED NEXT TIMESTEP IN PS SLAVE MODE
       -- NMC_PMODE_SWITCH                  : out STD_LOGIC_VECTOR(1 DOWNTO 0);   -- slv_reg4(1 downto 0)
       -- SYNAPSE_ROUTE                     : out std_logic_vector(1 downto 0);   -- slv_reg4(3 downto 2)
       -- NMC_PROG_MEM_PORTA_EN             : out STD_LOGIC;                      -- slv_reg4(4)
       -- NMC_PROG_MEM_PORTA_WEN            : out STD_LOGIC;                      -- slv_reg4(5)
       -- LEARN_LUT_EN                      : out std_logic;                      -- slv_reg4(6)
       -- TIMESTEP_UPDATE_CYCLES            : out std_logic_vector(15 downto 0);  -- slv_reg4(31 downto 16)   

        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
     
        wait until global_timestep_update = '1';
                
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';
    
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00"); 
         
        wait until global_timestep_update = '1';

        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';
    
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");          
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");    
        
             
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
     
        wait until global_timestep_update = '1';
                
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';
    
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00"); 
         
        wait until global_timestep_update = '1';

        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';
    
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");          
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");    
        
                
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
     
        wait until global_timestep_update = '1';
                
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';
    
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00"); 
         
        wait until global_timestep_update = '1';

        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';
    
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");          
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");    
        
             
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
     
        wait until global_timestep_update = '1';
                
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';
    
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00"); 
         
        wait until global_timestep_update = '1';

        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';
    
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");          
        
        wait until global_timestep_update = '1';        
        
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_1_0_1_0_00_00_00");
        Controls_Write(B"0100_00",B"000000000000000000000"&B"0_0_0_1_0_00_00_00");   
                 
        wait for 100*CLKPERIOD100;
        

		if( spike_out_tvalid = '1') then
		  		spike_out_tready <= '1';
		else
		  		spike_out_tready <= '0';
		end if;
		
		wait until spike_out_tlast = '1';
        
        
        wait for 100*CLKPERIOD100;
        
        assert false report "Done" severity failure;
        
        end process;



SUT : SNN_PROCESSOR
    	generic map(
        CROSSBAR_MATRIX_DIMENSIONS => CROSSBAR_MATRIX_DIMENSIONS,
        SYNAPSE_MEM_DEPTH          => SYNAPSE_MEM_DEPTH      ,
        NEURAL_MEM_DEPTH           => NEURAL_MEM_DEPTH     ,
		C_CONTROLS_DATA_WIDTH	   => C_CONTROLS_DATA_WIDTH ,
		C_CONTROLS_ADDR_WIDTH	   => C_CONTROLS_ADDR_WIDTH , 
		C_PARAMSPACE_DATA_WIDTH	   => C_PARAMSPACE_DATA_WIDTH, 
		C_PARAMSPACE_ADDR_WIDTH	   => C_PARAMSPACE_ADDR_WIDTH, 
		C_SYNAPSES_DATA_WIDTH	   => C_SYNAPSES_DATA_WIDTH  ,
		C_SYNAPSES_ADDR_WIDTH	   => C_SYNAPSES_ADDR_WIDTH	  ,
		C_SPIKE_IN_TDATA_WIDTH	   => C_SPIKE_IN_TDATA_WIDTH  ,
		C_SPIKE_OUT_TDATA_WIDTH	   => C_SPIKE_OUT_TDATA_WIDTH ,
		C_SPIKE_OUT_START_COUNT	   => C_SPIKE_OUT_START_COUNT 
    	)
    	port map(
            CORE_CLOCK             => CORE_CLOCK            ,
            CORE_RESET             => CORE_RESET            ,
            core_math_error        => core_math_error       ,
            core_memory_violation  => core_memory_violation ,
            input_buffer_full    => primary_buffer_full   ,
            output_buffer_full     => output_buffer_full    ,
            event_presence         => event_presence        ,
            global_timestep_update => global_timestep_update,
    		-- User ports ends
    		-- Do not modify the ports beyond this line
    		-- Ports of Axi Slave Bus Interface CONTROLS
    		controls_aclk	       => controls_aclk	    ,
    		controls_aresetn	   => controls_aresetn	,
    		controls_awaddr	       => controls_awaddr	,
    		controls_awprot	       => controls_awprot	,
    		controls_awvalid	   => controls_awvalid	,
    		controls_awready	   => controls_awready	,
    		controls_wdata	       => controls_wdata	, 
    		controls_wstrb	       => controls_wstrb	, 
    		controls_wvalid	       => controls_wvalid	,
    		controls_wready	       => controls_wready	,
    		controls_bresp	       => controls_bresp	, 
    		controls_bvalid	       => controls_bvalid	,
    		controls_bready	       => controls_bready	,
    		controls_araddr	       => controls_araddr	,
    		controls_arprot	       => controls_arprot	,
    		controls_arvalid	   => controls_arvalid	,
    		controls_arready	   => controls_arready	,
    		controls_rdata	       => controls_rdata	, 
    		controls_rresp	       => controls_rresp	, 
    		controls_rvalid	       => controls_rvalid	,
    		controls_rready	       => controls_rready	,
    
    		-- Ports of Axi Slave Bus Interface PARAMSPACE
    		paramspace_aclk	       =>  paramspace_aclk	   ,
    		paramspace_aresetn	   =>  paramspace_aresetn  ,
    		paramspace_awaddr	   =>  paramspace_awaddr   ,
    		paramspace_awprot	   =>  paramspace_awprot   , 
    		paramspace_awvalid	   =>  paramspace_awvalid  , 
    		paramspace_awready	   =>  paramspace_awready  ,  
    		paramspace_wdata	   =>  paramspace_wdata	   ,
    		paramspace_wstrb	   =>  paramspace_wstrb	   ,
    		paramspace_wvalid	   =>  paramspace_wvalid   ,  
    		paramspace_wready	   =>  paramspace_wready   ,   
    		paramspace_bresp	   =>  paramspace_bresp	   ,
    		paramspace_bvalid	   =>  paramspace_bvalid   ,
    		paramspace_bready	   =>  paramspace_bready   ,
    		paramspace_araddr	   =>  paramspace_araddr   ,
    		paramspace_arprot	   =>  paramspace_arprot   , 
    		paramspace_arvalid	   =>  paramspace_arvalid  , 
    		paramspace_arready	   =>  paramspace_arready  ,  
    		paramspace_rdata	   =>  paramspace_rdata	   ,
    		paramspace_rresp	   =>  paramspace_rresp	   ,
    		paramspace_rvalid	   =>  paramspace_rvalid   ,  
    		paramspace_rready	   =>  paramspace_rready   ,   
    
    		-- Ports of Axi Slave Bus Interface SYNAPSES
    		synapses_aclk	       => synapses_aclk	    ,
    		synapses_aresetn	   => synapses_aresetn	,
    		synapses_awaddr	       => synapses_awaddr	,
    		synapses_awprot	       => synapses_awprot	,
    		synapses_awvalid	   => synapses_awvalid	,
    		synapses_awready	   => synapses_awready	,
    		synapses_wdata	       => synapses_wdata	, 
    		synapses_wstrb	       => synapses_wstrb	, 
    		synapses_wvalid	       => synapses_wvalid	,
    		synapses_wready	       => synapses_wready	,
    		synapses_bresp	       => synapses_bresp	, 
    		synapses_bvalid	       => synapses_bvalid	,
    		synapses_bready	       => synapses_bready	,
    		synapses_araddr	       => synapses_araddr	,
    		synapses_arprot	       => synapses_arprot	,
    		synapses_arvalid	   => synapses_arvalid	,
    		synapses_arready	   => synapses_arready	,
    		synapses_rdata	       => synapses_rdata	, 
    		synapses_rresp	       => synapses_rresp	, 
    		synapses_rvalid	       => synapses_rvalid	,
    		synapses_rready	       => synapses_rready	,
    
    		-- Ports of Axi Slave Bus Interface SPIKE_IN
    		spike_in_aclk	       => spike_in_aclk	    ,
    		spike_in_aresetn	   => spike_in_aresetn	,
    		spike_in_tready	       => spike_in_tready	,
    		spike_in_tdata	       => spike_in_tdata	, 
    		spike_in_tstrb	       => spike_in_tstrb	, 
    		spike_in_tlast	       => spike_in_tlast	, 
    		spike_in_tvalid	       => spike_in_tvalid	,
    
    		-- Ports of Axi Master Bus Interface SPIKE_OUT
    		spike_out_aclk	     => spike_out_aclk    ,
    		spike_out_aresetn	 => spike_out_aresetn ,
    		spike_out_tvalid	 => spike_out_tvalid  ,
    		spike_out_tdata      => spike_out_tdata   ,
    		spike_out_tstrb      => spike_out_tstrb   , 
    		spike_out_tlast      => spike_out_tlast   ,
    		spike_out_tready	 => spike_out_tready
    	);



end ivory;
