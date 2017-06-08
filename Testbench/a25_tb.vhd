---------------------------------------------------------------
-- Title         : Testbench A25
-- Project       : 
---------------------------------------------------------------
-- File          : a25_tb.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 31/01/12
---------------------------------------------------------------
-- Simulator     : 
-- Synthesis     : 
---------------------------------------------------------------
-- Description :
--
-- 
---------------------------------------------------------------
-- Hierarchy:
--
-- 
---------------------------------------------------------------
-- Copyright (c) 2016, MEN Mikro Elektronik GmbH
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.fpga_pkg_2.ALL;
USE work.vme_sim_pack.all;
USE work.terminal_pkg.all;
use work.pcie_sim_pkg.all;

ENTITY a25_tb IS
   generic(
      BFM_LANE_WIDTH : integer range 8 downto 0 := 1                            -- set configuration: 1=x1, 2=x2, 4=x4 and 8=x8
   );
END a25_tb;

ARCHITECTURE a25_tb_arch OF a25_tb IS 
COMPONENT A25_top 
GENERIC (
   SIMULATION        : boolean                        := FALSE;
   FPGA_FAMILY       : family_type := CYCLONE4;
   BFM_LANE_WIDTH    : integer range 8 downto 0 := 1;                           -- set configuration: 1=x1, 2=x2, 4=x4 and 8=x8
   sets              : std_logic_vector(3 DOWNTO 0) := "1110";
   timeout           : integer := 5000 );
PORT (

   clk_16mhz         : IN std_logic;
   led_green_n       : OUT std_logic;
   led_red_n         : OUT std_logic;                                                   
   hreset_n          : IN std_logic;                        -- reset
   v2p_rstn          : OUT std_logic;                       -- connected to hreset_req1_n
   fpga_test         : INOUT std_logic_vector(5 DOWNTO 1);

   -- pcie
   refclk            : IN std_logic;                        -- 100 MHz pcie clock
   pcie_rx           : IN    std_logic_vector(3 DOWNTO 0);                     -- PCIe receive line
   pcie_tx           : OUT   std_logic_vector(3 DOWNTO 0);                     -- PCIe transmit line

   -- sram bus
   sr_clk            : OUT std_logic;
   sr_a              : OUT std_logic_vector(18 DOWNTO 0);
   sr_d              : INOUT std_logic_vector(15 DOWNTO 0);
   sr_bwa_n          : OUT std_logic;
   sr_bwb_n          : OUT std_logic;
   sr_bw_n           : OUT std_logic;
   sr_cs1_n          : OUT std_logic;
   sr_adsc_n         : OUT std_logic;
   sr_oe_n           : OUT std_logic;
   
   -- vmebus
   vme_ga            : IN std_logic_vector(4 DOWNTO 0);     -- geographical addresses
   vme_gap           : IN std_logic;     -- geographical addresses
   vme_a             : INOUT std_logic_vector(31 DOWNTO 0);
   vme_a_dir         : OUT std_logic;
   vme_a_oe_n        : OUT std_logic;                   
   vme_d             : INOUT std_logic_vector(31 DOWNTO 0);
   vme_d_dir         : OUT std_logic;
   vme_d_oe_n        : OUT std_logic;
   vme_am_dir        : OUT std_logic;
   vme_am            : INOUT std_logic_vector(5 DOWNTO 0);
   vme_am_oe_n       : OUT std_logic;
   vme_write_n       : INOUT std_logic;
   vme_iack_n        : INOUT std_logic;
   vme_irq_i_n       : IN std_logic_vector(7 DOWNTO 1);
   vme_irq_o         : OUT std_logic_vector(7 DOWNTO 1); -- high active on A25
   vme_as_i_n        : IN std_logic;
   vme_as_o_n        : OUT std_logic;
   vme_as_oe         : OUT std_logic;                    -- high active on A25
   vme_retry_o_n     : OUT std_logic;
   vme_retry_oe      : OUT std_logic;                    -- high active on A25
   vme_retry_i_n     : IN std_logic;
   vme_sysres_i_n    : IN std_logic;
   vme_sysres_o      : OUT std_logic;                    -- high active on A25
   vme_ds_i_n        : IN std_logic_vector(1 DOWNTO 0);
   vme_ds_o_n        : OUT std_logic_vector(1 DOWNTO 0);
   vme_ds_oe         : OUT std_logic;                    -- high active on A25
   vme_berr_i_n      : IN std_logic;
   vme_berr_o        : OUT std_logic;                      -- high active on A25
   vme_dtack_i_n     : IN std_logic;
   vme_dtack_o       : OUT std_logic;                      -- high active on A25
   vme_scon          : OUT std_logic;                    -- high active on A25
   vme_sysfail_i_n   : IN std_logic;
   vme_sysfail_o     : OUT std_logic;                    -- high active on A25
   vme_bbsy_i_n      : IN std_logic;
   vme_bbsy_o        : OUT std_logic;                    -- high active on A25
   vme_bclr_i_n      : IN std_logic;                           -- bus clear input
   vme_bclr_o_n      : OUT std_logic;                          -- bus clear output
   vme_br_i_n        : IN std_logic_vector(3 DOWNTO 0);
   vme_br_o          : OUT std_logic_vector(3 DOWNTO 0); -- high active on A25
   vme_iack_i_n      : IN std_logic;
   vme_iack_o_n      : OUT std_logic;
   vme_acfail_i_n    : IN std_logic;
   vme_sysclk        : OUT std_logic;
   vme_bg_i_n        : IN std_logic_vector(3 DOWNTO 0);
   vme_bg_o_n        : OUT std_logic_vector(3 DOWNTO 0);

   -- Hard IP BFM connections
   ep_rxvalid_i    : in  std_logic_vector(BFM_LANE_WIDTH -1 downto 0);       -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
   ep_rxstatus_i   : in  std_logic_vector(3*BFM_LANE_WIDTH -1 downto 0);     -- 3bits per lane, [2:0]=lane0, [5:3]=lane1 etc.
   ep_rxdatak_i    : in  std_logic_vector(BFM_LANE_WIDTH -1 downto 0);       -- 1bits per lane, [0]=lane0, [1]=lane1 etc.
   ep_rxdata_i     : in  std_logic_vector(8*BFM_LANE_WIDTH -1 downto 0);     -- 8bits per lane, [7:0]=lane0, [15:8]=lane1 etc.
   ep_rxelecidle_i : in  std_logic_vector(BFM_LANE_WIDTH -1 downto 0);       -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
   ep_phystatus_i  : in  std_logic_vector(BFM_LANE_WIDTH -1 downto 0);       -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
   
   ep_clk250_o        : out std_logic;                                       -- endpoint SERDES 250MHz clk output
   ep_clk500_o        : out std_logic;                                       -- endpoint SERDES 500MHz clk output
   ep_rate_ext_o      : out std_logic;                                       -- endpoint rate_ext
   ep_powerdown_ext_o : out std_logic_vector(2*BFM_LANE_WIDTH -1 downto 0);  -- 2bits per lane, [1:0]=lane0, [3:2]=lane1 etc.
   ep_txdatak_o       : out std_logic_vector(BFM_LANE_WIDTH -1 downto 0);    -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
   ep_txdata_o        : out std_logic_vector(8*BFM_LANE_WIDTH -1 downto 0);  -- 8bits per lane, [7:0]=lane0, [15:8]=lane1 etc.
   ep_txcompl_o       : out std_logic_vector(BFM_LANE_WIDTH -1 downto 0);    -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
   ep_txelecidle_o    : out std_logic_vector(BFM_LANE_WIDTH -1 downto 0);    -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
   ep_txdetectrx_o    : out std_logic_vector(BFM_LANE_WIDTH -1 downto 0);    -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
   ep_rxpolarity_o    : out std_logic_vector(BFM_LANE_WIDTH -1 downto 0)     -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
   );
