-------------------------------------------------------------------------------
-- Title       : utilitiy package for 16z091-00 PCIe test bench
-- Project     : 16z091-00
-------------------------------------------------------------------------------
-- File        : utils_pkg.vhd
-- Author      : susanne.reinfelder@men.de
-- Organization: MEN Mikro Elektronik GmbH
-- Created     : 2012-08-22
-------------------------------------------------------------------------------
-- Simulator   : ModelSim PE 6.6 Revision 2010.01
-- Synthesis   : 
-------------------------------------------------------------------------------
-- Description : 
-- Contains useful procedures
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
use std.textio.all;
use ieee.std_logic_textio.all;

package utils_pkg is
   procedure write_label(
      constant use_time  : in string;
      constant string_in : in string;
      integer_in         : in integer
   );

   procedure wait_clk(
      signal   clk     : in std_logic;
      constant clk_cnt : in integer
   );

   procedure write_s_slvec(
         string_in : in  string;
         slvec_in  : in  std_logic_vector
      );
end utils_pkg;

package body utils_pkg is

   -----------------------------------------------------------------------------------------------------------------------------------------
   -- write_label:
   -- This procedure prints out a box to the transcript which is formated according to the length of the input string.
   -- use_time    : provide time resolution or "none" if no time shall be printed
   -- string_in   : input string that will be printed to the box
   -- integer_in  : integer value that will be printed to the box, omitted if set to 0
   -----------------------------------------------------------------------------------------------------------------------------------------
   procedure write_label(
      constant use_time  : in string;
      constant string_in : in string;
      integer_in         : in integer
   ) is
      variable wrLine     : line;
      variable cnt        : integer := 0;
      constant LABEL_C    : string  := "-";
      constant LABEL_STR  : string  := "--";
      constant LABEL_STR1 : string  := "---";
      constant CORNER_C   : string  := "+";
      constant HEADER_C   : string  := "=";
      constant LINE_LEN   : integer := 105;
      constant T_WIDTH    : integer := 15;
   begin
      write(wrLine, CORNER_C);
      for i in string_in'range loop
         write(wrLine, LABEL_C);
      end loop;
      
      if integer_in >= 0 then
         for i in 0 to 9 loop
            if (integer_in / (10**i)) /= 0 then cnt := i; end if;
         end loop;
         for j in 0 to cnt loop
            write(wrLine, label_c);
         end loop;
         write(wrLine, LABEL_STR1);
      else
         write(wrLine, LABEL_STR);
      end if;
      if use_time /= "none" then
         for i in 0 to T_WIDTH loop
            write(wrLine, LABEL_C);
         end loop;
      end if;
      write(wrLine, CORNER_C);
      writeline(output,wrLine);

      write(wrLine, string'("| "));
      if use_time /= "none" then
         if use_time = "fs" then
            write(wrLine,now, justified=>right,field =>T_WIDTH, unit=> fs );
         elsif use_time = "ps" then
            write(wrLine,now, justified=>right,field =>T_WIDTH, unit=> ps );
         elsif use_time = "us" then
            write(wrLine,now, justified=>right,field =>T_WIDTH, unit=> us );
         elsif use_time = "ms" then
            write(wrLine,now, justified=>right,field =>T_WIDTH, unit=> ms );
         else
            write(wrLine,now, justified=>right,field =>T_WIDTH, unit=> ns );
         end if;
         
         write(wrLine, string'(" "));
      end if;
      
      write(wrLine, string_in);
      if integer_in >= 0 then
         write(wrLine, string'(" "));
         write(wrLine, integer_in);
      end if;
      write(wrLine, string'(" |"));
      writeline(output,wrLine);

      write(wrLine, CORNER_C);
      for i in string_in'range loop
         write(wrLine, LABEL_C);
      end loop;
      
      if integer_in >= 0 then
         for i in 0 to 9 loop
            if (integer_in / (10**i)) /= 0 then cnt := i; end if;
         end loop;
         for j in 0 to cnt loop
            write(wrLine, label_c);
         end loop;
         write(wrLine, LABEL_STR1);
      else
         write(wrLine, LABEL_STR);
      end if;
      if use_time /= "none" then
         for i in 0 to T_WIDTH loop
            write(wrLine, LABEL_C);
         end loop;
      end if;
      write(wrLine, CORNER_C);
      writeline(output,wrLine);
   end procedure write_label;

   -----------------------------------------------------------------------------------------------------------------------------------------
   -- wait_clk:
   -- This procedure waits for the given amount of input clock cycles.
   -----------------------------------------------------------------------------------------------------------------------------------------
   procedure wait_clk(
      signal   clk     : in std_logic;
      constant clk_cnt : in integer
   ) is
   begin
      for i in 1 to clk_cnt loop
         wait until rising_edge(clk);
      end loop;
   end procedure wait_clk;

   -----------------------------------------------------------------------------------------------------------------------------------------
   -- write_s_slvec:
   -- This procedure prints std_logic_vector values in a way that collisions (e.g. 'X' or 'U') can be detected.
   -----------------------------------------------------------------------------------------------------------------------------------------
   procedure write_s_slvec(
      string_in : in  string;
      slvec_in  : in  std_logic_vector
   ) is
      variable l : line;
   begin
      write(l,string_in);
      write(l, std_ulogic_vector(slvec_in), justified => right, field => 10);
      writeline(output,l);
   end procedure write_s_slvec;
end;
