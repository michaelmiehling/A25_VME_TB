--------------------------------------------------------------------------------
-- Title       : PCIe simulation model
-- Project     : -
--------------------------------------------------------------------------------
-- File        : pcie_sim.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 2017-05-26
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6
-- Synthesis   : -
--------------------------------------------------------------------------------
-- Description : 
-- PCIe simulation model for x1, x2, x4 and x8 configurations.
-- The BFM shared memory is configured to be 2 MBytes. It is mapped into
-- the first 2 MBytes of I/O space and also the first 2 MBytes of memory
-- space. The BFM is assigned to device number 0 on internal bus number 0.
--------------------------------------------------------------------------------
-- Hierarchy   : 
--------------------------------------------------------------------------------
-- Copyright (C) 2017, MEN Mikro Elektronik Nuremberg GmbH
--
-- All rights reserved. Reproduction in whole or part is
-- prohibited without the written permission of the
-- copyright owner.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.altpcietb_bfm_constants.all;
use work.altpcietb_bfm_log.all;
use work.altpcietb_bfm_shmem.all;
use work.altpcietb_bfm_rdwr.all;
use work.altpcietb_bfm_configure.all;

use work.utils_pkg.all;
use work.pcie_sim_pkg.all;
use work.print_pkg.all;
use work.terminal_pkg.all;

entity pcie_sim is
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
      ep_ltssm_i         : in  std_logic_vector(4 downto 0);

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
end entity pcie_sim;

architecture pcie_sim_arch of pcie_sim is
   type bar_addr_array is array (5 downto 0) of std_logic_vector(31 downto 0);
   type bar_limit_array is array (5 downto 0) of natural;

-- +----------------------------------------------------------------------------
-- | components
-- +----------------------------------------------------------------------------
   component altpcietb_bfm_rp_top_x8_pipen1b is
      port(
         signal rxdata4_ext      : in std_logic_vector(7 downto 0);
         signal rx_in7           : in std_logic;
         signal phystatus5_ext   : in std_logic;
         signal rxdata5_ext      : in std_logic_vector(7 downto 0);
         signal phystatus1_ext   : in std_logic;
         signal pipe_mode        : in std_logic;
         signal rxstatus3_ext    : in std_logic_vector(2 downto 0);
         signal pcie_rstn        : in std_logic;
         signal rxelecidle7_ext  : in std_logic;
         signal rxelecidle0_ext  : in std_logic;
         signal clk500_in        : in std_logic;
         signal rxelecidle3_ext  : in std_logic;
         signal rxdatak1_ext     : in std_logic;
         signal phystatus0_ext   : in std_logic;
         signal rx_in0           : in std_logic;
         signal rx_in5           : in std_logic;
         signal rxelecidle5_ext  : in std_logic;
         signal rxvalid1_ext     : in std_logic;
         signal rx_in2           : in std_logic;
         signal rx_in3           : in std_logic;
         signal rxdatak3_ext     : in std_logic;
         signal clk250_in        : in std_logic;
         signal phystatus6_ext   : in std_logic;
         signal rxdata6_ext      : in std_logic_vector(7 downto 0);
         signal rxdata3_ext      : in std_logic_vector(7 downto 0);
         signal rxstatus5_ext    : in std_logic_vector(2 downto 0);
         signal rxstatus1_ext    : in std_logic_vector(2 downto 0);
         signal rxdata0_ext      : in std_logic_vector(7 downto 0);
         signal rxvalid7_ext     : in std_logic;
         signal phystatus7_ext   : in std_logic;
         signal rxdata2_ext      : in std_logic_vector(7 downto 0);
         signal rxvalid5_ext     : in std_logic;
         signal rxvalid0_ext     : in std_logic;
         signal rxdatak2_ext     : in std_logic;
         signal rxstatus4_ext    : in std_logic_vector(2 downto 0);
         signal rxdatak7_ext     : in std_logic;
         signal rxstatus0_ext    : in std_logic_vector(2 downto 0);
         signal phystatus3_ext   : in std_logic;
         signal rxelecidle4_ext  : in std_logic;
         signal phystatus2_ext   : in std_logic;
         signal rxvalid4_ext     : in std_logic;
         signal rx_in6           : in std_logic;
         signal rx_in1           : in std_logic;
         signal rxstatus2_ext    : in std_logic_vector(2 downto 0);
         signal rxdata7_ext      : in std_logic_vector(7 downto 0);
         signal rxdatak0_ext     : in std_logic;
         signal rxelecidle1_ext  : in std_logic;
         signal rxdata1_ext      : in std_logic_vector(7 downto 0);
         signal rxstatus6_ext    : in std_logic_vector(2 downto 0);
         signal test_in          : in std_logic_vector(31 downto 0);
         signal rx_in4           : in std_logic;
         signal rxdatak4_ext     : in std_logic;
         signal rxelecidle2_ext  : in std_logic;
         signal rxdatak5_ext     : in std_logic;
         signal rxstatus7_ext    : in std_logic_vector(2 downto 0);
         signal rxelecidle6_ext  : in std_logic;
         signal rxvalid3_ext     : in std_logic;
         signal rxvalid2_ext     : in std_logic;
         signal phystatus4_ext   : in std_logic;
         signal rxvalid6_ext     : in std_logic;
         signal local_rstn       : in std_logic;
         signal rxdatak6_ext     : in std_logic;

         signal tx_out6          : out std_logic;
         signal tx_out4          : out std_logic;
         signal txdatak4_ext     : out std_logic;
         signal txelecidle0_ext  : out std_logic;
         signal txdatak1_ext     : out std_logic;
         signal test_out         : out std_logic_vector(511 downto 0);
         signal txelecidle2_ext  : out std_logic;
         signal txdatak7_ext     : out std_logic;
         signal txdatak2_ext     : out std_logic;
         signal txcompl4_ext     : out std_logic;
         signal rxpolarity5_ext  : out std_logic;
         signal rxpolarity4_ext  : out std_logic;
         signal powerdown7_ext   : out std_logic_vector(1 downto 0);
         signal txdetectrx7_ext  : out std_logic;
         signal txelecidle1_ext  : out std_logic;
         signal tx_out3          : out std_logic;
         signal rxpolarity3_ext  : out std_logic;
         signal txdata0_ext      : out std_logic_vector(7 downto 0);
         signal txdetectrx1_ext  : out std_logic;
         signal powerdown0_ext   : out std_logic_vector(1 downto 0);
         signal txdata1_ext      : out std_logic_vector(7 downto 0);
         signal txdatak6_ext     : out std_logic;
         signal txdata3_ext      : out std_logic_vector(7 downto 0);
         signal txcompl7_ext     : out std_logic;
         signal txdata4_ext      : out std_logic_vector(7 downto 0);
         signal powerdown3_ext   : out std_logic_vector(1 downto 0);
         signal txcompl5_ext     : out std_logic;
         signal txcompl0_ext     : out std_logic;
         signal txdetectrx5_ext  : out std_logic;
         signal txcompl1_ext     : out std_logic;
         signal powerdown1_ext   : out std_logic_vector(1 downto 0);
         signal txelecidle7_ext  : out std_logic;
         signal swdn_out         : out std_logic_vector(5 downto 0);
         signal txelecidle6_ext  : out std_logic;
         signal tx_out0          : out std_logic;
         signal powerdown6_ext   : out std_logic_vector(1 downto 0);
         signal rxpolarity0_ext  : out std_logic;
         signal tx_out2          : out std_logic;
         signal txdetectrx2_ext  : out std_logic;
         signal txdata5_ext      : out std_logic_vector(7 downto 0);
         signal txelecidle3_ext  : out std_logic;
         signal txdatak3_ext     : out std_logic;
         signal txdetectrx0_ext  : out std_logic;
         signal rxpolarity6_ext  : out std_logic;
         signal powerdown2_ext   : out std_logic_vector(1 downto 0);
         signal rate_ext         : out std_logic;
         signal txcompl3_ext     : out std_logic;
         signal txdetectrx6_ext  : out std_logic;
         signal tx_out5          : out std_logic;
         signal rxpolarity2_ext  : out std_logic;
         signal tx_out7          : out std_logic;
         signal tx_out1          : out std_logic;
         signal txdetectrx3_ext  : out std_logic;
         signal txdata6_ext      : out std_logic_vector(7 downto 0);
         signal txcompl2_ext     : out std_logic;
         signal rxpolarity1_ext  : out std_logic;
         signal txelecidle4_ext  : out std_logic;
         signal txdata2_ext      : out std_logic_vector(7 downto 0);
         signal powerdown4_ext   : out std_logic_vector(1 downto 0);
         signal txcompl6_ext     : out std_logic;
         signal txdatak5_ext     : out std_logic;
         signal txdata7_ext      : out std_logic_vector(7 downto 0);
         signal txdatak0_ext     : out std_logic;
         signal rxpolarity7_ext  : out std_logic;
         signal powerdown5_ext   : out std_logic_vector(1 downto 0);
         signal txdetectrx4_ext  : out std_logic;
         signal txelecidle5_ext  : out std_logic

      );
   end component altpcietb_bfm_rp_top_x8_pipen1b;

   component altpcietb_pipe_phy is
      generic(
         APIPE_WIDTH : natural;
         BPIPE_WIDTH : natural;
         LANE_NUM    : natural
      );
      port(
         signal b_powerdown  : in std_logic_vector(1 downto 0);
         signal a_txdatak    : in std_logic_vector(0 downto 0);
         signal pipe_mode    : in std_logic;
         signal a_powerdown  : in std_logic_vector(1 downto 0);
         signal b_txcompl    : in std_logic;
         signal b_lane_conn  : in std_logic;
         signal b_txdetectrx : in std_logic;
         signal pclk_a       : in std_logic;
         signal b_txelecidle : in std_logic;
         signal a_lane_conn  : in std_logic;
         signal resetn       : in std_logic;
         signal a_txdata     : in std_logic_vector(7 downto 0);
         signal b_rate       : in std_logic;
         signal a_txcompl    : in std_logic;
         signal pclk_b       : in std_logic;
         signal a_txelecidle : in std_logic;
         signal a_txdetectrx : in std_logic;
         signal a_rxpolarity : in std_logic;
         signal b_txdata     : in std_logic_vector(7 downto 0);
         signal b_rxpolarity : in std_logic;
         signal b_txdatak    : in std_logic_vector(0 downto 0);
         signal a_rate       : in std_logic;

         signal a_rxvalid    : out std_logic;
         signal a_rxstatus   : out std_logic_vector(2 downto 0);
         signal b_phystatus  : out std_logic;
         signal b_rxvalid    : out std_logic;
         signal a_rxdatak    : out std_logic_vector(0 downto 0);
         signal b_rxelecidle : out std_logic;
         signal b_rxdatak    : out std_logic_vector(0 downto 0);
         signal a_rxdata     : out std_logic_vector(7 downto 0);
         signal b_rxdata     : out std_logic_vector(7 downto 0);
         signal a_rxelecidle : out std_logic;
         signal a_phystatus  : out std_logic;
         signal b_rxstatus   : out std_logic_vector(2 downto 0)
      );
   end component altpcietb_pipe_phy;

   component altpcietb_ltssm_mon is
      port(
         signal rp_clk    : in std_logic;
         signal ep_ltssm  : in std_logic_vector (4 downto 0);
         signal rstn      : in std_logic;
         signal rp_ltssm  : in std_logic_vector (4 downto 0);

         signal dummy_out : out std_logic
      );
   end component altpcietb_ltssm_mon;