END COMPONENT;

COMPONENT MT58L512L18F 
    GENERIC (
        -- Clock
        tKC       : TIME    :=  8.0 ns;  -- Timing are for -6.8
        tKH       : TIME    :=  1.8 ns;
        tKL       : TIME    :=  1.8 ns;
        -- Output Times
        tKQHZ     : TIME    :=  3.8 ns;
        -- Setup Times
        tAS       : TIME    :=  1.8 ns;
        tADSS     : TIME    :=  1.8 ns;
        tAAS      : TIME    :=  1.8 ns;
        tWS       : TIME    :=  1.8 ns;
        tDS       : TIME    :=  1.8 ns;
        tCES      : TIME    :=  1.8 ns;
        -- Hold Times
        tAH       : TIME    :=  0.5 ns;
        tADSH     : TIME    :=  0.5 ns;
        tAAH      : TIME    :=  0.5 ns;
        tWH       : TIME    :=  0.5 ns;
        tDH       : TIME    :=  0.5 ns;
        tCEH      : TIME    :=  0.5 ns;
        -- Bus Width and Data Bus
        addr_bits : INTEGER := 19;
        data_bits : INTEGER := 18
    );
    PORT (
        Dq        : INOUT STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');
        Addr      : IN    STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);
        Mode      : IN    STD_LOGIC;
        Adv_n     : IN    STD_LOGIC;
        Clk       : IN    STD_LOGIC;
        Adsc_n    : IN    STD_LOGIC;
        Adsp_n    : IN    STD_LOGIC;
        Bwa_n     : IN    STD_LOGIC;
        Bwb_n     : IN    STD_LOGIC;
        Bwe_n     : IN    STD_LOGIC;
        Gw_n      : IN    STD_LOGIC;
        Ce_n      : IN    STD_LOGIC;
        Ce2       : IN    STD_LOGIC;
        Ce2_n     : IN    STD_LOGIC;
        Oe_n      : IN    STD_LOGIC;
        Zz        : IN    STD_LOGIC
    );
END COMPONENT;

COMPONENT vmebus
PORT (
   slot1          : IN boolean:=TRUE;                     -- if true dut is in slot1
   vme_slv_in     : IN vme_slv_in_type;
   vme_slv_out    : OUT vme_slv_out_type;
   vme_mon_out    : OUT vme_mon_out_type;
   terminal_in_x  : OUT terminal_in_type;
   terminal_out_x : IN terminal_out_type;
   
    -- the VME signals:
   vb_am          : INOUT std_logic_vector(5 DOWNTO 0);   
   vb_data        : INOUT std_logic_vector(31 DOWNTO 0);   
   vb_adr         : INOUT std_logic_vector(31 DOWNTO 0);   
   vb_writen      : INOUT std_logic;            
   vb_iackn       : INOUT std_logic;            
   vb_asn         : INOUT std_logic;            
   vb_dsan        : INOUT std_logic;            
   vb_dsbn        : INOUT std_logic;            
   vb_bbsyn       : INOUT std_logic;            
   vb_berrn       : INOUT std_logic;            
   vb_brn         : INOUT std_logic_vector(3 DOWNTO 0);            
   vb_dtackn      : INOUT std_logic;            
   vb_sysresn     : INOUT std_logic;            
   vb_irq1n       : INOUT std_logic;         
   vb_irq2n       : INOUT std_logic;         
   vb_irq3n       : INOUT std_logic;         
   vb_irq4n       : INOUT std_logic;         
   vb_irq5n       : INOUT std_logic;         
   vb_irq6n       : INOUT std_logic;         
   vb_irq7n       : INOUT std_logic;         
   vb_bgin        : OUT std_logic_vector(3 DOWNTO 0);            
   vb_bgout       : IN std_logic_vector(3 DOWNTO 0);             
   vb_iackin      : OUT std_logic;            
   vb_iackout     : IN std_logic;            
   vb_acfailn     : INOUT std_logic
   );
