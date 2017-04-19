-------------------------------------------------------------------------------
-- Title       : PCIe simulation model
-- Project     : 16z091-
-------------------------------------------------------------------------------
-- File        : pcie_x1_sim.vhd
-- Author      : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik GmbH
-- Created     : 2012-10-02
-------------------------------------------------------------------------------
-- Simulator   : 
-- Synthesis   : 
-------------------------------------------------------------------------------
-- Description : 
-- PCIe simulation model for x1 configuration
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
use work.utils_pkg.all;
use work.print_pkg.all;
use work.pcie_x1_pkg.all;
use work.terminal_pkg.all;

library pciebfm_lib;
use pciebfm_lib.pkg_plda_fio.all;
use pciebfm_lib.pkg_xbfm.all;

entity pcie_x1_sim is
   generic(
      INSTANCE_NBR   : integer range  3 downto  0 :=  0;                        -- nbr of BFM instance
      BFM_IO_SIZE    : integer range 24 downto 12 := 16;                        -- 12 <= x <= 24
      BFM_MEM32_SIZE : integer range 24 downto 12 := 16;                        -- 12 <= x <= 24
      BFM_MEM64_SIZE : integer range 24 downto 12 := 16                         -- 12 <= x <= 24
   );
   port(
      clk       : in  std_logic;
      rst       : in  std_logic;
    
      -- BFM signals
      clk125    : in  std_logic;
      clk250    : in  std_logic;
      rstn      : in  std_logic;
      bfm_tx_0  : in  std_logic;
      bfm_rx_0  : out std_logic;
    
      term_out : in  terminal_out_type;
      term_in  : out terminal_in_type
   );
end entity pcie_x1_sim;

architecture pcie_x1_sim_arch of pcie_x1_sim is