-- +----------------------------------------------------------------------------
-- | functions
-- +----------------------------------------------------------------------------
   function get_bar_limit(bar_addr : std_logic_vector(31 downto 0); bar_num : natural)
      return natural is
         variable var_log2_size : natural;
         variable var_is_mem    : std_logic;
         variable var_is_pref   : std_logic;
         variable var_is_64b    : std_logic;
   begin
      ebfm_cfg_decode_bar(
         bar_table => BAR_TABLE_POINTER,
         bar_num   => bar_num,
         log2_size => var_log2_size,
         is_mem    => var_is_mem,
         is_pref   => var_is_pref,
         is_64b    => var_is_64b
      );

      return var_log2_size;

   end function get_bar_limit;

-- +----------------------------------------------------------------------------
-- | procedures
-- +----------------------------------------------------------------------------
   procedure get_pcie_addr_and_offset(
      pcie_addr  : in  std_logic_vector(31 downto 0);
      bar_addr   : in  bar_addr_array;
      bar_limit  : in  bar_limit_array;
      bar_num    : out natural;
      bar_offset : out natural
   ) is
      variable var_act_limit  : natural := 0;
      variable var_act_addr   : std_logic_vector(31 downto 0) := (others => '0');
      variable var_act_offset : std_logic_vector(31 downto 0) := (others => '0');
      variable var_bar_num    : natural := 6;
   begin
   -- loop through all BARs and check for matches
   -- address must match from MSB of address to actual limit value
   -- address offset for BAR is from limit downto 0
      loop_1 : for i in 0 to 5 loop
         var_act_limit  := bar_limit(i);
         var_act_offset := ZERO_32BIT(31 downto var_act_limit) & pcie_addr(var_act_limit -1 downto 0);
         var_act_addr   := pcie_addr(31 downto var_act_limit) & ZERO_32BIT(var_act_limit -1 downto 0);

         if bar_addr(i) = var_act_addr then
            var_bar_num := i;
            exit loop_1;
         else
            -- set to invalid value to denote error condition
            var_bar_num := 6;
         end if;
      end loop;

      if var_bar_num = 6 then
         report "ERROR (pcie_sim.vhd->get_pcie_addr_and_offset(): given PCIe address does not match stored BAR addresses" severity error;
      else
         bar_num    := var_bar_num;
         bar_offset := to_integer(unsigned(var_act_offset));
      end if;

   end procedure get_pcie_addr_and_offset;

-- +----------------------------------------------------------------------------
-- | constants
-- +----------------------------------------------------------------------------

-- +----------------------------------------------------------------------------
-- | internal signals
-- +----------------------------------------------------------------------------
   -- BFM connections
   signal bfm_rate_int      : std_logic;
   signal bfm_pipe_mode_int : std_logic;
   signal bfm_pclk_int      : std_logic;
   signal lane_pclk_int     : std_logic;
   signal bfm_rstn_delayed  : std_logic := '0';

   signal bfm_txcompl_0_int : std_logic;
   signal bfm_txcompl_1_int : std_logic;
   signal bfm_txcompl_2_int : std_logic;
   signal bfm_txcompl_3_int : std_logic;
   signal bfm_txcompl_4_int : std_logic;
   signal bfm_txcompl_5_int : std_logic;
   signal bfm_txcompl_6_int : std_logic;
   signal bfm_txcompl_7_int : std_logic;

   signal bfm_txdetectrx_0_int : std_logic;
   signal bfm_txdetectrx_1_int : std_logic;
   signal bfm_txdetectrx_2_int : std_logic;
   signal bfm_txdetectrx_3_int : std_logic;
   signal bfm_txdetectrx_4_int : std_logic;
   signal bfm_txdetectrx_5_int : std_logic;
   signal bfm_txdetectrx_6_int : std_logic;
   signal bfm_txdetectrx_7_int : std_logic;

   signal bfm_txelecidle_0_int : std_logic;
   signal bfm_txelecidle_1_int : std_logic;
   signal bfm_txelecidle_2_int : std_logic;
   signal bfm_txelecidle_3_int : std_logic;
   signal bfm_txelecidle_4_int : std_logic;
   signal bfm_txelecidle_5_int : std_logic;
   signal bfm_txelecidle_6_int : std_logic;
   signal bfm_txelecidle_7_int : std_logic;

   signal bfm_rxpolarity_0_int : std_logic;
   signal bfm_rxpolarity_1_int : std_logic;
   signal bfm_rxpolarity_2_int : std_logic;
   signal bfm_rxpolarity_3_int : std_logic;
   signal bfm_rxpolarity_4_int : std_logic;
   signal bfm_rxpolarity_5_int : std_logic;
   signal bfm_rxpolarity_6_int : std_logic;
   signal bfm_rxpolarity_7_int : std_logic;

   signal bfm_phystatus_0_int : std_logic;
   signal bfm_phystatus_1_int : std_logic;
   signal bfm_phystatus_2_int : std_logic;
   signal bfm_phystatus_3_int : std_logic;
   signal bfm_phystatus_4_int : std_logic;
   signal bfm_phystatus_5_int : std_logic;
   signal bfm_phystatus_6_int : std_logic;
   signal bfm_phystatus_7_int : std_logic;

   signal bfm_rxvalid_0_int : std_logic;
   signal bfm_rxvalid_1_int : std_logic;
   signal bfm_rxvalid_2_int : std_logic;
   signal bfm_rxvalid_3_int : std_logic;
   signal bfm_rxvalid_4_int : std_logic;
   signal bfm_rxvalid_5_int : std_logic;
   signal bfm_rxvalid_6_int : std_logic;
   signal bfm_rxvalid_7_int : std_logic;

   signal bfm_rxelecidle_0_int : std_logic;
   signal bfm_rxelecidle_1_int : std_logic;
   signal bfm_rxelecidle_2_int : std_logic;
   signal bfm_rxelecidle_3_int : std_logic;
   signal bfm_rxelecidle_4_int : std_logic;
   signal bfm_rxelecidle_5_int : std_logic;
   signal bfm_rxelecidle_6_int : std_logic;
   signal bfm_rxelecidle_7_int : std_logic;

   signal bfm_rxdatak_0_int : std_logic;
   signal bfm_rxdatak_1_int : std_logic;
   signal bfm_rxdatak_2_int : std_logic;
   signal bfm_rxdatak_3_int : std_logic;
   signal bfm_rxdatak_4_int : std_logic;
   signal bfm_rxdatak_5_int : std_logic;
   signal bfm_rxdatak_6_int : std_logic;
   signal bfm_rxdatak_7_int : std_logic;

   signal bfm_rx_int      : std_logic_vector(7 downto 0) := (others => '1');
   signal bfm_tx_int      : std_logic_vector(7 downto 0) := (others => 'Z');
   signal bfm_test_in_int : std_logic_vector(31 downto 0);
   signal bfm_irq_int     : std_logic_vector(5 downto 0);
   signal bfm_ltssm_rp    : std_logic_vector(4 downto 0);
   signal test_out_int    : std_logic_vector(511 downto 0);

   signal bfm_txdata_0_int  : std_logic_vector(7 downto 0);
   signal bfm_txdata_1_int  : std_logic_vector(7 downto 0);
   signal bfm_txdata_2_int  : std_logic_vector(7 downto 0);
   signal bfm_txdata_3_int  : std_logic_vector(7 downto 0);
   signal bfm_txdata_4_int  : std_logic_vector(7 downto 0);
   signal bfm_txdata_5_int  : std_logic_vector(7 downto 0);
   signal bfm_txdata_6_int  : std_logic_vector(7 downto 0);
   signal bfm_txdata_7_int  : std_logic_vector(7 downto 0);
   signal bfm_txdatak_0_int : std_logic_vector(0 downto 0);
   signal bfm_txdatak_1_int : std_logic_vector(0 downto 0);
   signal bfm_txdatak_2_int : std_logic_vector(0 downto 0);
   signal bfm_txdatak_3_int : std_logic_vector(0 downto 0);
   signal bfm_txdatak_4_int : std_logic_vector(0 downto 0);
   signal bfm_txdatak_5_int : std_logic_vector(0 downto 0);
   signal bfm_txdatak_6_int : std_logic_vector(0 downto 0);
   signal bfm_txdatak_7_int : std_logic_vector(0 downto 0);

   signal bfm_powerdown_0_int : std_logic_vector(1 downto 0);
   signal bfm_powerdown_1_int : std_logic_vector(1 downto 0);
   signal bfm_powerdown_2_int : std_logic_vector(1 downto 0);
   signal bfm_powerdown_3_int : std_logic_vector(1 downto 0);
   signal bfm_powerdown_4_int : std_logic_vector(1 downto 0);
   signal bfm_powerdown_5_int : std_logic_vector(1 downto 0);
   signal bfm_powerdown_6_int : std_logic_vector(1 downto 0);
   signal bfm_powerdown_7_int : std_logic_vector(1 downto 0);

   signal bfm_rxdata_0_int : std_logic_vector(7 downto 0);
   signal bfm_rxdata_1_int : std_logic_vector(7 downto 0);
   signal bfm_rxdata_2_int : std_logic_vector(7 downto 0);
   signal bfm_rxdata_3_int : std_logic_vector(7 downto 0);
   signal bfm_rxdata_4_int : std_logic_vector(7 downto 0);
   signal bfm_rxdata_5_int : std_logic_vector(7 downto 0);
   signal bfm_rxdata_6_int : std_logic_vector(7 downto 0);
   signal bfm_rxdata_7_int : std_logic_vector(7 downto 0);

   signal bfm_rxstatus_0_int : std_logic_vector(2 downto 0);
   signal bfm_rxstatus_1_int : std_logic_vector(2 downto 0);
   signal bfm_rxstatus_2_int : std_logic_vector(2 downto 0);
   signal bfm_rxstatus_3_int : std_logic_vector(2 downto 0);
   signal bfm_rxstatus_4_int : std_logic_vector(2 downto 0);
   signal bfm_rxstatus_5_int : std_logic_vector(2 downto 0);
   signal bfm_rxstatus_6_int : std_logic_vector(2 downto 0);
   signal bfm_rxstatus_7_int : std_logic_vector(2 downto 0);

   signal bar_addr : bar_addr_array;
   signal bar_limit : bar_limit_array;