END COMPONENT;

COMPONENT SN74LVTH245
GENERIC (
   OP_COND  : integer:=1;                                      -- 0=min, 1=typ, 2=max
   WIDTH    : integer:=8
   );
PORT (
   dir      : IN std_logic;                                    -- direction: 0= B data to A, 1= A data to B
   oe_n     : IN std_logic;                                    -- output enable: 0= driver is active, 1= tri-state
   a        : INOUT std_logic_vector(WIDTH-1 DOWNTO 0);        -- port A
   b        : INOUT std_logic_vector(WIDTH-1 DOWNTO 0)         -- port B
   );
END COMPONENT;

COMPONENT SN74ABT125
GENERIC (
   OP_COND  : integer:=1;                             -- 0=min, 1=typ, 2=max
   WIDTH    : integer:=8
   );
PORT (
   oe_n     : IN std_logic_vector(WIDTH-1 DOWNTO 0);     -- output enable: 0= driver is active, 1= tri-state
   a        : IN std_logic_vector(WIDTH-1 DOWNTO 0);     -- port A
   b        : OUT std_logic_vector(WIDTH-1 DOWNTO 0)      -- port B
   );
END COMPONENT;

COMPONENT terminal 
PORT (
   hreset_n          : OUT std_logic;
   
   slot1             : OUT boolean:=TRUE;                     -- if true dut is in slot1
   en_clk            : OUT boolean;
   terminal_in_0     : IN terminal_in_type;
   terminal_out_0    : OUT terminal_out_type;
   terminal_in_1     : IN terminal_in_type;
   terminal_out_1    : OUT terminal_out_type;

   v2p_rstn          : IN std_logic;                       -- connected to hreset_req1_n
   vme_slv_in        : OUT vme_slv_in_type;
   vme_slv_out       : IN vme_slv_out_type;
   vme_mon_out       : IN vme_mon_out_type;
   
   vme_ga            : OUT std_logic_vector(4 DOWNTO 0);     -- geographical addresses
   vme_gap           : OUT std_logic                       -- geographical addresses
     );
END COMPONENT;
   
component pcie_sim
   generic(
      BFM_LANE_WIDTH : integer range 8 downto 0 := 1                            -- set configuration: 1=x1, 2=x2, 4=x4 and 8=x8
   );
   port(
      rst_i       : in  std_logic;
      pcie_rstn_i : in  std_logic;
      clk_i       : in  std_logic;
      ep_clk250_i : in  std_logic;                                              -- endpoint SERDES 250MHz clk output
      ep_clk500_i : in  std_logic;                                              -- endpoint SERDES 500MHz clk output

      -- PCIe lanes
      bfm_tx_i : in  std_logic_vector(BFM_LANE_WIDTH -1 downto 0);
      bfm_rx_o : out std_logic_vector(BFM_LANE_WIDTH -1 downto 0);

      -- PCIe SERDES connection,  in/out references are BFM view
      ep_rate_ext_i      : in  std_logic;                                       -- endpoint rate_ext
      ep_powerdown_ext_i : in  std_logic_vector(2*BFM_LANE_WIDTH -1 downto 0);  -- 2bits per lane, [1:0]=lane0, [3:2]=lane1 etc.
      ep_txdatak_i       : in  std_logic_vector(BFM_LANE_WIDTH -1 downto 0);    -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
      ep_txdata_i        : in  std_logic_vector(8*BFM_LANE_WIDTH -1 downto 0);  -- 8bits per lane, [7:0]=lane0, [15:8]=lane1 etc.
      ep_txcompl_i       : in  std_logic_vector(BFM_LANE_WIDTH -1 downto 0);    -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
      ep_txelecidle_i    : in  std_logic_vector(BFM_LANE_WIDTH -1 downto 0);    -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
      ep_txdetectrx_i    : in  std_logic_vector(BFM_LANE_WIDTH -1 downto 0);    -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
      ep_rxpolarity_i    : in  std_logic_vector(BFM_LANE_WIDTH -1 downto 0);    -- 1bit per lane, [0]=lane0, [1]=lane1 etc.

      ep_rxvalid_o    : out std_logic_vector(BFM_LANE_WIDTH -1 downto 0);       -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
      ep_rxstatus_o   : out std_logic_vector(3*BFM_LANE_WIDTH -1 downto 0);     -- 3bits per lane, [2:0]=lane0, [5:3]=lane1 etc.
      ep_rxdatak_o    : out std_logic_vector(BFM_LANE_WIDTH -1 downto 0);       -- 1bits per lane, [0]=lane0, [1]=lane1 etc.
      ep_rxdata_o     : out std_logic_vector(8*BFM_LANE_WIDTH -1 downto 0);     -- 8bits per lane, [7:0]=lane0, [15:8]=lane1 etc.
      ep_rxelecidle_o : out std_logic_vector(BFM_LANE_WIDTH -1 downto 0);       -- 1bit per lane, [0]=lane0, [1]=lane1 etc.
      ep_phystatus_o  : out std_logic_vector(BFM_LANE_WIDTH -1 downto 0);       -- 1bit per lane, [0]=lane0, [1]=lane1 etc.

      -- MEN terminal connection, in/out references are terminal view
      term_out : in  terminal_out_type;
      term_in  : out terminal_in_type
   );
