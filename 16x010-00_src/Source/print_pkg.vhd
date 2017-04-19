---------------------------------------------------------------
-- Title         : Print Package
-- Project       : none
---------------------------------------------------------------
-- File          : print_pkg.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 26/08/03
---------------------------------------------------------------
-- Simulator     : 
-- Synthesis     : 
---------------------------------------------------------------
-- Description :
--
-- several procedures and functions for screen printing
---------------------------------------------------------------
-- Hierarchy:
--
-- none
---------------------------------------------------------------
-- Copyright (C) 2001, MEN Mikroelektronik Nuernberg GmbH
--
--   All rights reserved. Reproduction in whole or part is 
--      prohibited without the written permission of the 
--                    copyright owner.           
---------------------------------------------------------------
--                         History                                    
---------------------------------------------------------------
-- $Revision: 1.9 $
--
-- $Log: print_pkg.vhd,v $
-- Revision 1.9  2015/11/12 14:57:26  AGeissler
-- R1: Missing now procedure with one string
-- M1: Overload existing print_now_s with sting instead of integer
--
-- Revision 1.8  2015/11/12 13:56:46  AGeissler
-- R1: Missing character to std_logic_vector conversion function
-- M1: Added functions std_logic_vector_to_char and char_to_std_logic_vector
-- R2: Missing now procedures
-- M2: Added for each procedure a equivalent one, with an additional time print
--
-- Revision 1.7  2015/11/12 11:04:50  AGeissler
-- R1: The user shall decide, when and if spaces are used
-- M1: Removed spaces from print procedures
--
-- Revision 1.6  2015/03/10 10:20:34  AGeissler
-- R1:   Improvement
-- M1.1: Added overloaded function for print_s_hb, print_s_hw, print_s_hl with std_logic_vector as parameter
-- M1.2: Replaced print_s_bit with print_s_std as a overloaded function with a std_logic as parameter
-- M1.3: Added short description for each function
--
-- Revision 1.5  2015/03/10 09:25:56  AGeissler
-- R1: Missing function to print an single bit
-- M1: Added function print_s_bit
--
-- Revision 1.4  2014/12/02 17:27:10  AGeissler
-- R1: Missing print functions for integer in hex with different sizes
-- M1: Added print functions print_s_hb, print_s_hw, print_s_hl
--
-- Revision 1.3  2014/11/24 11:26:00  AGeissler
-- R1: Missing function to print two strings for example text + time
--     (print_s("   it took ", time'image(tmp_time));)
-- M1: Added procedure print_s
--
-- Revision 1.2  2006/03/01 09:34:09  mmiehling
-- added print_now_s
--
-- Revision 1.1  2005/10/20 10:42:26  mmiehling
-- Initial Revision
--
-- Revision 1.1  2005/09/15 12:05:59  MMiehling
-- Initial Revision
--
-- Revision 1.2  2004/05/13 14:22:49  MMiehling
-- multifunction device support
--
-- Revision 1.1  2004/04/14 09:42:28  MMiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_textio.all;
USE ieee.numeric_std.all;

LIBRARY std;
USE std.textio.all;

PACKAGE print_pkg IS
   
   PROCEDURE print_mtest      (  source      : string;
                                 address     : std_logic_vector;
                                 is_data     : std_logic_vector;
                                 should_data : std_logic_vector;
                                 arg         : boolean);
   PROCEDURE print            (s: IN string);
   PROCEDURE print_s          (s: IN string; s2: IN string);
   PROCEDURE print_s_s        (s: IN string; s2: IN string; s3: IN string);
   PROCEDURE print_s_i        (s: IN string; s2: IN integer);
   PROCEDURE print_s_h        (s: IN string; s2: IN integer);
   PROCEDURE print_s_hb       (s: IN string; s2: IN integer);
   PROCEDURE print_s_hw       (s: IN string; s2: IN integer);
   PROCEDURE print_s_hl       (s: IN string; s2: IN integer);
   PROCEDURE print_s_hb       (s: IN string; s2: IN std_logic_vector(7 DOWNTO 0));
   PROCEDURE print_s_hw       (s: IN string; s2: IN std_logic_vector(15 DOWNTO 0));
   PROCEDURE print_s_hl       (s: IN string; s2: IN std_logic_vector(31 DOWNTO 0));
   PROCEDURE print_s_dl       (s: IN string; s2: IN std_logic_vector);
   PROCEDURE print_cycle      (  header      : string;
                                 address     : std_logic_vector;
                                 data        : std_logic_vector;
                                 sel_o_int   : std_logic_vector(3 DOWNTO 0);
                                 ende        : string);
   PROCEDURE print_s_std      (s: IN string; bit: IN std_logic);
   PROCEDURE print_s_std      (s: IN string; vec: IN std_logic_vector);
   PROCEDURE print_time       (s: IN string);
   PROCEDURE print_sum        (intext: IN string; mstr_err: IN integer; wb_err: IN integer);
   
   -- now procedures
   PROCEDURE print_now        (s: IN string);
   PROCEDURE print_now_s      (s: IN string; s2:  IN integer);
   PROCEDURE print_now_s      (s: IN string; s2:  IN string);
   PROCEDURE print_now_s_s    (s: IN string; s2:  IN string; s3: IN string);
   PROCEDURE print_now_s_i    (s: IN string; s2:  IN integer);
   PROCEDURE print_now_s_h    (s: IN string; s2:  IN integer);
   PROCEDURE print_now_s_hb   (s: IN string; s2:  IN integer);
   PROCEDURE print_now_s_hw   (s: IN string; s2:  IN integer);
   PROCEDURE print_now_s_hl   (s: IN string; s2:  IN integer);
   PROCEDURE print_now_s_hb   (s: IN string; s2:  IN std_logic_vector(7 DOWNTO 0));
   PROCEDURE print_now_s_hw   (s: IN string; s2:  IN std_logic_vector(15 DOWNTO 0));
   PROCEDURE print_now_s_hl   (s: IN string; s2:  IN std_logic_vector(31 DOWNTO 0));
   PROCEDURE print_now_s_dl   (s: IN string; s2:  IN std_logic_vector);
   PROCEDURE print_now_s_std  (s: IN string; bit: IN std_logic);
   PROCEDURE print_now_s_std  (s: IN string; vec: IN std_logic_vector);
   
   FUNCTION char_to_std_logic_vector(arg : character) RETURN std_logic_vector;
   FUNCTION std_logic_vector_to_char(arg : std_logic_vector(7 DOWNTO 0)) RETURN character;
   
END print_pkg;

PACKAGE BODY print_pkg IS
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a string with the current simulation time
   PROCEDURE print_time(s: IN string) IS
      VARIABLE l: line;
   BEGIN
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      WRITELINE(output,l);
      
   END print_time;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a string and a std_logic
   PROCEDURE print_s_std(s: IN string; bit: IN std_logic) IS
      VARIABLE l:  line;
      VARIABLE s2: string(1 TO 3);
   BEGIN
      WRITE(l, s);
      IF bit = '1' THEN
        s2 := "'1'";
      ELSE
        s2 := "'0'";
      END IF;
      WRITE(l, s2);
      WRITELINE(output,l);
   
   END print_s_std;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a string and a std_logic_vector as a hexadecimal number
   PROCEDURE print_s_std(s: IN string; vec: IN std_logic_vector) IS
      VARIABLE l: line;
   BEGIN
      WRITE(l, s);
      HWRITE(l, vec);
      WRITELINE(output,l);
   
   END print_s_std;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print wishbone information
   PROCEDURE  print_cycle( header   : string; 
                           address  : std_logic_vector; 
                           data     : std_logic_vector; 
                           sel_o_int: std_logic_vector(3 DOWNTO 0); 
                           ende     : string)  IS
      VARIABLE  l : line;
   BEGIN 
      WRITE(l,header);
      WRITE(l,string'("   "));
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l,string'("  ADR: "));
      HWRITE(l,address,justified=>left);
      WRITE(l,string'("  DATA: "));
      IF address(1) = '0' THEN
         CASE sel_o_int IS
            WHEN "1111" => HWRITE(l,data);
            WHEN "0001" => HWRITE(l,data(7 DOWNTO 0));
                           WRITE(l,string'("      "));
            WHEN "0010" => HWRITE(l,data(15 DOWNTO 8));
                           WRITE(l,string'("      "));
            WHEN "0100" => HWRITE(l,data(23 DOWNTO 16));
                           WRITE(l,string'("      "));
            WHEN "1000" => HWRITE(l,data(31 DOWNTO 24));
                           WRITE(l,string'("      "));
            WHEN "0011" => HWRITE(l,data(15 DOWNTO 0));
                           WRITE(l,string'("    "));
            WHEN "1100" => HWRITE(l,data(31 DOWNTO 16));
                           WRITE(l,string'("    "));
            WHEN OTHERS => ASSERT FALSE REPORT "PRINT_PKG Error: sel_o is undefined" SEVERITY error;
         END CASE;
      ELSE
         HWRITE(l,data);
      END IF;
      WRITE(l,string'("   "));
      WRITE(l,ende);
      WRITELINE(output,l);
   
   END  print_cycle;     
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print the result of a memory test
   PROCEDURE print_mtest(  source      : string; 
                           address     : std_logic_vector;
                           is_data     : std_logic_vector; 
                           should_data : std_logic_vector; 
                           arg         : boolean) IS
     VARIABLE tranx : line;
   BEGIN
      WRITE(tranx,source);
      WRITE(tranx,now, justified=>right,field =>10, unit=> ns );
      WRITE(tranx,string'(" Memory Test "));
      WRITE(tranx,string'("  ADR: "));
      HWRITE(tranx,address,justified=>left);
      IF NOT arg THEN
         WRITE(tranx,string'("     DATA should be: "));
         HWRITE(tranx,should_data);
         WRITE(tranx, string'("   is "));
      ELSE
         WRITE(tranx,string'("   DATA: "));
      END IF;
      HWRITE(tranx,is_data);
      WRITE(tranx,string'("   "));
      IF arg THEN
         WRITE(tranx,string'("OK"));
      ELSE
         WRITE(tranx,string'("ERROR!"));
      END IF;
      WRITELINE(output,tranx);
      
   END print_mtest;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print string
   PROCEDURE print(s: IN string) IS
      VARIABLE l: line;
   BEGIN
      WRITE(l, s);
      WRITELINE(output,l);
      
   END print;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print two strings (for example to print string and time = print_s("   it took ", time'image(tmp_time));
   PROCEDURE print_s(s: IN string;s2: IN string) IS
      VARIABLE l: line;
   BEGIN
      WRITE(l, s);
      WRITE(l, s2);
      WRITELINE(output,l);
      
   END print_s;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print three strings (for example to print string, value and type = print_s("   it took ", integer, "ns");
   PROCEDURE print_s_s(s: IN string; s2: IN string; s3: IN string) IS
      VARIABLE l: line;
   BEGIN
      WRITE(l, s);
      WRITE(l, s2);
      WRITE(l, s3);
      WRITELINE(output,l);
      
   END print_s_s;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a integer as a decimal number
   PROCEDURE print_s_i(s: IN string;s2: IN integer) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l, s);
      WRITE(l, s2);
      WRITELINE(output,l);
      
   END print_s_i;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print an integer as a hexadecimal number with 8 digits (equal to print_s_hl but is needed to be backward compatible)
   PROCEDURE print_s_h(s: IN string;s2: IN integer) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l, s);
      HWRITE(l, std_logic_vector(to_unsigned(s2,32)));
      WRITELINE(output,l);
      
   END print_s_h;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print an integer as a hexadecimal number with 2 digits
   PROCEDURE print_s_hb(s: IN string;s2: IN integer) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l, s);
      HWRITE(l, std_logic_vector(to_unsigned(s2,8)));
      WRITELINE(output,l);
      
   END print_s_hb;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print an integer as a hexadecimal number with 4 digits
   PROCEDURE print_s_hw(s: IN string;s2: IN integer) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l, s);
      HWRITE(l, std_logic_vector(to_unsigned(s2,16)));
      WRITELINE(output,l);
      
   END print_s_hw;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print an integer as a hexadecimal number with 8 digits
   PROCEDURE print_s_hl(s: IN string;s2: IN integer) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l, s);
      HWRITE(l, std_logic_vector(to_unsigned(s2,32)));
      WRITELINE(output,l);
      
   END print_s_hl;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a std_logic_vector as a hexadecimal number with 2 digits
   PROCEDURE print_s_hb(s: IN string;s2: IN std_logic_vector(7 DOWNTO 0)) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l, s);
      HWRITE(l, s2);
      WRITELINE(output,l);
      
   END print_s_hb;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a std_logic_vector as a hexadecimal number with 4 digits
   PROCEDURE print_s_hw(s: IN string;s2: IN std_logic_vector(15 DOWNTO 0)) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l, s);
      HWRITE(l, s2);
      WRITELINE(output,l);
      
   END print_s_hw;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a std_logic_vector as a hexadecimal number with 8 digits
   PROCEDURE print_s_hl(s: IN string;s2: IN std_logic_vector(31 DOWNTO 0)) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l, s);
      HWRITE(l, s2);
      WRITELINE(output,l);
      
   END print_s_hl;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a std_logic_vector as a decimal number
   PROCEDURE print_s_dl(s: IN string;s2: IN std_logic_vector) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l, s);
      WRITE(l, to_integer(unsigned(s2)));
      WRITELINE(output,l);
      
   END print_s_dl;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print the result of a test case
   PROCEDURE print_sum(intext: IN string; mstr_err: IN integer; wb_err: IN integer) IS 
      VARIABLE l: line;
   BEGIN
      WRITE(l, string'(" "));
      WRITELINE(output,l);
      IF mstr_err = 0 AND wb_err = 0 THEN
         WRITE(l, string'(" P A S S  "));
         WRITE(l, intext);
         WRITELINE(output,l);
      ELSE    
         WRITE(l, string'(" F A I L  "));
         WRITE(l, intext);
         WRITELINE(output,l);
         WRITE(l, string'("     Number of PCI errors:            "));
         WRITE(l, mstr_err);
         WRITELINE(output,l);
         WRITE(l, string'("     Number of WB errors:            "));
         WRITE(l, wb_err);
         WRITELINE(output,l);
      END IF;
      WRITE(l, string'("*************************************************************************************************************"));
      WRITELINE(output,l);
      
   END print_sum;
   
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a string with the current simulation time
   PROCEDURE print_now(s: IN string) IS
      VARIABLE l: line;
   BEGIN
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      WRITELINE(output,l);
      
   END print_now;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a string and an integer as decimal number withthe current simulation time
   PROCEDURE print_now_s(s: IN string; s2: IN integer) IS
      VARIABLE l: line;
   BEGIN
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      WRITE(l, s2);
      WRITELINE(output,l);
      
   END print_now_s;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print two strings (for example to print string and time = print_s("   it took ", time'image(tmp_time));
   PROCEDURE print_now_s(s: IN string;s2: IN string) IS
      VARIABLE l: line;
   BEGIN
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      WRITE(l, s2);
      WRITELINE(output,l);
      
   END print_now_s;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print three strings (for example to print string, value and type = print_s("   it took ", integer, "ns");
   PROCEDURE print_now_s_s(s: IN string; s2: IN string; s3: IN string) IS
      VARIABLE l: line;
   BEGIN
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      WRITE(l, s2);
      WRITE(l, s3);
      WRITELINE(output,l);
      
   END print_now_s_s;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a integer as a decimal number
   PROCEDURE print_now_s_i(s: IN string;s2: IN integer) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      WRITE(l, s2);
      WRITELINE(output,l);
      
   END print_now_s_i;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print an integer as a hexadecimal number with 8 digits (equal to print_s_hl but is needed to be backward compatible)
   PROCEDURE print_now_s_h(s: IN string;s2: IN integer) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      HWRITE(l, std_logic_vector(to_unsigned(s2,32)));
      WRITELINE(output,l);
      
   END print_now_s_h;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print an integer as a hexadecimal number with 2 digits
   PROCEDURE print_now_s_hb(s: IN string;s2: IN integer) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      HWRITE(l, std_logic_vector(to_unsigned(s2,8)));
      WRITELINE(output,l);
      
   END print_now_s_hb;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print an integer as a hexadecimal number with 4 digits
   PROCEDURE print_now_s_hw(s: IN string;s2: IN integer) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      HWRITE(l, std_logic_vector(to_unsigned(s2,16)));
      WRITELINE(output,l);
      
   END print_now_s_hw;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print an integer as a hexadecimal number with 8 digits
   PROCEDURE print_now_s_hl(s: IN string;s2: IN integer) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      HWRITE(l, std_logic_vector(to_unsigned(s2,32)));
      WRITELINE(output,l);
      
   END print_now_s_hl;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a std_logic_vector as a hexadecimal number with 2 digits
   PROCEDURE print_now_s_hb(s: IN string;s2: IN std_logic_vector(7 DOWNTO 0)) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      HWRITE(l, s2);
      WRITELINE(output,l);
      
   END print_now_s_hb;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a std_logic_vector as a hexadecimal number with 4 digits
   PROCEDURE print_now_s_hw(s: IN string;s2: IN std_logic_vector(15 DOWNTO 0)) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      HWRITE(l, s2);
      WRITELINE(output,l);
      
   END print_now_s_hw;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a std_logic_vector as a hexadecimal number with 8 digits
   PROCEDURE print_now_s_hl(s: IN string;s2: IN std_logic_vector(31 DOWNTO 0)) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      HWRITE(l, s2);
      WRITELINE(output,l);
      
   END print_now_s_hl;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a std_logic_vector as a decimal number
   PROCEDURE print_now_s_dl(s: IN string;s2: IN std_logic_vector) IS
      VARIABLE l: line;
   BEGIN 
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      WRITE(l, to_integer(unsigned(s2)));
      WRITELINE(output,l);
      
   END print_now_s_dl;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a string and a std_logic
   PROCEDURE print_now_s_std(s: IN string; bit: IN std_logic) IS
      VARIABLE l:  line;
      VARIABLE s2: string(1 TO 3);
   BEGIN
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      IF bit = '1' THEN
        s2 := "'1'";
      ELSE
        s2 := "'0'";
      END IF;
      WRITE(l, s2);
      WRITELINE(output,l);
   
   END print_now_s_std;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- print a string and a std_logic_vector as a hexadecimal number
   PROCEDURE print_now_s_std(s: IN string; vec: IN std_logic_vector) IS
      VARIABLE l: line;
   BEGIN
      WRITE(l,now, justified=>right,field =>10, unit=> ns );
      WRITE(l, string'("   "));
      WRITE(l, s);
      HWRITE(l, vec);
      WRITELINE(output,l);
   
   END print_now_s_std;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- function to convert character to std_logic_vector
   FUNCTION char_to_std_logic_vector( arg : character) RETURN std_logic_vector IS
   BEGIN
      RETURN std_logic_vector(to_unsigned(character'POS(arg), 8));
   END FUNCTION char_to_std_logic_vector;
   
   ----------------------------------------------------------------------------------------------------------------------------------------
   -- function to convert std_logic_vector to character
   FUNCTION std_logic_vector_to_char( arg : std_logic_vector(7 DOWNTO 0) ) RETURN character IS
   BEGIN
      CASE arg IS
   -- NUL,  SOH,  STX,  ETX,  EOT,  ENQ,  ACK,  BEL,
   -- BS,   HT,   LF,   VT,   FF,   CR,   SO,   SI,
      WHEN "00000000" =>
        RETURN NUL;
      WHEN "00000001" =>
        RETURN SOH;
      WHEN "00000010" =>
        RETURN STX;
      WHEN "00000011" =>
        RETURN ETX;
      WHEN "00000100" =>
        RETURN EOT;
      WHEN "00000101"=>
        RETURN ENQ;
      WHEN "00000110" =>
        RETURN ACK;
      WHEN "00000111" =>
        RETURN BEL;
      WHEN "00001000" =>
        RETURN BS;
      WHEN "00001001" =>
        RETURN HT;
      WHEN "00001010" =>
        RETURN LF;
      WHEN "00001011" =>
        RETURN VT;
      WHEN "00001100" =>
        RETURN FF;
      WHEN "00001101" =>
        RETURN CR;
      WHEN "00001110" =>
        RETURN SO;
      WHEN "00001111" =>
        RETURN SI;
      
      -- DLE,  DC1,  DC2,  DC3,  DC4,  NAK,  SYN,  ETB,
      -- CAN,  EM,   SUB,  ESC,  FSP,  GSP,  RSP,  USP, 
      WHEN "00010000" =>
        RETURN DLE;
      WHEN "00010001" =>
        RETURN DC1;
      WHEN "00010010" =>
        RETURN DC2;
      WHEN "00010011" =>
        RETURN DC3;
      WHEN "00010100" =>
        RETURN DC4;
      WHEN "00010101" =>
        RETURN NAK;
      WHEN "00010110" =>
        RETURN SYN;
      WHEN "00010111" =>
        RETURN ETB;
      WHEN "00011000" =>
        RETURN CAN;
      WHEN "00011001" =>
        RETURN EM;
      WHEN "00011010" =>
        RETURN SUB;
      WHEN "00011011" =>
        RETURN ESC;
      WHEN "00011100" =>
        RETURN FSP;
      WHEN "00011101" =>
        RETURN GSP;
      WHEN "00011110" =>
        RETURN RSP;
      WHEN "00011111" =>
        RETURN USP;
     
      -- ' ',  '!',  '"',  '#',  '$',  '%',  '&',  ''',
      -- '(',  ')',  '*',  '+',  ',',  '-',  '.',  '/',
      WHEN "00100000" =>
        RETURN ' ';
      WHEN "00100001" =>
        RETURN '!';
      WHEN "00100010" =>
        RETURN '"';              --"
      WHEN "00100011" =>
        RETURN '#';
      WHEN "00100100" =>
        RETURN '$';
      WHEN "00100101" =>
        RETURN '%';
      WHEN "00100110" =>
        RETURN '&';
      WHEN "00100111" =>
        RETURN ''';
      WHEN "00101000" =>
        RETURN '(';
      WHEN "00101001" =>
        RETURN ')';
      WHEN "00101010" =>
        RETURN '*';
      WHEN "00101011" =>
        RETURN '+';
      WHEN "00101100" =>
        RETURN ',';
      WHEN "00101101" =>
        RETURN '-';
      WHEN "00101110" =>
        RETURN '.';
      WHEN "00101111" =>
        RETURN '/';
        
      -- '0',  '1',  '2',  '3',  '4',  '5',  '6',  '7',
      -- '8',  '9',  ':',  ';',  '<',  '=',  '>',  '?',
      WHEN "00110000" =>
        RETURN '0';
      WHEN "00110001" =>
        RETURN '1';
      WHEN "00110010" =>
        RETURN '2';
      WHEN "00110011" =>
        RETURN '3';
      WHEN "00110100" =>
        RETURN '4';
      WHEN "00110101" =>
        RETURN '5';
      WHEN "00110110" =>
        RETURN '6';
      WHEN "00110111" =>
        RETURN '7';
      WHEN "00111000" =>
        RETURN '8';
      WHEN "00111001" =>
        RETURN '9';
      WHEN "00111010" =>
        RETURN ':';
      WHEN "00111011" =>
        RETURN ';';
      WHEN "00111100" =>
        RETURN '<';
      WHEN "00111101" =>
        RETURN '=';
      WHEN "00111110" =>
        RETURN '>';
      WHEN "00111111" =>
        RETURN '?';
        
      -- '@',  'A',  'B',  'C',  'D',  'E',  'F',  'G',
      -- 'H',  'I',  'J',  'K',  'L',  'M',  'N',  'O',
      WHEN "01000000" =>
        RETURN '@';
      WHEN "01000001" =>
        RETURN 'A';
      WHEN "01000010" =>
        RETURN 'B';
      WHEN "01000011" =>
        RETURN 'C';
      WHEN "01000100" =>
        RETURN 'D';
      WHEN "01000101" =>
        RETURN 'E';
      WHEN "01000110" =>
        RETURN 'F';
      WHEN "01000111" =>
        RETURN 'G';
      WHEN "01001000" =>
        RETURN 'H';
      WHEN "01001001" =>
        RETURN 'I';
      WHEN "01001010" =>
        RETURN 'J';
      WHEN "01001011" =>
        RETURN 'K';
      WHEN "01001100" =>
        RETURN 'L';
      WHEN "01001101" =>
        RETURN 'M';
      WHEN "01001110" =>
        RETURN 'N';
      WHEN "01001111" =>
        RETURN 'O';
        
      -- 'P',  'Q',  'R',  'S',  'T',  'U',  'V',  'W',
      -- 'X',  'Y',  'Z',  '[',  '\',  ']',  '^',  '_', 
      WHEN "01010000" =>
        RETURN 'P';
      WHEN "01010001" =>
        RETURN 'Q';
      WHEN "01010010" =>
        RETURN 'R';
      WHEN "01010011" =>
        RETURN 'S';
      WHEN "01010100" =>
        RETURN 'T';
      WHEN "01010101" =>
        RETURN 'U';
      WHEN "01010110" =>
        RETURN 'V';
      WHEN "01010111" =>
        RETURN 'W';
      WHEN "01011000" =>
        RETURN 'X';
      WHEN "01011001" =>
        RETURN 'Y';
      WHEN "01011010" =>
        RETURN 'Z';
      WHEN "01011011" =>
        RETURN '[';
      WHEN "01011100" =>
        RETURN '\';
      WHEN "01011101" =>
        RETURN ']';
      WHEN "01011110" =>
        RETURN '^';
      WHEN "01011111" =>
        RETURN '_';   
        
      -- '`',  'a',  'b',  'c',  'd',  'e',  'f',  'g',
      -- 'h',  'i',  'j',  'k',  'l',  'm',  'n',  'o',
      WHEN "01100000" =>
        RETURN '`';
      WHEN "01100001" =>
        RETURN 'a';
      WHEN "01100010" =>
        RETURN 'b';
      WHEN "01100011" =>
        RETURN 'c';
      WHEN "01100100" =>
        RETURN 'd';
      WHEN "01100101" =>
        RETURN 'e';
      WHEN "01100110" =>
        RETURN 'f';
      WHEN "01100111" =>
        RETURN 'g';
      WHEN "01101000" =>
        RETURN 'h';
      WHEN "01101001" =>
        RETURN 'i';
      WHEN "01101010" =>
        RETURN 'j';
      WHEN "01101011" =>
        RETURN 'k';
      WHEN "01101100" =>
        RETURN 'l';
      WHEN "01101101" =>
        RETURN 'm';
      WHEN "01101110" =>
        RETURN 'n';
      WHEN "01101111" =>
        RETURN 'o';
        
      -- 'p',  'q',  'r',  's',  't',  'u',  'v',  'w',
      -- 'x',  'y',  'z',  '{',  '|',  '}',  '~',  DEL,
      WHEN "01110000" =>
        RETURN 'p';
      WHEN "01110001" =>
        RETURN 'q';
      WHEN "01110010" =>
        RETURN 'r';
      WHEN "01110011" =>
        RETURN 's';
      WHEN "01110100" =>
        RETURN 't';
      WHEN "01110101" =>
        RETURN 'u';
      WHEN "01110110" =>
        RETURN 'v';
      WHEN "01110111" =>
        RETURN 'w';
      WHEN "01111000" =>
        RETURN 'x';
      WHEN "01111001" =>
        RETURN 'y';
      WHEN "01111010" =>
        RETURN 'z';
      WHEN "01111011" =>
        RETURN '{';
      WHEN "01111100" =>
        RETURN '|';
      WHEN "01111101" =>
        RETURN '}';
      WHEN "01111110" =>
        RETURN '~';
      WHEN "01111111" =>
        RETURN DEL;   
      WHEN OTHERS => 
        RETURN '0';
      END CASE;
      
      -- missing characters:
      --    C128,   C129,   C130,   C131,   C132,   C133,   C134,   C135,
      --    C136,   C137,   C138,   C139,   C140,   C141,   C142,   C143,
      --    C144,   C145,   C146,   C147,   C148,   C149,   C150,   C151,
      --    C152,   C153,   C154,   C155,   C156,   C157,   C158,   C159,
      --   ' ',  '¡', '¢', '£', '¤', '¥', '¦', '§',
      --   '¨',  '©', 'ª', '«', '¬', '­', '®', '¯',
      --   '°',  '±', '²', '³', '´', 'µ', '¶', '·',
      --   '¸', '¹', 'º',  '»', '¼', '½', '¾', '¿',  
      --   'À', 'Á', 'Â',  'Ã', 'Ä', 'Å', 'Æ', 'Ç',
      --   'È',  'É', 'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï',
      --   'Ð',  'Ñ', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö',  '×',
      --   'Ø',  'Ù', 'Ú', 'Û', 'Ü', 'Ý', 'Þ', 'ß',
      --   'à',  'á', 'â', 'ã', 'ä', 'å', 'æ', 'ç',
      --   'è',  'é', 'ê', 'ë', 'ì', 'í', 'î', 'ï',
      --   'ð',  'ñ', 'ò', 'ó', 'ô', 'õ', 'ö', '÷',
      --   'ø',  'ù', 'ú', 'û', 'ü', 'ý', 'þ', 'ÿ');
   
   END FUNCTION std_logic_vector_to_char;
   
END;