begin
-- +----------------------------------------------------------------------------
-- | concurrent section
-- +----------------------------------------------------------------------------
   assert (BFM_LANE_WIDTH = 1 or BFM_LANE_WIDTH = 2 or BFM_LANE_WIDTH = 4 or BFM_LANE_WIDTH = 8)
      report "ERROR (pcie_sim.vhd): invalid value for generic BFM_LANE_WIDTH; use 1, 2, 4, or 8!" severity failure;

   -- clock switch
   bfm_pclk_int  <= ep_clk500_i when bfm_rate_int = '1' else ep_clk250_i;
   lane_pclk_int <= ep_clk500_i when ep_rate_ext_i = '1' else ep_clk250_i;

   -- delay reset for BFM by 100 ns
   bfm_rstn_delayed <= transport pcie_rstn_i after 100 ns;

   bfm_pipe_mode_int            <= '1';
   bfm_test_in_int(31 downto 8) <= (others => '0');
   bfm_test_in_int(7)           <= not bfm_pipe_mode_int;                       -- disable entrance to low power mode
   bfm_test_in_int(6)           <= '0';
   bfm_test_in_int(5)           <= '1';                                         -- disable polling.compliance
   bfm_test_in_int(4)           <= '0';
   bfm_test_in_int(3)           <= not bfm_pipe_mode_int;                       -- forces all lanes to detect the receiver
   bfm_test_in_int(2 downto 1)  <= (others => '0');
   bfm_test_in_int(0)           <= '1';                                         -- speed up simulation by making counters faster than normal

   bfm_ltssm_rp <= test_out_int(324 downto 320);

   bfm_rx_o(BFM_LANE_WIDTH -1 downto 0)   <= bfm_rx_int(BFM_LANE_WIDTH -1 downto 0);
   bfm_tx_int(BFM_LANE_WIDTH -1 downto 0) <= bfm_tx_i(BFM_LANE_WIDTH -1 downto 0);
-- +----------------------------------------------------------------------------
-- | process section
-- +----------------------------------------------------------------------------
   main : process
      variable first_be_en     : std_logic_vector(3 downto 0);
      variable byte_count      : integer;
      variable addr32_int      : std_logic_vector(31 downto 0);
      variable bfm_id          : integer := 0;
      variable success_int     : boolean := false;
      variable return_data32   : std_logic_vector(31 downto 0) := (others => '0');
      variable return_data_vec : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable data_vec        : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable var_bar_num     : natural;
      variable var_bar_offset  : natural;
      variable var_bar0_addr   : std_logic_vector(31 downto 0) := x"ffff_ffff";
      variable var_bar1_addr   : std_logic_vector(31 downto 0) := x"ffff_ffff";
      variable var_bar2_addr   : std_logic_vector(31 downto 0) := x"ffff_ffff";
      variable var_bar3_addr   : std_logic_vector(31 downto 0) := x"ffff_ffff";
      variable var_bar4_addr   : std_logic_vector(31 downto 0) := x"ffff_ffff";
      variable var_bar5_addr   : std_logic_vector(31 downto 0) := x"ffff_ffff";
      variable var_bar0_limit  : natural := 0;
      variable var_bar1_limit  : natural := 0;
      variable var_bar2_limit  : natural := 0;
      variable var_bar3_limit  : natural := 0;
      variable var_bar4_limit  : natural := 0;
      variable var_bar5_limit  : natural := 0;

   begin
      -- reset all
      term_in.busy <= '1';
      term_in.done <= true;

      wait until rst_i = '0';
      wait_clk(clk_i,1);

      if term_out.start /= true then
         wait until term_out.start = true;
      end if;

      loop
         wait on term_out.start;
         term_in.busy <= '1';
         term_in.err  <= 0;
         success_int  := false;

         ---------------------------
         -- check for wrong values
         ---------------------------
         assert term_out.typ <= 2 report "ERROR (pcie_sim): illegal value for signal term_out.typ" severity failure;
         assert term_out.wr  <= 2 report "ERROR (pcie_sim): illegal value for signal term_out.wr" severity failure;

         if term_out.typ = 0 then
            assert term_out.numb = 1 report "ERROR (pcie_sim): illegal combination for signals term_out.typ and term_out.numb => bytewise burst is impossible" severity failure;
         end if;

         if term_out.typ = 1 then
            assert term_out.numb = 1 report "ERROR (pcie_sim): illegal combination for signals term_out.typ and term_out.numb => wordwise burst is impossible" severity failure;
         end if;
         assert term_out.numb <= 1024 report "ERROR (pcie_sim): maximum value for signal term_out.numb is 1024" severity failure;

         ----------------------------
         -- set values for this run
         ----------------------------
         addr32_int := term_out.adr(31 downto 2) & "00";
         bfm_id     := to_integer(unsigned(term_out.tga(3 downto 2)));

         if term_out.typ = 0 then                                               -- byte
            byte_count := 1;
            if term_out.adr(1 downto 0) = "01" then
               first_be_en := "0010";
            elsif term_out.adr(1 downto 0) = "10" then
               first_be_en := "0100";
            elsif term_out.adr(1 downto 0) = "11" then
               first_be_en := "1000";
            else
               first_be_en := "0001";
            end if;
         elsif term_out.typ = 1 then                                            -- word
            byte_count := 2;
            if term_out.adr(1) = '0' then
               first_be_en := "0011";
            else
               first_be_en := "1100";
            end if;
         else                                                                   -- long word
            byte_count := term_out.numb *4;
            first_be_en := x"F";
         end if;

         for i in 0 to term_out.numb -1 loop
            data_vec(i)        := std_logic_vector(unsigned(term_out.dat) + to_unsigned(i,32));
            return_data_vec(i) := (others => '0');
            wait for 0 ns;
         end loop;

         if term_out.wr = 0 then                                                -- read
            if term_out.tga(1 downto 0) = IO_TRANSFER then                      -- I/O 
               report "ERROR(pcie_sim): I/O transfer not supported" severity error;
            elsif term_out.tga(1 downto 0) = MEM32_TRANSFER then                -- memory
               get_pcie_addr_and_offset(
                  pcie_addr  => addr32_int,
                  bar_addr   => bar_addr,
                  bar_limit  => bar_limit,
                  bar_num    => var_bar_num,
                  bar_offset => var_bar_offset
               );
               if term_out.numb = 1 then
                  bfm_rd_mem32(
                     bar_num    => var_bar_num,
                     bar_offset => var_bar_offset,
                     byte_en    => first_be_en,
                     ref_data32 => term_out.dat,
                     data32_out => return_data32,
                     success    => success_int
                  );
               else
                  bfm_rd_mem32(
                     bar_num    => var_bar_num,
                     bar_offset => var_bar_offset,
                     byte_count => byte_count,
                     ref_data32 => data_vec,
                     data32_out => return_data_vec,
                     success    => success_int
                  );
               end if;
            elsif term_out.tga(1 downto 0) = CONFIG_TRANSFER then               -- configuration type 0 
               bfm_rd_config(
                  byte_en      => first_be_en,
                  pcie_addr    => addr32_int(31 downto 2),
                  ref_data32   => term_out.dat,
                  data32_out   => return_data32,
                  success      => success_int
               );
            else
               assert false report "ERROR (pcie_sim): term_out.tga(1 downto 0) = 11 is reserved for reads" severity failure;
            end if;
         elsif term_out.wr = 1 then                                             -- write
            if term_out.tga(1 downto 0) = IO_TRANSFER then                      -- I/O
               report "ERROR(pcie_sim): I/O transfer not supported" severity error;
            elsif term_out.tga(1 downto 0) = MEM32_TRANSFER then                -- memory
               get_pcie_addr_and_offset(
                  pcie_addr  => term_out.adr,
                  bar_addr   => bar_addr,
                  bar_limit  => bar_limit,
                  bar_num    => var_bar_num,
                  bar_offset => var_bar_offset
               );
               if term_out.numb = 1 then
                  bfm_wr_mem32(
                     pcie_addr  => term_out.adr(1 downto 0),
                     bar_num    => var_bar_num,
                     bar_offset => var_bar_offset,
                     byte_count => byte_count,
                     data32     => term_out.dat,
                     success    => success_int
                  );
               else
                  bfm_wr_mem32(
                     bar_num    => var_bar_num,
                     bar_offset => var_bar_offset,
                     byte_count => byte_count,
                     data32     => data_vec,
                     success    => success_int
                  );
               end if;
            elsif term_out.tga(1 downto 0) = CONFIG_TRANSFER then               -- configuration type 0
               bfm_wr_config(
                  byte_en   => first_be_en,
                  pcie_addr => addr32_int(31 downto 2),
                  data32    => term_out.dat,
                  success   => success_int
               );
            else
            -- => term_out.tga(1 downto 0) = SETUP_CYCLE then                   -- BFM setup
               if term_out.txt >= 2 then
                  print("pcie_sim.vhd: starting SETUP_CYCLE");
               end if;

               if term_out.adr(2 downto 0) = "000" then                         -- BAR0
                  var_bar0_addr  := term_out.dat;
                  var_bar0_limit := get_bar_limit(bar_addr => var_bar0_addr, bar_num => 0);
                  bar_addr(0)    <= var_bar0_addr;
                  bar_limit(0)   <= var_bar0_limit;
                  success_int    := true;
               elsif term_out.adr(2 downto 0) = "001" then                      -- BAR1
                  var_bar1_addr  := term_out.dat;
                  var_bar1_limit := get_bar_limit(bar_addr => var_bar1_addr, bar_num => 1);
                  bar_addr(1)    <= var_bar1_addr;
                  bar_limit(1)   <= var_bar1_limit;
                  success_int    := true;
               elsif term_out.adr(2 downto 0) = "010" then                      -- BAR2
                  var_bar2_addr  := term_out.dat;
                  var_bar2_limit := get_bar_limit(bar_addr => var_bar2_addr, bar_num => 2);
                  bar_addr(2)    <= var_bar2_addr;
                  bar_limit(2)   <= var_bar2_limit;
                  success_int    := true;
               elsif term_out.adr(2 downto 0) = "011" then                      -- BAR3
                  var_bar3_addr  := term_out.dat;
                  var_bar3_limit := get_bar_limit(bar_addr => var_bar3_addr, bar_num => 3);
                  bar_addr(3)    <= var_bar3_addr;
                  bar_limit(3)   <= var_bar3_limit;
                  success_int    := true;
               elsif term_out.adr(2 downto 0) = "100" then                      -- BAR4
                  var_bar4_addr  := term_out.dat;
                  var_bar4_limit := get_bar_limit(bar_addr => var_bar4_addr, bar_num => 4);
                  bar_addr(4)    <= var_bar4_addr;
                  bar_limit(4)   <= var_bar4_limit;
                  success_int    := true;
               elsif term_out.adr(2 downto 0) = "101" then                      -- BAR5
                  var_bar5_addr  := term_out.dat;
                  var_bar5_limit := get_bar_limit(bar_addr => var_bar5_addr, bar_num => 5);
                  bar_addr(5)    <= var_bar5_addr;
                  bar_limit(5)   <= var_bar5_limit;
                  success_int    := true;
               else
                  report "ERROR: pcie_sim.vhd: term_out.tga is set to SETUP_CYCLE but term_out.adr has an invalid value!" &
                         " Use values 000 to 101." severity error;
               end if;
               wait_clk(clk_i,1);

            end if;
         else                                                                   -- wait
            wait_clk(clk_i,term_out.numb);
         end if;
            
         --------------------------------------
         -- return values and finish transfer
         --------------------------------------
         term_in.dat <= return_data32;
         if success_int then
            term_in.err <= 0;
         else
            term_in.err <= 1;
         end if;
         term_in.busy <= '0';
         term_in.done <= term_out.start;
      end loop;
   end process main;