end component;

   CONSTANT T_FPGA_TO_SRAM  : time := 0 ns;

   SIGNAL clk_125           : std_logic:='1';
   SIGNAL clk_250           : std_logic:='0';
   SIGNAL clk_16mhz_int     : std_logic:='0';
   SIGNAL clk_16mhz         : std_logic:='0';
   SIGNAL en_clk            : boolean;
   SIGNAL led_green_n       : std_logic;
   SIGNAL led_red_n         : std_logic;                                                   
   SIGNAL hreset_n          : std_logic;                        -- reset
   SIGNAL hreset           : std_logic;                        -- reset
   SIGNAL v2p_rstn          : std_logic;                       -- connected to hreset_req1_n

   SIGNAL refclk           : std_logic:='0';                        -- 100 MHz pcie clock
   SIGNAL pcie_rx           : std_logic_vector(3 DOWNTO 0);                     -- PCIe receive line
   SIGNAL pcie_tx           : std_logic_vector(3 DOWNTO 0);                     -- PCIe transmit line


   SIGNAL sr_clk            : std_logic;
   SIGNAL trans_sr_clk      : std_logic;
   SIGNAL sr_a              : std_logic_vector(18 DOWNTO 0);
   SIGNAL sr_d              : std_logic_vector(15 DOWNTO 0);
   SIGNAL sr_bwa_n          : std_logic;
   SIGNAL sr_bwb_n          : std_logic;
   SIGNAL sr_bw_n           : std_logic;
   SIGNAL sr_cs1_n          : std_logic;
   SIGNAL sr_adsc_n         : std_logic;
   SIGNAL sr_oe_n           : std_logic;

   SIGNAL vme_ga            : std_logic_vector(4 DOWNTO 0);
   SIGNAL vme_gap            : std_logic;
   SIGNAL vme_a             : std_logic_vector(31 DOWNTO 0);
   SIGNAL vme_a_dir         : std_logic;
   SIGNAL vme_a_oe_n        : std_logic;
   SIGNAL vme_d             : std_logic_vector(31 DOWNTO 0);
   SIGNAL vme_d_dir         : std_logic;
   SIGNAL vme_d_oe_n        : std_logic;
   SIGNAL vme_am_dir        : std_logic;
   SIGNAL vme_am            : std_logic_vector(5 DOWNTO 0);
   SIGNAL vme_am_oe_n       : std_logic;
   SIGNAL vme_write_n       : std_logic;
   SIGNAL vme_iack_n        : std_logic;
   SIGNAL vme_irq_i_n       : std_logic_vector(7 DOWNTO 1);
   SIGNAL vme_irq_o_n       : std_logic_vector(7 DOWNTO 1);
   SIGNAL vme_as_i_n        : std_logic;
   SIGNAL vme_as_o_n        : std_logic;
   SIGNAL vme_as_oe         : std_logic;
   SIGNAL vme_as_oe_n       : std_logic;
   SIGNAL vme_retry_o_n     : std_logic;
   SIGNAL vme_retry_oe_n    : std_logic;
   SIGNAL vme_retry_i_n     : std_logic;
   SIGNAL vme_sysres_i_n    : std_logic;
   SIGNAL vme_sysres_o_n    : std_logic;
   SIGNAL vme_ds_i_n        : std_logic_vector(1 DOWNTO 0);
   SIGNAL vme_ds_o_n        : std_logic_vector(1 DOWNTO 0);
   SIGNAL vme_ds_oe_n       : std_logic;
   SIGNAL vme_berr_i_n      : std_logic;
   SIGNAL vme_berr_o_n      : std_logic;
   SIGNAL vme_berr_o      : std_logic;
   SIGNAL vme_dtack_i_n     : std_logic;
   SIGNAL vme_dtack_o_n     : std_logic;
   SIGNAL vme_dtack_o     : std_logic;
   SIGNAL vme_scon_n        : std_logic;
   SIGNAL vme_sysfail_i_n   : std_logic;
   SIGNAL vme_sysfail_o_n   : std_logic;
   SIGNAL vme_bbsy_i_n      : std_logic;
   SIGNAL vme_bbsy_o_n      : std_logic;
   SIGNAL vme_bclr_i_n      : std_logic;                           -- bus clear input
   SIGNAL vme_bclr_o_n      : std_logic;                          -- bus clear output
   SIGNAL vme_br_i_n        : std_logic_vector(3 DOWNTO 0);
   SIGNAL vme_br_o_n        : std_logic_vector(3 DOWNTO 0);
   SIGNAL vme_iack_i_n      : std_logic;
   SIGNAL vme_iack_o_n      : std_logic;
   SIGNAL vme_acfail_i_n    : std_logic;
   SIGNAL vme_sysclk        : std_logic;
   SIGNAL vme_bg_i_n        : std_logic_vector(3 DOWNTO 0);
   SIGNAL vme_bg_o_n        : std_logic_vector(3 DOWNTO 0);

   -- high active signals on A25
   SIGNAL vme_irq_o       : std_logic_vector(7 DOWNTO 1);
   SIGNAL vme_retry_oe    : std_logic;
   SIGNAL vme_sysres_o    : std_logic;
   SIGNAL vme_ds_oe       : std_logic;
   SIGNAL vme_scon        : std_logic;
   SIGNAL vme_sysfail_o   : std_logic;
   SIGNAL vme_bbsy_o      : std_logic;
   SIGNAL vme_br_o        : std_logic_vector(3 DOWNTO 0);

   SIGNAL terminal_in_0    : terminal_in_type;
   SIGNAL terminal_out_0   : terminal_out_type;
   SIGNAL terminal_in_1    : terminal_in_type;
   SIGNAL terminal_out_1   : terminal_out_type;
   SIGNAL vme_slv_in       : vme_slv_in_type;
   SIGNAL vme_slv_out      : vme_slv_out_type;
   SIGNAL vme_mon_out      : vme_mon_out_type;
   

   SIGNAL Addr           : std_logic_vector(18 DOWNTO 0);
   SIGNAL Adsc_n         : std_logic;
   SIGNAL Bwa_n          : std_logic;
   SIGNAL Bwb_n          : std_logic;
   SIGNAL Bwe_n          : std_logic;
   SIGNAL Oe_n           : std_logic;
   SIGNAL ce_n           : std_logic;

   SIGNAL vb_am          : std_logic_vector(5 DOWNTO 0);   
   SIGNAL vb_data        : std_logic_vector(31 DOWNTO 0);   
   SIGNAL vb_adr         : std_logic_vector(31 DOWNTO 0);   
   SIGNAL vb_writen      : std_logic;            
   SIGNAL vb_iackn       : std_logic;            
   SIGNAL vb_asn         : std_logic;            
   SIGNAL vb_dsan        : std_logic;            
   SIGNAL vb_dsbn        : std_logic;            
   SIGNAL vb_bbsyn       : std_logic;            
   SIGNAL vb_berrn       : std_logic;            
   SIGNAL vb_brn         : std_logic_vector(3 DOWNTO 0);            
   SIGNAL vb_dtackn      : std_logic;            
   SIGNAL vb_sysresn     : std_logic;            
   SIGNAL vb_irq1n       : std_logic;         
   SIGNAL vb_irq2n       : std_logic;         
   SIGNAL vb_irq3n       : std_logic;         
   SIGNAL vb_irq4n       : std_logic;         
   SIGNAL vb_irq5n       : std_logic;         
   SIGNAL vb_irq6n       : std_logic;         
   SIGNAL vb_irq7n       : std_logic;         
   SIGNAL vb_bgin        : std_logic_vector(3 DOWNTO 0);            
   SIGNAL vb_bgout       : std_logic_vector(3 DOWNTO 0);            
   SIGNAL vb_iackin      : std_logic;            
   SIGNAL vb_iackout     : std_logic;            
   SIGNAL vb_acfailn     : std_logic;                
   SIGNAL vb_sysclk      : std_logic;
   SIGNAL vb_sysfailn    : std_logic;
   SIGNAL dummy          : std_logic:='1';
   SIGNAL slot1          : boolean;

   -- Hard IP BFM connections
   signal ep_rxvalid_int    : std_logic_vector(BFM_LANE_WIDTH -1 downto 0);
   signal ep_rxstatus_int   : std_logic_vector(3*BFM_LANE_WIDTH -1 downto 0);
   signal ep_rxdatak_int    : std_logic_vector(BFM_LANE_WIDTH -1 downto 0);
   signal ep_rxdata_int     : std_logic_vector(8*BFM_LANE_WIDTH -1 downto 0);
   signal ep_rxelecidle_int : std_logic_vector(BFM_LANE_WIDTH -1 downto 0);
   signal ep_phystatus_int  : std_logic_vector(BFM_LANE_WIDTH -1 downto 0);

   signal ep_clk250_int        : std_logic;
   signal ep_clk500_int        : std_logic;
   signal ep_rate_ext_int      : std_logic;
   signal ep_powerdown_ext_int : std_logic_vector(2*BFM_LANE_WIDTH -1 downto 0);
   signal ep_txdatak_int       : std_logic_vector(BFM_LANE_WIDTH -1 downto 0);
   signal ep_txdata_int        : std_logic_vector(8*BFM_LANE_WIDTH -1 downto 0);
   signal ep_txcompl_int       : std_logic_vector(BFM_LANE_WIDTH -1 downto 0);
   signal ep_txelecidle_int    : std_logic_vector(BFM_LANE_WIDTH -1 downto 0);
   signal ep_txdetectrx_int    : std_logic_vector(BFM_LANE_WIDTH -1 downto 0);
   signal ep_rxpolarity_int    : std_logic_vector(BFM_LANE_WIDTH -1 downto 0);

