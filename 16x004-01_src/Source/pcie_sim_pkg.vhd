--------------------------------------------------------------------------------
-- Title       : simulation package for PCIe simulation model 16x004-01
-- Project     : 
--------------------------------------------------------------------------------
-- File        : pcie_sim_pkg.vhd
-- Author      : Susanne Reinfelder
-- Email       : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 2017-05-31
--------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6
-- Synthesis   : 
--------------------------------------------------------------------------------
-- Description : 
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
use work.print_pkg.all;
use work.utils_pkg.all;

use work.altpcietb_bfm_constants.all;
use work.altpcietb_bfm_log.all;
use work.altpcietb_bfm_req_intf.all;
use work.altpcietb_bfm_shmem.all;
use work.altpcietb_bfm_rdwr.all;
use work.altpcietb_bfm_configure.all;


package pcie_sim_pkg is

   type dword_vector is array (integer range <>) of std_logic_vector(31 downto 0);

-- +----------------------------------------------------------------------------
-- | constants
-- +----------------------------------------------------------------------------
   -----------------------------------------------------
   -- constants to use in terminal_out.tga(1 downto 0)
   -----------------------------------------------------
   constant IO_TRANSFER         : std_logic_vector(1 downto 0) := "00";
   constant MEM32_TRANSFER      : std_logic_vector(1 downto 0) := "01";
   constant CONFIG_TRANSFER     : std_logic_vector(1 downto 0) := "10";
   constant SETUP_CYCLE         : std_logic_vector(1 downto 0) := "11";

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
   constant ZERO_32BIT          : std_logic_vector(31 downto 0) := (others => '0');

-- +----------------------------------------------------------------------------
-- | functions
-- +----------------------------------------------------------------------------
   --! function that calculates the last byte enables of a transfer
   --! @param first_dw first enabled bytes of this transfer
   --! @param byte_count amount of bytes for this transfer
   --! @return last_dw(3 downto 0) last enabled bytes for this transfer
   function calc_last_dw(
      first_dw   : std_logic_vector(3 downto 0);
      byte_count : integer
   ) return std_logic_vector;                                          -- returns std_logic_vector(3 downto 0)

-- +----------------------------------------------------------------------------
-- | procedures
-- +----------------------------------------------------------------------------
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

   procedure set_bfm_memory(
      nbr_of_dw      : in integer;
      mem_addr       : in std_logic_vector(31 downto 0);
      start_data_val : in std_logic_vector(31 downto 0);
      data_inc       : in integer
   );

   procedure get_bfm_memory(
      nbr_of_dw      : in  integer;
      mem_addr       : in  std_logic_vector(31 downto 0);
      databuf_out    : out dword_vector(BFM_BUFFER_MAX_SIZE downto 0)
   );

   -----------------------------------------------
   -- single memory write to 32bit address space
   -----------------------------------------------
   procedure bfm_wr_mem32(
      bar_num    : in  natural;
      bar_offset : in  natural;
      data32     : in  std_logic_vector(31 downto 0);
      success    : out boolean
   );

   ----------------------------------------------
   -- burst memory write to 32bit address space
   ----------------------------------------------
   procedure bfm_wr_mem32(
      bar_num    : in  natural;
      bar_offset : in  natural;
      byte_count : in  integer;
      data32     : in  dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      success    : out boolean
   );

   procedure bfm_rd_mem32(
      bar_num    : in  natural;
      bar_offset : in  natural;
      byte_en    : in  std_logic_vector(3 downto 0);
      ref_data32 : in  std_logic_vector(31 downto 0);
      data32_out : out std_logic_vector(31 downto 0);
      success    : out boolean
   );

   procedure bfm_rd_mem32(
      bar_num    : in  natural;
      bar_offset : in  natural;
      byte_count : in  integer;
      ref_data32 : in  dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      data32_out : out dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      success    : out boolean
   );

   procedure bfm_wr_config(
      byte_en      : in  std_logic_vector(3 downto 0);
      pcie_addr    : in  std_logic_vector(31 downto 2);
      data32       : in  std_logic_vector(31 downto 0);
      success      : out boolean
   );

   procedure bfm_rd_config(
      byte_en      : in  std_logic_vector(3 downto 0);
      pcie_addr    : in  std_logic_vector(31 downto 2);
      ref_data32   : in  std_logic_vector(31 downto 0);
      data32_out   : out std_logic_vector(31 downto 0);
      success      : out boolean
   );

   procedure wait_on_irq_assert(
      irq_nbr : in  integer range 3 downto 0
   );

   procedure wait_on_irq_deassert(
      irq_nbr : in  integer range 3 downto 0
   );

   procedure bfm_configure_msi(
      constant msi_addr     : in  natural;                                      -- MSI address in shared memory
      msi_data              : in  std_logic_vector(15 downto 0);                -- contained in MSI message
      variable msi_expected : out std_logic_vector(31 downto 0);                -- expected data value for MSI
      success               : out boolean
   );

   procedure bfm_poll_msi(
      constant track_msi    : in natural;
      constant msi_addr     : in natural;
      constant msi_expected : in std_logic_vector(31 downto 0);
      constant txt_out      : in integer;
      success               : out boolean
   );