begin
   print_s_i("DEBUG(1): BFM_IO_SIZE = ", BFM_IO_SIZE);
   assert BFM_IO_SIZE >= 12 report "ERROR (pcie_x1_sim): value for generic BFM_IO_SIZE is too small" severity failure;
   assert BFM_IO_SIZE <= 24 report "ERROR (pcie_x1_sim): value for generic BFM_IO_SIZE is too big" severity failure;
   assert BFM_MEM32_SIZE >= 12 report "ERROR (pcie_x1_sim): value for generic BFM_MEM32_SIZE is too small" severity failure;
   assert BFM_MEM32_SIZE <= 24 report "ERROR (pcie_x1_sim): value for generic BFM_MEM32_SIZE is too big" severity failure;
   assert BFM_MEM64_SIZE >= 12 report "ERROR (pcie_x1_sim): value for generic BFM_MEM64_SIZE is too small" severity failure;
   assert BFM_MEM64_SIZE <= 24 report "ERROR (pcie_x1_sim): value for generic BFM_MEM64_SIZE is too big" severity failure;
   bfm_inst : entity pciebfm_lib.pldawrap_link
      generic map (
         BFM_ID      => INSTANCE_NBR,
         BFM_TYPE    => '0',
         BFM_LANES   => 1,
         BFM_WIDTH   => 1,
         IO_SIZE     => BFM_IO_SIZE,
         MEM32_SIZE  => BFM_MEM32_SIZE,
         MEM64_SIZE  => BFM_MEM64_SIZE
      )
      port map (
         clk125      => clk125,
         clk250      => clk250,
         rstn        => rstn,

         tx_rate     => open,
         
         tx_in0(0)   => bfm_tx_0,
         tx_in1(0)   => '0',
         tx_in2(0)   => '0',
         tx_in3(0)   => '0',
         tx_in4(0)   => '0',
         tx_in5(0)   => '0',
         tx_in6(0)   => '0',
         tx_in7(0)   => '0',
         tx_val      => x"00",  -- unused in serial mode (BFM_WIDTH = 1)
         
         rx_out0(0)  => bfm_rx_0,
         rx_val      => open,  -- unused in serial mode (BFM_WIDTH = 1)

         chk_txval   => open,
         chk_txdata  => open,
         chk_txdatak => open,
         chk_rxval   => open,
         chk_rxdata  => open,
         chk_rxdatak => open,
         chk_ltssm   => open
      );

   main : process
      variable first_be_en     : std_logic_vector(3 downto 0);
      variable byte_count      : integer;
      variable addr32_int      : std_logic_vector(31 downto 0);
      variable bfm_id          : integer := 0;
      variable success_int     : boolean := false;
      variable return_data32   : std_logic_vector(31 downto 0) := (others => '0');
      variable return_data_vec : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable data_vec        : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
      variable temp_inst_nbr   : std_logic_vector(1 downto 0);
   begin
      -- reset all
      term_in.busy <= '1';
      term_in.done <= true;

      wait until rst = '0';
      wait_clk(clk,1);

      if term_out.start /= true then
         wait until term_out.start = true;
      end if;

      loop
         wait on term_out.start;
         term_in.busy <= '1';

         ---------------------------
         -- check for wrong values
         ---------------------------
         temp_inst_nbr := std_logic_vector(to_unsigned(INSTANCE_NBR,2));
         if temp_inst_nbr /= term_out.tga(3 downto 2) then
            assert false report "ERROR (pcie_x1_sim): instance number in term_out.tga(3 downto 2) does not match INSTANCE_NBR for this component" severity failure;
         end if;
         assert term_out.typ <= 2 report "ERROR (pcie_x1_sim): illegal value for signal term_out.typ" severity failure;
         assert term_out.wr <= 2 report "ERROR (pcie_x1_sim): illegal value for signal term_out.wr" severity failure;
         if term_out.typ = 0 then
            assert term_out.numb = 1 report "ERROR (pcie_x1_sim): illegal combination for signals term_out.typ and term_out.numb => bytewise burst is impossible" severity failure;
         end if;

         if term_out.typ = 1 then
            assert term_out.numb = 1 report "ERROR (pcie_x1_sim): illegal combination for signals term_out.typ and term_out.numb => wordwise burst is impossible" severity failure;
         end if;
         assert term_out.numb <= 1024 report "ERROR (pcie_x1_sim): maximum value for signal term_out.numb is 1024" severity failure;

         ----------------------------
         -- set values for this run
         ----------------------------
         addr32_int := term_out.adr(31 downto 2) & "00";
         byte_count := term_out.numb *4;
         bfm_id     := to_integer(unsigned(term_out.tga(3 downto 2)));

         if term_out.typ = 0 then                                               -- byte
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
            if term_out.adr(1) = '0' then
               first_be_en := "0011";
            else
               first_be_en := "1100";
            end if;
         else                                                                   -- long word
            first_be_en := x"F";
         end if;

         for i in 0 to term_out.numb -1 loop
            data_vec(i)        := std_logic_vector(unsigned(term_out.dat) + to_unsigned(i,32));
            return_data_vec(i) := (others => '0');
            wait for 0 ns;
         end loop;

         if term_out.wr = 0 then                                                -- read
            if term_out.tga(1 downto 0) = IO_TRANSFER then                      -- I/O 
               bfm_rd_io(
                  bfm_inst_nbr  => bfm_id,
                  byte_en       => first_be_en,
                  pcie_addr     => addr32_int(31 downto 2),
                  ref_data32    => term_out.dat,
                  wait_end      => true,
                  data32_out    => return_data32,
                  success       => success_int
               );
            elsif term_out.tga(1 downto 0) = MEM32_TRANSFER then                -- memory
               if term_out.numb = 1 then
                  bfm_rd_mem32(
                     bfm_inst_nbr   => bfm_id,
                     byte_en        => first_be_en,
                     pcie_addr      => addr32_int(31 downto 2),
                     ref_data32     => term_out.dat,
                     wait_end       => true,
                     data32_out     => return_data32,
                     success        => success_int
                  );
               else
                  bfm_rd_mem32(
                     bfm_inst_nbr => bfm_id,
                     byte_count   => byte_count,
                     pcie_addr    => addr32_int,
                     ref_data32   => data_vec,
                     t_class      => "000",
                     attributes   => "00",
                     wait_end     => true,
                     data32_out   => return_data_vec,
                     success      => success_int
                  );
               end if;
            elsif term_out.tga(1 downto 0) = CONFIG_TRANSFER then               -- configuration type 0 
               bfm_rd_config(
                  bfm_inst_nbr => bfm_id,
                  byte_en      => first_be_en,
                  pcie_addr    => addr32_int(31 downto 2),
                  ref_data32   => term_out.dat,
                  wait_end     => true,
                  data32_out   => return_data32,
                  success      => success_int
               );
            else
               assert false report "ERROR (pcie_x1_sim): term_out.tga(1 downto 0) = 11 is reserved" severity failure;
            end if;
         elsif term_out.wr = 1 then                                             -- write
            if term_out.tga(1 downto 0) = IO_TRANSFER then                      -- I/O
               bfm_wr_io(
                  bfm_inst_nbr => bfm_id,
                  byte_en      => first_be_en,
                  pcie_addr    => addr32_int(31 downto 2),
                  data32       => term_out.dat,
                  wait_end     => true,
                  success      => success_int
               );
               
            elsif term_out.tga(1 downto 0) = MEM32_TRANSFER then                -- memory
               if term_out.numb = 1 then
                  bfm_wr_mem32(
                     bfm_inst_nbr => bfm_id,
                     byte_en      => first_be_en,
                     pcie_addr    => addr32_int,
                     data32       => term_out.dat,
                     wait_end     => true,
                     success      => success_int
                  );
               else
                  bfm_wr_mem32(
                     bfm_inst_nbr => bfm_id,
                     byte_count   => byte_count,
                     pcie_addr    => addr32_int,
                     data32       => data_vec,
                     t_class      => "000",
                     attributes   => "00",
                     wait_end     => true,
                     success      => success_int
                  );
               end if;
            elsif term_out.tga(1 downto 0) = CONFIG_TRANSFER then               -- configuration type 0
               bfm_wr_config(
                  bfm_inst_nbr => bfm_id,
                  byte_en      => first_be_en,
                  pcie_addr    => addr32_int(31 downto 2),
                  data32       => term_out.dat,
                  wait_end     => true,
                  success      => success_int
               );
            else
               assert false report "ERROR (pcie_x1_sim): term_out.tga(1 downto 0) = 11 is reserved" severity failure;
            end if;
         else                                                                   -- wait
            wait_clk(clk,term_out.numb);
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
end architecture pcie_x1_sim_arch;