BEGIN
   -- high active signals on A25
   vme_irq_o_n     <= NOT vme_irq_o     ;
   vme_retry_oe_n  <= NOT vme_retry_oe  ;
   vme_sysres_o_n  <= NOT vme_sysres_o  ;
   vme_ds_oe_n     <= NOT vme_ds_oe     ;
   vme_scon_n      <= NOT vme_scon      ;
   vme_sysfail_o_n <= NOT vme_sysfail_o ;
   vme_bbsy_o_n    <= NOT vme_bbsy_o    ;
   vme_br_o_n      <= NOT vme_br_o      ;
   vme_as_oe_n     <= NOT vme_as_oe;
   vme_dtack_o_n   <= NOT vme_dtack_o;
   vme_berr_o_n    <= NOT vme_berr_o;

   
   
a25: A25_top 
GENERIC MAP (
   SIMULATION        => TRUE,
   FPGA_FAMILY       =>  CYCLONE4,
   BFM_LANE_WIDTH    => BFM_LANE_WIDTH,
   sets              => "1110",
   timeout           => 5000 
   )
PORT MAP (
   clk_16mhz         => clk_16mhz        ,
   led_green_n       => led_green_n      ,
   led_red_n         => led_red_n        ,
   hreset_n          => hreset_n         ,
   v2p_rstn          => v2p_rstn         ,
   fpga_test         => open,
                                         
   refclk            => refclk         ,
   pcie_rx           => pcie_rx          ,
   pcie_tx           => pcie_tx          ,
                                         
   sr_clk            => sr_clk           ,
   sr_a              => sr_a             ,
   sr_d              => sr_d             ,
   sr_bwa_n          => sr_bwa_n         ,
   sr_bwb_n          => sr_bwb_n         ,
   sr_bw_n           => sr_bw_n          ,
   sr_cs1_n          => sr_cs1_n         ,
   sr_adsc_n         => sr_adsc_n        ,
   sr_oe_n           => sr_oe_n          ,
                                         
   vme_ga            => vme_ga,
   vme_gap            => vme_gap,
   vme_a             => vme_a            ,
   vme_a_dir         => vme_a_dir        ,
   vme_a_oe_n        => vme_a_oe_n       ,
   vme_d             => vme_d            ,
   vme_d_dir         => vme_d_dir        ,
   vme_d_oe_n        => vme_d_oe_n       ,
   vme_am_dir        => vme_am_dir       ,
   vme_am            => vme_am           ,
   vme_am_oe_n       => vme_am_oe_n      ,
   vme_write_n       => vme_write_n      ,
   vme_iack_n        => vme_iack_n       ,
   vme_irq_i_n       => vme_irq_i_n      ,
   vme_irq_o       => vme_irq_o      ,
   vme_as_i_n        => vme_as_i_n       ,
   vme_as_o_n        => vme_as_o_n       ,
   vme_as_oe       => vme_as_oe      ,
   vme_retry_o_n     => vme_retry_o_n    ,
   vme_retry_oe    => vme_retry_oe   ,
   vme_retry_i_n     => vme_retry_i_n    ,
   vme_sysres_i_n    => vme_sysres_i_n   ,
   vme_sysres_o    => vme_sysres_o   ,
   vme_ds_i_n        => vme_ds_i_n       ,
   vme_ds_o_n        => vme_ds_o_n       ,
   vme_ds_oe       => vme_ds_oe      ,
   vme_berr_i_n      => vme_berr_i_n     ,
   vme_berr_o      => vme_berr_o     ,
   vme_dtack_i_n     => vme_dtack_i_n    ,
   vme_dtack_o     => vme_dtack_o    ,
   vme_scon        => vme_scon       ,
   vme_sysfail_i_n   => vme_sysfail_i_n  ,
   vme_sysfail_o   => vme_sysfail_o  ,
   vme_bbsy_i_n      => vme_bbsy_i_n     ,
   vme_bbsy_o      => vme_bbsy_o     ,
   vme_bclr_i_n      => vme_bclr_i_n     ,
   vme_bclr_o_n      => vme_bclr_o_n     ,
   vme_br_i_n        => vme_br_i_n       ,
   vme_br_o        => vme_br_o       ,
   vme_iack_i_n      => vme_iack_i_n     ,
   vme_iack_o_n      => vme_iack_o_n     ,
   vme_acfail_i_n    => vme_acfail_i_n   ,
   vme_sysclk        => vme_sysclk       ,
   vme_bg_i_n        => vme_bg_i_n       ,
   vme_bg_o_n        => vme_bg_o_n,

   -- Hard IP BFM connections
   ep_rxvalid_i    => ep_rxvalid_int,
   ep_rxstatus_i   => ep_rxstatus_int,
   ep_rxdatak_i    => ep_rxdatak_int,
   ep_rxdata_i     => ep_rxdata_int,
   ep_rxelecidle_i => ep_rxelecidle_int,
   ep_phystatus_i  => ep_phystatus_int,
   
   ep_clk250_o        => ep_clk250_int,
   ep_clk500_o        => ep_clk500_int,
   ep_rate_ext_o      => ep_rate_ext_int,
   ep_powerdown_ext_o => ep_powerdown_ext_int,
   ep_txdatak_o       => ep_txdatak_int,
   ep_txdata_o        => ep_txdata_int,
   ep_txcompl_o       => ep_txcompl_int,
   ep_txelecidle_o    => ep_txelecidle_int,
   ep_txdetectrx_o    => ep_txdetectrx_int,
   ep_rxpolarity_o    => ep_rxpolarity_int
   );

   clk_16mhz_int <= NOT clk_16mhz_int AFTER 31.25 ns;
   clk_16mhz <= clk_16mhz_int WHEN en_clk ELSE '0';
   refclk <= NOT refclk AFTER 5 ns;
   clk_125 <= NOT clk_125 AFTER 4 ns;    -- 125 MHz
   clk_250 <= NOT clk_250 AFTER 2 ns;    -- 250 MHz
   hreset <= NOT hreset_n;
   
