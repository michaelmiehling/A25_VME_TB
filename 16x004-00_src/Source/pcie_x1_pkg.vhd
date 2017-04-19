-------------------------------------------------------------------------------
-- Title       : package for PCIe simulation model
-- Project     : 16z091-
-------------------------------------------------------------------------------
-- File        : pcie_x1_pkg.vhd
-- Author      : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik GmbH
-- Created     : 2012-10-02
-------------------------------------------------------------------------------
-- Simulator   : 
-- Synthesis   : 
-------------------------------------------------------------------------------
-- Description : 
-- PCIe package for x1 configuration
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

library work;
use work.print_pkg.all;
use work.types_pkg.all;
use work.utils_pkg.all;

library pciebfm_lib;
use pciebfm_lib.pkg_plda_fio.all;
use pciebfm_lib.pkg_xbfm.all;

package pcie_x1_pkg is
   -----------------------------------------------------
   -- constants to use in terminal_out.tga(1 downto 0)
   -----------------------------------------------------
   constant IO_TRANSFER         : std_logic_vector(1 downto 0) := "00";
   constant MEM32_TRANSFER      : std_logic_vector(1 downto 0) := "01";
   constant CONFIG_TRANSFER     : std_logic_vector(1 downto 0) := "10";

   -----------------------------------------------------
   -- constants to use in terminal_out.tga(3 downto 2)
   -----------------------------------------------------
   constant BFM_NBR_0           : std_logic_vector(1 downto 0) := "00";
   constant BFM_NBR_1           : std_logic_vector(1 downto 0) := "01";
   constant BFM_NBR_2           : std_logic_vector(1 downto 0) := "10";
   constant BFM_NBR_3           : std_logic_vector(1 downto 0) := "11";

   ------------------------------
   -- constants for general use
   ------------------------------
   constant BFM_BUFFER_MAX_SIZE : integer := 1024;
   constant DONT_CHECK32        : std_logic_vector(31 downto 0) := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
   
   --! function that calculates the last byte enables of a transfer
   --! @param first_dw first enabled bytes of this transfer
   --! @param byte_count amount of bytes for this transfer
   --! @return last_dw(3 downto 0) last enabled bytes for this transfer
   function calc_last_dw(
      first_dw   : std_logic_vector(3 downto 0);
      byte_count : integer
   ) return std_logic_vector;                                          -- returns std_logic_vector(3 downto 0)

   --! procedure to check a value against a reference value
   --! @param caller_proc string argument which is used in error messages to define the position where
   --!			  this procedure was called from
   --! @param ref_val 32bit reference value
   --! @param check_val 32bit value that is checked against ref_val
   --! @param byte_valid defines which byte of check_val is valid, invalid bytes are not compared
   --! @return check_ok boolean argument which states whether the check was ok (=true) or not
   procedure check_val(
      caller_proc : in  string;
      ref_val     : in  std_logic_vector(31 downto 0);
      check_val   : in  std_logic_vector(31 downto 0);
      byte_valid  : in  std_logic_vector(3 downto 0);
      check_ok    : out boolean
   );

   --! procedure to initialize the BFM
   --! @param bfm_inst_nbr number of the BFM instance that will be initialized
   --! @param io_add start address for the BFM internal I/O space
   --! @param mem32_addr start address for the BFM internal MEM32 space
   --! @param mem64_addr start address for the BFM internal MEM64 space
   --! @param requester_id defines the requester ID that is used for every BFM transfer
   --! @param max_payloadsize defines the maximum payload size for every write request
   procedure init_bfm(
      bfm_inst_nbr      : in integer;
      io_addr           : in std_logic_vector(31 downto 0);
      mem32_addr        : in std_logic_vector(31 downto 0);
      mem64_addr        : in std_logic_vector(63 downto 0);
      requester_id      : in std_logic_vector(15 downto 0);
      max_payloadsize   : in integer
   );

   --! procedure to configure the BFM0, custom version for cfg record
   --! @param cfg_i input record of type cfg_in_type
   --! @return cfg_o returns record of cfg_out_type
   procedure configure_bfm(
      signal cfg_i : in  cfg_in_type;
      signal cfg_o : out cfg_out_type
   );

   --! procedure to configure the BFM, custom version for cfg record
   --! @param cfg_i input record of type cfg_in_type
   --! @return cfg_o returns record of cfg_out_type
   procedure configure_bfm(
      bfm_inst_nbr : in integer;
      signal cfg_i : in  cfg_in_type;
      signal cfg_o : out cfg_out_type
   );

   --! procedure to configure the BFM
   --! @param bfm_inst_nbr number of the BFM instance that will be configured
   --! @param max_payload_size maximum payload size for write requests
   --! @param max_read_size maximum payload size for read requests
   --! @param bar0 BAR0 settings
   --! @param bar1 BAR1 settings
   --! @param bar2 BAR2 settings
   --! @param bar3 BAR3 settings
   --! @param bar4 BAR4 settings
   --! @param bar5 BAR5 settings
   --! @param cmd_status_reg settings for the command status register
   --! @param  ctrl_status_reg settings for the control status register
   procedure configure_bfm (
      bfm_inst_nbr      : in integer;
      max_payload_size  : in integer;
      max_read_size     : in integer;
      bar0              : in std_logic_vector(31 downto 0);
      bar1              : in std_logic_vector(31 downto 0);
      bar2              : in std_logic_vector(31 downto 0);
      bar3              : in std_logic_vector(31 downto 0);
      bar4              : in std_logic_vector(31 downto 0);
      bar5              : in std_logic_vector(31 downto 0);
      cmd_status_reg    : in std_logic_vector(31 downto 0);
      ctrl_status_reg   : in std_logic_vector(31 downto 0)
   );
   
   --! procedure to write values to the BFM internal memory
   --! @param bfm_inst_nbr number of the BFM instance that will be used
   --! @param nbr_of_dw number of DWORDS that will be written
   --! @param io_space set to true is I/O space is targeted
   --! @param mem32 set to true is MEM32 space is targeted, otherwise MEM64 space is used
   --! @param mem_addr offset for internal memory space, start at x"0000_0000"
   --! @param start_data_val first data value to write, other values are defined by data_inc
   --! @param data_inc defines the data increment added to start_data_val for DW 2 to nbr_of_dw
   procedure set_bfm_memory(
      bfm_inst_nbr   : in integer;
      nbr_of_dw      : in integer;
      io_space       : in boolean;
      mem32          : in boolean;
      mem_addr       : in std_logic_vector(31 downto 0);
      start_data_val : in std_logic_vector(31 downto 0);
      data_inc       : in integer
   );
   
   --! procedure to read from BFM internal memory
   --! @param bfm_inst_nbr number of the BFM instance that will be used
   --! @param nbr_of_dw number of DWORDS that will be written
   --! @param io_space set to true is I/O space is targeted
   --! @param mem32 set to true is MEM32 space is targeted, otherwise MEM64 space is used
   --! @param mem_addr offset for internal memory space, start at x"0000_0000"
   --! @return databuf_out returns a dword_vector that contains all data read from BFM internal memory
   procedure get_bfm_memory(
      bfm_inst_nbr   : in  integer;
      nbr_of_dw      : in  integer;
      io_space       : in  boolean;
      mem32          : in  boolean;
      mem_addr       : in  std_logic_vector(31 downto 0);
      databuf_out    : out dword_vector(BFM_BUFFER_MAX_SIZE downto 0)
   );
   
   --! procedure to issue an I/O write to the DUT
   --! @param bfm_inst_nbr number of the BFM instance that will be used
   --! @param byte_en bytes enables for this transfer
   --! @param pcie_addr address at DUT to write to
   --! @param data32 32bit data value to write
   --! @param wait_end set to true to wait until transfer is finished and check for transfer errors
   --! @return success returns true if transfer is done and finished without errors (if wait_end = true)
   procedure bfm_wr_io(
      bfm_inst_nbr   : in  integer;
      byte_en        : in  std_logic_vector(3 downto 0);
      pcie_addr      : in  std_logic_vector(31 downto 2);
      data32         : in  std_logic_vector(31 downto 0);
      wait_end       : in  boolean;
      success        : out boolean                                               -- used when wait_end = true
   );
   
   --! procedure to issue an I/O read to the DUT
   --! @param bfm_inst_nbr number of the BFM instance that will be used
   --! @param byte_en bytes enables for this transfer
   --! @param pcie_addr address at DUT to read from
   --! @param ref_data32 reference data value for read data check, use DONT_CHECK to skip check
   --! @param wait_end set to true to wait until transfer is finished and check for transfer errors
   --! @return data32_out 32bit data value returned from read
   --! @return success returns true if transfer is done and finished without errors (if wait_end = true)
   procedure bfm_rd_io(
      bfm_inst_nbr   : in  integer;
      byte_en        : in  std_logic_vector(3 downto 0);
      pcie_addr      : in  std_logic_vector(31 downto 2);
      ref_data32     : in  std_logic_vector(31 downto 0);
      wait_end       : in  boolean;
      data32_out     : out std_logic_vector(31 downto 0);
      success        : out boolean                                               -- used when wait_end = true
   );
   
   --! procedure to issue an single MEM32 write request to the DUT
   --! @param bfm_inst_nbr number of the BFM instance that will be used
   --! @param byte_en bytes enables for this transfer
   --! @param pcie_addr address at DUT to write to
   --! @param data32 32bit data value to write
   --! @param wait_end set to true to wait until transfer is finished and check for transfer errors
   --! @return success returns true if transfer is done and finished without errors (if wait_end = true)
   procedure bfm_wr_mem32(
      bfm_inst_nbr : in  integer;
      byte_en      : in  std_logic_vector(3 downto 0);
      pcie_addr    : in  std_logic_vector(31 downto 0);
      data32       : in  std_logic_vector(31 downto 0);
      wait_end     : in  boolean;
      success      : out boolean
   );

   --! procedure to issue an burst MEM32 write request to the DUT
   --! @param bfm_inst_nbr number of the BFM instance that will be used
   --! @param byte_count amount of bytes that shall be transferred
   --! @param pcie_addr address at DUT to write to
   --! @param data32 dword_vector that contains all data values to write
   --! @param t_class defines the traffic class this transfer shall have, use "000" as default
   --! @param attributes defines the attributes this transfer shall have, use "00" as default
   --! @param wait_end set to true to wait until transfer is finished and check for transfer errors
   --! @return success returns true if transfer is done and finished without errors (if wait_end = true)
   procedure bfm_wr_mem32(
      bfm_inst_nbr : in  integer;
      byte_count   : in  integer;
      pcie_addr    : in  std_logic_vector(31 downto 0);
      data32       : in  dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      t_class      : in  std_logic_vector(2 downto 0);
      attributes   : in  std_logic_vector(1 downto 0);
      wait_end     : in  boolean;
      success      : out boolean
   );

   --! procedure to issue a single MEM32 read request to the DUT
   --! @param bfm_inst_nbr number of the BFM instance that will be used
   --! @param byte_en bytes enables for this transfer
   --! @param pcie_addr address at DUT to read from
   --! @param ref_data32 reference data value for read data check, use DONT_CHECK to skip check
   --! @param wait_end set to true to wait until transfer is finished and check for transfer errors
   --! @return data32_out 32bit data value returned from read
   --! @return success returns true if transfer is done and finished without errors (if wait_end = true)
   procedure bfm_rd_mem32(
      bfm_inst_nbr   : in  integer;
      byte_en        : in  std_logic_vector(3 downto 0);
      pcie_addr      : in  std_logic_vector(31 downto 2);
      ref_data32     : in  std_logic_vector(31 downto 0);
      wait_end       : in  boolean;
      data32_out     : out std_logic_vector(31 downto 0);
      success        : out boolean                                               -- used when wait_end = true
   );

   --! procedure to issue a burst MEM32 read request to the DUT
   --! @param bfm_inst_nbr number of the BFM instance that will be used
   --! @param byte_count amount of bytes that shall be transferred
   --! @param pcie_addr address at DUT to read from
   --! @param ref_data32 dword_vector that contains the reference data values for read data check, use DONT_CHECK to skip check
   --! @param t_class defines the traffic class this transfer shall have, use "000" as default
   --! @param attributes defines the attributes this transfer shall have, use "00" as default
   --! @param wait_end set to true to wait until transfer is finished and check for transfer errors
   --! @return data32_out dword_vector that contains the data values returned from read
   --! @return success returns true if transfer is done and finished without errors (if wait_end = true)
   procedure bfm_rd_mem32(
      bfm_inst_nbr : in  integer;
      byte_count   : in  integer;
      pcie_addr    : in  std_logic_vector(31 downto 0);
      ref_data32   : in  dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      t_class      : in  std_logic_vector(2 downto 0);
      attributes   : in  std_logic_vector(1 downto 0);
      wait_end     : in  boolean;
      data32_out   : out dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      success      : out boolean
   );

   --! procedure to issue a configuration type 0 write request to the DUT
   --! @param bfm_inst_nbr number of the BFM instance that will be used
   --! @param byte_en bytes enables for this transfer
   --! @param pcie_addr address at DUT to write to
   --! @param data32 32bit data value to write
   --! @param wait_end set to true to wait until transfer is finished and check for transfer errors
   --! @return success returns true if transfer is done and finished without errors (if wait_end = true)
   procedure bfm_wr_config(
      bfm_inst_nbr : in  integer;
      byte_en      : in  std_logic_vector(3 downto 0);
      pcie_addr    : in  std_logic_vector(31 downto 2);
      data32       : in  std_logic_vector(31 downto 0);
      wait_end     : in  boolean;
      success      : out boolean
   );

   --! procedure to issue a configuration type 0 read request to the DUT
   --! @param bfm_inst_nbr number of the BFM instance that will be used
   --! @param byte_en bytes enables for this transfer
   --! @param pcie_addr address at DUT to read from
   --! @param ref_data32 reference data value for read data check, use DONT_CHECK to skip check
   --! @param wait_end set to true to wait until transfer is finished and check for transfer errors
   --! @return data32_out 32bit data value returned from read
   --! @return success returns true if transfer is done and finished without errors (if wait_end = true)
   procedure bfm_rd_config(
      bfm_inst_nbr : in  integer;
      byte_en      : in  std_logic_vector(3 downto 0);
      pcie_addr    : in  std_logic_vector(31 downto 2);
      ref_data32   : in  std_logic_vector(31 downto 0);
      wait_end     : in  boolean;
      data32_out   : out std_logic_vector(31 downto 0);
      success      : out boolean
   );

   --! procedure to configure the DUT configuration space to enable MSI
   --! @param bfm_inst_nbr number of the BFM instance that will be used
   --! @param msi_allowed number of MSI that are allowed, coded vector as defined by PCIe spec
   --! @return returns true if the configuration was successful
   procedure configure_msi(
      bfm_inst_nbr : in  integer;
      msi_allowed  : in  std_logic_vector(2 downto 0);
      success      : out boolean
   );

   --! procedure that waits for an assert INTx message
   --! @param bfm_inst_nbr number of the BFM instance that will be used
   --! @param legacy interrupt number, possible values: 0=A, 1=B, 2=C, 3=D
   --! @return none, procedure will NOT return if irq was not asserted
   procedure wait_on_irq_assert(
      bfm_inst_nbr : in  integer;
      irq_nbr      : in  integer range 3 downto 0
   );

   --! procedure that waits for a deassert INTx message
   --! @param bfm_inst_nbr number of the BFM instance that will be used
   --! @param legacy interrupt number, possible values: 0=A, 1=B, 2=C, 3=D
   --! @return none, procedure will NOT return if irq was not deasserted
   procedure wait_on_irq_deassert(
      bfm_inst_nbr : in  integer;
      irq_nbr      : in  integer range 3 downto 0
   );
      
