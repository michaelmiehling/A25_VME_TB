-------------------------------------------------------------------------------
-- Title       : 16z091-00 PCIe test bench
-- Project     : 16z091-00
-------------------------------------------------------------------------------
-- File        : types_pkg.vhd
-- Author      : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik GmbH
-- Created     : 2012-08-21
-------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6 Revision 2010.01
-- Synthesis   : 
-------------------------------------------------------------------------------
-- Description : 
-- Constants and types common to all test bench files
-------------------------------------------------------------------------------
-- Hierarchy   : 
-- 
-------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types_pkg is

   constant TST_PASS : integer := 1;
   constant TST_FAIL : integer := 2;
   
   --------------------------------------------------------
   -- define all configurable settings in tst_config_type
   --------------------------------------------------------
   type tst_config_type is record
--      iter              : integer;
--      iram_max_size     : integer;
      set_txt           : integer;
      max_payload       : integer;
      max_read          : integer;
--      msi_nbr           : integer;
--      msi_en            : integer;
--      min_loop          : integer;
--      max_loop          : integer;
--      len_wb_burst      : integer;
--      len_pcie_burst    : integer;
--      start_delay_iram  : integer;
--      wait_states_iram  : integer;
--      break_at_iram     : integer;
--      break_for_iram    : integer;
   end record;
   
--   type error_in_type is record
--      wbm_err     : integer;
--      wbs_err     : integer;
--      wb_mon_err  : integer;
--      mon001_err  : integer;
--   end record;
   
   type watchdog_type is record
      wd_start : boolean;
      wd_time  : time;
   end record;
   
--   type mon001_ctrl_in_type is record
--      busy : std_logic;
--   end record;
   
--   type mon001_ctrl_out_type is record
--      ref_data : std_logic_vector(31 downto 0);
--      ref_sel  : std_logic_vector(3 downto 0);
--      ref_addr : std_logic_vector(31 downto 0);
--      new_val  : boolean;                             -- edge states that ref_sel and ref_data have new values
--   end record;
   
   type cfg_in_type is record
      wb_clk         : std_logic;
      clk            : std_logic;
      tstcfg         : tst_config_type;
      --err_in         : error_in_type;
      --mon001_ctrl_i  : mon001_ctrl_in_type;
   end record;
   
   type cfg_out_type is record
      dut_rst        : std_logic;
      tb_rst         : std_logic;
      wb_rst         : std_logic;
      watchdog       : watchdog_type;
      --mon001_ctrl_o  : mon001_ctrl_out_type;
   end record;
   
end types_pkg;

package body types_pkg is
-- empty
end;