pcie_sim_inst: pcie_sim
   generic map(
      BFM_LANE_WIDTH => BFM_LANE_WIDTH
   )
   port map(
      rst_i       => hreset,
      pcie_rstn_i => hreset_n,
      clk_i       => refclk,
      ep_clk250_i => ep_clk250_int,
      ep_clk500_i => ep_clk500_int,

      -- PCIe lanes
      bfm_tx_i => pcie_tx(BFM_LANE_WIDTH -1 downto 0),
      bfm_rx_o => pcie_rx(BFM_LANE_WIDTH -1 downto 0),

      -- PCIe SERDES connection,  in/out references are BFM view
      ep_rate_ext_i      => ep_rate_ext_int,
      ep_powerdown_ext_i => ep_powerdown_ext_int,
      ep_txdatak_i       => ep_txdatak_int,
      ep_txdata_i        => ep_txdata_int,
      ep_txcompl_i       => ep_txcompl_int,
      ep_txelecidle_i    => ep_txelecidle_int,
      ep_txdetectrx_i    => ep_txdetectrx_int,
      ep_rxpolarity_i    => ep_rxpolarity_int,

      ep_rxvalid_o    => ep_rxvalid_int,
      ep_rxstatus_o   => ep_rxstatus_int,
      ep_rxdatak_o    => ep_rxdatak_int,
      ep_rxdata_o     => ep_rxdata_int,
      ep_rxelecidle_o => ep_rxelecidle_int,
      ep_phystatus_o  => ep_phystatus_int,

      -- MEN terminal connection, in/out references are terminal view
      term_out => terminal_out_0,
      term_in  => terminal_in_0
   );


   trans_sr_clk <= transport sr_clk AFTER 12 ns;
   Addr     <= transport sr_a AFTER (T_FPGA_TO_SRAM);
   Adsc_n   <= transport sr_adsc_n AFTER (T_FPGA_TO_SRAM);
   Bwa_n    <= transport sr_bwa_n AFTER (T_FPGA_TO_SRAM);
   Bwb_n    <= transport sr_bwb_n AFTER (T_FPGA_TO_SRAM);
   Bwe_n    <= transport sr_bw_n AFTER (T_FPGA_TO_SRAM);
   Oe_n     <= transport sr_oe_n AFTER (T_FPGA_TO_SRAM);
   ce_n     <= '1', '0' AFTER 28 ns;  