end pcie_x1_pkg;

package body pcie_x1_pkg is
   function calc_last_dw(
      first_dw   : std_logic_vector(3 downto 0);
      byte_count : integer
   ) return std_logic_vector is
      variable first_bytes : integer := 0;
      variable last_bytes  : integer := 0;
      variable return_int  : std_logic_vector(3 downto 0);
   begin
      if first_dw(0) = '1' then
         first_bytes := first_bytes +1;
      end if;
      if first_dw(1) = '1' then
         first_bytes := first_bytes +1;
      end if;
      if first_dw(2) = '1' then
         first_bytes := first_bytes +1;
      end if;
      if first_dw(3) = '1' then
         first_bytes := first_bytes +1;
      end if;

      last_bytes := (byte_count - first_bytes) mod 4;

      if last_bytes = 0 then
         return_int := "1111";
      elsif last_bytes = 1 then
         return_int := "0001";
      elsif last_bytes = 2 then
         return_int := "0011";
      elsif last_bytes = 3 then
         return_int := "0111";
      else
         return_int := "XXXX";
         assert false report "ERROR in function calc_last_dw(): illegal value for variable last_bytes" severity error;
      end if;
      return return_int;
   end;

   procedure check_val(
      caller_proc : in  string;
      ref_val     : in  std_logic_vector(31 downto 0);
      check_val   : in  std_logic_vector(31 downto 0);
      byte_valid  : in  std_logic_vector(3 downto 0);
      check_ok    : out boolean
   ) is
      variable pass : boolean := true;
   begin
      if byte_valid(0) = '1' then
         if ref_val(7 downto 0) /= check_val(7 downto 0) then
            print_now("BFM ERROR in bfm_rd_mem32(): data read does not match given reference value - mismatch in byte0");
            write_s_slvec("BFM ERROR in" & caller_proc & "(): reference value[7:0] = ",ref_val(7 downto 0));
            write_s_slvec("BFM ERROR in" & caller_proc & "(): read value[7:0] = ",check_val(7 downto 0));
            pass := false;
         end if;
      end if;
      if byte_valid(1) = '1' then
         if ref_val(15 downto 8) /= check_val(15 downto 8) then
            print_now("BFM ERROR in bfm_rd_mem32(): data read does not match given reference value - mismatch in byte1");
            write_s_slvec("BFM ERROR in" & caller_proc & "(): reference value[15:8] = ",ref_val(15 downto 8));
            write_s_slvec("BFM ERROR in" & caller_proc & "(): read value[15:8] = ",check_val(15 downto 8));
            pass := false;
         end if;
      end if;
      if byte_valid(2) = '1' then
         if ref_val(23 downto 16) /= check_val(23 downto 16) then
            print_now("BFM ERROR in bfm_rd_mem32(): data read does not match given reference value - mismatch in byte2");
            write_s_slvec("BFM ERROR in" & caller_proc & "(): reference value[23:16] = ",ref_val(23 downto 16));
            write_s_slvec("BFM ERROR in" & caller_proc & "(): read value[23:16] = ",check_val(23 downto 16));
            pass := false;
         end if;
      end if;
      if byte_valid(3) = '1' then
         if ref_val(31 downto 24) /= check_val(31 downto 24) then
            print_now("BFM ERROR in bfm_rd_mem32(): data read does not match given reference value - mismatch in byte3");
            write_s_slvec("BFM ERROR in" & caller_proc & "(): reference value[31:24] = ",ref_val(31 downto 24));
            write_s_slvec("BFM ERROR in" & caller_proc & "(): read value[31:24] = ",check_val(31 downto 24));
            pass := false;
         end if;
      end if;
      check_ok := pass;
   end procedure;

   procedure init_bfm(
      bfm_inst_nbr      : in integer;
      io_addr           : in std_logic_vector(31 downto 0);
      mem32_addr        : in std_logic_vector(31 downto 0);
      mem64_addr        : in std_logic_vector(63 downto 0);
      requester_id      : in std_logic_vector(15 downto 0);
      max_payloadsize   : in integer
   ) is
   begin
      
      print_now_s("BFM: initialize PCIe BFM, bfm_inst_nbr ",bfm_inst_nbr);
      xbfm_init(bfm_inst_nbr,io_addr,mem32_addr,mem64_addr);
      xbfm_set_requesterid(bfm_inst_nbr,requester_id);
      xbfm_set_maxpayload(bfm_inst_nbr,max_payloadsize);

      print_now_s("BFM: Wait until link is initialized, bfm_inst_nbr ",bfm_inst_nbr);
      xbfm_wait_linkup(bfm_inst_nbr);

      print_now_s("BFM: link is up, bfm_inst_nbr ",bfm_inst_nbr);
      
   end procedure;
   
   procedure configure_bfm(
      signal cfg_i : in  cfg_in_type;
      signal cfg_o : out cfg_out_type
   ) is
      variable max_read  : std_logic_vector(2 downto 0);
      variable max_write : std_logic_vector(2 downto 0);
   begin
      ------------------------------
      -- set PCIe MAX_PAYLOAD_SIZE
      ------------------------------
      if cfg_i.tstcfg.max_payload <= 128 then
         max_write := "000";
      elsif cfg_i.tstcfg.max_payload <= 256 then
         max_write := "001";
      elsif cfg_i.tstcfg.max_payload <= 512 then
         max_write := "010";
      elsif cfg_i.tstcfg.max_payload <= 1024 then
         max_write := "011";
      elsif cfg_i.tstcfg.max_payload <= 2048 then
         max_write := "100";
      elsif cfg_i.tstcfg.max_payload <= 4096 then
         max_write := "101";
      else
         max_write := "000";
      end if;
         
      ------------------------------
      -- set PCIe MAX_READ_SIZE
      ------------------------------
      if cfg_i.tstcfg.max_read <= 128 then
         max_read := "000";
      elsif cfg_i.tstcfg.max_read <= 256 then
         max_read := "001";
      elsif cfg_i.tstcfg.max_read <= 512 then
         max_read := "010";
      elsif cfg_i.tstcfg.max_read <= 1024 then
         max_read := "011";
      elsif cfg_i.tstcfg.max_read <= 2048 then
         max_read := "100";
      elsif cfg_i.tstcfg.max_read <= 4096 then
         max_read := "101";
      else
         max_read := "000";
      end if;
      
      if(cfg_i.tstcfg.set_txt = 2) then write_label("none","configure BFM with typical values", -1); end if;
      if(cfg_i.tstcfg.set_txt = 2) then print("Setup BARs and command/control/status registers"); end if;
      xbfm_dword (0,XBFM_CFGWR0,x"00000010",x"F",x"11100000"); -- BAR0 4kb --> need 12Bit address --> here a 1MB (=20 Bit) address is used
      xbfm_dword (0,XBFM_CFGWR0,x"00000014",x"F",x"22200000"); -- BAR1 8KB --> need 13Bit address --> here a 1MB (=20 Bit) address is used
      xbfm_dword (0,XBFM_CFGWR0,x"00000018",x"F",x"33300000"); -- BAR2 is I/O mapped in z91 simulation and setup with adr.: x333......
      xbfm_dword (0,XBFM_CFGWR0,x"0000001C",x"F",x"44400000"); -- not used in z91 simulation but prepared for future use
      xbfm_dword (0,XBFM_CFGWR0,x"00000020",x"F",x"55500000"); -- not used in z91 simulation but prepared for future use
      xbfm_dword (0,XBFM_CFGWR0,x"00000024",x"F",x"66600000"); -- not used in z91 simulation but prepared for future use
      xbfm_dword (0,XBFM_CFGRD0,x"00000004",x"F",x"00100000"); -- Command/Status
      xbfm_dword (0,XBFM_CFGWR0,x"00000004",x"F",x"000001FF"); -- Control/Status
      xbfm_wait (0);

      if(cfg_i.tstcfg.set_txt = 2) then print("Set max payload & max read request registers"); end if;
      xbfm_dword (0,XBFM_CFGWR0,x"00000088",x"F",x"0000" & '0' & max_read & x"8" & max_write & "00000");
      xbfm_dword (0,XBFM_CFGRD0,x"00000088",x"F",x"0000" & '0' & max_read & x"8" & max_write & "00000");

      xbfm_wait (0);
      
      write_label("ns","PCIe config via BFM done", -1);
   end procedure;

   procedure configure_bfm(
      bfm_inst_nbr : in integer;
      signal cfg_i : in  cfg_in_type;
      signal cfg_o : out cfg_out_type
   ) is
      variable max_read  : std_logic_vector(2 downto 0);
      variable max_write : std_logic_vector(2 downto 0);
   begin
      ------------------------------
      -- set PCIe MAX_PAYLOAD_SIZE
      ------------------------------
      if cfg_i.tstcfg.max_payload <= 128 then
         max_write := "000";
      elsif cfg_i.tstcfg.max_payload <= 256 then
         max_write := "001";
      elsif cfg_i.tstcfg.max_payload <= 512 then
         max_write := "010";
      elsif cfg_i.tstcfg.max_payload <= 1024 then
         max_write := "011";
      elsif cfg_i.tstcfg.max_payload <= 2048 then
         max_write := "100";
      elsif cfg_i.tstcfg.max_payload <= 4096 then
         max_write := "101";
      else
         max_write := "000";
      end if;
         
      ------------------------------
      -- set PCIe MAX_READ_SIZE
      ------------------------------
      if cfg_i.tstcfg.max_read <= 128 then
         max_read := "000";
      elsif cfg_i.tstcfg.max_read <= 256 then
         max_read := "001";
      elsif cfg_i.tstcfg.max_read <= 512 then
         max_read := "010";
      elsif cfg_i.tstcfg.max_read <= 1024 then
         max_read := "011";
      elsif cfg_i.tstcfg.max_read <= 2048 then
         max_read := "100";
      elsif cfg_i.tstcfg.max_read <= 4096 then
         max_read := "101";
      else
         max_read := "000";
      end if;
      
      if(cfg_i.tstcfg.set_txt = 2) then write_label("none","configure BFM with typical values", -1); end if;
      if(cfg_i.tstcfg.set_txt = 2) then print("Setup BARs and command/control/status registers"); end if;
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000010",x"F",x"11100000"); -- BAR0 4kb --> need 12Bit address --> here a 1MB (=20 Bit) address is used
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000014",x"F",x"22200000"); -- BAR1 8KB --> need 13Bit address --> here a 1MB (=20 Bit) address is used
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000018",x"F",x"33300000"); -- BAR2 is I/O mapped in z91 simulation and setup with adr.: x333......
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"0000001C",x"F",x"44400000"); -- not used in z91 simulation but prepared for future use
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000020",x"F",x"55500000"); -- not used in z91 simulation but prepared for future use
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000024",x"F",x"66600000"); -- not used in z91 simulation but prepared for future use
      xbfm_dword (bfm_inst_nbr,XBFM_CFGRD0,x"00000004",x"F",x"00100000"); -- Command/Status
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000004",x"F",x"000001FF"); -- Control/Status
      xbfm_wait (bfm_inst_nbr);

      if(cfg_i.tstcfg.set_txt = 2) then print("Set max payload & max read request registers"); end if;
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000088",x"F",x"0000" & '0' & max_read & x"8" & max_write & "00000");
      xbfm_dword (bfm_inst_nbr,XBFM_CFGRD0,x"00000088",x"F",x"0000" & '0' & max_read & x"8" & max_write & "00000");

      xbfm_wait (bfm_inst_nbr);
      
      write_label("ns","PCIe config via BFM done", -1);
   end procedure;

   procedure configure_bfm (
      bfm_inst_nbr      : in integer;
      max_payload_size  : in integer;
      max_read_size     : in integer;
      bar0              : in std_logic_vector(31 downto 0);
      bar1              : in std_logic_vector(31 downto 0);
      bar2              : in std_logic_vector(31 downto 0);
      bar3              : in std_logic_vector(31 downto 0);
      bar4              : in std_logic_vector(31 downto 0);
      bar5              : in std_logic_vector(31 downto 0);
      cmd_status_reg    : in std_logic_vector(31 downto 0);
      ctrl_status_reg   : in std_logic_vector(31 downto 0)
   ) is
      variable max_read  : std_logic_vector(2 downto 0);
      variable max_write : std_logic_vector(2 downto 0);
   begin
      print_now("BFM: calculate max_payload_size and max_read_size");
      ------------------------------
      -- set PCIe MAX_PAYLOAD_SIZE
      ------------------------------
      if max_payload_size <= 128 then
         max_write := "000";
      elsif max_payload_size <= 256 then
         max_write := "001";
      elsif max_payload_size <= 512 then
         max_write := "010";
      elsif max_payload_size <= 1024 then
         max_write := "011";
      elsif max_payload_size <= 2048 then
         max_write := "100";
      elsif max_payload_size <= 4096 then
         max_write := "101";
      else
         max_write := "000";
      end if;
         
      ------------------------------
      -- set PCIe MAX_READ_SIZE
      ------------------------------
      if max_read_size <= 128 then
         max_read := "000";
      elsif max_read_size <= 256 then
         max_read := "001";
      elsif max_read_size <= 512 then
         max_read := "010";
      elsif max_read_size <= 1024 then
         max_read := "011";
      elsif max_read_size <= 2048 then
         max_read := "100";
      elsif max_read_size <= 4096 then
         max_read := "101";
      else
         max_read := "000";
      end if;
      
      print_now_s("BFM: setup BARs and command/control/status registers, bfm_inst_nbr ",bfm_inst_nbr);
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000010",x"F",bar0);                          -- BAR0
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000014",x"F",bar1);                          -- BAR1
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000018",x"F",bar2);                          -- BAR2
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"0000001C",x"F",bar3);                          -- BAR3
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000020",x"F",bar4);                          -- BAR4
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000024",x"F",bar5);                          -- BAR5
      xbfm_dword (bfm_inst_nbr,XBFM_CFGRD0,x"00000004",x"F",cmd_status_reg);                -- Command/Status
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000004",x"F",ctrl_status_reg);               -- Control/Status
      print_now_s("BFM: wait until all values are set, bfm_inst_nbr ",bfm_inst_nbr);
      xbfm_wait (bfm_inst_nbr);

      print_now_s("BFM: set max_payload & max_read registers, bfm_inst_nbr ",bfm_inst_nbr);
      xbfm_dword (bfm_inst_nbr,XBFM_CFGWR0,x"00000088",x"F",x"0000" & '0' & max_read & x"8" & max_write & "00000");
      xbfm_dword (bfm_inst_nbr,XBFM_CFGRD0,x"00000088",x"F",x"0000" & '0' & max_read & x"8" & max_write & "00000");
      print_now_s("BFM: wait until all values are set, bfm_inst_nbr ",bfm_inst_nbr);
      xbfm_wait (bfm_inst_nbr);
      
      print_now_s("BFM: BARs and registers initialized, bfm_inst_nbr ",bfm_inst_nbr);
   end procedure;
   
   procedure set_bfm_memory(
      bfm_inst_nbr   : in integer;
      nbr_of_dw      : in integer;
      io_space       : in boolean;
      mem32          : in boolean;
      mem_addr       : in std_logic_vector(31 downto 0);
      start_data_val : in std_logic_vector(31 downto 0);
      data_inc       : in integer
   ) is
      variable bfm_databuf : dword_vector(nbr_of_dw -1 downto 0);
   begin
      
      print_now_s("BFM: set BFM internal memory, bfm_inst_nbr ",bfm_inst_nbr);
      print_s_i("BFM: number of dwords = ",nbr_of_dw);
      print_s_std("BFM: start address = ", mem_addr);
      print_s_std("BFM: initial data value = ", start_data_val);
      print_s_i("BFM: data value increment = ",data_inc);

      for i in 0 to nbr_of_dw -1 loop
         bfm_databuf(i) := std_logic_vector(unsigned(start_data_val) + to_unsigned(i*data_inc,32));
      end loop;
      
      if io_space then
         print("BFM: write data to IO space");
         xbfm_memory_write(bfm_inst_nbr,XBFM_IO,mem_addr,nbr_of_dw,bfm_databuf);
      else
         if mem32 then
            print("BFM: write data to MEM32 space");
            xbfm_memory_write(bfm_inst_nbr,XBFM_MEM32,mem_addr,nbr_of_dw,bfm_databuf);
         else
            print("BFM: write data to MEM64 space");
            xbfm_memory_write(bfm_inst_nbr,XBFM_MEM64,mem_addr,nbr_of_dw,bfm_databuf);
         end if;
      end if;
   end procedure;
   
   procedure get_bfm_memory(
      bfm_inst_nbr   : in  integer;
      nbr_of_dw      : in  integer;
      io_space       : in  boolean;
      mem32          : in  boolean;
      mem_addr       : in  std_logic_vector(31 downto 0);
      databuf_out    : out dword_vector(BFM_BUFFER_MAX_SIZE downto 0)
   ) is
   begin
      if nbr_of_dw > BFM_BUFFER_MAX_SIZE then
         print_now_s("BFM ERROR in get_bfm_memory(): nbr_of_dw exceeds BFM_BUFFER_MAX_SIZE, bfm_inst_nbr ",bfm_inst_nbr);
      else
         print_now_s("BFM: get values from BFM internal memory, bfm_inst_nbr ",bfm_inst_nbr);
         print_s_i("BFM: number of dwords = ",nbr_of_dw);
         
         if io_space then
            print("BFM: read data from IO space");
            xbfm_memory_read(bfm_inst_nbr,XBFM_IO,mem_addr,nbr_of_dw,databuf_out);
         else
            if mem32 then
               print("BFM: read data from MEM32 space");
               xbfm_memory_read(bfm_inst_nbr,XBFM_MEM32,mem_addr,nbr_of_dw,databuf_out);
            else
               print("BFM: read data from MEM64 space");
               xbfm_memory_read(bfm_inst_nbr,XBFM_MEM64,mem_addr,nbr_of_dw,databuf_out);
            end if;
         end if;
      end if;
   end procedure;
   
   procedure bfm_wr_io(
      bfm_inst_nbr   : in  integer;
      byte_en        : in  std_logic_vector(3 downto 0);
      pcie_addr      : in  std_logic_vector(31 downto 2);
      data32         : in  std_logic_vector(31 downto 0);
      wait_end       : in  boolean;
      success        : out boolean                                               -- used when wait_end = true
   ) is
      variable bfm_trans_id   : integer := 0;
      variable bfm_status     : integer;
      variable bfm_databuf    : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable pass           : boolean := true;
   begin
      
      print_now_s("BFM: BFM I/O write, bfm_inst_nbr ",bfm_inst_nbr);
      pass := true;
      
      xbfm_dword_id(bfm_inst_nbr,XBFM_IOWR,pcie_addr & "00",byte_en,data32,bfm_trans_id);
      
      if wait_end then
         xbfm_wait_id(bfm_inst_nbr, bfm_trans_id, bfm_status, bfm_databuf);
         ---------------------------------------------
         -- check for BFM errors during transmission
         ---------------------------------------------
         if bfm_status /= XBFM_SC then
            if bfm_status = XBFM_CA then
               print_now("BFM ERROR in bfm_wr_io(): BFM status: completer abort");
            elsif bfm_status = XBFM_UR then
               print_now("BFM ERROR in bfm_wr_io(): BFM status: unsupported request");
            elsif bfm_status = XBFM_TIMEOUT then
               print_now("BFM ERROR in bfm_wr_io(): BFM status: completion timeout");
            else
               print_now("BFM ERROR in bfm_wr_io(): BFM status other than successful but unknown");
            end if;
            pass := false;
         end if;
      end if;

      success := pass;
   end procedure;
   
   procedure bfm_rd_io(
      bfm_inst_nbr   : in  integer;
      byte_en        : in  std_logic_vector(3 downto 0);
      pcie_addr      : in  std_logic_vector(31 downto 2);
      ref_data32     : in  std_logic_vector(31 downto 0);
      wait_end       : in  boolean;
      data32_out     : out std_logic_vector(31 downto 0);
      success        : out boolean                                               -- used when wait_end = true
   ) is
      variable bfm_trans_id   : integer := 0;
      variable bfm_status     : integer;
      variable bfm_databuf    : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable pass           : boolean := true;
   begin
      
      print_now_s("BFM: BFM I/O read, bfm_inst_nbr ",bfm_inst_nbr);
      pass := true;
      data32_out := (others => '0');
      
      xbfm_dword_id(bfm_inst_nbr,XBFM_IORD,pcie_addr & "00",byte_en,bfm_databuf(0),bfm_trans_id);
      
      if wait_end then
         xbfm_wait_id(bfm_inst_nbr, bfm_trans_id, bfm_status, bfm_databuf);
         ---------------------------------------------
         -- check for BFM errors during transmission
         ---------------------------------------------
         if bfm_status /= XBFM_SC then
            if bfm_status = XBFM_CA then
               print_now("BFM ERROR in bfm_rd_io(): BFM status: completer abort");
            elsif bfm_status = XBFM_UR then
               print_now("BFM ERROR in bfm_rd_io(): BFM status: unsupported request");
            elsif bfm_status = XBFM_TIMEOUT then
               print_now("BFM ERROR in bfm_rd_io(): BFM status: completion timeout");
            else
               print_now("BFM ERROR in bfm_rd_io(): BFM status other than successful but unknown");
            end if;
            pass := false;
         end if;
         
         -----------------------------------
         -- check if read value is correct
         -----------------------------------
         if ref_data32 = DONT_CHECK32 then
            print_now("BFM: checking of read value skipped on user command");
         else
            check_val(
               caller_proc => "bfm_rd_io",
               ref_val     => ref_data32,
               check_val   => bfm_databuf(0),
               byte_valid  => byte_en,
               check_ok    => pass
            );
         end if;
         data32_out := bfm_databuf(0);
      else
         print("BFM: skipped check of read value because wait_end = false");   
      end if;

      success := pass;
   end procedure;
   
   procedure bfm_wr_mem32(
      bfm_inst_nbr : in  integer;
      byte_en      : in  std_logic_vector(3 downto 0);
      pcie_addr    : in  std_logic_vector(31 downto 0);
      data32       : in  std_logic_vector(31 downto 0);
      wait_end     : in  boolean;
      success      : out boolean
   ) is
      variable bfm_trans_id   : integer := 0;
      variable bfm_status     : integer;
      variable bfm_databuf    : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable pass           : boolean := true;
   begin
      print_now_s("BFM: BFM MEM32 write (single), bfm_inst_nbr ",bfm_inst_nbr);
      pass := true;

      xbfm_dword_id(bfm_inst_nbr,XBFM_MWR,pcie_addr(31 downto 2) & "00",byte_en,data32,bfm_trans_id);

      if wait_end then
         xbfm_wait_id(bfm_inst_nbr, bfm_trans_id, bfm_status, bfm_databuf);
         ---------------------------------------------
         -- check for BFM errors during transmission
         ---------------------------------------------
         if bfm_status /= XBFM_SC then
            if bfm_status = XBFM_CA then
               print_now("BFM ERROR in bfm_wr_mem32(): BFM status: completer abort");
            elsif bfm_status = XBFM_UR then
               print_now("BFM ERROR in bfm_wr_mem32(): BFM status: unsupported request");
            elsif bfm_status = XBFM_TIMEOUT then
               print_now("BFM ERROR in bfm_wr_mem32(): BFM status: completion timeout");
            else
               print_now("BFM ERROR in bfm_wr_mem32(): BFM status other than successful but unknown");
            end if;
            pass := false;
         end if;
      else
         print("BFM: skipped tranfer check because wait_end = false");
      end if;

      success := pass;
   end procedure;

   procedure bfm_wr_mem32(
      bfm_inst_nbr : in  integer;
      byte_count   : in  integer;
      pcie_addr    : in  std_logic_vector(31 downto 0);
      data32       : in  dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      t_class      : in  std_logic_vector(2 downto 0);
      attributes   : in  std_logic_vector(1 downto 0);
      wait_end     : in  boolean;
      success      : out boolean
   ) is
      variable bfm_trans_id   : integer := 0;
      variable bfm_status     : integer;
      variable bfm_databuf    : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable pass           : boolean := true;
   begin
      print_now_s("BFM: BFM MEM32 write (burst), bfm_inst_nbr ",bfm_inst_nbr);
      pass := true;

      xbfm_burst_id(bfm_inst_nbr,XBFM_MWR,x"0000_0000" & pcie_addr,byte_count,data32,t_class,attributes,bfm_trans_id);
      
      if wait_end then
         xbfm_wait_id(bfm_inst_nbr,bfm_trans_id,bfm_status,bfm_databuf);
         ---------------------------------------------
         -- check for BFM errors during transmission
         ---------------------------------------------
         if bfm_status /= XBFM_SC then
            if bfm_status = XBFM_CA then
               print_now("BFM ERROR in bfm_wr_mem32(): BFM status: completer abort");
            elsif bfm_status = XBFM_UR then
               print_now("BFM ERROR in bfm_wr_mem32(): BFM status: unsupported request");
            elsif bfm_status = XBFM_TIMEOUT then
               print_now("BFM ERROR in bfm_wr_mem32(): BFM status: completion timeout");
            else
               print_now("BFM ERROR in bfm_wr_mem32(): BFM status other than successful but unknown");
            end if;
            pass := false;
         end if;
      else
         print("BFM: skipped tranfer check because wait_end = false");
      end if;

      success := pass;
   end procedure;

   procedure bfm_rd_mem32(
      bfm_inst_nbr   : in  integer;
      byte_en        : in  std_logic_vector(3 downto 0);
      pcie_addr      : in  std_logic_vector(31 downto 2);
      ref_data32     : in  std_logic_vector(31 downto 0);
      wait_end       : in  boolean;
      data32_out     : out std_logic_vector(31 downto 0);
      success        : out boolean                                               -- used when wait_end = true
   ) is
      variable bfm_trans_id   : integer := 0;
      variable bfm_status     : integer;
      variable bfm_databuf    : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable pass           : boolean := true;
   begin
      print_now_s("BFM: BFM MEM32 read, bfm_inst_nbr ",bfm_inst_nbr);
      pass := true;
      data32_out := (others => '0');
      
      xbfm_dword_id(bfm_inst_nbr,XBFM_MRD,pcie_addr & "00",byte_en,bfm_databuf(0),bfm_trans_id);
      
      if wait_end then
         xbfm_wait_id(bfm_inst_nbr, bfm_trans_id, bfm_status, bfm_databuf);
         ---------------------------------------------
         -- check for BFM errors during transmission
         ---------------------------------------------
         if bfm_status /= XBFM_SC then
            if bfm_status = XBFM_CA then
               print_now("BFM ERROR in bfm_rd_mem32(): BFM status: completer abort");
            elsif bfm_status = XBFM_UR then
               print_now("BFM ERROR in bfm_rd_mem32(): BFM status: unsupported request");
            elsif bfm_status = XBFM_TIMEOUT then
               print_now("BFM ERROR in bfm_rd_mem32(): BFM status: completion timeout");
            else
               print_now("BFM ERROR in bfm_rd_mem32(): BFM status other than successful but unknown");
            end if;
            pass := false;
         end if;
         
         -----------------------------------
         -- check if read value is correct
         -----------------------------------
         if ref_data32 = DONT_CHECK32 then
            print_now("BFM: checking of read value skipped on user command");
         else
            check_val(
               caller_proc => "bfm_rd_mem32",
               ref_val     => ref_data32,
               check_val   => bfm_databuf(0),
               byte_valid  => byte_en,
               check_ok    => pass
            );
         end if;
         data32_out := bfm_databuf(0);
      else
         print("BFM: skipped check of read value because wait_end = false");   
      end if;

      success := pass;
   end procedure;

   procedure bfm_rd_mem32(
      bfm_inst_nbr : in  integer;
      byte_count   : in  integer;
      pcie_addr    : in  std_logic_vector(31 downto 0);
      ref_data32   : in  dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      t_class      : in  std_logic_vector(2 downto 0);
      attributes   : in  std_logic_vector(1 downto 0);
      wait_end     : in  boolean;
      data32_out   : out dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      success      : out boolean
   ) is
      variable bfm_trans_id   : integer := 0;
      variable bfm_status     : integer;
      variable bfm_databuf    : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable pass           : boolean := true;
      variable byte_en        : std_logic_vector(3 downto 0) := (others => '0');
      variable first_DW_en    : std_logic_vector(3 downto 0) := (others => '0');
      variable last_DW_en     : std_logic_vector(3 downto 0) := (others => '0');
   begin
      print_now_s("BFM: BFM MEM32 read (burst), bfm_inst_nbr ",bfm_inst_nbr);
      pass := true;
      data32_out := (others => (others => '0'));
      case pcie_addr(1 downto 0) is
         when "00" => first_DW_en := "1111";
         when "01" => first_DW_en := "1110";
         when "10" => first_DW_en := "1100";
         when "11" => first_DW_en := "1000";
         when others => first_DW_en := "1111";
      end case;
      last_DW_en := calc_last_dw(
         first_dw   => first_DW_en,
         byte_count => byte_count );

      xbfm_burst_id(bfm_inst_nbr,XBFM_MRD,x"0000_0000" & pcie_addr,byte_count,bfm_databuf,t_class,attributes,bfm_trans_id);
      
      if wait_end then
         xbfm_wait_id(bfm_inst_nbr,bfm_trans_id,bfm_status,bfm_databuf);
         ---------------------------------------------
         -- check for BFM errors during transmission
         ---------------------------------------------
         if bfm_status /= XBFM_SC then
            if bfm_status = XBFM_CA then
               print_now("BFM ERROR in bfm_rd_mem32(): BFM status: completer abort");
            elsif bfm_status = XBFM_UR then
               print_now("BFM ERROR in bfm_rd_mem32(): BFM status: unsupported request");
            elsif bfm_status = XBFM_TIMEOUT then
               print_now("BFM ERROR in bfm_rd_mem32(): BFM status: completion timeout");
            else
               print_now("BFM ERROR in bfm_rd_mem32(): BFM status other than successful but unknown");
            end if;
            pass := false;
         end if;

         for i in 0 to (byte_count /4) -1 loop
            if ref_data32(i) = DONT_CHECK32 then
               print_now("BFM: checking of read value skipped on user command");
            else
               if i = 0 then
                  byte_en := first_DW_en;
               elsif i = (byte_count /4) -1 then
                  byte_en := last_DW_en;
               else
                  byte_en := x"F";
               end if;

               check_val(
                  caller_proc => "bfm_rd_mem32",
                  ref_val     => ref_data32(i),
                  check_val   => bfm_databuf(i),
                  byte_valid  => byte_en,
                  check_ok    => pass
               );
            end if;
            wait for 0 ns;
         end loop;
         data32_out := bfm_databuf;
      else
         print("BFM: skipped check of read value because wait_end = false");   
      end if;

      success := pass;
   end procedure;

   procedure bfm_wr_config(
      bfm_inst_nbr : in  integer;
      byte_en      : in  std_logic_vector(3 downto 0);
      pcie_addr    : in  std_logic_vector(31 downto 2);
      data32       : in  std_logic_vector(31 downto 0);
      wait_end     : in  boolean;
      success      : out boolean
   ) is
      variable bfm_trans_id   : integer := 0;
      variable bfm_status     : integer;
      variable bfm_databuf    : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable pass           : boolean := true;
   begin
      print_now_s("BFM: BFM configuration write, bfm_inst_nbr ",bfm_inst_nbr);
      pass := true;
      
      xbfm_dword_id(bfm_inst_nbr,XBFM_CFGWR0,pcie_addr & "00",byte_en,data32,bfm_trans_id);
      
      if wait_end then
         xbfm_wait_id(bfm_inst_nbr, bfm_trans_id, bfm_status, bfm_databuf);
         ---------------------------------------------
         -- check for BFM errors during transmission
         ---------------------------------------------
         if bfm_status /= XBFM_SC then
            if bfm_status = XBFM_CA then
               print_now("BFM ERROR in bfm_wr_config(): BFM status: completer abort");
            elsif bfm_status = XBFM_UR then
               print_now("BFM ERROR in bfm_wr_config(): BFM status: unsupported request");
            elsif bfm_status = XBFM_TIMEOUT then
               print_now("BFM ERROR in bfm_wr_config(): BFM status: completion timeout");
            else
               print_now("BFM ERROR in bfm_wr_config(): BFM status other than successful but unknown");
            end if;
            pass := false;
         end if;
      else
         print("BFM: skipped transfer check because wait_end = false");   
      end if;

      success := pass;
   end procedure;

   procedure bfm_rd_config(
      bfm_inst_nbr : in  integer;
      byte_en      : in  std_logic_vector(3 downto 0);
      pcie_addr    : in  std_logic_vector(31 downto 2);
      ref_data32   : in  std_logic_vector(31 downto 0);
      wait_end     : in  boolean;
      data32_out   : out std_logic_vector(31 downto 0);
      success      : out boolean
   ) is
      variable bfm_trans_id   : integer := 0;
      variable bfm_status     : integer;
      variable bfm_databuf    : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable pass           : boolean := true;
   begin
      print_now_s("BFM: BFM configuration read, bfm_inst_nbr ",bfm_inst_nbr);
      pass := true;
      data32_out := (others => '0');
      
      xbfm_dword_id(bfm_inst_nbr,XBFM_CFGRD0,pcie_addr & "00",byte_en,bfm_databuf(0),bfm_trans_id);
      
      if wait_end then
         xbfm_wait_id(bfm_inst_nbr, bfm_trans_id, bfm_status, bfm_databuf);
         ---------------------------------------------
         -- check for BFM errors during transmission
         ---------------------------------------------
         if bfm_status /= XBFM_SC then
            if bfm_status = XBFM_CA then
               print_now("BFM ERROR in bfm_rd_config(): BFM status: completer abort");
            elsif bfm_status = XBFM_UR then
               print_now("BFM ERROR in bfm_rd_config(): BFM status: unsupported request");
            elsif bfm_status = XBFM_TIMEOUT then
               print_now("BFM ERROR in bfm_rd_config(): BFM status: completion timeout");
            else
               print_now("BFM ERROR in bfm_rd_config(): BFM status other than successful but unknown");
            end if;
            pass := false;
         end if;
         
         -----------------------------------
         -- check if read value is correct
         -----------------------------------
         if ref_data32 = DONT_CHECK32 then
            print_now("BFM: checking of read value skipped on user command");
         else
            check_val(
               caller_proc => "bfm_rd_config",
               ref_val     => ref_data32,
               check_val   => bfm_databuf(0),
               byte_valid  => byte_en,
               check_ok    => pass
            );
         end if;
         data32_out := bfm_databuf(0);
      else
         print("BFM: skipped check of read value because wait_end = false");   
      end if;

      success := pass;
   end procedure;

   procedure configure_msi(
      bfm_inst_nbr : in  integer;
      msi_allowed  : in  std_logic_vector(2 downto 0);
      success      : out boolean
   ) is
      variable bfm_trans_id      : integer := 0;
      variable bfm_status        : integer;
      variable bfm_databuf       : dword_vector(255 downto 0);
      variable nextCapAddr       : std_logic_vector(7 downto 0);  -- address of next capability
      variable data32bit         : std_logic_vector(31 downto 0);
      variable capID             : std_logic_vector(7 downto 0);
      variable msi_addr_is_64bit : std_logic;
      variable temp_addr         : std_logic_vector(31 downto 0);
      variable pass              : boolean;
   begin
      pass := true;
      
