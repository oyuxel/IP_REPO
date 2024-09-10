library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.crossbar_utils.all;
use work.processor_primitives.all;
use work.processor_utils.all;
Library xpm;
use xpm.vcomponents.all;

entity SNN_PROCESSOR is
	generic (
		-- Users to add parameters here
            CROSSBAR_MATRIX_DIMENSIONS : integer := 24;
            SYNAPSE_MEM_DEPTH  : integer := 4096;
            NEURAL_MEM_DEPTH   : integer := 2048;
		-- User parameters ends

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
        input_buffer_full      : out std_logic;
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
end SNN_PROCESSOR;

architecture arch_imp of SNN_PROCESSOR is

constant C_CROSSBAR_ROW_WIDTH : integer := CROSSBAR_MATRIX_DIMENSIONS;
constant C_CROSSBAR_COL_WIDTH : integer := CROSSBAR_MATRIX_DIMENSIONS;

constant PROPOGATOR_WIDTH : integer := NEURAL_MEM_DEPTH/8;

component SPIKE_PROCESSOR is
    Generic (
            CROSSBAR_ROW_WIDTH : integer := 16;
            CROSSBAR_COL_WIDTH : integer := 16;
            SYNAPSE_MEM_DEPTH  : integer := 9216;
            NEURAL_MEM_DEPTH   : integer := 3584
            );
    Port ( 
            SP_CLOCK                    : in  std_logic;
            PARAMETER_MEM_RDCLK         : in  std_logic;
            SP_RESET                    : in  std_logic;
            TIMESTEP_STARTED            : in  std_logic;
            TIMESTEP_COMPLETED          : out std_logic;
            -- SPIKE_BUFFERS CONTROL (MAIN OR AUX)
            SPIKEVECTOR_IN              : in  std_logic_vector(CROSSBAR_ROW_WIDTH-1 downto 0); 
            SPIKEVECTOR_VLD_IN          : in  std_logic;                         
            READ_MAIN_SPIKE_BUFFER      : out std_logic;
            READ_PROPOGATOR_0           : out std_logic;
            READ_PROPOGATOR_1           : out std_logic;
            -- EVENT ACCEPTANCE
            EVENT_ACCEPT                : out std_logic;
            -- SYNAPSE RECYCLE OR EXTERNAL ACCESS
            SYNAPSE_ROUTE               : in  std_logic; -- 00: Recycle, 01: In, 10: Out
            -- SYNAPSE MEMORY INTERFACE SELECTION
            SYNAPTIC_MEM_DIN            : in  SYNAPTICMEMDATA(0 to CROSSBAR_COL_WIDTH-1);
            SYNAPTIC_MEM_DADDR          : in  SYNAPTICMEMADDR(0 to CROSSBAR_COL_WIDTH-1);
            SYNAPTIC_MEM_EN             : in  std_logic_vector(0 to CROSSBAR_COL_WIDTH-1);
            SYNAPTIC_MEM_WREN           : in  std_logic_vector(0 to CROSSBAR_COL_WIDTH-1);
            SYNAPTIC_MEM_DOUT           : out SYNAPTICMEMDATA(0 to CROSSBAR_COL_WIDTH-1);
            -- NMC MEMORY BOUNDARY REGISTERS
            NMC_XNEVER_BASE             : in  std_logic_vector(9 downto 0);
            NMC_XNEVER_HIGH             : in  std_logic_vector(9 downto 0);
            -- NMC PROGRAMMING INTERFACE TIED TO ALL NMC UNITS
            NMC_PMODE_SWITCH            : in  std_logic;  -- 0 : NMC Memory ports are tied to Neural Memory Ports, 1 : NMC Memory External Access
            NMC_NPARAM_DATA             : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
            NMC_NPARAM_ADDR             : in  STD_LOGIC_VECTOR(9  DOWNTO 0);
            NMC_PROG_MEM_PORTA_EN       : in  std_logic;
            NMC_PROG_MEM_PORTA_WEN      : in  std_logic;
            -- SPIKE OUTPUTS
            NMC_SPIKE_OUT               : out std_logic_vector(0 to CROSSBAR_COL_WIDTH-1 );
            NMC_SPIKE_OUT_VLD           : out std_logic_vector(0 to CROSSBAR_COL_WIDTH-1 );
            NMC_WR_PROPOGATOR_0         : out std_logic;
            NMC_WR_PROPOGATOR_1         : out std_logic;
            NMC_WR_OUT_BUFFER           : out std_logic;
             -- ULEARN LUT TIED TO ALL LEARNING ENGINES
            LEARN_LUT_DIN               : in  std_logic_vector(7 downto 0);
            LEARN_LUT_ADDR              : in  std_logic_vector(7 downto 0);
            LEARN_LUT_EN                : in  std_logic;
            -- PARAMETER MEMORY INTERFACE SELECTION
            PARAM_MEM_DIN               : in  PARAMMEMDATA(0 to CROSSBAR_COL_WIDTH-1);
            PARAM_MEM_DADDR             : in  PARAMMEMADDR(0 to CROSSBAR_COL_WIDTH-1);
            PARAM_MEM_EN                : in  std_logic_vector(0 to CROSSBAR_COL_WIDTH-1); 
            PARAM_MEM_WREN              : in  std_logic_vector(0 to CROSSBAR_COL_WIDTH-1); 
            PARAM_MEM_DOUT              : out PARAMMEMDATA(0 to CROSSBAR_COL_WIDTH-1);
            -- ERROR FLAGS
            NMC_MATH_ERROR_VEC          : out std_logic_vector(0 to CROSSBAR_COL_WIDTH-1); 
            NMC_MEM_VIOLATION_VEC       : out std_logic_vector(0 to CROSSBAR_COL_WIDTH-1)
            
          );
end component SPIKE_PROCESSOR;

------------------------------------------------------------------------------------------------------
---------------------------------- PROCESSOR SIGNALS BEGIN -------------------------------------------

        signal CORE_GATED_RESET : std_logic ;
        
        signal PROCESSOR_TIMESTEP_STARTED : std_logic ;
        
		-- Users to add ports here
		signal CONTROLS_MAIN_BUFFER_FLUSH                 : std_logic;                      -- slv_reg4(10)
		signal CONTROLS_AUX_BUFFER_FLUSH                  : std_logic;                      -- slv_reg4(11)
		signal CONTROLS_OUT_BUFFER_FLUSH                  : std_logic;                      -- slv_reg4(12)
		signal CONTROLS_WORKMODE                          : std_logic;                      -- slv_reg4(7)         -- CT/ PS SLAVE
		signal CONTROLS_PROCEED_NEXT                      : std_logic;                      -- slv_reg4(9)         -- PROCEED NEXT TIMESTEP IN PS SLAVE MODE
        signal CONTROLS_NMC_PMODE_SWITCH                  : STD_LOGIC;                      -- slv_reg4(1)
        signal CONTROLS_SYNAPSE_ROUTE                     : std_logic                   ;   -- slv_reg4(3)
        signal CONTROLS_NMC_NPARAM_DATA                   : STD_LOGIC_VECTOR(15 DOWNTO 0);  -- slv_reg5(31 downto 16)
        signal CONTROLS_NMC_NPARAM_ADDR                   : STD_LOGIC_VECTOR(9  DOWNTO 0);  -- slv_reg5(9 downto 0)
        signal CONTROLS_NMC_PROG_MEM_PORTA_EN             : std_logic;                        -- slv_reg4(4)
        signal CONTROLS_NMC_PROG_MEM_PORTA_WEN            : std_logic;                        -- slv_reg4(5)
        signal CONTROLS_LEARN_LUT_DIN                     : std_logic_vector(7 downto 0);   -- slv_reg6(7 downto 0)
        signal CONTROLS_LEARN_LUT_ADDR                    : std_logic_vector(7 downto 0);   -- slv_reg6(15 downto 0)
        signal CONTROLS_LEARN_LUT_EN                      : std_logic;                      -- slv_reg4(6)
        signal CONTROLS_NMC_XNEVER_BASE                   : std_logic_vector(9 downto 0);   -- slv_reg7(9 downto 0)
        signal CONTROLS_NMC_XNEVER_HIGH                   : std_logic_vector(9 downto 0);   -- slv_reg7(25 downto 16)
        signal CONTROLS_TIMESTEP_UPDATE_CYCLES            : std_logic_vector(15 downto 0);  -- slv_reg4(31 downto 16)   
        signal CONTROLS_SPIKE_OUT_RDCOUNT                 : std_logic_vector(15 downto 0);  -- slv-reg8(15 downto 0)
        signal CONTROLS_READSPIKES                        : std_logic;                      -- slv_reg8(27)
        signal CONTROLS_SPIKE_OUT_TRANSFER_DELAY          : std_logic_vector(9 downto 0);   -- slv_reg8(25 downto 16)

        signal PROCESSOR_NMC_MATH_ERROR_VEC          : std_logic_vector(0 to C_CROSSBAR_COL_WIDTH-1); 
        signal PROCESSOR_NMC_MEM_VIOLATION_VEC       : std_logic_vector(0 to C_CROSSBAR_COL_WIDTH-1);


        signal PROCESSOR_SPIKEVECTOR_IN              : std_logic_vector(C_CROSSBAR_ROW_WIDTH-1 downto 0); 
        signal PROCESSOR_SPIKEVECTOR_VLD_IN          : std_logic;                         

            -- EVENT ACCEPTANCE
        signal PROCESSOR_EVENT_ACCEPT                : std_logic;
        
        signal PROCESSOR_NMC_SPIKE_OUT               : std_logic_vector(0 to C_CROSSBAR_COL_WIDTH-1 );
        signal PROCESSOR_NMC_SPIKE_OUT_VLD           : std_logic_vector(0 to C_CROSSBAR_COL_WIDTH-1 );
        
        
        signal PROCESSOR_READ_MAIN_SPIKE_BUFFER      : std_logic;
        signal PROCESSOR_READ_PROPOGATOR_0           : std_logic;
        signal PROCESSOR_READ_PROPOGATOR_1           : std_logic;

        signal PROCESSOR_NMC_WR_PROPOGATOR_0    : std_logic;
        signal PROCESSOR_NMC_WR_PROPOGATOR_1    : std_logic;
        signal PROCESSOR_NMC_WR_OUT_BUFFER      : std_logic;
            
            
                    -- PARAMETER MEMORY INTERFACE SELECTION
        signal PROCESSOR_PARAM_MEM_DIN               :PARAMMEMDATA(0 to C_CROSSBAR_COL_WIDTH-1);
        signal PROCESSOR_PARAM_MEM_DADDR             :PARAMMEMADDR(0 to C_CROSSBAR_COL_WIDTH-1);
        signal PROCESSOR_PARAM_MEM_EN                :std_logic_vector(0 to C_CROSSBAR_COL_WIDTH-1); 
        signal PROCESSOR_PARAM_MEM_WREN              :std_logic_vector(0 to C_CROSSBAR_COL_WIDTH-1); 
        signal PROCESSOR_PARAM_MEM_DOUT              :PARAMMEMDATA(0 to C_CROSSBAR_COL_WIDTH-1);
        
        signal PROCESSOR_SYNAPTIC_MEM_DIN            :SYNAPTICMEMDATA(0 to C_CROSSBAR_COL_WIDTH-1);
        signal PROCESSOR_SYNAPTIC_MEM_DADDR          :SYNAPTICMEMADDR(0 to C_CROSSBAR_COL_WIDTH-1);
        signal PROCESSOR_SYNAPTIC_MEM_EN             :std_logic_vector(0 to C_CROSSBAR_COL_WIDTH-1);
        signal PROCESSOR_SYNAPTIC_MEM_WREN           :std_logic_vector(0 to C_CROSSBAR_COL_WIDTH-1);
        signal PROCESSOR_SYNAPTIC_MEM_DOUT           :SYNAPTICMEMDATA(0 to C_CROSSBAR_COL_WIDTH-1);
        
          signal  PROCESSOR_SYNAPSE_ROUTE            :   std_logic; -- 00: Recycle, 01: In, 10: Out
          signal  PROCESSOR_SPIKEVECTOR_VLD_IN_DLY            :   std_logic; 

---------------------------------- PROCESSOR SIGNALS END ---------------------------------------------
------------------------------------------------------------------------------------------------------

---------------------------------- SYNAPSES INTERFACE SIGNALS BEGIN ----------------------------------
------------------------------------------------------------------------------------------------------
	    signal SYNAPSES_SELECT_SYNAPSE_MEM                :  std_logic_vector(clogb2(C_CROSSBAR_COL_WIDTH)-1 downto 0);
        signal SYNAPSES_SYNAPSE_MEM_ADDR                  :  std_logic_vector(clogb2(SYNAPSE_MEM_DEPTH)-1 downto 0);
        signal SYNAPSES_SYNAPSE_MEM_DIN                   :  std_logic_vector(15 downto 0);	
        signal SYNAPSES_SYNAPSE_MEM_DOUT                  :  std_logic_vector(15 downto 0);
        signal SYNAPSES_SYNAPSE_MEM_EN                    :  std_logic_vector(C_CROSSBAR_COL_WIDTH-1 downto 0); 
        signal SYNAPSES_SYNAPSE_MEM_WREN                  :  std_logic_vector(C_CROSSBAR_COL_WIDTH-1 downto 0); 
---------------------------------- SYNAPSES INTERFACE SIGNALS END ------------------------------------
------------------------------------------------------------------------------------------------------

---------------------------------- PARAMSPACE INTERFACE SIGNALS BEGIN --------------------------------
------------------------------------------------------------------------------------------------------
	    signal PARAMSPACE_SELECT_PARAM_MEM                : std_logic_vector(clogb2(C_CROSSBAR_COL_WIDTH)-1 downto 0);
        signal PARAMSPACE_PARAM_MEM_ADDR                  : std_logic_vector(clogb2(NEURAL_MEM_DEPTH)-1 downto 0);
        signal PARAMSPACE_PARAM_MEM_DIN                   : std_logic_vector(31 downto 0);	
        signal PARAMSPACE_PARAM_MEM_DOUT                  : std_logic_vector(31 downto 0);
        signal PARAMSPACE_PARAM_MEM_EN                    : std_logic_vector(C_CROSSBAR_COL_WIDTH-1 downto 0); 
        signal PARAMSPACE_PARAM_MEM_WREN                  : std_logic_vector(C_CROSSBAR_COL_WIDTH-1 downto 0); 
---------------------------------- PARAMSPACE INTERFACE SIGNALS END ----------------------------------
------------------------------------------------------------------------------------------------------


---------------------------------- MAIN SPIKE BUFFER SIGNALS BEGIN -----------------------------------
------------------------------------------------------------------------------------------------------

      signal MAIN_SPIKE_BUFFER_DOUT  : std_logic_vector(C_CROSSBAR_ROW_WIDTH-1 downto 0);
      signal MAIN_SPIKE_BUFFER_DIN   : std_logic_vector(C_CROSSBAR_ROW_WIDTH-1 downto 0);
      signal MAIN_SPIKE_BUFFER_RDEN  : std_logic;
      signal MAIN_SPIKE_BUFFER_FULL  : std_logic;
      signal MAIN_SPIKE_BUFFER_EMPTY : std_logic;
      signal MAIN_SPIKE_BUFFER_WREN  : std_logic;
      signal MAIN_SPIKE_BUFFER_FLUSH : std_logic;

---------------------------------- MAIN SPIKE_BUFFER SIGNALS END -------------------------------------
------------------------------------------------------------------------------------------------------


---------------------------------- AUX SPIKE BUFFER SIGNALS BEGIN -----------------------------------
------------------------------------------------------------------------------------------------------

      signal FLUSHPROPOGATORS    : std_logic;
    
      signal PROPOGATOR_0_DOUT  : std_logic_vector(C_CROSSBAR_ROW_WIDTH-1 downto 0);
      signal PROPOGATOR_0_DIN   : std_logic_vector(C_CROSSBAR_ROW_WIDTH-1 downto 0);
      signal PROPOGATOR_0_RDEN  : std_logic;
      signal PROPOGATOR_0_WREN  : std_logic;
      signal PROPOGATOR_0_FLUSH : std_logic;
      
      signal PROPOGATOR_1_DOUT  : std_logic_vector(C_CROSSBAR_ROW_WIDTH-1 downto 0);
      signal PROPOGATOR_1_DIN   : std_logic_vector(C_CROSSBAR_ROW_WIDTH-1 downto 0);
      signal PROPOGATOR_1_RDEN  : std_logic;
      signal PROPOGATOR_1_WREN  : std_logic;
      signal PROPOGATOR_1_FLUSH : std_logic;      

---------------------------------- AUX SPIKE_BUFFER SIGNALS END -------------------------------------
------------------------------------------------------------------------------------------------------


---------------------------------- OUT SPIKE BUFFER SIGNALS BEGIN -----------------------------------
------------------------------------------------------------------------------------------------------

      signal OUT_SPIKE_BUFFER_DOUT  : std_logic_vector(31 downto 0);
      signal OUT_SPIKE_BUFFER_DIN   : std_logic_vector(31 downto 0);
      signal OUT_SPIKE_BUFFER_RDEN  : std_logic;
      signal OUT_SPIKE_BUFFER_FULL  : std_logic;
      signal OUT_SPIKE_BUFFER_EMPTY : std_logic;
      signal OUT_SPIKE_BUFFER_WREN  : std_logic;
      signal OUT_SPIKE_BUFFER_FLUSH : std_logic;
      signal OUT_SPIKE_BUFFER_LAST : std_logic;

---------------------------------- OUT SPIKE_BUFFER SIGNALS END -------------------------------------
------------------------------------------------------------------------------------------------------

      signal NMC_SPIKE_OUT_LATCH    : std_logic_vector(0 to C_CROSSBAR_COL_WIDTH-1 );
      signal NMC_SPIKE_OUT_LATCH_DELAY    : std_logic_vector(0 to C_CROSSBAR_COL_WIDTH-1 );
      signal ALL_SPIKES_ARRIVED     : std_logic_vector(0 to C_CROSSBAR_COL_WIDTH-1 );

      type SSTATES is (LISTENING,CATCHSPIKE,HOLDSPIKE);
      
      type SPIKE_STATES is array (0 to C_CROSSBAR_COL_WIDTH-1) of SSTATES; 
      
      signal SPIKE_STATE : SPIKE_STATES;
      
      signal READFIFOSELECT : std_logic_vector(2 downto 0);
      signal WRITEFIFOSELECT : std_logic_vector(2 downto 0);
      
      type FIFOSTATES is (WAITINPUT,WRITE);
      signal FIFOSTATE : FIFOSTATES;

      constant ARRIVAL : std_logic_vector(0 to C_CROSSBAR_COL_WIDTH-1 ) := (others=>'1');
      
      signal SPIKE_SYNCHRONIZER : std_logic;
      signal WRITESPIKES : std_logic;
      
------------------------------------------------------------------------------------------------------

	-- component declaration
	component SNN_PROCESSOR_slave_lite_v1_0_CONTROLS is
		generic (
		CROSSBAR_ROW_WIDTH  : integer := 32;
        CROSSBAR_COL_WIDTH  : integer := 32;
        SYNAPSE_MEM_DEPTH   : integer := 2048;
        NEURAL_MEM_DEPTH    : integer := 1024;
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
		);
		port (
		-- Users to add ports here
		MAIN_BUFFER_FLUSH                 : out std_logic;                      -- slv_reg4(10)
		AUX_BUFFER_FLUSH                  : out std_logic;                      -- slv_reg4(11)
		OUT_BUFFER_FLUSH                  : out std_logic;                      -- slv_reg4(12)
		WORKMODE                          : out std_logic;                      -- slv_reg4(7)         -- CT/ PS SLAVE
		PROCEED_NEXT                      : out std_logic;                      -- slv_reg4(9)         -- PROCEED NEXT TIMESTEP IN PS SLAVE MODE
        NMC_PMODE_SWITCH                  : out STD_LOGIC;                      -- slv_reg4(1)
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
        
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component SNN_PROCESSOR_slave_lite_v1_0_CONTROLS;

	component SNN_PROCESSOR_slave_lite_v1_0_PARAMSPACE is
		generic (
		CROSSBAR_COL_WIDTH  : integer := 32;
        NEURAL_MEM_DEPTH    : integer := 2048;
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
	    SELECT_PARAM_MEM                : out  std_logic_vector(clogb2(CROSSBAR_COL_WIDTH)-1 downto 0);
        PARAM_MEM_ADDR                  : out  std_logic_vector(clogb2(NEURAL_MEM_DEPTH)-1 downto 0);
        PARAM_MEM_DIN                   : out  std_logic_vector(31 downto 0);	
        PARAM_MEM_DOUT                  : in   std_logic_vector(31 downto 0);
        PARAM_MEM_EN                    : out  std_logic_vector(CROSSBAR_COL_WIDTH-1 downto 0); 
        PARAM_MEM_WREN                  : out  std_logic_vector(CROSSBAR_COL_WIDTH-1 downto 0); 
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component SNN_PROCESSOR_slave_lite_v1_0_PARAMSPACE;

	component SNN_PROCESSOR_slave_lite_v1_0_SYNAPSES is
		generic (
		CROSSBAR_COL_WIDTH  : integer := 32;
        SYNAPSE_MEM_DEPTH    : integer := 1024;
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
		SELECT_SYNAPSE_MEM                : out  std_logic_vector(clogb2(CROSSBAR_COL_WIDTH)-1 downto 0);
        SYNAPSE_MEM_ADDR                  : out  std_logic_vector(clogb2(SYNAPSE_MEM_DEPTH)-1 downto 0);
        SYNAPSE_MEM_DIN                   : out  std_logic_vector(15 downto 0);	
        SYNAPSE_MEM_DOUT                  : in   std_logic_vector(15 downto 0);
        SYNAPSE_MEM_EN                    : out  std_logic_vector(CROSSBAR_COL_WIDTH-1 downto 0); 
        SYNAPSE_MEM_WREN                  : out  std_logic_vector(CROSSBAR_COL_WIDTH-1 downto 0); 
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component SNN_PROCESSOR_slave_lite_v1_0_SYNAPSES;

	component SNN_PROCESSOR_slave_stream_v1_0_SPIKE_IN is
		generic (
		CROSSBAR_ROW_WIDTH  : integer := 32;
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
	
        MAIN_BUFFER_FULL : in std_logic;
        MAIN_BUFFER_WREN : out std_logic;
        MAIN_BUFFER_DIN  : out std_logic_vector(CROSSBAR_ROW_WIDTH-1 downto 0);

		S_AXIS_ACLK	: in std_logic;
		S_AXIS_ARESETN	: in std_logic;
		S_AXIS_TREADY	: out std_logic;
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		S_AXIS_TLAST	: in std_logic;
		S_AXIS_TVALID	: in std_logic
		);
	end component SNN_PROCESSOR_slave_stream_v1_0_SPIKE_IN;

	component SNN_PROCESSOR_master_stream_v1_0_SPIKE_OUT is
		generic (
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M_START_COUNT	: integer	:= 32
		);
		port (
		OUTFIFO_DOUT : in std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
        OUTFIFO_EMPTY : in std_logic;
        OUTFIFO_LAST  : in std_logic;
        DMA_READY     : out std_logic;
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic
		);
	end component SNN_PROCESSOR_master_stream_v1_0_SPIKE_OUT;


begin

-- Instantiation of Axi Bus Interface CONTROLS
SNN_PROCESSOR_slave_lite_v1_0_CONTROLS_inst : SNN_PROCESSOR_slave_lite_v1_0_CONTROLS
	generic map (
	    CROSSBAR_ROW_WIDTH  => C_CROSSBAR_ROW_WIDTH,
        CROSSBAR_COL_WIDTH  => C_CROSSBAR_COL_WIDTH,
        SYNAPSE_MEM_DEPTH   => SYNAPSE_MEM_DEPTH ,
        NEURAL_MEM_DEPTH    => NEURAL_MEM_DEPTH  ,
	
		C_S_AXI_DATA_WIDTH	=> C_CONTROLS_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_CONTROLS_ADDR_WIDTH
	)
	port map (
	       MAIN_BUFFER_FLUSH                 => MAIN_SPIKE_BUFFER_FLUSH   ,                    -- slv_reg4(10)
	       AUX_BUFFER_FLUSH                  => FLUSHPROPOGATORS        ,                    -- slv_reg4(11)
	       OUT_BUFFER_FLUSH                  => OUT_SPIKE_BUFFER_FLUSH   ,                    -- slv_reg4(12)
	       --WORKMODE                          : out std_logic;                             -- slv_reg4(7)         -- CT/ PS SLAVE
	       PROCEED_NEXT                      => PROCESSOR_TIMESTEP_STARTED,
	       NMC_PMODE_SWITCH                  => CONTROLS_NMC_PMODE_SWITCH  ,
	       SYNAPSE_ROUTE                     => PROCESSOR_SYNAPSE_ROUTE   ,
	       NMC_NPARAM_DATA                   => CONTROLS_NMC_NPARAM_DATA        ,    
	       NMC_NPARAM_ADDR                   => CONTROLS_NMC_NPARAM_ADDR        ,    
	       NMC_PROG_MEM_PORTA_EN             => CONTROLS_NMC_PROG_MEM_PORTA_EN  ,    
	       NMC_PROG_MEM_PORTA_WEN            => CONTROLS_NMC_PROG_MEM_PORTA_WEN ,
	       LEARN_LUT_DIN                     => CONTROLS_LEARN_LUT_DIN    ,
	       LEARN_LUT_ADDR                    => CONTROLS_LEARN_LUT_ADDR   ,
	       LEARN_LUT_EN                      => CONTROLS_LEARN_LUT_EN     ,
	       NMC_XNEVER_BASE                   => CONTROLS_NMC_XNEVER_BASE  ,      
	       NMC_XNEVER_HIGH                   => CONTROLS_NMC_XNEVER_HIGH  ,      
	       --TIMESTEP_UPDATE_CYCLES            : out std_logic_vector(15 downto 0);  -- slv_reg4(31 downto 16)   
	       --SPIKE_OUT_RDCOUNT                 : out std_logic_vector(15 downto 0);  -- slv-reg8(15 downto 0)
	       --READSPIKES                        : out std_logic;                      -- slv_reg8(27)
	       --SPIKE_OUT_TRANSFER_DELAY          : out std_logic_vector(9 downto 0);   -- slv_reg8(25 downto 16)
		S_AXI_ACLK	=> controls_aclk,
		S_AXI_ARESETN	=> controls_aresetn,
		S_AXI_AWADDR	=> controls_awaddr,
		S_AXI_AWPROT	=> controls_awprot,
		S_AXI_AWVALID	=> controls_awvalid,
		S_AXI_AWREADY	=> controls_awready,
		S_AXI_WDATA	=> controls_wdata,
		S_AXI_WSTRB	=> controls_wstrb,
		S_AXI_WVALID	=> controls_wvalid,
		S_AXI_WREADY	=> controls_wready,
		S_AXI_BRESP	=> controls_bresp,
		S_AXI_BVALID	=> controls_bvalid,
		S_AXI_BREADY	=> controls_bready,
		S_AXI_ARADDR	=> controls_araddr,
		S_AXI_ARPROT	=> controls_arprot,
		S_AXI_ARVALID	=> controls_arvalid,
		S_AXI_ARREADY	=> controls_arready,
		S_AXI_RDATA	=> controls_rdata,
		S_AXI_RRESP	=> controls_rresp,
		S_AXI_RVALID	=> controls_rvalid,
		S_AXI_RREADY	=> controls_rready
	);

-- Instantiation of Axi Bus Interface PARAMSPACE

    GENERATE_PARAMETER_MEM_INTF : for i in 0 to C_CROSSBAR_COL_WIDTH-1 generate

            PROCESSOR_PARAM_MEM_DIN(i)   <= PARAMSPACE_PARAM_MEM_DIN  ;
            PROCESSOR_PARAM_MEM_DADDR(i)(clogb2(NEURAL_MEM_DEPTH)-1 downto 0) <= PARAMSPACE_PARAM_MEM_ADDR  ;

            PROCESSOR_PARAM_MEM_EN(i)    <= PARAMSPACE_PARAM_MEM_EN(i)   ;
            PROCESSOR_PARAM_MEM_WREN(i)  <= PARAMSPACE_PARAM_MEM_WREN(i)  ;

    end generate GENERATE_PARAMETER_MEM_INTF;


SNN_PROCESSOR_slave_lite_v1_0_PARAMSPACE_inst : SNN_PROCESSOR_slave_lite_v1_0_PARAMSPACE
	generic map (
	    CROSSBAR_COL_WIDTH  => C_CROSSBAR_COL_WIDTH  ,
        NEURAL_MEM_DEPTH    => NEURAL_MEM_DEPTH    ,
		C_S_AXI_DATA_WIDTH	=> C_PARAMSPACE_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_PARAMSPACE_ADDR_WIDTH
	)
	port map (
	    SELECT_PARAM_MEM                => PARAMSPACE_SELECT_PARAM_MEM    ,        
        PARAM_MEM_ADDR                  => PARAMSPACE_PARAM_MEM_ADDR      ,     
        PARAM_MEM_DIN                   => PARAMSPACE_PARAM_MEM_DIN       ,     
        PARAM_MEM_DOUT                  => PARAMSPACE_PARAM_MEM_DOUT      ,     
        PARAM_MEM_EN                    => PARAMSPACE_PARAM_MEM_EN        ,     
        PARAM_MEM_WREN                  => PARAMSPACE_PARAM_MEM_WREN      ,     
		S_AXI_ACLK	=> paramspace_aclk,
		S_AXI_ARESETN	=> paramspace_aresetn,
		S_AXI_AWADDR	=> paramspace_awaddr,
		S_AXI_AWPROT	=> paramspace_awprot,
		S_AXI_AWVALID	=> paramspace_awvalid,
		S_AXI_AWREADY	=> paramspace_awready,
		S_AXI_WDATA	=> paramspace_wdata,
		S_AXI_WSTRB	=> paramspace_wstrb,
		S_AXI_WVALID	=> paramspace_wvalid,
		S_AXI_WREADY	=> paramspace_wready,
		S_AXI_BRESP	=> paramspace_bresp,
		S_AXI_BVALID	=> paramspace_bvalid,
		S_AXI_BREADY	=> paramspace_bready,
		S_AXI_ARADDR	=> paramspace_araddr,
		S_AXI_ARPROT	=> paramspace_arprot,
		S_AXI_ARVALID	=> paramspace_arvalid,
		S_AXI_ARREADY	=> paramspace_arready,
		S_AXI_RDATA	=> paramspace_rdata,
		S_AXI_RRESP	=> paramspace_rresp,
		S_AXI_RVALID	=> paramspace_rvalid,
		S_AXI_RREADY	=> paramspace_rready
	);

-- Instantiation of Axi Bus Interface SYNAPSES

    GENERATE_SYNAPTIC_MEM_INTF : for i in 0 to C_CROSSBAR_COL_WIDTH-1 generate

            PROCESSOR_SYNAPTIC_MEM_DIN(i)   <= SYNAPSES_SYNAPSE_MEM_DIN  ;
            PROCESSOR_SYNAPTIC_MEM_DADDR(i)(clogb2(SYNAPSE_MEM_DEPTH)-1 downto 0) <= SYNAPSES_SYNAPSE_MEM_ADDR  ;

                
            PROCESSOR_SYNAPTIC_MEM_EN(i)    <= SYNAPSES_SYNAPSE_MEM_EN(i)   ;
            PROCESSOR_SYNAPTIC_MEM_WREN(i)  <= SYNAPSES_SYNAPSE_MEM_WREN(i)  ;

    end generate GENERATE_SYNAPTIC_MEM_INTF;


SNN_PROCESSOR_slave_lite_v1_0_SYNAPSES_inst : SNN_PROCESSOR_slave_lite_v1_0_SYNAPSES
	generic map (
	    CROSSBAR_COL_WIDTH  => C_CROSSBAR_COL_WIDTH  ,
        SYNAPSE_MEM_DEPTH   => SYNAPSE_MEM_DEPTH   ,    
		C_S_AXI_DATA_WIDTH	=> C_SYNAPSES_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_SYNAPSES_ADDR_WIDTH
	)
	port map (
	    SELECT_SYNAPSE_MEM                => SYNAPSES_SELECT_SYNAPSE_MEM    ,
        SYNAPSE_MEM_ADDR                  => SYNAPSES_SYNAPSE_MEM_ADDR      ,
        SYNAPSE_MEM_DIN                   => SYNAPSES_SYNAPSE_MEM_DIN       ,
        SYNAPSE_MEM_DOUT                  => SYNAPSES_SYNAPSE_MEM_DOUT      ,
        SYNAPSE_MEM_EN                    => SYNAPSES_SYNAPSE_MEM_EN        ,
        SYNAPSE_MEM_WREN                  => SYNAPSES_SYNAPSE_MEM_WREN      ,
		S_AXI_ACLK	=> synapses_aclk,
		S_AXI_ARESETN	=> synapses_aresetn,
		S_AXI_AWADDR	=> synapses_awaddr,
		S_AXI_AWPROT	=> synapses_awprot,
		S_AXI_AWVALID	=> synapses_awvalid,
		S_AXI_AWREADY	=> synapses_awready,
		S_AXI_WDATA	=> synapses_wdata,
		S_AXI_WSTRB	=> synapses_wstrb,
		S_AXI_WVALID	=> synapses_wvalid,
		S_AXI_WREADY	=> synapses_wready,
		S_AXI_BRESP	=> synapses_bresp,
		S_AXI_BVALID	=> synapses_bvalid,
		S_AXI_BREADY	=> synapses_bready,
		S_AXI_ARADDR	=> synapses_araddr,
		S_AXI_ARPROT	=> synapses_arprot,
		S_AXI_ARVALID	=> synapses_arvalid,
		S_AXI_ARREADY	=> synapses_arready,
		S_AXI_RDATA	=> synapses_rdata,
		S_AXI_RRESP	=> synapses_rresp,
		S_AXI_RVALID	=> synapses_rvalid,
		S_AXI_RREADY	=> synapses_rready
	);

-- Instantiation of Axi Bus Interface SPIKE_IN
SNN_PROCESSOR_slave_stream_v1_0_SPIKE_IN_inst : SNN_PROCESSOR_slave_stream_v1_0_SPIKE_IN
	generic map (
		    CROSSBAR_ROW_WIDTH  => C_CROSSBAR_ROW_WIDTH  ,
		C_S_AXIS_TDATA_WIDTH	=> C_SPIKE_IN_TDATA_WIDTH
	)
	port map (
	    MAIN_BUFFER_FULL => MAIN_SPIKE_BUFFER_FULL ,
        MAIN_BUFFER_WREN => MAIN_SPIKE_BUFFER_WREN ,
        MAIN_BUFFER_DIN  => MAIN_SPIKE_BUFFER_DIN  ,
		S_AXIS_ACLK	    => spike_in_aclk,
		S_AXIS_ARESETN	=> spike_in_aresetn,
		S_AXIS_TREADY	=> spike_in_tready,
		S_AXIS_TDATA	=> spike_in_tdata,
		S_AXIS_TSTRB	=> spike_in_tstrb,
		S_AXIS_TLAST	=> spike_in_tlast,
		S_AXIS_TVALID	=> spike_in_tvalid
	);

-- Instantiation of Axi Bus Interface SPIKE_OUT
SNN_PROCESSOR_master_stream_v1_0_SPIKE_OUT_inst : SNN_PROCESSOR_master_stream_v1_0_SPIKE_OUT
	generic map (
		C_M_AXIS_TDATA_WIDTH	=> C_SPIKE_OUT_TDATA_WIDTH,
		C_M_START_COUNT	=> C_SPIKE_OUT_START_COUNT
	)
	port map (
	    OUTFIFO_DOUT  => OUT_SPIKE_BUFFER_DOUT  ,
        OUTFIFO_EMPTY => OUT_SPIKE_BUFFER_EMPTY ,
        OUTFIFO_LAST  => OUT_SPIKE_BUFFER_LAST  ,
        DMA_READY     => OUT_SPIKE_BUFFER_RDEN  ,
		M_AXIS_ACLK	=> spike_out_aclk,
		M_AXIS_ARESETN	=> spike_out_aresetn,
		M_AXIS_TVALID	=> spike_out_tvalid,
		M_AXIS_TDATA	=> spike_out_tdata,
		M_AXIS_TSTRB	=> spike_out_tstrb,
		M_AXIS_TLAST	=> spike_out_tlast,
		M_AXIS_TREADY	=> spike_out_tready
	);

	
	---------------------------- CROSSBAR BLOCK	BEGIN ---------------------------- 
	
	PROCESSOR_INIT :  SPIKE_PROCESSOR
    Generic Map(
            CROSSBAR_ROW_WIDTH  => C_CROSSBAR_ROW_WIDTH ,
            CROSSBAR_COL_WIDTH  => C_CROSSBAR_COL_WIDTH ,
            SYNAPSE_MEM_DEPTH   => SYNAPSE_MEM_DEPTH  ,
            NEURAL_MEM_DEPTH    => NEURAL_MEM_DEPTH   
            )
    Port Map( 
            SP_CLOCK                    => CORE_CLOCK      ,
            PARAMETER_MEM_RDCLK         => paramspace_aclk ,
            SP_RESET                    => CORE_RESET      ,
            TIMESTEP_STARTED            => PROCESSOR_TIMESTEP_STARTED ,
            TIMESTEP_COMPLETED          => global_timestep_update ,
            -- SPIKE_BUFFERS CONTROL (MAIN OR AUX)
            SPIKEVECTOR_IN              => PROCESSOR_SPIKEVECTOR_IN              ,
            SPIKEVECTOR_VLD_IN          => PROCESSOR_SPIKEVECTOR_VLD_IN          ,
            READ_MAIN_SPIKE_BUFFER      => PROCESSOR_READ_MAIN_SPIKE_BUFFER  ,
            READ_PROPOGATOR_0           => PROCESSOR_READ_PROPOGATOR_0       ,
            READ_PROPOGATOR_1           => PROCESSOR_READ_PROPOGATOR_1       ,
            -- EVENT ACCEPTANCE
            EVENT_ACCEPT                => PROCESSOR_EVENT_ACCEPT ,
            -- SYNAPSE RECYCLE OR EXTERNAL ACCESS
            SYNAPSE_ROUTE               => PROCESSOR_SYNAPSE_ROUTE ,
            -- SYNAPSE MEMORY INTERFACE SELECTION
            SYNAPTIC_MEM_DIN            => PROCESSOR_SYNAPTIC_MEM_DIN   ,
            SYNAPTIC_MEM_DADDR          => PROCESSOR_SYNAPTIC_MEM_DADDR ,
            SYNAPTIC_MEM_EN             => PROCESSOR_SYNAPTIC_MEM_EN    ,
            SYNAPTIC_MEM_WREN           => PROCESSOR_SYNAPTIC_MEM_WREN  ,
            SYNAPTIC_MEM_DOUT           => PROCESSOR_SYNAPTIC_MEM_DOUT  ,
            -- NMC MEMORY BOUNDARY REGISTERS
            NMC_XNEVER_BASE             => CONTROLS_NMC_XNEVER_BASE  ,
            NMC_XNEVER_HIGH             => CONTROLS_NMC_XNEVER_HIGH  ,
            -- NMC PROGRAMMING INTERFACE TIED TO ALL NMC UNITS
            NMC_PMODE_SWITCH            => CONTROLS_NMC_PMODE_SWITCH  ,
            NMC_NPARAM_DATA             => CONTROLS_NMC_NPARAM_DATA        ,
            NMC_NPARAM_ADDR             => CONTROLS_NMC_NPARAM_ADDR        ,
            NMC_PROG_MEM_PORTA_EN       => CONTROLS_NMC_PROG_MEM_PORTA_EN  ,
            NMC_PROG_MEM_PORTA_WEN      => CONTROLS_NMC_PROG_MEM_PORTA_WEN ,
            -- SPIKE OUTPUTS
            NMC_SPIKE_OUT               => PROCESSOR_NMC_SPIKE_OUT           ,
            NMC_SPIKE_OUT_VLD           => PROCESSOR_NMC_SPIKE_OUT_VLD       ,
            NMC_WR_PROPOGATOR_0         => PROCESSOR_NMC_WR_PROPOGATOR_0   ,
            NMC_WR_PROPOGATOR_1         => PROCESSOR_NMC_WR_PROPOGATOR_1   ,
            NMC_WR_OUT_BUFFER           => PROCESSOR_NMC_WR_OUT_BUFFER     ,
             -- ULEARN LUT TIED TO ALL LEARNING ENGINES
            LEARN_LUT_DIN               => CONTROLS_LEARN_LUT_DIN      ,
            LEARN_LUT_ADDR              => CONTROLS_LEARN_LUT_ADDR     ,
            LEARN_LUT_EN                => CONTROLS_LEARN_LUT_EN       ,
            -- PARAMETER MEMORY INTERFACE SELECTION
            PARAM_MEM_DIN               => PROCESSOR_PARAM_MEM_DIN       ,
            PARAM_MEM_DADDR             => PROCESSOR_PARAM_MEM_DADDR     ,
            PARAM_MEM_EN                => PROCESSOR_PARAM_MEM_EN        ,
            PARAM_MEM_WREN              => PROCESSOR_PARAM_MEM_WREN      ,
            PARAM_MEM_DOUT              => PROCESSOR_PARAM_MEM_DOUT      ,
            -- ERROR FLAGS
            NMC_MATH_ERROR_VEC          => PROCESSOR_NMC_MATH_ERROR_VEC     ,
            NMC_MEM_VIOLATION_VEC       => PROCESSOR_NMC_MEM_VIOLATION_VEC  
            
          );
    
   VIOLATION_SQUEEZE : or_reduce
    generic map(
        N => C_CROSSBAR_COL_WIDTH
    )
    port map (
        A => PROCESSOR_NMC_MEM_VIOLATION_VEC  ,
        Y => core_memory_violation
    );
   
   ERROR_SQUEEZE : or_reduce
    generic map(
        N =>  C_CROSSBAR_COL_WIDTH
    )
    port map(
        A => PROCESSOR_NMC_MATH_ERROR_VEC , 
        Y => core_math_error
    );

PARAM_MEM_DOUT_ROUT :  Param_Dout_Mux
	Generic Map (
		CROSSBAR_COL_WIDTH  => C_CROSSBAR_COL_WIDTH
		)
    Port Map ( 
        PARAM_MEM_SELECT   => PARAMSPACE_SELECT_PARAM_MEM ,
        PARAM_MEM_DOUT     => PROCESSOR_PARAM_MEM_DOUT ,
        MUXDOUT            =>  PARAMSPACE_PARAM_MEM_DOUT
        );


SYNAPSE_MEM_DOUT_ROUT :  Synapse_Dout_Mux
	Generic Map (
		CROSSBAR_COL_WIDTH  => C_CROSSBAR_COL_WIDTH
		)
    Port Map ( 
         SYNAPSE_MEM_SELECT  => SYNAPSES_SELECT_SYNAPSE_MEM ,
         SYNAPSE_MEM_DOUT    => PROCESSOR_SYNAPTIC_MEM_DOUT ,
         MUXDOUT             => SYNAPSES_SYNAPSE_MEM_DOUT
        );
        
 
 EVENT_SINK_PROCESS : process(CORE_CLOCK)
 
    begin
    
        if(rising_edge(CORE_CLOCK)) then
        
            if(CORE_RESET = '1') then
            
                MAIN_SPIKE_BUFFER_RDEN  <= '0';
                PROPOGATOR_0_RDEN       <= '0';
                PROPOGATOR_1_RDEN       <= '0';
            else
                        
                if PROCESSOR_READ_MAIN_SPIKE_BUFFER = '1' and MAIN_SPIKE_BUFFER_EMPTY = '0' then
            
                    MAIN_SPIKE_BUFFER_RDEN <= MAIN_SPIKE_BUFFER_RDEN xor PROCESSOR_EVENT_ACCEPT;
                    
                else
                
                    MAIN_SPIKE_BUFFER_RDEN <= '0';
                
                end if;
                         
                if PROCESSOR_READ_PROPOGATOR_0 = '1' then
            
                    PROPOGATOR_0_RDEN <= PROPOGATOR_0_RDEN xor PROCESSOR_EVENT_ACCEPT;
                    
                else
                
                    PROPOGATOR_0_RDEN <= '0';    
                    
                end if;          
                         
                if PROCESSOR_READ_PROPOGATOR_1 = '1' then
                
                     PROPOGATOR_1_RDEN <= PROPOGATOR_1_RDEN  xor PROCESSOR_EVENT_ACCEPT;
             
                else
                
                     PROPOGATOR_1_RDEN <= '0';    
                
                end if;                          
                            
            end if;
        
        end if;
    
 end process EVENT_SINK_PROCESS;


 READFIFOSELECT <= PROCESSOR_READ_PROPOGATOR_1 & PROCESSOR_READ_PROPOGATOR_0 & PROCESSOR_READ_MAIN_SPIKE_BUFFER;

 PROCESSOR_SPIKEVECTOR_VLD_IN <= MAIN_SPIKE_BUFFER_RDEN when READFIFOSELECT = "001" else
                                 PROPOGATOR_0_RDEN      when READFIFOSELECT = "010" else
                                 PROPOGATOR_1_RDEN      when READFIFOSELECT = "100" else
                                 '0';
 PROCESSOR_SPIKEVECTOR_IN     <= MAIN_SPIKE_BUFFER_DOUT when READFIFOSELECT = "001" else 
                                 PROPOGATOR_0_DOUT      when READFIFOSELECT = "010" else
                                 PROPOGATOR_1_DOUT      when READFIFOSELECT = "100" else
                                 (others=>'0');
 
 MAIN_SPIKE_BUFFER : xpm_fifo_async
   generic map (
      CASCADE_HEIGHT => 0,            -- DECIMAL
      CDC_SYNC_STAGES => 2,           -- DECIMAL
      DOUT_RESET_VALUE => "0",        -- String
      ECC_MODE => "no_ecc",           -- String
      EN_SIM_ASSERT_ERR => "warning", -- String
      FIFO_MEMORY_TYPE => "auto",     -- String
      FIFO_READ_LATENCY => 1,         -- DECIMAL
      FIFO_WRITE_DEPTH => 2048,       -- DECIMAL
      FULL_RESET_VALUE => 0,          -- DECIMAL
      PROG_EMPTY_THRESH => 10,        -- DECIMAL
      PROG_FULL_THRESH => 10,         -- DECIMAL
      RD_DATA_COUNT_WIDTH => 1,       -- DECIMAL
      READ_DATA_WIDTH => C_CROSSBAR_ROW_WIDTH,          -- DECIMAL
      READ_MODE => "fwft",             -- String
      RELATED_CLOCKS => 0,            -- DECIMAL
      SIM_ASSERT_CHK => 0,            -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      USE_ADV_FEATURES => "0000",     -- String
      WAKEUP_TIME => 0,               -- DECIMAL
      WRITE_DATA_WIDTH => C_CROSSBAR_ROW_WIDTH,         -- DECIMAL
      WR_DATA_COUNT_WIDTH => 1        -- DECIMAL
   )
   port map (
      dout          => MAIN_SPIKE_BUFFER_DOUT    ,                                                        
      empty         => MAIN_SPIKE_BUFFER_EMPTY   ,                 
      full          => MAIN_SPIKE_BUFFER_FULL    ,                   
      din           => MAIN_SPIKE_BUFFER_DIN     ,                     
      injectdbiterr => '0'                       , 
      injectsbiterr => '0'                       , 
      rd_clk        => CORE_CLOCK                ,               
      rd_en         => MAIN_SPIKE_BUFFER_RDEN    ,                 
      rst           => MAIN_SPIKE_BUFFER_FLUSH   ,                     
      sleep         => '0'                       ,                 
      wr_clk        => spike_in_aclk              ,               
      wr_en         => MAIN_SPIKE_BUFFER_WREN                  
   );

    GENERATE_NMC_SPIKE_LATCH : for k in 0 to C_CROSSBAR_COL_WIDTH-1 generate

        NMC_SPIKE_HOOK : process(CORE_CLOCK)
 
        begin
        
            if(rising_edge(CORE_CLOCK)) then
            
                if(CORE_RESET = '1') then
                
                    SPIKE_STATE(k) <= LISTENING ;
                
                else
                
                    case SPIKE_STATE(k) is
                    
                        when LISTENING  =>
                        
                            if(PROCESSOR_NMC_SPIKE_OUT_VLD(k) = '1') then
                                SPIKE_STATE(k)         <=  CATCHSPIKE;
                                ALL_SPIKES_ARRIVED(k)  <= '1';
                            else
                                NMC_SPIKE_OUT_LATCH(k) <=  '0';
                                ALL_SPIKES_ARRIVED(k)  <=  '0';
                                SPIKE_STATE(k)         <=  LISTENING;
                            end if;
                        
                        when CATCHSPIKE =>
                        
                            NMC_SPIKE_OUT_LATCH(k) <=  PROCESSOR_NMC_SPIKE_OUT(k);
                        
                            if (SPIKE_SYNCHRONIZER = '1') then
                                SPIKE_STATE(k)         <=  CATCHSPIKE;
                            else
                                SPIKE_STATE(k)         <=  LISTENING;
                            end if;
                                                
                        when others =>
                             SPIKE_STATE(k)         <=  LISTENING;
                             
                     end case;
                                          
                end if;
            end if;
        
        end process NMC_SPIKE_HOOK;
  
    end generate GENERATE_NMC_SPIKE_LATCH;
    
    LATCH_DELAY : process(CORE_CLOCK)
    
        begin
            
                if(rising_edge(CORE_CLOCK)) then
                
                    if(CORE_RESET = '1') then
                    
                        NMC_SPIKE_OUT_LATCH_DELAY <= (others=>'0');
                        
                    else   
                    
                        NMC_SPIKE_OUT_LATCH_DELAY <= NMC_SPIKE_OUT_LATCH;
                    
                    end if;
                    
                end if; 
    
    end process LATCH_DELAY;

    FIFO_WRCNTROLS : process(CORE_CLOCK)
    
        begin
            
                if(rising_edge(CORE_CLOCK)) then
                
                    if(CORE_RESET = '1') then
                    
                        FIFOSTATE <= WAITINPUT;
                        
                    else
                    
                        case FIFOSTATE is
                        
                            when WAITINPUT =>
                            
                                SPIKE_SYNCHRONIZER <= '0';
                                WRITESPIKES        <= '0';
                                
                                if(ALL_SPIKES_ARRIVED = ARRIVAL) then
                                    FIFOSTATE <= WRITE;
                                else
                                    FIFOSTATE <= WAITINPUT;
                                end if;
                            
                            when WRITE     =>
                                SPIKE_SYNCHRONIZER <= '1';
                                WRITESPIKES        <= '1';
                                FIFOSTATE          <= WAITINPUT;
                            when others    =>
                                 FIFOSTATE <= WAITINPUT;
                        end case;
                    
                    end if;
                    
                 end if;
                 
     end process FIFO_WRCNTROLS;

      PROPOGATOR_0_DIN      <= NMC_SPIKE_OUT_LATCH_DELAY;
      PROPOGATOR_1_DIN      <= NMC_SPIKE_OUT_LATCH_DELAY;
      OUT_SPIKE_BUFFER_DIN(C_CROSSBAR_ROW_WIDTH-1 downto 0)  <= NMC_SPIKE_OUT_LATCH_DELAY;
      
      PROPOGATOR_0_WREN     <= PROCESSOR_NMC_WR_PROPOGATOR_0 and WRITESPIKES ;
      PROPOGATOR_1_WREN     <= PROCESSOR_NMC_WR_PROPOGATOR_1 and WRITESPIKES ;
      OUT_SPIKE_BUFFER_WREN <= PROCESSOR_NMC_WR_OUT_BUFFER and WRITESPIKES ;
       
      PROPOGATOR_0_FLUSH <= FLUSHPROPOGATORS;
      PROPOGATOR_1_FLUSH <= FLUSHPROPOGATORS;
       
    PROPOGATOR_0 :  SPIKE_PROPOGATOR 
    generic map(
        DEPTH => PROPOGATOR_WIDTH,
        WIDTH => C_CROSSBAR_ROW_WIDTH
    )
    port map(
        clk       => CORE_CLOCK            ,
        rst       => PROPOGATOR_0_FLUSH,
        wr_en     => PROPOGATOR_0_WREN ,
        rd_en     => PROPOGATOR_0_RDEN ,
        data_in   => PROPOGATOR_0_DIN  ,
        data_out  => PROPOGATOR_0_DOUT
    );
      
    PROPOGATOR_1 :  SPIKE_PROPOGATOR 
    generic map(
        DEPTH => PROPOGATOR_WIDTH,
        WIDTH => C_CROSSBAR_ROW_WIDTH
    )
    port map(
        clk       => CORE_CLOCK            ,
        rst       => PROPOGATOR_1_FLUSH,
        wr_en     => PROPOGATOR_1_WREN ,
        rd_en     => PROPOGATOR_1_RDEN ,
        data_in   => PROPOGATOR_1_DIN  ,
        data_out  => PROPOGATOR_1_DOUT
    );      


OUT_SPIKE_BUFFER : OUTFIFO 
    generic map(
        RAMTYPE => "block",
        DEPTH   =>  PROPOGATOR_WIDTH , 
        WIDTH   =>  32   
    )
    port map(
        wr_clk    =>   CORE_CLOCK             ,
        rd_clk    =>   spike_out_aclk         ,
        rst       =>   OUT_SPIKE_BUFFER_FLUSH ,
        wr_en     => OUT_SPIKE_BUFFER_WREN ,
        rd_en     => OUT_SPIKE_BUFFER_RDEN ,
        data_in   => OUT_SPIKE_BUFFER_DIN  ,
        data_out  => OUT_SPIKE_BUFFER_DOUT ,
        full      => OUT_SPIKE_BUFFER_FULL ,
        last      => OUT_SPIKE_BUFFER_LAST ,
        empty     => OUT_SPIKE_BUFFER_EMPTY
    );

        input_buffer_full      <= MAIN_SPIKE_BUFFER_FULL ;
        output_buffer_full     <= OUT_SPIKE_BUFFER_FULL  ;
        event_presence         <= not OUT_SPIKE_BUFFER_EMPTY ;


end arch_imp;