end package pcie_sim_pkg;

package body pcie_sim_pkg is

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
            print_now("BFM ERROR in " & caller_proc & "(): data read does not match given reference value - mismatch in byte0");
            write_s_slvec("BFM ERROR in " & caller_proc & "(): reference value[7:0] = ",ref_val(7 downto 0));
            write_s_slvec("BFM ERROR in " & caller_proc & "(): read value[7:0] = ",check_val(7 downto 0));
            pass := false;
         end if;
      end if;
      if byte_valid(1) = '1' then
         if ref_val(15 downto 8) /= check_val(15 downto 8) then
            print_now("BFM ERROR in " & caller_proc & "(): data read does not match given reference value - mismatch in byte1");
            write_s_slvec("BFM ERROR in " & caller_proc & "(): reference value[15:8] = ",ref_val(15 downto 8));
            write_s_slvec("BFM ERROR in " & caller_proc & "(): read value[15:8] = ",check_val(15 downto 8));
            pass := false;
         end if;
      end if;
      if byte_valid(2) = '1' then
         if ref_val(23 downto 16) /= check_val(23 downto 16) then
            print_now("BFM ERROR in " & caller_proc & "(): data read does not match given reference value - mismatch in byte2");
            write_s_slvec("BFM ERROR in " & caller_proc & "(): reference value[23:16] = ",ref_val(23 downto 16));
            write_s_slvec("BFM ERROR in " & caller_proc & "(): read value[23:16] = ",check_val(23 downto 16));
            pass := false;
         end if;
      end if;
      if byte_valid(3) = '1' then
         if ref_val(31 downto 24) /= check_val(31 downto 24) then
            print_now("BFM ERROR in " & caller_proc & "(): data read does not match given reference value - mismatch in byte3");
            write_s_slvec("BFM ERROR in " & caller_proc & "(): reference value[31:24] = ",ref_val(31 downto 24));
            write_s_slvec("BFM ERROR in " & caller_proc & "(): read value[31:24] = ",check_val(31 downto 24));
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
      print_now("BFM: initialize PCIe BFM");
      ebfm_cfg_rp_ep(
         bar_table          => BAR_TABLE_POINTER, -- defined in BFM shared memory
         ep_bus_num         => 1,
         ep_dev_num         => 1,
         --rp_max_rd_req_size => natural(max_payloadsize),
         rp_max_rd_req_size => max_payloadsize,
         display_ep_config  => 1, -- display config space after endpoint config setup
         addr_map_4GB_limit => 0  -- limit BAR assignment to 4GB address map
      );

      print_now("BFM: link is up");
   end procedure;

   procedure set_bfm_memory(
      nbr_of_dw      : in integer;
      mem_addr       : in std_logic_vector(31 downto 0);
      start_data_val : in std_logic_vector(31 downto 0);
      data_inc       : in integer
   ) is
      --variable bfm_databuf  : dword_vector(nbr_of_dw -1 downto 0);
      variable var_byte_len : integer;
      variable var_addr     : natural;
      variable var_data_buf : std_logic_vector(nbr_of_dw *32 -1 downto 0);
   begin
      --print_now("BFM: set BFM internal memory");
      --print_s_i("BFM: number of dwords = ",nbr_of_dw);
      --print_s_std("BFM: start address = ", mem_addr);
      --print_s_std("BFM: initial data value = ", start_data_val);
      --print_s_i("BFM: data value increment = ",data_inc);

      for i in 0 to nbr_of_dw -1 loop
         var_data_buf(i*32+31 downto i*32) := std_logic_vector(unsigned(start_data_val) + to_unsigned(i*data_inc,32));
      end loop;

      var_byte_len := natural(nbr_of_dw *4);
      var_addr     := to_integer(unsigned(mem_addr));

      -------------------------------------------------------------------------------------------
      -- Altera BFM doesn't distinguish between I/O and memory space concerning rd/wr functions
      -------------------------------------------------------------------------------------------
      shmem_write(
         addr => var_addr,
         data => var_data_buf,
         leng => var_byte_len
      );
   end procedure;

   procedure get_bfm_memory(
      nbr_of_dw      : in  integer;
      mem_addr       : in  std_logic_vector(31 downto 0);
      databuf_out    : out dword_vector(BFM_BUFFER_MAX_SIZE downto 0)
   ) is
      variable var_databuf_max : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable var_byte_len    : integer;
      variable var_addr        : natural;
      variable var_data_buf    : std_logic_vector(nbr_of_dw *32 -1 downto 0);
   begin
      if nbr_of_dw > BFM_BUFFER_MAX_SIZE then
         print_now("BFM ERROR in get_bfm_memory(): nbr_of_dw exceeds BFM_BUFFER_MAX_SIZE");
      else
         --print_now("BFM: get values from BFM internal memory");
         --print_s_i("BFM: number of dwords = ",nbr_of_dw);
         
         var_byte_len := natural(nbr_of_dw *4);
         var_addr     := to_integer(unsigned(mem_addr));
         var_data_buf  := shmem_read(addr => var_addr, leng => var_byte_len);

         for i in 0 to nbr_of_dw -1 loop
            var_databuf_max(i) := var_data_buf(i*32+31 downto i*32);
         end loop;
         databuf_out := var_databuf_max;

      end if;
   end procedure;

   procedure bfm_wr_mem32(
      bar_num    : in  natural;
      bar_offset : in  natural;
      data32     : in  std_logic_vector(31 downto 0);
      success    : out boolean
   ) is
      variable var_pass       : boolean := true;
      variable var_local_addr : natural := 0;
   begin
      var_pass := true;

      -----------------------------------------
      -- write user data to BFM shared memory
      -----------------------------------------
      var_local_addr := 0;
      shmem_write(
         addr => var_local_addr,
         data => data32,
         leng => 4                                                              -- length in bytes
      );

      ---------------------------
      -- transfer data via PCIe
      ---------------------------
      ebfm_barwr(
         bar_table   => BAR_TABLE_POINTER,
         bar_num     => bar_num,
         pcie_offset => bar_offset,
         lcladdr     => var_local_addr,                                         -- shmem address
         byte_len    => 4,
         tclass      => 0
      );

      report "WARNING (bfm_wr_mem32): return value for success is always true" severity warning;
      success := var_pass;
   end procedure;

   procedure bfm_wr_mem32(
      bar_num    : in  natural;
      bar_offset : in  natural;
      byte_count : in  integer;
      data32     : in  dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      success    : out boolean
   ) is
      --variable var_databuf : dword_vector(8*byte_count -1 downto 0);
      variable var_data_buf   : std_logic_vector(8*byte_count -1 downto 0);
      variable var_pass       : boolean := true;
      variable var_nbr_of_dw  : integer;
      variable var_local_addr : natural := 0;
   begin
      var_pass      := true;
      var_nbr_of_dw := byte_count * 4;

      -------------------
      -- copy user data
      -------------------
      for i in 0 to var_nbr_of_dw -1 loop
         var_data_buf(i*32+31 downto i*32) := data32(i);
      end loop;

      -----------------------------------------
      -- write user data to BFM shared memory
      -----------------------------------------
      var_local_addr := 0 + bar_offset;
      shmem_write(
         addr => var_local_addr,
         data => var_data_buf,
         leng => byte_count                                                     -- length in bytes
      );

      ---------------------------
      -- transfer data via PCIe
      ---------------------------
      ebfm_barwr(
         bar_table   => BAR_TABLE_POINTER,
         bar_num     => bar_num,
         pcie_offset => bar_offset,
         lcladdr     => var_local_addr,                                         -- shmem address
         byte_len    => byte_count,
         tclass      => 0
      );

      report "WARNING (bfm_wr_mem32): return value for success is always true" severity warning;
      success := var_pass;
   end procedure;

   procedure bfm_rd_mem32(
      bar_num    : in  natural;
      bar_offset : in  natural;
      byte_en    : in  std_logic_vector(3 downto 0);
      ref_data32 : in  std_logic_vector(31 downto 0);
      data32_out : out std_logic_vector(31 downto 0);
      success    : out boolean
   ) is
      variable var_byte_len   : natural := 0;
      variable var_pass       : boolean := true;
      variable var_databuf    : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable var_local_addr : natural := 0;
   begin
      var_pass   := true;
      data32_out := (others => '0');

      -- initialize data buffer with known default values
      for i in 0 to BFM_BUFFER_MAX_SIZE loop
         var_databuf(i) := x"CAFE_AFFE";
      end loop;

      if byte_en(0) = '1' then
         var_byte_len := var_byte_len +1;
      end if;
      if byte_en(1) = '1' then
         var_byte_len := var_byte_len +1;
      end if;
      if byte_en(2) = '1' then
         var_byte_len := var_byte_len +1;
      end if;
      if byte_en(3) = '1' then
         var_byte_len := var_byte_len +1;
      end if;
      print_s_i("var_byte_len = ", var_byte_len);
      
      var_local_addr := 0;
      ebfm_barrd_wait(
         bar_table   => BAR_TABLE_POINTER,
         bar_num     => bar_num,
         pcie_offset => bar_offset,
         lcladdr     => var_local_addr,
         byte_len    => var_byte_len,
         tclass      => 0
      );

      get_bfm_memory(
         nbr_of_dw   => 1,
         mem_addr    => std_logic_vector(to_unsigned(var_local_addr,32)), --x"0000_0000",
         databuf_out => var_databuf
      );

      -----------------------------------
      -- check if read value is correct
      -----------------------------------
      if ref_data32 = DONT_CHECK32 then
         print_now("BFM: checking of read value skipped on user command");
      else
         check_val(
            caller_proc => "bfm_rd_mem32",
            ref_val     => ref_data32,
            check_val   => var_databuf(0),
            byte_valid  => byte_en,
            check_ok    => var_pass
         );
      end if;
      data32_out := var_databuf(0);

      success := var_pass;
   end procedure;

   procedure bfm_rd_mem32(
      bar_num    : in  natural;
      bar_offset : in  natural;
      byte_count : in  integer;
      ref_data32 : in  dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      data32_out : out dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      success    : out boolean
   ) is
      variable var_databuf_max  : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable var_databuf  : std_logic_vector(byte_count *8 downto 0);
      variable var_pass     : boolean := true;
      variable var_pass_temp : boolean := true;
      variable var_nbr_of_dw : integer;
      variable var_local_addr : natural := 0;
      variable byte_en      : std_logic_vector(3 downto 0) := (others => '0');
      variable first_DW_en  : std_logic_vector(3 downto 0) := (others => '0');
      variable last_DW_en   : std_logic_vector(3 downto 0) := (others => '0');
   begin
      var_pass   := true;
      data32_out := (others => (others => '0'));

      -- initialize data buffer with known default values
      for i in 0 to BFM_BUFFER_MAX_SIZE loop
         var_databuf_max(i) := x"CAFE_AFFE";
      end loop;

      var_local_addr := 0;
      ebfm_barrd_wait(
         bar_table   => BAR_TABLE_POINTER,
         bar_num     => bar_num,
         pcie_offset => bar_offset,
         lcladdr     => var_local_addr,
         byte_len    => byte_count,
         tclass      => 0
      );

      var_databuf := shmem_read(addr => 0, leng => byte_count);

      var_nbr_of_dw := byte_count *4;
      for i in 0 to var_nbr_of_dw -1 loop
         var_databuf_max(i) := var_databuf(i*32+31 downto i*32);
      end loop;

      -----------------------------------
      -- check if read value is correct
      -----------------------------------
      for i in 0 to BFM_BUFFER_MAX_SIZE loop
         if ref_data32(i) = DONT_CHECK32 then
            print_now("BFM: checking of read value skipped on user command");
         else
            check_val(
               caller_proc => "bfm_rd_mem32",
               ref_val     => ref_data32(i),
               check_val   => var_databuf_max(i),
               byte_valid  => x"F",
               check_ok    => var_pass_temp
            );
         end if;
         var_pass := var_pass and var_pass_temp;
      end loop;

      data32_out  := var_databuf_max;

      success := var_pass;
   end procedure;

   procedure bfm_wr_config(
      byte_en      : in  std_logic_vector(3 downto 0);
      pcie_addr    : in  std_logic_vector(31 downto 2);
      data32       : in  std_logic_vector(31 downto 0);
      success      : out boolean
   ) is
      variable var_compl_status : std_logic_vector(2 downto 0);
      variable var_byte_len     : natural := 0;
      variable var_pass         : boolean := true;
   begin
      var_pass := true;
      
      if byte_en(0) = '1' then
         var_byte_len := var_byte_len +1;
      end if;
      if byte_en(1) = '1' then
         var_byte_len := var_byte_len +1;
      end if;
      if byte_en(2) = '1' then
         var_byte_len := var_byte_len +1;
      end if;
      if byte_en(3) = '1' then
         var_byte_len := var_byte_len +1;
      end if;

      ebfm_cfgwr_imm_wait(
         bus_num      => 1,
         dev_num      => 1,
         fnc_num      => 0,
         regb_ad      => to_integer(unsigned(pcie_addr)),
         regb_ln      => var_byte_len,
         imm_data     => data32,
         compl_status => var_compl_status
      );

      if var_compl_status = "000" then
         var_pass := true;                                                      -- successful completion
      elsif var_compl_status = "001" then
         print_now("ERROR(bfm_wr_config): return status for config write is unsupported request");
         var_pass := false;
      elsif var_compl_status = "010" then
         print_now("ERROR(bfm_wr_config): return status for config write is configuration request retry status");
         var_pass := false;
      elsif var_compl_status = "100" then
         print_now("ERROR(bfm_wr_config): return status for config write is completer abort");
         var_pass := false;
      end if;

      success := var_pass;
   end procedure;

   procedure bfm_rd_config(
      byte_en      : in  std_logic_vector(3 downto 0);
      pcie_addr    : in  std_logic_vector(31 downto 2);
      ref_data32   : in  std_logic_vector(31 downto 0);
      data32_out   : out std_logic_vector(31 downto 0);
      success      : out boolean
   ) is
      variable var_databuf      : std_logic_vector(31 downto 0);
      variable var_compl_status : std_logic_vector(2 downto 0);
      variable var_byte_len     : natural := 0;
      variable var_pass         : boolean := true;
   begin
      var_pass   := true;
      data32_out := (others => '0');

      if byte_en(0) = '1' then
         var_byte_len := var_byte_len +1;
      end if;
      if byte_en(1) = '1' then
         var_byte_len := var_byte_len +1;
      end if;
      if byte_en(2) = '1' then
         var_byte_len := var_byte_len +1;
      end if;
      if byte_en(3) = '1' then
         var_byte_len := var_byte_len +1;
      end if;
      
      ebfm_cfgrd_wait(
         bus_num => 1,
         dev_num => 1,
         fnc_num => 0,
         regb_ad => to_integer(unsigned(pcie_addr)),
         regb_ln => var_byte_len,
         lcladdr => 0,
         compl_status => var_compl_status
      );
      if var_compl_status = "000" then
         var_pass := true;                                                      -- successful completion
      elsif var_compl_status = "001" then
         print_now("ERROR(bfm_rd_config): return status for config read is unsupported request");
         var_pass := false;
      elsif var_compl_status = "010" then
         print_now("ERROR(bfm_rd_config): return status for config read is configuration request retry status");
         var_pass := false;
      elsif var_compl_status = "100" then
         print_now("ERROR(bfm_rd_config): return status for config read is completer abort");
         var_pass := false;
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
            check_val   => var_databuf,
            byte_valid  => byte_en,
            check_ok    => var_pass
         );
      end if;
      data32_out := var_databuf;

      success := var_pass;
   end procedure;

   procedure wait_on_irq_assert(
      irq_nbr : in  integer range 3 downto 0
   ) is
   begin
      report "ERROR: NO CONTENT IN PROCEDURE WAIT_ON_IRQ_ASSERT" severity error;
   end procedure;

   procedure wait_on_irq_deassert(
      irq_nbr : in  integer range 3 downto 0
   ) is
   begin
      report "ERROR: NO CONTENT IN PROCEDURE WAIT_ON_IRQ_DEASSERT" severity error;
   end procedure;

   procedure bfm_configure_msi(
      constant msi_addr     : in  natural;                                      -- MSI address in shared memory
      msi_data              : in  std_logic_vector(15 downto 0);                -- contained in MSI message
      variable msi_expected : out std_logic_vector(31 downto 0);                -- expected data value for MSI
      success               : out boolean
   ) is
      function check_compl_status(
         compl_status : in std_logic_vector(2 downto 0)
      ) return boolean is

         variable var_pass : boolean := false;
      begin
         if compl_status = "000" then
            var_pass := true;                                                      -- successful completion
         elsif compl_status = "001" then
            print_now("ERROR(bfm_configure_msi): return status for config read is unsupported request");
            var_pass := false;
         elsif compl_status = "010" then
            print_now("ERROR(bfm_configure_msi): return status for config read is configuration request retry status");
            var_pass := false;
         elsif compl_status = "100" then
            print_now("ERROR(bfm_configure_msi): return status for config read is completer abort");
            var_pass := false;
         end if;
         return var_pass;
      end function check_compl_status;

      constant MSI_CAP_ADDR  : natural := 80;                                   -- MSI capabilities register
      constant TRAFFIC_CLASS : std_logic_vector(2 downto 0) := "000";
      constant BUS_NUM       : natural := 1;
      constant DEV_NUM       : natural := 1;
      constant FUNC_NUM      : natural := 0;

      variable var_pass          : boolean := true;
      variable var_msi_ctrl_reg  : std_logic_vector(15 downto 0) := (others => '0');
      variable var_msi_is_64b    : std_logic_vector(0 downto 0) := (others => '0');
      variable var_is_multi_mess : std_logic_vector(2 downto 0) := (others => '0');
      variable var_multi_mess_en : std_logic_vector(2 downto 0) := (others => '0');
      variable var_msi_en        : std_logic := '0';
      variable var_compl_status  : std_logic_vector(2 downto 0) := (others => '0');
      variable var_msi_expected  : std_logic_vector(31 downto 0) := (others => '0');
      variable var_msi_nbr       : std_logic_vector(4 downto 0) := (others => '0');
      variable var_msi_addr      : std_logic_vector(31 downto 0) := (others => '0');
   begin 
      var_pass     := true;
      var_msi_addr := std_logic_vector(to_unsigned(msi_addr,32));

      -- read EP config space
      ebfm_cfgrd_wait(
         bus_num      => BUS_NUM,
         dev_num      => DEV_NUM,
         fnc_num      => FUNC_NUM,
         regb_ad      => MSI_CAP_ADDR,
         regb_ln      => 4,
         lcladdr      => msi_addr,
         compl_status => var_compl_status
      );
      var_pass := check_compl_status(var_compl_status);
         
      -- check if EP has 64bit MSI and multi message enabled
      var_msi_ctrl_reg  := shmem_read(msi_addr +2, 2);
      var_msi_is_64b    := var_msi_ctrl_reg(7 downto 7);
      var_is_multi_mess := var_msi_ctrl_reg(3 downto 1);
      var_multi_mess_en := var_is_multi_mess;

      -- enable msi
      var_msi_en := '1';

      -- write changed content back tp EP config space
      ebfm_cfgwr_imm_wait(
         bus_num => BUS_NUM,
         dev_num => DEV_NUM,
         fnc_num => FUNC_NUM,
         regb_ad => MSI_CAP_ADDR,
         regb_ln => 4,
         imm_data => (x"00" & var_msi_is_64b &
                     var_multi_mess_en &
                     var_is_multi_mess &
                     var_msi_en & x"0000"),
         compl_status => var_compl_status
      );
      var_pass := check_compl_status(var_compl_status);

      -- define expected msi message
      var_msi_nbr := "00001";
      if (var_multi_mess_en = "000") then
          var_msi_expected := x"0000" & msi_data(15 downto 0);
      elsif (var_multi_mess_en = "001") then
          var_msi_expected := x"0000" & msi_data(15 downto 1) & var_msi_nbr(0 downto 0);
      elsif (var_multi_mess_en = "010") then
          var_msi_expected := x"0000" & msi_data(15 downto 2) & var_msi_nbr(1 downto 0);
      elsif (var_multi_mess_en = "011") then
          var_msi_expected := x"0000" & msi_data(15 downto 3) & var_msi_nbr(2 downto 0);
      elsif (var_multi_mess_en = "100") then
          var_msi_expected := x"0000" & msi_data(15 downto 4) & var_msi_nbr(3 downto 0);
      elsif (var_multi_mess_en = "101") then
          var_msi_expected := x"0000" & msi_data(15 downto 5) & var_msi_nbr(4 downto 0);
      else
         print_now("ERROR(bfm_configure_msi): illegal value for multi message enable, can't configure MSI");
         var_pass := false;
      end if;
      msi_expected := var_msi_expected;

      -- program all msi capability registers (64 and 32 bit!)
      if var_msi_is_64b = "1" then -- 64bit addressing
         -- set lower address where MSI will be written
         ebfm_cfgwr_imm_wait(
            bus_num      => BUS_NUM,
            dev_num      => DEV_NUM,
            fnc_num      => FUNC_NUM,
            regb_ad      => (MSI_CAP_ADDR +4),
            regb_ln      => 4,
            imm_data     => var_msi_addr,
            compl_status => var_compl_status
         );
         var_pass := check_compl_status(var_compl_status);

         -- set upper address where MSI will be written
         ebfm_cfgwr_imm_wait(
            bus_num      => BUS_NUM,
            dev_num      => DEV_NUM,
            fnc_num      => FUNC_NUM,
            regb_ad      => (MSI_CAP_ADDR +4),
            regb_ln      => 4,
            imm_data     => x"0000_0000",
            compl_status => var_compl_status
         );
         var_pass := check_compl_status(var_compl_status);

         -- set which data value shall be writen when endpoint issues MSI
         ebfm_cfgwr_imm_wait(
            bus_num      => BUS_NUM,
            dev_num      => DEV_NUM,
            fnc_num      => FUNC_NUM,
            regb_ad      => (MSI_CAP_ADDR +12),
            regb_ln      => 4,
            imm_data     => x"0000" & msi_data,
            compl_status => var_compl_status
         );
         var_pass := check_compl_status(var_compl_status);

      else  -- 32bit addressing
         -- set lower address where MSI will be written
         ebfm_cfgwr_imm_wait(
            bus_num      => BUS_NUM,
            dev_num      => DEV_NUM,
            fnc_num      => FUNC_NUM,
            regb_ad      => (MSI_CAP_ADDR +4),
            regb_ln      => 4,
            imm_data     => var_msi_addr,
            compl_status => var_compl_status
         );
         var_pass := check_compl_status(var_compl_status);

         -- set which data value shall be writen when endpoint issues MSI
         ebfm_cfgwr_imm_wait(
            bus_num      => BUS_NUM,
            dev_num      => DEV_NUM,
            fnc_num      => FUNC_NUM,
            regb_ad      => (MSI_CAP_ADDR +8),
            regb_ln      => 4,
            imm_data     => x"0000" & msi_data,
            compl_status => var_compl_status
         );
         var_pass := check_compl_status(var_compl_status);

      end if;

      -- clear MSI location in shared memory
      shmem_write(msi_addr, x"FADE_FADE", 4);

      success := var_pass;
   end procedure;
    
   procedure bfm_poll_msi(
      constant track_msi    : in natural;
      constant msi_addr     : in natural;
      constant msi_expected : in std_logic_vector(31 downto 0);
      constant txt_out      : in integer;
      success               : out boolean
   ) is
      constant POLLING_TIMEOUT  : natural :=  2048;
      variable var_pass         : boolean := true;
      variable var_loop_val     : natural range 1 downto 0 := 1;
      variable var_poll_timer   : natural := 0;
      variable var_msi_received : std_logic_vector(15 downto 0) := (others => '0');
   begin
      var_pass := true;

      track_msi_loop : for i in 0 to track_msi loop
         if txt_out >=2 then print_s_i("bfm_poll_msi(): tracking MSI number: ", i); end if;

         var_loop_val := 1;
         while var_loop_val = 1 loop
            --wait for 10 ns;
            wait for 10 us;
            var_poll_timer := var_poll_timer +1;