--         if(cfg_i.tstcfg.set_txt = 2) then print_now("Test MSI generation"); end if;
      ----------------------------------------------
      -- configure PCIe config space to enable MSI
      -- MSI capabilities registers for 32bit MSI addresses:
      -- 31               16 15               8 7           0
      -- -----------------------------------------------------
      -- | message ctrl reg | next cap pointer | cap ID=0x05 | DW0
      -- -----------------------------------------------------
      -- | message address register                          | DW1
      -- -----------------------------------------------------
      -- | reserved         | message data register          | DW2
      -- -----------------------------------------------------
      -- MSI capabilities registers for 64bit MSI addresses:
      -- 31               16 15               8 7           0
      -- -----------------------------------------------------
      -- | message ctrl reg | next cap pointer | cap ID=0x05 | DW0
      -- -----------------------------------------------------
      -- | least signif. 32bits of message address register  | DW1
      -- -----------------------------------------------------
      -- | most signif. 32bits of message address register   | DW2
      -- -----------------------------------------------------
      -- | reserved         | message data register          | DW3
      -- -----------------------------------------------------
      -- cycle:
      -- 1. read status register and check bit4
      --    if =1 then function has extended capabilities implemented
      --    and capabilities pointer is implemented @DW13 = 0x34
      -- 2. read capabilities pointer value which is start address of extended capabilities list
      -- 3. read register @address from step 2 and check bit 7:0
      --    if 7:0=0x05 then MSI register set is present
      --    else read next address @15:8
      -- 4. if MSI register set is found
      --    check if 64bit addresses are used
      --    program message address register to DW1 with 31:2=addr and 1:0=0
      --    program message data register to DW2 with 31:16=0 and 15:0=data
      -- 5. program DW0 with nbr of MSI allowed and enable MSI
      --    read bit 19:17 of DW0 which contains nbr of MSI requested by function
      --    program nbr of MSI allowed to DW0 bit 22:20 and enable MSI bit 16=1
      ----------------------------------------------
      -- step1: read status register but disable data value check
      print_now("Step1: read status register");
      data32bit := (others => 'X');
      xbfm_dword_id(bfm_inst_nbr,XBFM_CFGRD0,x"0000_0004",x"F",data32bit,bfm_trans_id);
      xbfm_wait_id(bfm_inst_nbr,bfm_trans_id,bfm_status,bfm_databuf);
      if bfm_status /= XBFM_SC then
         print_now("BFM ERROR in configure_msi(): completion status other than successful!");
         pass := false;
      end if;
      data32bit := bfm_databuf(0);
         
      if data32bit(20) = '0' then
         --error because no next capabilities implemented
         print_now("BFM ERROR in configure_msi(): function does not implement next capabilities structure thus MSI registers can not be programmmed.");
         pass := false;
      else
         -- step2: read capabilities pointer
         print_now("Step2: read capabilities pointer");
         data32bit := (others => 'X');
         xbfm_dword_id(bfm_inst_nbr,XBFM_CFGRD0,x"0000_0034",x"F",data32bit,bfm_trans_id);
         xbfm_wait_id(bfm_inst_nbr,bfm_trans_id,bfm_status,bfm_databuf);
         if bfm_status /= XBFM_SC then
            print_now("BFM ERROR in configure_msi(): completion status other than successful!");
            pass := false;
         end if;
         data32bit   := bfm_databuf(0);
         nextCapAddr := data32bit(7 downto 0);
         
         -- step3: read byte0 of registers pointed to by capabilities pointer
         print_now("Step3: read byte0 of registers pointed to by capabilities pointer");
         capID := (others => '0');
         while capID /= x"05" loop
            data32bit := (others => 'X');
            xbfm_dword_id(bfm_inst_nbr,XBFM_CFGRD0,x"000000" & nextCapAddr,x"F",data32bit,bfm_trans_id);
            xbfm_wait_id(bfm_inst_nbr,bfm_trans_id,bfm_status,bfm_databuf);
            if bfm_status /= XBFM_SC then
               print_now("BFM ERROR in configure_msi(): completion status other than successful!");
               pass := false;
            end if;
            data32bit := bfm_databuf(0);
            capID     := data32bit(7 downto 0);
            if capID /= x"05" then
               nextCapAddr := data32bit(15 downto 8);
            end if;
         end loop;
         
         -- step4: write MSI register set contents
         print_now("Step4: write MSI register set contents");
         -- check if 64bit addresses are used
         msi_addr_is_64bit := '0';
         data32bit := (others => 'X');
         xbfm_dword_id(bfm_inst_nbr,XBFM_CFGRD0,x"000000" & nextCapAddr,x"F",data32bit,bfm_trans_id);
         xbfm_wait_id(bfm_inst_nbr,bfm_trans_id,bfm_status,bfm_databuf);
         if bfm_status /= XBFM_SC then
            print_now("BFM ERROR in configure_msi(): completion status other than successful!");
            pass := false;
         end if;
         data32bit         := bfm_databuf(0);
         msi_addr_is_64bit := data32bit(23);
         
         -- program message address register to DW1 with 31:2=addr and 1:0=0
         -- set to zero as 64bit addresses shall not be used
         if msi_addr_is_64bit = '1' then
            -- function does support 64bit addresses
            temp_addr := x"000000" & nextCapAddr;
            temp_addr := std_logic_vector(unsigned(temp_addr)+ to_unsigned(4,32));
            xbfm_dword_id(bfm_inst_nbr,XBFM_CFGWR0,temp_addr,x"F",x"AAAA_0034",bfm_trans_id);
            xbfm_wait_id(bfm_inst_nbr,bfm_trans_id,bfm_status,bfm_databuf);
            if bfm_status /= XBFM_SC then
               print_now("BFM ERROR in configure_msi(): completion status other than successful!");
               pass := false;
            end if;
            temp_addr := x"000000" & nextCapAddr;
            temp_addr := std_logic_vector(unsigned(temp_addr)+ to_unsigned(8,32));
            xbfm_dword_id(bfm_inst_nbr,XBFM_CFGWR0,temp_addr,x"F",x"0000_0000",bfm_trans_id);
            xbfm_wait_id(bfm_inst_nbr,bfm_trans_id,bfm_status,bfm_databuf);
            if bfm_status /= XBFM_SC then
               print_now("BFM ERROR in configure_msi(): completion status other than successful!");
               pass := false;
            end if;
            
            -- program message data register to DW2 with 31:16=0 and 15:0=data
            temp_addr := x"000000" & nextCapAddr;
            temp_addr := std_logic_vector(unsigned(temp_addr)+ to_unsigned(12,32));
            xbfm_dword_id(bfm_inst_nbr,XBFM_CFGWR0,temp_addr,x"F",x"0000_2222",bfm_trans_id);
            xbfm_wait_id(bfm_inst_nbr,bfm_trans_id,bfm_status,bfm_databuf);
            if bfm_status /= XBFM_SC then
               print_now("BFM ERROR in configure_msi(): completion status other than successful!");
               pass := false;
            end if;
            
         else  
            -- fucntion does not support 64bit addresses
            temp_addr := x"000000" & nextCapAddr;
            temp_addr := std_logic_vector(unsigned(temp_addr)+ to_unsigned(4,32));
            xbfm_dword_id(bfm_inst_nbr,XBFM_CFGWR0,temp_addr,x"F",x"AAAA_0034",bfm_trans_id);
            xbfm_wait_id(bfm_inst_nbr,bfm_trans_id,bfm_status,bfm_databuf);
            if bfm_status /= XBFM_SC then
               print_now("BFM ERROR in configure_msi(): completion status other than successful!");
               pass := false;
            end if;
            
            -- program message data register to DW2 with 31:16=0 and 15:0=data
            temp_addr := x"000000" & nextCapAddr;
            temp_addr := std_logic_vector(unsigned(temp_addr)+ to_unsigned(8,32));
            xbfm_dword_id(bfm_inst_nbr,XBFM_CFGWR0,temp_addr,x"F",x"0000_2222",bfm_trans_id);
            xbfm_wait_id(bfm_inst_nbr,bfm_trans_id,bfm_status,bfm_databuf);
            if bfm_status /= XBFM_SC then
               print_now("BFM ERROR in configure_msi(): completion status other than successful!");
               pass := false;
            end if;
         end if;
         
         -- step5: program DW0 with nbr of MSI allowed and enable MSI
         print_now("Step5: program DW0 with nbr of MSI allowed and enable MSI");
         ------------------------------------------------------------------------------------------------
         -- if msi_allowed = Z program the value given by "MSI requested" to the register "MSI allowed"
         -- otherwise program value given by msi_allowed
         ------------------------------------------------------------------------------------------------
         -- read bit 19:17 of DW0 which contains nbr of MSI requested by function
         data32bit := (others => 'X');
         xbfm_dword_id(bfm_inst_nbr,XBFM_CFGRD0,x"000000" & nextCapAddr,x"F",data32bit,bfm_trans_id);
         xbfm_wait_id(bfm_inst_nbr,bfm_trans_id,bfm_status,bfm_databuf);
         if bfm_status /= XBFM_SC then
            print_now("BFM ERROR in configure_msi(): completion status other than successful!");
            pass := false;
         end if;
         data32bit := bfm_databuf(0);
            
         -- program nbr of MSI allowed to DW0 bit 22:20 and enable MSI bit 16=1
         if msi_allowed = "ZZZ" then
            data32bit(22 downto 20) := data32bit(19 downto 17);
         else
            data32bit(22 downto 20) := msi_allowed;
         end if;
         data32bit(16) := '1';
         xbfm_dword_id(bfm_inst_nbr,XBFM_CFGWR0,x"000000" & nextCapAddr,"1100",data32bit,bfm_trans_id);
         xbfm_wait_id(bfm_inst_nbr,bfm_trans_id,bfm_status,bfm_databuf);
         if bfm_status /= XBFM_SC then
            print_now("BFM ERROR in configure_msi(): completion status other than successful!");
            pass := false;
         end if;
      end if;
      success := pass;
   end procedure;

   procedure wait_on_irq_assert(
      bfm_inst_nbr : in  integer;
      irq_nbr      : in  integer range 3 downto 0
   ) is
   begin
      if irq_nbr = 0 then
         print_now("BFM: waiting on assert-INTA message");
         xbfm_wait_event(bfm_inst_nbr, XBFM_INTAA_RCVD);
      elsif irq_nbr = 1 then
         print_now("BFM: waiting on assert-INTB message");
         xbfm_wait_event(bfm_inst_nbr, XBFM_INTBA_RCVD);
      elsif irq_nbr = 2 then
         print_now("BFM: waiting on assert-INTC message");
         xbfm_wait_event(bfm_inst_nbr, XBFM_INTCA_RCVD);
      elsif irq_nbr = 3 then
         print_now("BFM: waiting on assert-INTD message");
         xbfm_wait_event(bfm_inst_nbr, XBFM_INTDA_RCVD);
      else
         assert false report "BFM ERROR in wait_on_irq_assert(): invalid value for interrupt number irq_nbr" severity failure;
      end if;
   end procedure wait_on_irq_assert;

   procedure wait_on_irq_deassert(
      bfm_inst_nbr : in  integer;
      irq_nbr      : in  integer range 3 downto 0
   ) is
   begin
      if irq_nbr = 0 then
         print_now("BFM: waiting on deassert-INTA message");
         xbfm_wait_event(bfm_inst_nbr, XBFM_INTAD_RCVD);
      elsif irq_nbr = 1 then
         print_now("BFM: waiting on deassert-INTB message");
         xbfm_wait_event(bfm_inst_nbr, XBFM_INTBD_RCVD);
      elsif irq_nbr = 2 then
         print_now("BFM: waiting on deassert-INTC message");
         xbfm_wait_event(bfm_inst_nbr, XBFM_INTCD_RCVD);
      elsif irq_nbr = 3 then
         print_now("BFM: waiting on deassert-INTD message");
         xbfm_wait_event(bfm_inst_nbr, XBFM_INTDD_RCVD);
      else
         assert false report "BFM ERROR in wait_on_irq_deassert(): invalid value for interrupt number irq_nbr" severity failure;
      end if;
   end procedure wait_on_irq_deassert;
end;
   