sram : MT58L512L18F
   GENERIC MAP (
     addr_bits => 19,
     data_bits => 16
   )
   PORT MAP(
      Clk     => trans_sr_clk,
      Dq      => sr_d    ,
      Addr    => Addr  ,
      Adsc_n  => adsc_n,
      Bwa_n   => Bwa_n ,
      Bwb_n   => Bwb_n ,
      Bwe_n   => Bwe_n ,
      Oe_n    => Oe_n  ,
      
      Adsp_n  => '1',
      Mode    => '0',
      Adv_n   => '1',
      Gw_n    => '1',
      Ce_n    => ce_n,
      Ce2     => '1',
      Ce2_n   => '0',
      Zz      => '0'
   );               

vme_bus : vmebus 
PORT MAP (
   slot1          => slot1,            -- if true dut is in slot1
   vme_slv_in     => vme_slv_in ,
   vme_slv_out    => vme_slv_out,
   vme_mon_out    => vme_mon_out,
   terminal_in_x  => terminal_in_1  ,
   terminal_out_x => terminal_out_1 ,

   vb_am          => vb_am        ,
   vb_data        => vb_data      ,
   vb_adr         => vb_adr      ,
   vb_writen      => vb_writen   ,
   vb_iackn       => vb_iackn    ,
   vb_asn         => vb_asn      ,
   vb_dsan        => vb_dsan     ,
   vb_dsbn        => vb_dsbn     ,
   vb_bbsyn       => vb_bbsyn    ,
   vb_berrn       => vb_berrn    ,
   vb_brn         => vb_brn     ,
   vb_dtackn      => vb_dtackn   ,
   vb_sysresn     => vb_sysresn  ,
   vb_irq1n       => vb_irq1n    ,
   vb_irq2n       => vb_irq2n    ,
   vb_irq3n       => vb_irq3n    ,
   vb_irq4n       => vb_irq4n    ,
   vb_irq5n       => vb_irq5n    ,
   vb_irq6n       => vb_irq6n    ,
   vb_irq7n       => vb_irq7n    ,
   vb_bgin        => vb_bgin    ,
   vb_bgout       => vb_bgout   ,
   vb_iackin      => vb_iackin   ,
   vb_iackout     => vb_iackout  ,
   vb_acfailn     => vb_acfailn  
     );

bus_drv_ctrl_out: SN74ABT125
GENERIC MAP (
   OP_COND  => 2,
   WIDTH    => 21
   )
PORT MAP (
   oe_n(0)     => vme_irq_o_n(1),
   oe_n(1)     => vme_irq_o_n(2),
   oe_n(2)     => vme_irq_o_n(3),
   oe_n(3)     => vme_irq_o_n(4),
   oe_n(4)     => vme_irq_o_n(5),
   oe_n(5)     => vme_irq_o_n(6),
   oe_n(6)     => vme_irq_o_n(7),
   oe_n(7)     => vme_as_oe_n,
   oe_n(8)     => vme_dtack_o_n,
   oe_n(9)     => vme_ds_o_n(0),
   oe_n(10)    => vme_ds_o_n(1),
   oe_n(11)    => vme_sysclk,
   oe_n(12)    => vme_berr_o_n,
   oe_n(13)    => vme_sysres_o_n,
   oe_n(14)    => vme_sysfail_o_n,
   oe_n(15)    => vme_br_o_n(0),
   oe_n(16)    => vme_br_o_n(1),
   oe_n(17)    => vme_br_o_n(2),
   oe_n(18)    => vme_br_o_n(3),
   oe_n(19)    => '1',
   oe_n(20)    => vme_bbsy_o_n,

   a(0)        => vme_irq_o_n(1),
   a(1)        => vme_irq_o_n(2),
   a(2)        => vme_irq_o_n(3),
   a(3)        => vme_irq_o_n(4),
   a(4)        => vme_irq_o_n(5),
   a(5)        => vme_irq_o_n(6),
   a(6)        => vme_irq_o_n(7),
   a(7)        => vme_as_o_n,
   a(8)        => vme_dtack_o_n,
   a(9)        => vme_ds_o_n(0),
   a(10)       => vme_ds_o_n(1),
   a(11)       => vme_sysclk,
   a(12)       => vme_berr_o_n,
   a(13)       => vme_sysres_o_n,
   a(14)       => vme_sysfail_o_n,
   a(15)       => vme_br_o_n(0),
   a(16)       => vme_br_o_n(1),
   a(17)       => vme_br_o_n(2),
   a(18)       => vme_br_o_n(3),
   a(19)       => '1',
   a(20)       => vme_bbsy_o_n,

   b(0)        => vb_irq1n,
   b(1)        => vb_irq2n,
   b(2)        => vb_irq3n,
   b(3)        => vb_irq4n,
   b(4)        => vb_irq5n,
   b(5)        => vb_irq6n,
   b(6)        => vb_irq7n,
   b(7)        => vb_asn,
   b(8)        => vb_dtackn,
   b(9)        => vb_dsan,
   b(10)       => vb_dsbn,      
   b(11)       => vb_sysclk,
   b(12)       => vb_berrn,
   b(13)       => vb_sysresn,
   b(14)       => vb_sysfailn,
   b(15)       => vb_brn(0),
   b(16)       => vb_brn(1),
   b(17)       => vb_brn(2),
   b(18)       => vb_brn(3),
   b(19)       => vb_acfailn,
   b(20)       => vb_bbsyn
   );
   
   vb_irq1n <= 'H';