-- +----------------------------------------------------------------------------
-- | component instanciation section
-- +----------------------------------------------------------------------------
   bfm_inst: altpcietb_bfm_rp_top_x8_pipen1b
      port map(
         pcie_rstn        => bfm_rstn_delayed, --pcie_rstn_i,
         local_rstn       => '1',
         clk250_in        => ep_clk250_i,
         clk500_in        => ep_clk500_i,
         pipe_mode        => bfm_pipe_mode_int,

         rxdata4_ext      => bfm_rxdata_4_int,
         rx_in7           => bfm_rx_int(7),
         phystatus5_ext   => bfm_phystatus_5_int,
         rxdata5_ext      => bfm_rxdata_5_int,
         phystatus1_ext   => bfm_phystatus_1_int,
         rxstatus3_ext    => bfm_rxstatus_3_int,
         rxelecidle7_ext  => bfm_rxelecidle_7_int,
         rxelecidle0_ext  => bfm_rxelecidle_0_int,
         rxelecidle3_ext  => bfm_rxelecidle_3_int,
         rxdatak1_ext     => bfm_rxdatak_1_int,
         phystatus0_ext   => bfm_phystatus_0_int,
         rx_in0           => bfm_rx_int(0),
         rx_in5           => bfm_rx_int(5),
         rxelecidle5_ext  => bfm_rxelecidle_5_int,
         rxvalid1_ext     => bfm_rxvalid_1_int,
         rx_in2           => bfm_rx_int(2),
         rx_in3           => bfm_rx_int(3),
         rxdatak3_ext     => bfm_rxdatak_3_int,
         phystatus6_ext   => bfm_phystatus_6_int,
         rxdata6_ext      => bfm_rxdata_6_int,
         rxdata3_ext      => bfm_rxdata_3_int,
         rxstatus5_ext    => bfm_rxstatus_5_int,
         rxstatus1_ext    => bfm_rxstatus_1_int,
         rxdata0_ext      => bfm_rxdata_0_int,
         rxvalid7_ext     => bfm_rxvalid_7_int,
         phystatus7_ext   => bfm_phystatus_7_int,
         rxdata2_ext      => bfm_rxdata_2_int,
         rxvalid5_ext     => bfm_rxvalid_5_int,
         rxvalid0_ext     => bfm_rxvalid_0_int,
         rxdatak2_ext     => bfm_rxdatak_2_int,
         rxstatus4_ext    => bfm_rxstatus_4_int,
         rxdatak7_ext     => bfm_rxdatak_7_int,
         rxstatus0_ext    => bfm_rxstatus_0_int,
         phystatus3_ext   => bfm_phystatus_3_int,
         rxelecidle4_ext  => bfm_rxelecidle_4_int,
         phystatus2_ext   => bfm_phystatus_2_int,
         rxvalid4_ext     => bfm_rxvalid_4_int,
         rx_in6           => bfm_rx_int(6),
         rx_in1           => bfm_rx_int(1),
         rxstatus2_ext    => bfm_rxstatus_2_int,
         rxdata7_ext      => bfm_rxdata_7_int,
         rxdatak0_ext     => bfm_rxdatak_0_int,
         rxelecidle1_ext  => bfm_rxelecidle_1_int,
         rxdata1_ext      => bfm_rxdata_1_int,
         rxstatus6_ext    => bfm_rxstatus_6_int,
         test_in          => bfm_test_in_int,
         rx_in4           => bfm_rx_int(4),
         rxdatak4_ext     => bfm_rxdatak_4_int,
         rxelecidle2_ext  => bfm_rxelecidle_2_int,
         rxdatak5_ext     => bfm_rxdatak_5_int,
         rxstatus7_ext    => bfm_rxstatus_7_int,
         rxelecidle6_ext  => bfm_rxelecidle_6_int,
         rxvalid3_ext     => bfm_rxvalid_3_int,
         rxvalid2_ext     => bfm_rxvalid_2_int,
         phystatus4_ext   => bfm_phystatus_4_int,
         rxvalid6_ext     => bfm_rxvalid_6_int,
         rxdatak6_ext     => bfm_rxdatak_6_int,

         tx_out6          => bfm_tx_int(6),
         tx_out4          => bfm_tx_int(4),
         txdatak4_ext     => bfm_txdatak_4_int(0),
         txelecidle0_ext  => bfm_txelecidle_0_int,
         txdatak1_ext     => bfm_txdatak_1_int(0),
         test_out         => test_out_int,
         txelecidle2_ext  => bfm_txelecidle_2_int,
         txdatak7_ext     => bfm_txdatak_7_int(0),
         txdatak2_ext     => bfm_txdatak_2_int(0),
         txcompl4_ext     => bfm_txcompl_4_int,
         rxpolarity5_ext  => bfm_rxpolarity_5_int,
         rxpolarity4_ext  => bfm_rxpolarity_4_int,
         powerdown7_ext   => bfm_powerdown_7_int,
         txdetectrx7_ext  => bfm_txdetectrx_7_int,
         txelecidle1_ext  => bfm_txelecidle_1_int,
         tx_out3          => bfm_tx_int(3),
         rxpolarity3_ext  => bfm_rxpolarity_3_int,
         txdata0_ext      => bfm_txdata_0_int,
         txdetectrx1_ext  => bfm_txdetectrx_1_int,
         powerdown0_ext   => bfm_powerdown_0_int,
         txdata1_ext      => bfm_txdata_1_int,
         txdatak6_ext     => bfm_txdatak_6_int(0),
         txdata3_ext      => bfm_txdata_3_int,
         txcompl7_ext     => bfm_txcompl_7_int,
         txdata4_ext      => bfm_txdata_4_int,
         powerdown3_ext   => bfm_powerdown_3_int,
         txcompl5_ext     => bfm_txcompl_5_int,
         txcompl0_ext     => bfm_txcompl_0_int,
         txdetectrx5_ext  => bfm_txdetectrx_5_int,
         txcompl1_ext     => bfm_txcompl_1_int,
         powerdown1_ext   => bfm_powerdown_1_int,
         txelecidle7_ext  => bfm_txelecidle_7_int,
         swdn_out         => bfm_irq_int,
         txelecidle6_ext  => bfm_txelecidle_6_int,
         tx_out0          => bfm_tx_int(0),
         powerdown6_ext   => bfm_powerdown_6_int,
         rxpolarity0_ext  => bfm_rxpolarity_0_int,
         tx_out2          => bfm_tx_int(2),
         txdetectrx2_ext  => bfm_txdetectrx_2_int,
         txdata5_ext      => bfm_txdata_5_int,
         txelecidle3_ext  => bfm_txelecidle_3_int,
         txdatak3_ext     => bfm_txdatak_3_int(0),
         txdetectrx0_ext  => bfm_txdetectrx_0_int,
         rxpolarity6_ext  => bfm_rxpolarity_6_int,
         powerdown2_ext   => bfm_powerdown_2_int,
         rate_ext         => bfm_rate_int,
         txcompl3_ext     => bfm_txcompl_3_int,
         txdetectrx6_ext  => bfm_txdetectrx_6_int,
         tx_out5          => bfm_tx_int(5),
         rxpolarity2_ext  => bfm_rxpolarity_2_int,
         tx_out7          => bfm_tx_int(7),
         tx_out1          => bfm_tx_int(1),
         txdetectrx3_ext  => bfm_txdetectrx_3_int,
         txdata6_ext      => bfm_txdata_6_int,
         txcompl2_ext     => bfm_txcompl_2_int,
         rxpolarity1_ext  => bfm_rxpolarity_1_int,
         txelecidle4_ext  => bfm_txelecidle_4_int,
         txdata2_ext      => bfm_txdata_2_int,
         powerdown4_ext   => bfm_powerdown_4_int,
         txcompl6_ext     => bfm_txcompl_6_int,
         txdatak5_ext     => bfm_txdatak_5_int(0),
         txdata7_ext      => bfm_txdata_7_int,
         txdatak0_ext     => bfm_txdatak_0_int(0),
         rxpolarity7_ext  => bfm_rxpolarity_7_int,
         powerdown5_ext   => bfm_powerdown_5_int,
         txdetectrx4_ext  => bfm_txdetectrx_4_int,
         txelecidle5_ext  => bfm_txelecidle_5_int
      );

   ----------------------
   -- use LTSSM monitor
   ----------------------
   ltssm_mon : altpcietb_ltssm_mon
      port map(
         ep_ltssm => ep_ltssm_i,
         rp_clk   => bfm_pclk_int,
         rp_ltssm => bfm_ltssm_rp,
         rstn     => pcie_rstn_i,

         dummy_out => open
      );

   ------------------------
   -- manage unused lanes
   ------------------------
   --manage_lanes: if BFM_LANE_WIDTH = 1 generate
   manage_x1_lanes: if BFM_LANE_WIDTH = 1 generate
   -- x1 configuration, BFM connected with 1 lane, using dummy transceiver for lanes 2 to 8

      x1_lane_0 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 0
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(1 downto 0),
            a_txdatak(0) => ep_txdatak_i(0),
            a_txdata     => ep_txdata_i(7 downto 0),
            a_txcompl    => ep_txcompl_i(0),
            a_txelecidle => ep_txelecidle_i(0),
            a_txdetectrx => ep_txdetectrx_i(0),
            a_rxpolarity => ep_rxpolarity_i(0),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_0_int,
            b_txcompl    => bfm_txcompl_0_int,
            b_txdetectrx => bfm_txdetectrx_0_int,
            b_txelecidle => bfm_txelecidle_0_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_0_int,
            b_rxpolarity => bfm_rxpolarity_0_int,
            b_txdatak    => bfm_txdatak_0_int,

            a_rxvalid    => ep_rxvalid_o(0),
            a_rxstatus   => ep_rxstatus_o(2 downto 0),
            a_rxdatak(0) => ep_rxdatak_o(0),
            a_rxdata     => ep_rxdata_o(7 downto 0),
            a_rxelecidle => ep_rxelecidle_o(0),
            a_phystatus  => ep_phystatus_o(0),
            b_phystatus  => bfm_phystatus_0_int,
            b_rxvalid    => bfm_rxvalid_0_int,
            b_rxelecidle => bfm_rxelecidle_0_int,
            b_rxdatak(0) => bfm_rxdatak_0_int,
            b_rxdata     => bfm_rxdata_0_int,
            b_rxstatus   => bfm_rxstatus_0_int
         );

      x1_lane_1 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 1
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_1_int,
            b_txcompl    => bfm_txcompl_1_int,
            b_txdetectrx => bfm_txdetectrx_1_int,
            b_txelecidle => bfm_txelecidle_1_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_1_int,
            b_rxpolarity => bfm_rxpolarity_1_int,
            b_txdatak    => bfm_txdatak_1_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_1_int,
            b_rxvalid    => bfm_rxvalid_1_int,
            b_rxelecidle => bfm_rxelecidle_1_int,
            b_rxdatak(0) => bfm_rxdatak_1_int,
            b_rxdata     => bfm_rxdata_1_int,
            b_rxstatus   => bfm_rxstatus_1_int
         );

      x1_lane_2 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 2
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_2_int,
            b_txcompl    => bfm_txcompl_2_int,
            b_txdetectrx => bfm_txdetectrx_2_int,
            b_txelecidle => bfm_txelecidle_2_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_2_int,
            b_rxpolarity => bfm_rxpolarity_2_int,
            b_txdatak    => bfm_txdatak_2_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_2_int,
            b_rxvalid    => bfm_rxvalid_2_int,
            b_rxelecidle => bfm_rxelecidle_2_int,
            b_rxdatak(0) => bfm_rxdatak_2_int,
            b_rxdata     => bfm_rxdata_2_int,
            b_rxstatus   => bfm_rxstatus_2_int
         );

      x1_lane_3 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 3
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_3_int,
            b_txcompl    => bfm_txcompl_3_int,
            b_txdetectrx => bfm_txdetectrx_3_int,
            b_txelecidle => bfm_txelecidle_3_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_3_int,
            b_rxpolarity => bfm_rxpolarity_3_int,
            b_txdatak    => bfm_txdatak_3_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_3_int,
            b_rxvalid    => bfm_rxvalid_3_int,
            b_rxelecidle => bfm_rxelecidle_3_int,
            b_rxdatak(0) => bfm_rxdatak_3_int,
            b_rxdata     => bfm_rxdata_3_int,
            b_rxstatus   => bfm_rxstatus_3_int
         );

      x1_lane_4 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 4
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_4_int,
            b_txcompl    => bfm_txcompl_4_int,
            b_txdetectrx => bfm_txdetectrx_4_int,
            b_txelecidle => bfm_txelecidle_4_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_4_int,
            b_rxpolarity => bfm_rxpolarity_4_int,
            b_txdatak    => bfm_txdatak_4_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_4_int,
            b_rxvalid    => bfm_rxvalid_4_int,
            b_rxelecidle => bfm_rxelecidle_4_int,
            b_rxdatak(0) => bfm_rxdatak_4_int,
            b_rxdata     => bfm_rxdata_4_int,
            b_rxstatus   => bfm_rxstatus_4_int
         );

      x1_lane_5 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 5
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_5_int,
            b_txcompl    => bfm_txcompl_5_int,
            b_txdetectrx => bfm_txdetectrx_5_int,
            b_txelecidle => bfm_txelecidle_5_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_5_int,
            b_rxpolarity => bfm_rxpolarity_5_int,
            b_txdatak    => bfm_txdatak_5_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_5_int,
            b_rxvalid    => bfm_rxvalid_5_int,
            b_rxelecidle => bfm_rxelecidle_5_int,
            b_rxdatak(0) => bfm_rxdatak_5_int,
            b_rxdata     => bfm_rxdata_5_int,
            b_rxstatus   => bfm_rxstatus_5_int
         );

      x1_lane_6 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 6
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_6_int,
            b_txcompl    => bfm_txcompl_6_int,
            b_txdetectrx => bfm_txdetectrx_6_int,
            b_txelecidle => bfm_txelecidle_6_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_6_int,
            b_rxpolarity => bfm_rxpolarity_6_int,
            b_txdatak    => bfm_txdatak_6_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_6_int,
            b_rxvalid    => bfm_rxvalid_6_int,
            b_rxelecidle => bfm_rxelecidle_6_int,
            b_rxdatak(0) => bfm_rxdatak_6_int,
            b_rxdata     => bfm_rxdata_6_int,
            b_rxstatus   => bfm_rxstatus_6_int
         );

      x1_lane_7 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 7
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_7_int,
            b_txcompl    => bfm_txcompl_7_int,
            b_txdetectrx => bfm_txdetectrx_7_int,
            b_txelecidle => bfm_txelecidle_7_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_7_int,
            b_rxpolarity => bfm_rxpolarity_7_int,
            b_txdatak    => bfm_txdatak_7_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_7_int,
            b_rxvalid    => bfm_rxvalid_7_int,
            b_rxelecidle => bfm_rxelecidle_7_int,
            b_rxdatak(0) => bfm_rxdatak_7_int,
            b_rxdata     => bfm_rxdata_7_int,
            b_rxstatus   => bfm_rxstatus_7_int
         );
   end generate manage_x1_lanes;

   --elsif BFM_LANE_WIDTH = 2 generate
   manage_x2_lanes : if BFM_LANE_WIDTH = 2 generate
   -- x2 configuration, BFM connected with 2 lanes, using dummy transceiver for lanes 3 to 8

      x2_lane_0 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 0
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(1 downto 0),
            a_txdatak(0) => ep_txdatak_i(0),
            a_txdata     => ep_txdata_i(7 downto 0),
            a_txcompl    => ep_txcompl_i(0),
            a_txelecidle => ep_txelecidle_i(0),
            a_txdetectrx => ep_txdetectrx_i(0),
            a_rxpolarity => ep_rxpolarity_i(0),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_0_int,
            b_txcompl    => bfm_txcompl_0_int,
            b_txdetectrx => bfm_txdetectrx_0_int,
            b_txelecidle => bfm_txelecidle_0_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_0_int,
            b_rxpolarity => bfm_rxpolarity_0_int,
            b_txdatak    => bfm_txdatak_0_int,

            a_rxvalid    => ep_rxvalid_o(0),
            a_rxstatus   => ep_rxstatus_o(2 downto 0),
            a_rxdatak(0) => ep_rxdatak_o(0),
            a_rxdata     => ep_rxdata_o(7 downto 0),
            a_rxelecidle => ep_rxelecidle_o(0),
            a_phystatus  => ep_phystatus_o(0),
            b_phystatus  => bfm_phystatus_0_int,
            b_rxvalid    => bfm_rxvalid_0_int,
            b_rxelecidle => bfm_rxelecidle_0_int,
            b_rxdatak(0) => bfm_rxdatak_0_int,
            b_rxdata     => bfm_rxdata_0_int,
            b_rxstatus   => bfm_rxstatus_0_int
         );

      x2_lane_1 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 1
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(3 downto 2),
            a_txdatak(0) => ep_txdatak_i(1),
            a_txdata     => ep_txdata_i(15 downto 8),
            a_txcompl    => ep_txcompl_i(1),
            a_txelecidle => ep_txelecidle_i(1),
            a_txdetectrx => ep_txdetectrx_i(1),
            a_rxpolarity => ep_rxpolarity_i(1),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_0_int,
            b_txcompl    => bfm_txcompl_0_int,
            b_txdetectrx => bfm_txdetectrx_0_int,
            b_txelecidle => bfm_txelecidle_0_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_0_int,
            b_rxpolarity => bfm_rxpolarity_0_int,
            b_txdatak    => bfm_txdatak_0_int,

            a_rxvalid    => ep_rxvalid_o(1),
            a_rxstatus   => ep_rxstatus_o(5 downto 3),
            a_rxdatak(0) => ep_rxdatak_o(1),
            a_rxdata     => ep_rxdata_o(15 downto 8),
            a_rxelecidle => ep_rxelecidle_o(1),
            a_phystatus  => ep_phystatus_o(1),
            b_phystatus  => bfm_phystatus_0_int,
            b_rxvalid    => bfm_rxvalid_0_int,
            b_rxelecidle => bfm_rxelecidle_0_int,
            b_rxdatak(0) => bfm_rxdatak_0_int,
            b_rxdata     => bfm_rxdata_0_int,
            b_rxstatus   => bfm_rxstatus_0_int
         );

      x2_lane_2 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 2
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_2_int,
            b_txcompl    => bfm_txcompl_2_int,
            b_txdetectrx => bfm_txdetectrx_2_int,
            b_txelecidle => bfm_txelecidle_2_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_2_int,
            b_rxpolarity => bfm_rxpolarity_2_int,
            b_txdatak    => bfm_txdatak_2_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_2_int,
            b_rxvalid    => bfm_rxvalid_2_int,
            b_rxelecidle => bfm_rxelecidle_2_int,
            b_rxdatak(0) => bfm_rxdatak_2_int,
            b_rxdata     => bfm_rxdata_2_int,
            b_rxstatus   => bfm_rxstatus_2_int
         );

      x2_lane_3 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 3
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_3_int,
            b_txcompl    => bfm_txcompl_3_int,
            b_txdetectrx => bfm_txdetectrx_3_int,
            b_txelecidle => bfm_txelecidle_3_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_3_int,
            b_rxpolarity => bfm_rxpolarity_3_int,
            b_txdatak    => bfm_txdatak_3_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_3_int,
            b_rxvalid    => bfm_rxvalid_3_int,
            b_rxelecidle => bfm_rxelecidle_3_int,
            b_rxdatak(0) => bfm_rxdatak_3_int,
            b_rxdata     => bfm_rxdata_3_int,
            b_rxstatus   => bfm_rxstatus_3_int
         );

      x2_lane_4 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 4
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_4_int,
            b_txcompl    => bfm_txcompl_4_int,
            b_txdetectrx => bfm_txdetectrx_4_int,
            b_txelecidle => bfm_txelecidle_4_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_4_int,
            b_rxpolarity => bfm_rxpolarity_4_int,
            b_txdatak    => bfm_txdatak_4_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_4_int,
            b_rxvalid    => bfm_rxvalid_4_int,
            b_rxelecidle => bfm_rxelecidle_4_int,
            b_rxdatak(0) => bfm_rxdatak_4_int,
            b_rxdata     => bfm_rxdata_4_int,
            b_rxstatus   => bfm_rxstatus_4_int
         );

      x2_lane_5 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 5
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_5_int,
            b_txcompl    => bfm_txcompl_5_int,
            b_txdetectrx => bfm_txdetectrx_5_int,
            b_txelecidle => bfm_txelecidle_5_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_5_int,
            b_rxpolarity => bfm_rxpolarity_5_int,
            b_txdatak    => bfm_txdatak_5_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_5_int,
            b_rxvalid    => bfm_rxvalid_5_int,
            b_rxelecidle => bfm_rxelecidle_5_int,
            b_rxdatak(0) => bfm_rxdatak_5_int,
            b_rxdata     => bfm_rxdata_5_int,
            b_rxstatus   => bfm_rxstatus_5_int
         );

      x2_lane_6 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 6
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_6_int,
            b_txcompl    => bfm_txcompl_6_int,
            b_txdetectrx => bfm_txdetectrx_6_int,
            b_txelecidle => bfm_txelecidle_6_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_6_int,
            b_rxpolarity => bfm_rxpolarity_6_int,
            b_txdatak    => bfm_txdatak_6_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_6_int,
            b_rxvalid    => bfm_rxvalid_6_int,
            b_rxelecidle => bfm_rxelecidle_6_int,
            b_rxdatak(0) => bfm_rxdatak_6_int,
            b_rxdata     => bfm_rxdata_6_int,
            b_rxstatus   => bfm_rxstatus_6_int
         );

      x2_lane_7 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 7
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_7_int,
            b_txcompl    => bfm_txcompl_7_int,
            b_txdetectrx => bfm_txdetectrx_7_int,
            b_txelecidle => bfm_txelecidle_7_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_7_int,
            b_rxpolarity => bfm_rxpolarity_7_int,
            b_txdatak    => bfm_txdatak_7_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_7_int,
            b_rxvalid    => bfm_rxvalid_7_int,
            b_rxelecidle => bfm_rxelecidle_7_int,
            b_rxdatak(0) => bfm_rxdatak_7_int,
            b_rxdata     => bfm_rxdata_7_int,
            b_rxstatus   => bfm_rxstatus_7_int
         );
   end generate manage_x2_lanes;

   --elsif BFM_LANE_WIDTH = 4 generate
   manage_x4_lanes: if BFM_LANE_WIDTH = 4 generate
   -- x4 configuration, BFM connected with 4 lanes, using dummy transceiver for lanes 5 to 8

      x4_lane_0 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 0
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(1 downto 0),
            a_txdatak(0) => ep_txdatak_i(0),
            a_txdata     => ep_txdata_i(7 downto 0),
            a_txcompl    => ep_txcompl_i(0),
            a_txelecidle => ep_txelecidle_i(0),
            a_txdetectrx => ep_txdetectrx_i(0),
            a_rxpolarity => ep_rxpolarity_i(0),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_0_int,
            b_txcompl    => bfm_txcompl_0_int,
            b_txdetectrx => bfm_txdetectrx_0_int,
            b_txelecidle => bfm_txelecidle_0_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_0_int,
            b_rxpolarity => bfm_rxpolarity_0_int,
            b_txdatak    => bfm_txdatak_0_int,

            a_rxvalid    => ep_rxvalid_o(0),
            a_rxstatus   => ep_rxstatus_o(2 downto 0),
            a_rxdatak(0) => ep_rxdatak_o(0),
            a_rxdata     => ep_rxdata_o(7 downto 0),
            a_rxelecidle => ep_rxelecidle_o(0),
            a_phystatus  => ep_phystatus_o(0),
            b_phystatus  => bfm_phystatus_0_int,
            b_rxvalid    => bfm_rxvalid_0_int,
            b_rxelecidle => bfm_rxelecidle_0_int,
            b_rxdatak(0) => bfm_rxdatak_0_int,
            b_rxdata     => bfm_rxdata_0_int,
            b_rxstatus   => bfm_rxstatus_0_int
         );

      x4_lane_1 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 1
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(3 downto 2),
            a_txdatak(0) => ep_txdatak_i(1),
            a_txdata     => ep_txdata_i(15 downto 8),
            a_txcompl    => ep_txcompl_i(1),
            a_txelecidle => ep_txelecidle_i(1),
            a_txdetectrx => ep_txdetectrx_i(1),
            a_rxpolarity => ep_rxpolarity_i(1),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_0_int,
            b_txcompl    => bfm_txcompl_0_int,
            b_txdetectrx => bfm_txdetectrx_0_int,
            b_txelecidle => bfm_txelecidle_0_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_0_int,
            b_rxpolarity => bfm_rxpolarity_0_int,
            b_txdatak    => bfm_txdatak_0_int,

            a_rxvalid    => ep_rxvalid_o(1),
            a_rxstatus   => ep_rxstatus_o(5 downto 3),
            a_rxdatak(0) => ep_rxdatak_o(1),
            a_rxdata     => ep_rxdata_o(15 downto 8),
            a_rxelecidle => ep_rxelecidle_o(1),
            a_phystatus  => ep_phystatus_o(1),
            b_phystatus  => bfm_phystatus_0_int,
            b_rxvalid    => bfm_rxvalid_0_int,
            b_rxelecidle => bfm_rxelecidle_0_int,
            b_rxdatak(0) => bfm_rxdatak_0_int,
            b_rxdata     => bfm_rxdata_0_int,
            b_rxstatus   => bfm_rxstatus_0_int
         );

      x4_lane_2 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 2
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(5 downto 4),
            a_txdatak(0) => ep_txdatak_i(2),
            a_txdata     => ep_txdata_i(23 downto 16),
            a_txcompl    => ep_txcompl_i(2),
            a_txelecidle => ep_txelecidle_i(2),
            a_txdetectrx => ep_txdetectrx_i(2),
            a_rxpolarity => ep_rxpolarity_i(2),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_0_int,
            b_txcompl    => bfm_txcompl_0_int,
            b_txdetectrx => bfm_txdetectrx_0_int,
            b_txelecidle => bfm_txelecidle_0_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_0_int,
            b_rxpolarity => bfm_rxpolarity_0_int,
            b_txdatak    => bfm_txdatak_0_int,

            a_rxvalid    => ep_rxvalid_o(2),
            a_rxstatus   => ep_rxstatus_o(8 downto 6),
            a_rxdatak(0) => ep_rxdatak_o(2),
            a_rxdata     => ep_rxdata_o(23 downto 16),
            a_rxelecidle => ep_rxelecidle_o(2),
            a_phystatus  => ep_phystatus_o(2),
            b_phystatus  => bfm_phystatus_0_int,
            b_rxvalid    => bfm_rxvalid_0_int,
            b_rxelecidle => bfm_rxelecidle_0_int,
            b_rxdatak(0) => bfm_rxdatak_0_int,
            b_rxdata     => bfm_rxdata_0_int,
            b_rxstatus   => bfm_rxstatus_0_int
         );

      x4_lane_3 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 3
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(7 downto 6),
            a_txdatak(0) => ep_txdatak_i(3),
            a_txdata     => ep_txdata_i(31 downto 24),
            a_txcompl    => ep_txcompl_i(3),
            a_txelecidle => ep_txelecidle_i(3),
            a_txdetectrx => ep_txdetectrx_i(3),
            a_rxpolarity => ep_rxpolarity_i(3),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_0_int,
            b_txcompl    => bfm_txcompl_0_int,
            b_txdetectrx => bfm_txdetectrx_0_int,
            b_txelecidle => bfm_txelecidle_0_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_0_int,
            b_rxpolarity => bfm_rxpolarity_0_int,
            b_txdatak    => bfm_txdatak_0_int,

            a_rxvalid    => ep_rxvalid_o(3),
            a_rxstatus   => ep_rxstatus_o(11 downto 9),
            a_rxdatak(0) => ep_rxdatak_o(3),
            a_rxdata     => ep_rxdata_o(31 downto 24),
            a_rxelecidle => ep_rxelecidle_o(3),
            a_phystatus  => ep_phystatus_o(3),
            b_phystatus  => bfm_phystatus_0_int,
            b_rxvalid    => bfm_rxvalid_0_int,
            b_rxelecidle => bfm_rxelecidle_0_int,
            b_rxdatak(0) => bfm_rxdatak_0_int,
            b_rxdata     => bfm_rxdata_0_int,
            b_rxstatus   => bfm_rxstatus_0_int
         );

      x4_lane_4 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 4
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_4_int,
            b_txcompl    => bfm_txcompl_4_int,
            b_txdetectrx => bfm_txdetectrx_4_int,
            b_txelecidle => bfm_txelecidle_4_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_4_int,
            b_rxpolarity => bfm_rxpolarity_4_int,
            b_txdatak    => bfm_txdatak_4_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_4_int,
            b_rxvalid    => bfm_rxvalid_4_int,
            b_rxelecidle => bfm_rxelecidle_4_int,
            b_rxdatak(0) => bfm_rxdatak_4_int,
            b_rxdata     => bfm_rxdata_4_int,
            b_rxstatus   => bfm_rxstatus_4_int
         );

      x4_lane_5 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 5
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_5_int,
            b_txcompl    => bfm_txcompl_5_int,
            b_txdetectrx => bfm_txdetectrx_5_int,
            b_txelecidle => bfm_txelecidle_5_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_5_int,
            b_rxpolarity => bfm_rxpolarity_5_int,
            b_txdatak    => bfm_txdatak_5_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_5_int,
            b_rxvalid    => bfm_rxvalid_5_int,
            b_rxelecidle => bfm_rxelecidle_5_int,
            b_rxdatak(0) => bfm_rxdatak_5_int,
            b_rxdata     => bfm_rxdata_5_int,
            b_rxstatus   => bfm_rxstatus_5_int
         );

      x4_lane_6 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 6
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_6_int,
            b_txcompl    => bfm_txcompl_6_int,
            b_txdetectrx => bfm_txdetectrx_6_int,
            b_txelecidle => bfm_txelecidle_6_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_6_int,
            b_rxpolarity => bfm_rxpolarity_6_int,
            b_txdatak    => bfm_txdatak_6_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_6_int,
            b_rxvalid    => bfm_rxvalid_6_int,
            b_rxelecidle => bfm_rxelecidle_6_int,
            b_rxdatak(0) => bfm_rxdatak_6_int,
            b_rxdata     => bfm_rxdata_6_int,
            b_rxstatus   => bfm_rxstatus_6_int
         );

      x4_lane_7 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 7
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '0',                                             -- nothing connected on side A
            a_rate       => '0',
            a_powerdown  => (others => '0'),
            a_txdatak    => (others => '0'),
            a_txdata     => (others => '0'),
            a_txcompl    => '0',
            a_txelecidle => '0',
            a_txdetectrx => '0',
            a_rxpolarity => '0',
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_7_int,
            b_txcompl    => bfm_txcompl_7_int,
            b_txdetectrx => bfm_txdetectrx_7_int,
            b_txelecidle => bfm_txelecidle_7_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_7_int,
            b_rxpolarity => bfm_rxpolarity_7_int,
            b_txdatak    => bfm_txdatak_7_int,

            a_rxvalid    => open,
            a_rxstatus   => open,
            a_rxdatak    => open,
            a_rxdata     => open,
            a_rxelecidle => open,
            a_phystatus  => open,
            b_phystatus  => bfm_phystatus_7_int,
            b_rxvalid    => bfm_rxvalid_7_int,
            b_rxelecidle => bfm_rxelecidle_7_int,
            b_rxdatak(0) => bfm_rxdatak_7_int,
            b_rxdata     => bfm_rxdata_7_int,
            b_rxstatus   => bfm_rxstatus_7_int
         );
   end generate manage_x4_lanes;

   --else generate
   manage_x8_lanes: if BFM_LANE_WIDTH = 8 generate
   -- x8 configuration, BFM connected with maximum lanes, no dummy transceiver necessary

      x8_lane_0 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 0
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(1 downto 0),
            a_txdatak(0) => ep_txdatak_i(0),
            a_txdata     => ep_txdata_i(7 downto 0),
            a_txcompl    => ep_txcompl_i(0),
            a_txelecidle => ep_txelecidle_i(0),
            a_txdetectrx => ep_txdetectrx_i(0),
            a_rxpolarity => ep_rxpolarity_i(0),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_0_int,
            b_txcompl    => bfm_txcompl_0_int,
            b_txdetectrx => bfm_txdetectrx_0_int,
            b_txelecidle => bfm_txelecidle_0_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_0_int,
            b_rxpolarity => bfm_rxpolarity_0_int,
            b_txdatak    => bfm_txdatak_0_int,

            a_rxvalid    => ep_rxvalid_o(0),
            a_rxstatus   => ep_rxstatus_o(2 downto 0),
            a_rxdatak(0) => ep_rxdatak_o(0),
            a_rxdata     => ep_rxdata_o(7 downto 0),
            a_rxelecidle => ep_rxelecidle_o(0),
            a_phystatus  => ep_phystatus_o(0),
            b_phystatus  => bfm_phystatus_0_int,
            b_rxvalid    => bfm_rxvalid_0_int,
            b_rxelecidle => bfm_rxelecidle_0_int,
            b_rxdatak(0) => bfm_rxdatak_0_int,
            b_rxdata     => bfm_rxdata_0_int,
            b_rxstatus   => bfm_rxstatus_0_int
         );

      x8_lane_1 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 1
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(3 downto 2),
            a_txdatak(0) => ep_txdatak_i(1),
            a_txdata     => ep_txdata_i(15 downto 8),
            a_txcompl    => ep_txcompl_i(1),
            a_txelecidle => ep_txelecidle_i(1),
            a_txdetectrx => ep_txdetectrx_i(1),
            a_rxpolarity => ep_rxpolarity_i(1),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_0_int,
            b_txcompl    => bfm_txcompl_0_int,
            b_txdetectrx => bfm_txdetectrx_0_int,
            b_txelecidle => bfm_txelecidle_0_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_0_int,
            b_rxpolarity => bfm_rxpolarity_0_int,
            b_txdatak    => bfm_txdatak_0_int,

            a_rxvalid    => ep_rxvalid_o(1),
            a_rxstatus   => ep_rxstatus_o(5 downto 3),
            a_rxdatak(0) => ep_rxdatak_o(1),
            a_rxdata     => ep_rxdata_o(15 downto 8),
            a_rxelecidle => ep_rxelecidle_o(1),
            a_phystatus  => ep_phystatus_o(1),
            b_phystatus  => bfm_phystatus_0_int,
            b_rxvalid    => bfm_rxvalid_0_int,
            b_rxelecidle => bfm_rxelecidle_0_int,
            b_rxdatak(0) => bfm_rxdatak_0_int,
            b_rxdata     => bfm_rxdata_0_int,
            b_rxstatus   => bfm_rxstatus_0_int
         );

      x8_lane_2 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 2
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(5 downto 4),
            a_txdatak(0) => ep_txdatak_i(2),
            a_txdata     => ep_txdata_i(23 downto 16),
            a_txcompl    => ep_txcompl_i(2),
            a_txelecidle => ep_txelecidle_i(2),
            a_txdetectrx => ep_txdetectrx_i(2),
            a_rxpolarity => ep_rxpolarity_i(2),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_0_int,
            b_txcompl    => bfm_txcompl_0_int,
            b_txdetectrx => bfm_txdetectrx_0_int,
            b_txelecidle => bfm_txelecidle_0_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_0_int,
            b_rxpolarity => bfm_rxpolarity_0_int,
            b_txdatak    => bfm_txdatak_0_int,

            a_rxvalid    => ep_rxvalid_o(2),
            a_rxstatus   => ep_rxstatus_o(8 downto 6),
            a_rxdatak(0) => ep_rxdatak_o(2),
            a_rxdata     => ep_rxdata_o(23 downto 16),
            a_rxelecidle => ep_rxelecidle_o(2),
            a_phystatus  => ep_phystatus_o(2),
            b_phystatus  => bfm_phystatus_0_int,
            b_rxvalid    => bfm_rxvalid_0_int,
            b_rxelecidle => bfm_rxelecidle_0_int,
            b_rxdatak(0) => bfm_rxdatak_0_int,
            b_rxdata     => bfm_rxdata_0_int,
            b_rxstatus   => bfm_rxstatus_0_int
         );

      x8_lane_3 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 3
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(7 downto 6),
            a_txdatak(0) => ep_txdatak_i(3),
            a_txdata     => ep_txdata_i(31 downto 24),
            a_txcompl    => ep_txcompl_i(3),
            a_txelecidle => ep_txelecidle_i(3),
            a_txdetectrx => ep_txdetectrx_i(3),
            a_rxpolarity => ep_rxpolarity_i(3),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_0_int,
            b_txcompl    => bfm_txcompl_0_int,
            b_txdetectrx => bfm_txdetectrx_0_int,
            b_txelecidle => bfm_txelecidle_0_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_0_int,
            b_rxpolarity => bfm_rxpolarity_0_int,
            b_txdatak    => bfm_txdatak_0_int,

            a_rxvalid    => ep_rxvalid_o(3),
            a_rxstatus   => ep_rxstatus_o(11 downto 9),
            a_rxdatak(0) => ep_rxdatak_o(3),
            a_rxdata     => ep_rxdata_o(31 downto 24),
            a_rxelecidle => ep_rxelecidle_o(3),
            a_phystatus  => ep_phystatus_o(3),
            b_phystatus  => bfm_phystatus_0_int,
            b_rxvalid    => bfm_rxvalid_0_int,
            b_rxelecidle => bfm_rxelecidle_0_int,
            b_rxdatak(0) => bfm_rxdatak_0_int,
            b_rxdata     => bfm_rxdata_0_int,
            b_rxstatus   => bfm_rxstatus_0_int
         );

      x8_lane_4 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 4
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(9 downto 8),
            a_txdatak(0) => ep_txdatak_i(4),
            a_txdata     => ep_txdata_i(39 downto 32),
            a_txcompl    => ep_txcompl_i(4),
            a_txelecidle => ep_txelecidle_i(4),
            a_txdetectrx => ep_txdetectrx_i(4),
            a_rxpolarity => ep_rxpolarity_i(4),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_4_int,
            b_txcompl    => bfm_txcompl_4_int,
            b_txdetectrx => bfm_txdetectrx_4_int,
            b_txelecidle => bfm_txelecidle_4_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_4_int,
            b_rxpolarity => bfm_rxpolarity_4_int,
            b_txdatak    => bfm_txdatak_4_int,

            a_rxvalid    => ep_rxvalid_o(4),
            a_rxstatus   => ep_rxstatus_o(14 downto 12),
            a_rxdatak(0) => ep_rxdatak_o(4),
            a_rxdata     => ep_rxdata_o(39 downto 32),
            a_rxelecidle => ep_rxelecidle_o(4),
            a_phystatus  => ep_phystatus_o(4),
            b_phystatus  => bfm_phystatus_4_int,
            b_rxvalid    => bfm_rxvalid_4_int,
            b_rxelecidle => bfm_rxelecidle_4_int,
            b_rxdatak(0) => bfm_rxdatak_4_int,
            b_rxdata     => bfm_rxdata_4_int,
            b_rxstatus   => bfm_rxstatus_4_int
         );

      x8_lane_5 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 5
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(11 downto 10),
            a_txdatak(0) => ep_txdatak_i(5),
            a_txdata     => ep_txdata_i(47 downto 40),
            a_txcompl    => ep_txcompl_i(5),
            a_txelecidle => ep_txelecidle_i(5),
            a_txdetectrx => ep_txdetectrx_i(5),
            a_rxpolarity => ep_rxpolarity_i(5),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_5_int,
            b_txcompl    => bfm_txcompl_5_int,
            b_txdetectrx => bfm_txdetectrx_5_int,
            b_txelecidle => bfm_txelecidle_5_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_5_int,
            b_rxpolarity => bfm_rxpolarity_5_int,
            b_txdatak    => bfm_txdatak_5_int,

            a_rxvalid    => ep_rxvalid_o(5),
            a_rxstatus   => ep_rxstatus_o(17 downto 15),
            a_rxdatak(0) => ep_rxdatak_o(5),
            a_rxdata     => ep_rxdata_o(47 downto 40),
            a_rxelecidle => ep_rxelecidle_o(5),
            a_phystatus  => ep_phystatus_o(5),
            b_phystatus  => bfm_phystatus_5_int,
            b_rxvalid    => bfm_rxvalid_5_int,
            b_rxelecidle => bfm_rxelecidle_5_int,
            b_rxdatak(0) => bfm_rxdatak_5_int,
            b_rxdata     => bfm_rxdata_5_int,
            b_rxstatus   => bfm_rxstatus_5_int
         );

      x8_lane_6 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 6
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(13 downto 12),
            a_txdatak(0) => ep_txdatak_i(6),
            a_txdata     => ep_txdata_i(55 downto 48),
            a_txcompl    => ep_txcompl_i(6),
            a_txelecidle => ep_txelecidle_i(6),
            a_txdetectrx => ep_txdetectrx_i(6),
            a_rxpolarity => ep_rxpolarity_i(6),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_6_int,
            b_txcompl    => bfm_txcompl_6_int,
            b_txdetectrx => bfm_txdetectrx_6_int,
            b_txelecidle => bfm_txelecidle_6_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_6_int,
            b_rxpolarity => bfm_rxpolarity_6_int,
            b_txdatak    => bfm_txdatak_6_int,

            a_rxvalid    => ep_rxvalid_o(6),
            a_rxstatus   => ep_rxstatus_o(20 downto 18),
            a_rxdatak(0) => ep_rxdatak_o(6),
            a_rxdata     => ep_rxdata_o(55 downto 48),
            a_rxelecidle => ep_rxelecidle_o(6),
            a_phystatus  => ep_phystatus_o(6),
            b_phystatus  => bfm_phystatus_6_int,
            b_rxvalid    => bfm_rxvalid_6_int,
            b_rxelecidle => bfm_rxelecidle_6_int,
            b_rxdatak(0) => bfm_rxdatak_6_int,
            b_rxdata     => bfm_rxdata_6_int,
            b_rxstatus   => bfm_rxstatus_6_int
         );

      x8_lane_7 : altpcietb_pipe_phy
         generic map(
            APIPE_WIDTH => 8,
            BPIPE_WIDTH => 8,
            LANE_NUM    => 7
         )
         port map(
            resetn       => pcie_rstn_i,
            pclk_a       => lane_pclk_int,
            pclk_b       => bfm_pclk_int,
            pipe_mode    => bfm_pipe_mode_int,

            a_lane_conn  => '1',                                             -- endpoint connected on side A
            a_rate       => ep_rate_ext_i,
            a_powerdown  => ep_powerdown_ext_i(15 downto 14),
            a_txdatak(0) => ep_txdatak_i(7),
            a_txdata     => ep_txdata_i(63 downto 56),
            a_txcompl    => ep_txcompl_i(7),
            a_txelecidle => ep_txelecidle_i(7),
            a_txdetectrx => ep_txdetectrx_i(7),
            a_rxpolarity => ep_rxpolarity_i(7),
            b_lane_conn  => '1',                                             -- BFM connected on side B
            b_powerdown  => bfm_powerdown_7_int,
            b_txcompl    => bfm_txcompl_7_int,
            b_txdetectrx => bfm_txdetectrx_7_int,
            b_txelecidle => bfm_txelecidle_7_int,
            b_rate       => bfm_rate_int,
            b_txdata     => bfm_txdata_7_int,
            b_rxpolarity => bfm_rxpolarity_7_int,
            b_txdatak    => bfm_txdatak_7_int,

            a_rxvalid    => ep_rxvalid_o(7),
            a_rxstatus   => ep_rxstatus_o(23 downto 21),
            a_rxdatak(0) => ep_rxdatak_o(7),
            a_rxdata     => ep_rxdata_o(63 downto 56),
            a_rxelecidle => ep_rxelecidle_o(7),
            a_phystatus  => ep_phystatus_o(7),
            b_phystatus  => bfm_phystatus_7_int,
            b_rxvalid    => bfm_rxvalid_7_int,
            b_rxelecidle => bfm_rxelecidle_7_int,
            b_rxdatak(0) => bfm_rxdatak_7_int,
            b_rxdata     => bfm_rxdata_7_int,
            b_rxstatus   => bfm_rxstatus_7_int
         );
   --end generate manage_lanes;
   end generate manage_x8_lanes;


end architecture pcie_sim_arch;