--TODO: remove
print("");
print("+------------------------------------------------------------------+");
print_now("*** DEBUG - bfm_poll_msi() ***");
print_s_hl("msi_addr = ", std_logic_vector(to_unsigned(msi_addr,32)));
            var_msi_received := (others => '0');
print_s_hw("var_msi_received = ", var_msi_received);
print_now("*** before shmemread");
            var_msi_received := shmem_read(msi_addr, 2);
print_now("*** after shmemread");
print_s_hw("var_msi_received = ", var_msi_received);
print_s_hl("msi_expected(31 downto 0) = ", msi_expected);
print_s_hw("msi_expected(15 downto 0) = ", msi_expected(15 downto 0));
print("+------------------------------------------------------------------+");
print("");

            if var_msi_received = msi_expected(15 downto 0) then
               -- clear shared memory location and exit polling loop
--TODO: remove
print_now("bfm_poll_msi(): received correct data value, now clearing shared memory...");
               shmem_write(msi_addr, x"FADE_FADE", 4);
               var_loop_val := 0;
            end if;

            -- manage internal timeout
            if var_poll_timer >= POLLING_TIMEOUT then
               var_pass := false;
               if txt_out >= 1 then
                  print_now("ERROR(bfm_poll_msi): no MSI captured within timeout time");
               end if;
               success := var_pass;
--TODO: remove
report "*** DEBUG *** STOP DUE TO POLLING TIMER TIMEOUT" severity failure;
               exit track_msi_loop;
            end if;
         end loop;
      end loop track_msi_loop;

      success := var_pass;
   end procedure;

end package body pcie_sim_pkg;