bus_drv_ctrl_in: SN74LVTH245
GENERIC MAP (
   OP_COND  => 2,
   WIDTH    => 29
   )
PORT MAP(
   dir      => '1',  -- a->b
   oe_n     => '0',
   a(0)     => vb_irq1n,
   a(1)     => vb_irq2n,
   a(2)     => vb_irq3n,
   a(3)     => vb_irq4n,
   a(4)     => vb_irq5n,
   a(5)     => vb_irq6n,
   a(6)     => vb_irq7n,
   a(7)     => vb_iackin,
   a(8)     => vme_iack_o_n,
   a(9)     => vb_asn,
   a(10)    => vb_dtackn,
   a(11)    => vb_dsan,
   a(12)    => vb_dsbn,
   a(13)    => vb_berrn,
   a(14)    => vb_sysresn,
   a(15)    => dummy,
   a(16)    => vme_bg_o_n(0),
   a(17)    => vme_bg_o_n(1),
   a(18)    => vme_bg_o_n(2),
   a(19)    => vme_bg_o_n(3),
   a(20)    => vb_bgin(0),
   a(21)    => vb_bgin(1),
   a(22)    => vb_bgin(2),
   a(23)    => vb_bgin(3),
   a(24)    => vb_bbsyn,
   a(25)    => vb_brn(0),
   a(26)    => vb_brn(1),
   a(27)    => vb_brn(2),
   a(28)    => vb_brn(3),

   b(0)     => vme_irq_i_n(1),
   b(1)     => vme_irq_i_n(2),
   b(2)     => vme_irq_i_n(3),
   b(3)     => vme_irq_i_n(4),
   b(4)     => vme_irq_i_n(5),
   b(5)     => vme_irq_i_n(6),
   b(6)     => vme_irq_i_n(7),
   b(7)     => vme_iack_i_n,
   b(8)     => vb_iackout,
   b(9)     => vme_as_i_n,
   b(10)    => vme_dtack_i_n,
   b(11)    => vme_ds_i_n(0),
   b(12)    => vme_ds_i_n(1),
   b(13)    => vme_berr_i_n,
   b(14)    => vme_sysres_i_n,
   b(15)    => vme_sysfail_i_n,
   b(16)    => vb_bgout(0),
   b(17)    => vb_bgout(1),
   b(18)    => vb_bgout(2),
   b(19)    => vb_bgout(3),
   b(20)    => vme_bg_i_n(0),
   b(21)    => vme_bg_i_n(1),
   b(22)    => vme_bg_i_n(2),
   b(23)    => vme_bg_i_n(3),
   b(24)    => vme_bbsy_i_n,
   b(25)   => vme_br_i_n(0),
   b(26)   => vme_br_i_n(1),
   b(27)   => vme_br_i_n(2),
   b(28)   => vme_br_i_n(3)
   );

bus_drv_am: SN74LVTH245
GENERIC MAP (
   OP_COND  => 2,
   WIDTH    => 8
   )
PORT MAP(
   dir      => vme_am_dir,
   oe_n     => vme_am_oe_n,
   a(0)     => vme_am(0),
   a(1)     => vme_am(1),
   a(2)     => vme_am(2),
   a(3)     => vme_am(3),
   a(4)     => vme_am(4),
   a(5)     => vme_am(5),
   a(6)     => vme_iack_n,
   a(7)     => vme_write_n,
   b(0)     => vb_am(0),
   b(1)     => vb_am(1),
   b(2)     => vb_am(2),
   b(3)     => vb_am(3),
   b(4)     => vb_am(4),
   b(5)     => vb_am(5),
   b(6)     => vb_iackn,
   b(7)     => vb_writen
   );

bus_drv_adr: SN74LVTH245
GENERIC MAP (
   OP_COND  => 2,
   WIDTH    => 32
   )
PORT MAP(
   dir      => vme_a_dir,
   oe_n     => vme_a_oe_n,
   a        => vme_a,
   b        => vb_adr
   );

bus_drv_dat: SN74LVTH245
GENERIC MAP (
   OP_COND  => 2,
   WIDTH    => 32
   )
PORT MAP(
   dir      => vme_d_dir,
   oe_n     => vme_d_oe_n,
   a        => vme_d,
   b        => vb_data
   );


term: terminal 
PORT MAP (
   hreset_n       => hreset_n    ,
   slot1          => slot1,
   en_clk         => en_clk,
   terminal_in_0  => terminal_in_0 , 
   terminal_out_0 => terminal_out_0, 
   terminal_in_1  => terminal_in_1 , 
   terminal_out_1 => terminal_out_1, 
   vme_slv_in     => vme_slv_in ,
   vme_slv_out    => vme_slv_out,
   vme_mon_out    => vme_mon_out,
   v2p_rstn       => v2p_rstn    ,
   vme_ga         => vme_ga,
   vme_gap         => vme_gap
   );
   
END a25_tb_arch;

   CONFIGURATION a25_tb_conf of a25_tb IS
      FOR a25_tb_arch
         FOR a25 : A25_top
            USE CONFIGURATION work.top_cfg;          
         END FOR;                                              
      END FOR;
   END CONFIGURATION a25_tb_conf;
