---------------------------------------------------------------
-- Title         : vme Simulation Model Package
-- Project       : none
---------------------------------------------------------------
-- File          : vme_sim_pack.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 03/02/03
---------------------------------------------------------------
-- Simulator     : Modelsim
-- Synthesis     : no
---------------------------------------------------------------
-- Description :
--
---------------------------------------------------------------
-- Hierarchy:
--
-- 
---------------------------------------------------------------
-- Copyright (C) 2001, MEN Mikroelektronik Nuernberg GmbH
--
--   All rights reserved. Reproduction in whole or part is 
--      prohibited without the written permission of the 
--                    copyright owner.           
---------------------------------------------------------------
--                         History                                    
---------------------------------------------------------------
-- $Revision: 1.2 $
--
-- $Log: vme_sim_pack.vhd,v $
-- Revision 1.2  2013/04/18 15:11:14  MMiehling
-- added vme_mstr_read64
--
-- Revision 1.1  2012/03/29 10:28:48  MMiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee, std;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.standard.ALL;
USE std.textio.all;
USE ieee.std_logic_textio.all;
USE work.print_pkg.all;


PACKAGE vme_sim_pack IS

--------------------------------TYPES-------------------------------------------

   CONSTANT time_4      : time:= 35 ns;
   CONSTANT time_5      : time:= 40 ns;
   CONSTANT time_28     : time:= 30 ns;
   CONSTANT time_27     : time:= 25 ns;
   CONSTANT time_26     : time:= 5 ns; -- usually 0ns
   CONSTANT time_19     : time:= 40 ns;
   CONSTANT time_8      : time:= 35 ns;
   CONSTANT time_12     : time:= 35 ns;
   CONSTANT time_23     : time:= 10 ns;
   CONSTANT time_11     : time:= 40 ns;
   
   CONSTANT sl_base_A16 	: std_logic_vector(3 DOWNTO 0):= "0001";	-- vme base address for A16 slave = 0x1000
   CONSTANT sl_base_A24 	: std_logic_vector(3 DOWNTO 0):= "0010";	-- vme base address for A24 slave = 0x20_0000
   CONSTANT sl_base_CRCSR : std_logic_vector(3 DOWNTO 0):= "0100";	-- vme base address for CR/CSR slave = 0x40_0000
   CONSTANT sl_base_A32 	: std_logic_vector(3 DOWNTO 0):= "0011";	-- vme base address for A32 slave = 0x3000_0000
      
   -- Address Modifiers
   CONSTANT AM_A24_SUPER_BLT        : std_logic_vector(5 DOWNTO 0):="111111";
   CONSTANT AM_A24_SUPER_PROG       : std_logic_vector(5 DOWNTO 0):="111110";
   CONSTANT AM_A24_SUPER_DAT        : std_logic_vector(5 DOWNTO 0):="111101";
   CONSTANT AM_A24_SUPER_MBLT       : std_logic_vector(5 DOWNTO 0):="111100";
   CONSTANT AM_A24_NONPRIV_BLT      : std_logic_vector(5 DOWNTO 0):="111011";
   CONSTANT AM_A24_NONPRIV_PROG     : std_logic_vector(5 DOWNTO 0):="111010";
   CONSTANT AM_A24_NONPRIV_DAT      : std_logic_vector(5 DOWNTO 0):="111001";
   CONSTANT AM_A24_NONPRIV_MBLT     : std_logic_vector(5 DOWNTO 0):="111000";       
      
   CONSTANT AM_CRCSR                : std_logic_vector(5 DOWNTO 0):="101111";
   CONSTANT AM_A16_SUPER            : std_logic_vector(5 DOWNTO 0):="101101";
   CONSTANT AM_A16_NONPRIV          : std_logic_vector(5 DOWNTO 0):="101001";

   CONSTANT AM_A32_SUPER_BLT        : std_logic_vector(5 DOWNTO 0):="001111";
   CONSTANT AM_A32_SUPER_PROG       : std_logic_vector(5 DOWNTO 0):="001110";
   CONSTANT AM_A32_SUPER_DAT        : std_logic_vector(5 DOWNTO 0):="001101";
   CONSTANT AM_A32_SUPER_MBLT       : std_logic_vector(5 DOWNTO 0):="001100";
   CONSTANT AM_A32_NONPRIV_BLT      : std_logic_vector(5 DOWNTO 0):="001011";
   CONSTANT AM_A32_NONPRIV_PROG     : std_logic_vector(5 DOWNTO 0):="001010";
   CONSTANT AM_A32_NONPRIV_DAT      : std_logic_vector(5 DOWNTO 0):="001001";
   CONSTANT AM_A32_NONPRIV_MBLT     : std_logic_vector(5 DOWNTO 0):="001000";       
      
  
   SUBTYPE adr_type2 IS string(8 DOWNTO 1);
   SUBTYPE adr_type IS std_logic_vector(31 DOWNTO 0);
   SUBTYPE vec4 IS std_logic_vector(3 DOWNTO 0);
   SUBTYPE am_type IS std_logic_vector(5 DOWNTO 0);
   SUBTYPE data_type IS std_logic_vector(31 DOWNTO 0);
   SUBTYPE data_type8 IS string(8 DOWNTO 1);
   SUBTYPE data_type4 IS string(4 DOWNTO 1);
   SUBTYPE data_type2 IS string(2 DOWNTO 1);


   TYPE vme_mon_out_type IS record
      err            : integer;
   END record;

   ------------------------------------------------------------------------------------------------------------------
   -- vme_sim_mstr
   ------------------------------------------------------------------------------------------------------------------
   TYPE mstr_in_type IS record
      data           : std_logic_vector(31 DOWNTO 0);
      addr           : std_logic_vector(31 DOWNTO 0);
      dtackn         : std_logic;
      berrn          : std_logic;
      iackin         : std_logic;
      bg3n_in        : std_logic;
      bbsyn          : std_logic;
      asn            : std_logic;
   END record;
   
   TYPE mstr_out_type IS record
      sysresn        : std_logic;
      asn            : std_logic;
      dsan           : std_logic;
      dsbn           : std_logic;
      writen         : std_logic;
      addr           : std_logic_vector(31 DOWNTO 0);
      data           : std_logic_vector(31 DOWNTO 0);
      am             : std_logic_vector(5 DOWNTO 0);
      iackn          : std_logic;
      iackout        : std_logic;
      brn            : std_logic_vector(3 DOWNTO 0);
      bbsyn          : std_logic;
      berrn          : std_logic;
   END record;
   
   PROCEDURE vme_mstr_init (
      SIGNAL   mstr_out       : OUT mstr_out_type
      );

   PROCEDURE vme_mstr_write (
      SIGNAL   mstr_out       : OUT mstr_out_type;
      SIGNAL   mstr_in        : IN mstr_in_type;
               adress         : std_logic_vector(31 DOWNTO 0);
               data           : std_logic_vector(31 DOWNTO 0);
               mode           : character;
               txt_out        : integer;  -- 0=quiet, 1=only errors, 2=all
               number         : integer;
               tga            : std_logic_vector(5 DOWNTO 0)
      
      );

   PROCEDURE vme_mstr_read (
      SIGNAL   mstr_out       : OUT mstr_out_type;
      SIGNAL   mstr_in        : IN mstr_in_type;
               adress         : std_logic_vector(31 DOWNTO 0);
               ex_data        : std_logic_vector(31 DOWNTO 0);
               in_data        : OUT std_logic_vector(31 DOWNTO 0);
               mode           : character;
               txt_out        : integer;  -- 0=quiet, 1=only errors, 2=all
               number         : integer;
               tga            : std_logic_vector(5 DOWNTO 0);
               err            : OUT integer
      ) ;
   
   PROCEDURE vme_mstr_write64 (
      SIGNAL   mstr_out       : OUT mstr_out_type;
      SIGNAL   mstr_in        : IN mstr_in_type;
               adress         : std_logic_vector(31 DOWNTO 0);
               data           : std_logic_vector(31 DOWNTO 0);
               mode           : character;
               txt_out        : integer;  -- 0=quiet, 1=only errors, 2=all
               number         : integer;
               tga            : std_logic_vector(5 DOWNTO 0)
      
      );

   PROCEDURE vme_mstr_read64 (
      SIGNAL   mstr_out       : OUT mstr_out_type;
      SIGNAL   mstr_in        : IN mstr_in_type;
               adress         : std_logic_vector(31 DOWNTO 0);
               ex_data        : std_logic_vector(31 DOWNTO 0);
               in_data        : OUT std_logic_vector(31 DOWNTO 0);
               mode           : character;
               txt_out        : integer;  -- 0=quiet, 1=only errors, 2=all
               number         : integer;
               tga            : std_logic_vector(5 DOWNTO 0);
               err            : OUT integer
      ) ;
   


   ------------------------------------------------------------------------------------------------------------------
   -- vme_sim_slv
   ------------------------------------------------------------------------------------------------------------------
   TYPE vme_slv_in_type IS record
      conf_req       : boolean;                             -- changes on signal will call vme_sim_slv subfunctions
      req_type       : integer;                             -- if set to 0 during conf_req state changes, write request to iram is requested
                                                            -- if set to 1 during conf_req state changes, read request from iram is requested
                                                            -- if set to 2 during conf_req state changes, interrupt request will be set to active
                                                            -- if set to 3 during conf_req state changes, address modifier of last access to slave is requested
      adr            : std_logic_vector(31 DOWNTO 0);       -- address for config read write access
      wr_dat         : std_logic_vector(31 DOWNTO 0);       -- write data to iram
      
      irq            : integer range 7 DOWNTO 0;   
   END record;
   
   TYPE vme_slv_out_type IS record
      conf_ack       : boolean;                             -- if conf_req has changed state, subfunction end will result in conf_ack state change     
      rd_dat         : std_logic_vector(31 DOWNTO 0);       -- read data to iram                                                                       
      irq            : std_logic_vector(7 DOWNTO 1);
      rd_am          : std_logic_vector(5 downto 0);        -- address modifier of last access
   END record;


   TYPE mem_entry;
   TYPE entry_ptr IS access mem_entry;
   
   TYPE mem_entry IS record
      address  : integer;
      data     : std_logic_vector(31 DOWNTO 0);
      nxt      : entry_ptr;
   END record;
   
   TYPE head IS record
      num_entries    : integer;
      list_ptr       : entry_ptr;
   END record;

   TYPE head_ptr IS access head;

   PROCEDURE wr_data (
                        CONSTANT location : IN integer;
                        CONSTANT data     : IN std_logic_vector;
                        CONSTANT byte     : IN std_logic_vector(3 DOWNTO 0);
                        VARIABLE first    : INOUT head_ptr
                     );
   PROCEDURE rd_data (
                        CONSTANT location    : IN integer;
                        VARIABLE data        : OUT std_logic_vector;
                        VARIABLE allocated   : OUT boolean;
                        VARIABLE first       : INOUT head_ptr
                     );
   PROCEDURE rd_vme_slv (  
      SIGNAL   vme_slv_in     : OUT vme_slv_in_type;
      SIGNAL   vme_slv_out    : IN vme_slv_out_type;
               adr            : IN std_logic_vector(31 DOWNTO 0);
               dat            : OUT std_logic_vector(31 DOWNTO 0)
               );  
   PROCEDURE wr_vme_slv (  
      SIGNAL   vme_slv_in     : OUT vme_slv_in_type;
      SIGNAL   vme_slv_out    : IN vme_slv_out_type;
               adr            : IN std_logic_vector(31 DOWNTO 0);
               dat            : IN std_logic_vector(31 DOWNTO 0)
               ) ;
   PROCEDURE am_vme_slv (  
      SIGNAL   vme_slv_in     : OUT vme_slv_in_type;
      SIGNAL   vme_slv_out    : IN vme_slv_out_type;
               am             : OUT std_logic_vector(5 DOWNTO 0)
               ) ;
   PROCEDURE init_vme_slv (  
      SIGNAL   vme_slv_in     : OUT vme_slv_in_type
               ) ;
   PROCEDURE irq_vme_slv ( 
      SIGNAL   vme_slv_in     : OUT vme_slv_in_type;
      SIGNAL   vme_slv_out    : IN vme_slv_out_type;
               irq            : IN integer range 7 DOWNTO 0;
               dat            : IN std_logic_vector(7 DOWNTO 0)
               ) ;


------------------------------------CONSTANTS----------------------------


   FUNCTION hex_to_bit_vect (char_code : character) RETURN vec4;
   FUNCTION conv_addr (addr : adr_type2) RETURN adr_type;
   FUNCTION conv_data2 (data : data_type2; adr : adr_type) RETURN data_type;
   FUNCTION conv_data4 (data : data_type4; adr : adr_type) RETURN data_type;
   FUNCTION conv_data8 (data : data_type8) RETURN data_type;
   FUNCTION conv_am (data : data_type2) RETURN am_type;
   FUNCTION TO_HEX_STRING(val : std_logic_vector) RETURN string; 
   FUNCTION hex_to_character (hex_value : std_logic_vector(3 downto 0)) RETURN character; 
	PROCEDURE print(txt_out: IN integer; s: in string);


END vme_sim_pack;

-----------------------------------------------------------------------------------------------

PACKAGE BODY vme_sim_pack IS
	PROCEDURE print(txt_out: IN integer; s: in string) is
	    variable l: line;
	BEGIN
	    IF txt_out > 2 THEN
	       write(l,now, justified=>right,field =>10, unit=> ns );
	       WRITE(l, string'("   "));
	       write(l, s);
	       writeline(output,l);
	    END IF;
	END print;

--------------------------------------------------------------------------------------------
   PROCEDURE vme_mstr_init (
      SIGNAL mstr_out      : OUT mstr_out_type
      ) IS
   BEGIN
      mstr_out.sysresn        <= '0';
      mstr_out.asn            <= 'H';
      mstr_out.dsan           <= 'H';
      mstr_out.dsbn           <= 'H';
      mstr_out.writen         <= 'H';
      mstr_out.addr           <= (OTHERS => 'H');
      mstr_out.data           <= (OTHERS => 'H');
      mstr_out.am             <= (OTHERS => 'H');
      mstr_out.iackn          <= 'H';
      mstr_out.iackout        <= 'H';
      mstr_out.brn            <= (OTHERS => 'H');
      mstr_out.bbsyn          <= 'H';
      mstr_out.berrn          <= 'H';
      WAIT FOR 10 ns;   
      mstr_out.sysresn        <= 'H';
   END PROCEDURE vme_mstr_init;

--------------------------------------------------------------------------------------------
   PROCEDURE vme_mstr_write (
      SIGNAL   mstr_out       : OUT mstr_out_type;
      SIGNAL   mstr_in        : IN mstr_in_type;
               adress         : std_logic_vector(31 DOWNTO 0);
               data           : std_logic_vector(31 DOWNTO 0);
               mode           : character;
               txt_out        : integer;  -- 0=quiet, 1=only errors, 2=all
               number         : integer;
               tga            : std_logic_vector(5 DOWNTO 0)
      
      ) IS
      VARIABLE dsan     : std_logic;
      VARIABLE dsbn     : std_logic;
      VARIABLE vme_adr  : std_logic_vector(31 DOWNTO 0);
      VARIABLE dat_out  : std_logic_vector(31 DOWNTO 0);
      VARIABLE cnt      : integer;
      VARIABLE time_dat_changed  : time;
   BEGIN
      print(txt_out, "VME_SIM_MSTR: do we have bus arbitration?");
      IF mstr_in.bg3n_in /= '0' THEN
         mstr_out.brn <= "0HHH";          -- request bus
         WAIT until falling_edge(mstr_in.bg3n_in);   -- wait until bus grant
      END IF;
      
      print(txt_out, "VME_SIM_MSTR: wait until prior access has finished");
      IF mstr_in.bbsyn = '0' THEN
         WAIT until rising_edge(mstr_in.bbsyn);
      END IF;
   
      -- occupy bus
      mstr_out.bbsyn <= '0', 'H' AFTER 90 ns;
   
      -- prepare
      cnt := 0;
      vme_adr := adress;
      dat_out := (OTHERS => '0');
      IF mode = 'b' THEN            -- byte access
         CASE adress(1 DOWNTO 0) IS
            WHEN "00" =>   dsan := '1';         -- B0
                           dsbn := '0';
                           vme_adr(1) := '0';
                           vme_adr(0) := '1';      --lwordn
                           dat_out(15 DOWNTO 8) := data(7 DOWNTO 0);
                        
            WHEN "01" =>   dsan := '0';         -- B1
                           dsbn := '1';
                           vme_adr(1) := '0';
                           vme_adr(0) := '1';      --lwordn
                           dat_out(7 DOWNTO 0) := data(15 DOWNTO 8);
   
            WHEN "10" =>   dsan := '1';         -- B2
                           dsbn := '0';
                           vme_adr(1) := '1';
                           vme_adr(0) := '1';      --lwordn
                           dat_out(15 DOWNTO 8) := data(23 DOWNTO 16);
   
            WHEN "11" =>   dsan := '0';         -- B3
                           dsbn := '1';
                           vme_adr(1) := '1';
                           vme_adr(0) := '1';      --lwordn
                           dat_out(7 DOWNTO 0) := data(31 DOWNTO 24);
   
            WHEN OTHERS => dsan := '1';
                           dsbn := '0';
                           vme_adr(1) := '0';
                           vme_adr(0) := '1';      --lwordn
                           dat_out(15 DOWNTO 8) := data(7 DOWNTO 0);
   
         END CASE;      
      ELSIF mode = 'w' THEN         -- word access
         IF adress(1) = '0' THEN   
            dsan := '0';                     -- B0,B1
            dsbn := '0';
            vme_adr(1) := '0';
            vme_adr(0) := '1';         --lwordn
            dat_out(15 DOWNTO 8) := data(7 DOWNTO 0);
            dat_out(7 DOWNTO 0) := data(15 DOWNTO 8);
         ELSE
            dsan := '0';                     -- B2, B3
            dsbn := '0';
            vme_adr(1) := '1';
            vme_adr(0) := '1';         --lwordn
            dat_out(15 DOWNTO 8) := data(23 DOWNTO 16);
            dat_out(7 DOWNTO 0) := data(31 DOWNTO 24);
         END IF;
            
      ELSE                              -- long access (mode='l')
            dsan := '0';                     -- B0, B1, B2, B3
            dsbn := '0';
            vme_adr(1) := '0';
            vme_adr(0) := '0';         --lwordn
            dat_out(31 DOWNTO 24) := data(7 DOWNTO 0);
            dat_out(23 DOWNTO 16) := data(15 DOWNTO 8);
            dat_out(15 DOWNTO 8) := data(23 DOWNTO 16);
            dat_out(7 DOWNTO 0) := data(31 DOWNTO 24);
      END IF;

      print(txt_out, "VME_SIM_MSTR: start of vme access");
      print(txt_out, "VME_SIM_MSTR: address phase");
      mstr_out.addr <= vme_adr;
      mstr_out.am <= tga;
      mstr_out.writen <= '0';
      WAIT FOR 40 ns;
      mstr_out.asn <= '0';
      WAIT FOR 5 ns;
      mstr_out.brn <= "HHHH";          -- release bus arbitration
      
      print(txt_out, "VME_SIM_MSTR: data phase");
      dat_phase: LOOP
         mstr_out.data <= dat_out;
         WAIT FOR 35 ns;
         mstr_out.addr <= (OTHERS => 'H');
         mstr_out.am <= (OTHERS => 'H');
         mstr_out.writen <= 'H';
         
         mstr_out.dsan <= dsan;
         mstr_out.dsbn <= dsbn;
         WAIT until falling_edge(mstr_in.dtackn);
         print(txt_out, "VME_SIM_MSTR: got dtackn");
         IF txt_out > 1 THEN
            print_mtest("VME_MSTR: WRITE ", adress, dat_out, dat_out, TRUE);
         END IF;
         WAIT FOR 1 ns;
         mstr_out.dsan <= 'H';
         mstr_out.dsbn <= 'H';
         cnt := cnt + 1;
         IF cnt < number THEN -- burst
            dat_out := dat_out + 1;
            mstr_out.data <= dat_out;
         ELSE
            mstr_out.data <= (OTHERS => 'H');
            mstr_out.asn <= 'H';
         END IF;
         time_dat_changed := now;
--         WAIT until rising_edge(mstr_in.dtackn);
--         WAIT FOR 1 ns;
--         mstr_out.asn <= 'H';
      
         IF cnt = number THEN
            exit dat_phase;
         END IF;

         IF time_dat_changed > 35 ns THEN
            next dat_phase;
         ELSE
            WAIT FOR (35 ns - time_dat_changed);
            next  dat_phase;
         END IF;
      END LOOP;
      

   END PROCEDURE vme_mstr_write;

--------------------------------------------------------------------------------------------
   PROCEDURE vme_mstr_write64 (
      SIGNAL   mstr_out       : OUT mstr_out_type;
      SIGNAL   mstr_in        : IN mstr_in_type;
               adress         : std_logic_vector(31 DOWNTO 0);
               data           : std_logic_vector(31 DOWNTO 0);
               mode           : character;
               txt_out        : integer;  -- 0=quiet, 1=only errors, 2=all
               number         : integer;
               tga            : std_logic_vector(5 DOWNTO 0)
      
      ) IS
      VARIABLE dsan     : std_logic;
      VARIABLE dsbn     : std_logic;
      VARIABLE vme_adr  : std_logic_vector(31 DOWNTO 0);
      VARIABLE dat_out  : std_logic_vector(31 DOWNTO 0);
      VARIABLE cnt      : integer;
      VARIABLE time_dat_changed  : time;
   BEGIN
      print(txt_out, "VME_SIM_MSTR: do we have bus arbitration?");
      IF mstr_in.bg3n_in /= '0' THEN
         mstr_out.brn <= "0HHH";          -- request bus
         WAIT until falling_edge(mstr_in.bg3n_in);   -- wait until bus grant
      END IF;
      
      print(txt_out, "VME_SIM_MSTR: wait until prior access has finished");
      IF mstr_in.bbsyn = '0' THEN
         WAIT until rising_edge(mstr_in.bbsyn);
      END IF;
   
      -- occupy bus
      mstr_out.bbsyn <= '0', 'H' AFTER 90 ns;
   
      -- prepare
      cnt := 0;
      vme_adr := adress;
      dat_out := (OTHERS => '0');
      -- mode = 'd'
      dsan := '0';                     -- B0, B1, B2, B3
      dsbn := '0';
      vme_adr(1) := '0';
      vme_adr(0) := '0';         --lwordn
      dat_out(31 DOWNTO 24) := data(7 DOWNTO 0);
      dat_out(23 DOWNTO 16) := data(15 DOWNTO 8);
      dat_out(15 DOWNTO 8) := data(23 DOWNTO 16);
      dat_out(7 DOWNTO 0) := data(31 DOWNTO 24);

      print(txt_out, "VME_SIM_MSTR: start of vme access");
      print(txt_out, "VME_SIM_MSTR: address phase");
      mstr_out.addr <= vme_adr;
      mstr_out.am <= tga;
      mstr_out.writen <= '0';
      WAIT FOR 40 ns;
      mstr_out.asn <= '0';
      WAIT FOR 5 ns;
      mstr_out.brn <= "HHHH";          -- release bus arbitration
      
      print(txt_out, "VME_SIM_MSTR: address phase");
      mstr_out.data <= (OTHERS => '0');   -- no data in first d64 phase: address phase
      WAIT FOR 35 ns;
      mstr_out.addr <= (OTHERS => 'H');
      mstr_out.am <= (OTHERS => 'H');
      mstr_out.writen <= 'H';
      
      mstr_out.dsan <= dsan;
      mstr_out.dsbn <= dsbn;
      WAIT until falling_edge(mstr_in.dtackn);
      print(txt_out, "VME_SIM_MSTR: got dtackn FOR address phase");
      WAIT FOR 1 ns;
      mstr_out.dsan <= 'H';
      mstr_out.dsbn <= 'H';
      WAIT until rising_edge(mstr_in.dtackn);
      WAIT FOR 1 ns;

      print(txt_out, "VME_SIM_MSTR: data phase");
      dat_phase: LOOP
         vme_adr:= NOT dat_out;
         mstr_out.data <= dat_out;
         mstr_out.addr <= vme_adr;
         WAIT FOR 35 ns;
         mstr_out.am <= (OTHERS => 'H');
         mstr_out.writen <= 'H';
         
         mstr_out.dsan <= dsan;
         mstr_out.dsbn <= dsbn;
         WAIT until falling_edge(mstr_in.dtackn);
         print(txt_out, "VME_SIM_MSTR: got dtackn");
         IF txt_out > 1 THEN
            print_mtest("VME_MSTR: WRITE ", adress, (vme_adr & dat_out), (vme_adr & dat_out), TRUE);
         END IF;
         WAIT FOR 1 ns;
         mstr_out.dsan <= 'H';
         mstr_out.dsbn <= 'H';
         cnt := cnt + 1;
         IF cnt < number THEN -- burst
            dat_out := dat_out + 1;
         mstr_out.data <= dat_out;
         mstr_out.addr <= vme_adr;
         ELSE
            mstr_out.data <= (OTHERS => 'H');
            mstr_out.addr <= (OTHERS => 'H');
            mstr_out.asn <= 'H';
         END IF;
         time_dat_changed := now;
--         WAIT until rising_edge(mstr_in.dtackn);
--         WAIT FOR 1 ns;
--         mstr_out.asn <= 'H';
      
         IF cnt = number THEN
            exit dat_phase;
         END IF;

         IF time_dat_changed > 35 ns THEN
            next dat_phase;
         ELSE
            WAIT FOR (35 ns - time_dat_changed);
            next  dat_phase;
         END IF;
      END LOOP;
      

   END PROCEDURE vme_mstr_write64;

--------------------------------------------------------------------------------------------
   PROCEDURE vme_mstr_read (
      SIGNAL   mstr_out       : OUT mstr_out_type;
      SIGNAL   mstr_in        : IN mstr_in_type;
               adress         : std_logic_vector(31 DOWNTO 0);
               ex_data        : std_logic_vector(31 DOWNTO 0);
               in_data        : OUT std_logic_vector(31 DOWNTO 0);
               mode           : character;
               txt_out        : integer;  -- 0=quiet, 1=only errors, 2=all
               number         : integer;
               tga            : std_logic_vector(5 DOWNTO 0);
               err            : OUT integer
      ) IS
      VARIABLE dsan     : std_logic;
      VARIABLE dsbn     : std_logic;
      VARIABLE vme_adr  : std_logic_vector(31 DOWNTO 0);
      VARIABLE dat_in  : std_logic_vector(31 DOWNTO 0);
      VARIABLE cnt      : integer;
      VARIABLE time_dat_changed  : time;
      VARIABLE dat_phase_err  : integer;
      VARIABLE loc_err  : integer;
      VARIABLE expected  : std_logic_vector(31 DOWNTO 0);
   BEGIN
      dat_phase_err := 0;
      loc_err := 0;
      expected := ex_data;
      print(txt_out, "VME_SIM_MSTR: do we have bus arbitration?");
      IF mstr_in.bg3n_in /= '0' THEN
         mstr_out.brn <= "0HHH";          -- request bus
         WAIT until falling_edge(mstr_in.bg3n_in);   -- wait until bus grant
      END IF;
      
      print(txt_out, "VME_SIM_MSTR: wait until prior access has finished");
--      IF mstr_in.bbsyn = '0' THEN
--         WAIT until rising_edge(mstr_in.bbsyn);
--      END IF;
      IF mstr_in.asn = '0' THEN
         WAIT until rising_edge(mstr_in.asn);
      END IF;
      IF mstr_in.asn'LAST_EVENT < 40 ns AND mstr_in.asn /= '0' THEN
         WAIT FOR (40 ns - mstr_in.asn'LAST_EVENT);
      END IF;
   
      -- occupy bus
      mstr_out.bbsyn <= '0', 'H' AFTER 90 ns;
   
      -- prepare
      cnt := 0;
      vme_adr := adress;
      expected := (OTHERS => '0');
      mstr_out.iackn <= 'H';
      IF mode = 'b' OR mode = 'i' THEN            -- byte access
         IF mode = 'i' THEN
            mstr_out.iackn <= '0';                 -- indicate iack cycle
         END IF;
         CASE adress(1 DOWNTO 0) IS
            WHEN "00" =>   dsan := '1';         -- B0
                           dsbn := '0';
                           vme_adr(1) := '0';
                           vme_adr(0) := '1';      --lwordn
                           expected(15 DOWNTO 8) := ex_data(7 DOWNTO 0);
                        
            WHEN "01" =>   dsan := '0';         -- B1
                           dsbn := '1';
                           vme_adr(1) := '0';
                           vme_adr(0) := '1';      --lwordn
                           expected(7 DOWNTO 0) := ex_data(15 DOWNTO 8);
   
            WHEN "10" =>   dsan := '1';         -- B2
                           dsbn := '0';
                           vme_adr(1) := '1';
                           vme_adr(0) := '1';      --lwordn
                           expected(15 DOWNTO 8) := ex_data(23 DOWNTO 16);
   
            WHEN "11" =>   dsan := '0';         -- B3
                           dsbn := '1';
                           vme_adr(1) := '1';
                           vme_adr(0) := '1';      --lwordn
                           expected(7 DOWNTO 0) := ex_data(31 DOWNTO 24);
   
            WHEN OTHERS => dsan := '1';
                           dsbn := '0';
                           vme_adr(1) := '0';
                           vme_adr(0) := '1';      --lwordn
                           expected(15 DOWNTO 8) := ex_data(7 DOWNTO 0);
   
         END CASE;      
      ELSIF mode = 'w' THEN         -- word access
         IF adress(1) = '0' THEN   
            dsan := '0';                     -- B0,B1
            dsbn := '0';
            vme_adr(1) := '0';
            vme_adr(0) := '1';         --lwordn
            expected(15 DOWNTO 8) := ex_data(7 DOWNTO 0);
            expected(7 DOWNTO 0) := ex_data(15 DOWNTO 8);
         ELSE
            dsan := '0';                     -- B2, B3
            dsbn := '0';
            vme_adr(1) := '1';
            vme_adr(0) := '1';         --lwordn
            expected(15 DOWNTO 8) := ex_data(23 DOWNTO 16);
            expected(7 DOWNTO 0) := ex_data(31 DOWNTO 24);
         END IF;
            
      ELSE                              -- long access (mode='l')
            dsan := '0';                     -- B0, B1, B2, B3
            dsbn := '0';
            vme_adr(1) := '0';
            vme_adr(0) := '0';         --lwordn
            expected(31 DOWNTO 24) := ex_data(7 DOWNTO 0);
            expected(23 DOWNTO 16) := ex_data(15 DOWNTO 8);
            expected(15 DOWNTO 8) := ex_data(23 DOWNTO 16);
            expected(7 DOWNTO 0) := ex_data(31 DOWNTO 24);
      END IF;

      print(txt_out, "VME_SIM_MSTR: start of vme access");
      print(txt_out, "VME_SIM_MSTR: address phase");
      mstr_out.addr <= vme_adr;
      mstr_out.am <= tga;
      mstr_out.writen <= '1';
      WAIT FOR 40 ns;
      mstr_out.asn <= '0';
      WAIT FOR 5 ns;
      mstr_out.brn <= "HHHH";          -- release bus arbitration
      
      print(txt_out, "VME_SIM_MSTR: data phase");
      dat_phase: LOOP
         dat_phase_err := 0;
         WAIT FOR 35 ns;
         mstr_out.addr <= (OTHERS => 'H');
         mstr_out.am <= (OTHERS => 'H');
         mstr_out.writen <= 'H';
         
         mstr_out.dsan <= dsan;
         mstr_out.dsbn <= dsbn;
         WAIT until falling_edge(mstr_in.dtackn);
         print(txt_out, "VME_SIM_MSTR: got dtackn");
         WAIT FOR 1 ns;
         dat_in := mstr_in.data;
         IF mode = 'b' OR mode = 'i' THEN
            IF adress(1 DOWNTO 0) = "01" AND dat_in(7 DOWNTO 0) /= expected(7 DOWNTO 0) THEN
               dat_phase_err := dat_phase_err + 1;
            ELSIF adress(1 DOWNTO 0) = "00" AND dat_in(15 DOWNTO 8) /= expected(15 DOWNTO 8) THEN
               dat_phase_err := dat_phase_err + 1;
            ELSIF adress(1 DOWNTO 0) = "11" AND dat_in(7 DOWNTO 0)  /= expected(7 DOWNTO 0) THEN
               dat_phase_err := dat_phase_err + 1;                 
            ELSIF adress(1 DOWNTO 0) = "10" AND dat_in(15 DOWNTO 8) /= expected(15 DOWNTO 8) THEN
               dat_phase_err := dat_phase_err + 1;
            END IF;
         ELSIF mode = 'w' THEN
            IF adress(1) = '0' AND 
               (dat_in(7 DOWNTO 0) /= expected(7 DOWNTO 0) OR
               dat_in(15 DOWNTO 8) /= expected(15 DOWNTO 8)) THEN
               dat_phase_err := dat_phase_err + 1;
            ELSIF adress(1) = '1' AND 
               (dat_in(7 DOWNTO 0) /= expected(7 DOWNTO 0) OR
               dat_in(15 DOWNTO 8) /= expected(15 DOWNTO 8)) THEN
               dat_phase_err := dat_phase_err + 1;
            END IF;
--         ELSIF mode = 'y' THEN   -- d64
--            IF dat_in2(7 DOWNTO 0)   /= expected(7 DOWNTO 0) OR
--               dat_in2(15 DOWNTO 8)  /= expected(15 DOWNTO 8) OR
--               dat_in2(23 DOWNTO 16) /= expected(23 DOWNTO 16) OR
--               dat_in2(31 DOWNTO 24) /= expected(31 DOWNTO 24) THEN
--               dat_phase_err := dat_phase_err + 1;
--            END IF;
--            expected := expected + 1;            
--            IF dat_in(7 DOWNTO 0)    /= expected(7 DOWNTO 0) OR
--               dat_in(15 DOWNTO 8)   /= expected(15 DOWNTO 8) OR
--               dat_in(23 DOWNTO 16)  /= expected(23 DOWNTO 16) OR
--               dat_in(31 DOWNTO 24)  /= expected(31 DOWNTO 24) THEN
--               dat_phase_err := dat_phase_err + 1;
--            END IF;
         ELSE  -- mode = 'l'
            IF dat_in(7 DOWNTO 0)   /= expected(7 DOWNTO 0) OR
               dat_in(15 DOWNTO 8)  /= expected(15 DOWNTO 8) OR
               dat_in(23 DOWNTO 16) /= expected(23 DOWNTO 16) OR
               dat_in(31 DOWNTO 24) /= expected(31 DOWNTO 24) THEN
               dat_phase_err := dat_phase_err + 1;
            END IF;
         END IF;

         IF txt_out > 0 AND dat_phase_err > 0 THEN
            print_mtest("VME_MSTR: READ ", adress, dat_in, expected, FALSE);
         END IF;
         IF txt_out > 1 AND dat_phase_err = 0 THEN
            print_mtest("VME_MSTR: READ ", adress, dat_in, expected, TRUE);
         END IF;
         mstr_out.dsan <= 'H';
         mstr_out.dsbn <= 'H';
         mstr_out.iackn <= 'H';
         cnt := cnt + 1;
         IF cnt < number THEN -- burst
            expected := expected + 1;
         ELSE
            mstr_out.asn <= 'H';
         END IF;
         time_dat_changed := now;
         WAIT until rising_edge(mstr_in.dtackn);
         WAIT FOR 1 ns;

         loc_err := loc_err + dat_phase_err;
         err := loc_err;

         IF cnt = number THEN
            mstr_out.asn <= 'H';
            exit dat_phase;
         END IF;

         IF time_dat_changed > 35 ns THEN
            next dat_phase;
         ELSE
            WAIT FOR (35 ns - time_dat_changed);
            next  dat_phase;
         END IF;
      END LOOP;
      
   END PROCEDURE vme_mstr_read;

   
--------------------------------------------------------------------------------------------
   PROCEDURE vme_mstr_read64 (
      SIGNAL   mstr_out       : OUT mstr_out_type;
      SIGNAL   mstr_in        : IN mstr_in_type;
               adress         : std_logic_vector(31 DOWNTO 0);
               ex_data        : std_logic_vector(31 DOWNTO 0);
               in_data        : OUT std_logic_vector(31 DOWNTO 0);
               mode           : character;
               txt_out        : integer;  -- 0=quiet, 1=only errors, 2=all
               number         : integer;
               tga            : std_logic_vector(5 DOWNTO 0);
               err            : OUT integer
      ) IS
      VARIABLE dsan     : std_logic;
      VARIABLE dsbn     : std_logic;
      VARIABLE vme_adr  : std_logic_vector(31 DOWNTO 0);
      VARIABLE dat_in  : std_logic_vector(63 DOWNTO 0);
      VARIABLE cnt      : integer;
      VARIABLE time_dat_changed  : time;
      VARIABLE dat_phase_err  : integer;
      VARIABLE loc_err  : integer;
      VARIABLE expected  : std_logic_vector(63 DOWNTO 0);
   BEGIN
      dat_phase_err := 0;
      loc_err := 0;
      expected(31 DOWNTO 0) := ex_data;
      print(txt_out, "VME_SIM_MSTR: do we have bus arbitration?");
      IF mstr_in.bg3n_in /= '0' THEN
         mstr_out.brn <= "0HHH";          -- request bus
         WAIT until falling_edge(mstr_in.bg3n_in);   -- wait until bus grant
      END IF;
      
      print(txt_out, "VME_SIM_MSTR: wait until prior access has finished");
      IF mstr_in.bbsyn = '0' THEN
         WAIT until rising_edge(mstr_in.bbsyn);
      END IF;
   
      -- occupy bus
      mstr_out.bbsyn <= '0', 'H' AFTER 90 ns;
   
      -- prepare
      cnt := 0;
      vme_adr := adress;
      expected := (OTHERS => '0');
                                    -- 64-bit access
            dsan := '0';                     -- B0, B1, B2, B3, B4, B5, B6
            dsbn := '0';
            vme_adr(1) := '0';
            vme_adr(0) := '0';         --lwordn
            expected(31 DOWNTO 24) := ex_data(7 DOWNTO 0);
            expected(23 DOWNTO 16) := ex_data(15 DOWNTO 8);
            expected(15 DOWNTO 8) := ex_data(23 DOWNTO 16);
            expected(7 DOWNTO 0) := ex_data(31 DOWNTO 24);
            expected(63 DOWNTO 32) := NOT expected(31 DOWNTO 0);

      print(txt_out, "VME_SIM_MSTR: start of vme access");
      print(txt_out, "VME_SIM_MSTR: address phase");
      mstr_out.addr <= vme_adr;
      mstr_out.am <= tga;
      mstr_out.writen <= '1';
      WAIT FOR 40 ns;
      mstr_out.asn <= '0';
      WAIT FOR 5 ns;
      mstr_out.brn <= "HHHH";          -- release bus arbitration
      
      print(txt_out, "VME_SIM_MSTR: address phase");
      WAIT FOR 35 ns;
      mstr_out.addr <= (OTHERS => 'H');
      mstr_out.am <= (OTHERS => 'H');
      mstr_out.writen <= 'H';
      
      mstr_out.dsan <= dsan;
      mstr_out.dsbn <= dsbn;
      WAIT until falling_edge(mstr_in.dtackn);
      print(txt_out, "VME_SIM_MSTR: got dtackn FOR address phase");
      WAIT FOR 1 ns;
      mstr_out.dsan <= 'H';
      mstr_out.dsbn <= 'H';
      WAIT until rising_edge(mstr_in.dtackn);
      WAIT FOR 1 ns;

      print(txt_out, "VME_SIM_MSTR: data phase");
      dat_phase: LOOP
         dat_phase_err := 0;
         WAIT FOR 35 ns;
         mstr_out.addr <= (OTHERS => 'H');
         mstr_out.am <= (OTHERS => 'H');
         mstr_out.writen <= 'H';
         
         mstr_out.dsan <= dsan;
         mstr_out.dsbn <= dsbn;
         WAIT until falling_edge(mstr_in.dtackn);
         print(txt_out, "VME_SIM_MSTR: got dtackn");
         WAIT FOR 1 ns;
         dat_in := mstr_in.addr & mstr_in.data;
         IF dat_in(7 DOWNTO 0)   /= expected(7 DOWNTO 0) OR
            dat_in(15 DOWNTO 8)  /= expected(15 DOWNTO 8) OR
            dat_in(23 DOWNTO 16) /= expected(23 DOWNTO 16) OR
            dat_in(31 DOWNTO 24) /= expected(31 DOWNTO 24) OR
            dat_in(39 DOWNTO 32) /= expected(39 DOWNTO 32) OR
            dat_in(47 DOWNTO 40) /= expected(47 DOWNTO 40) OR
            dat_in(55 DOWNTO 48) /= expected(55 DOWNTO 48) OR
            dat_in(63 DOWNTO 56) /= expected(63 DOWNTO 56) THEN
            dat_phase_err := dat_phase_err + 1;
         END IF;
      
         IF txt_out > 0 AND dat_phase_err > 0 THEN
            print_mtest("VME_MSTR: READ ", adress, dat_in, expected, FALSE);
         END IF;
         IF txt_out > 1 AND dat_phase_err = 0 THEN
            print_mtest("VME_MSTR: READ ", adress, dat_in, expected, TRUE);
         END IF;
         mstr_out.dsan <= 'H';
         mstr_out.dsbn <= 'H';
         cnt := cnt + 1;
         IF cnt < number THEN -- burst
            expected(31 DOWNTO 0) := expected(31 DOWNTO 0) + 1;
            expected(63 DOWNTO 32) := NOT expected(31 DOWNTO 0);
         ELSE
            mstr_out.asn <= 'H';
         END IF;
         time_dat_changed := now;
         WAIT until rising_edge(mstr_in.dtackn);
         WAIT FOR 1 ns;

         loc_err := loc_err + dat_phase_err;
         err := loc_err;

         IF cnt = number THEN
            mstr_out.asn <= 'H';
            exit dat_phase;
         END IF;

         IF time_dat_changed > 35 ns THEN
            next dat_phase;
         ELSE
            WAIT FOR (35 ns - time_dat_changed);
            next  dat_phase;
         END IF;
      END LOOP;
      
   END PROCEDURE vme_mstr_read64;

   



--------------------------------------------------------------------------------------------
   PROCEDURE init_vme_slv (  
      SIGNAL   vme_slv_in     : OUT vme_slv_in_type
               ) IS
   BEGIN
      vme_slv_in.req_type <= 0;
      vme_slv_in.wr_dat <= (OTHERS => '0');
      vme_slv_in.adr <= (OTHERS => '0');
      vme_slv_in.conf_req <= FALSE;
      vme_slv_in.irq <= 0;
   END PROCEDURE init_vme_slv;

--------------------------------------------------------------------------------------------
   PROCEDURE irq_vme_slv ( SIGNAL   vme_slv_in     : OUT vme_slv_in_type;
                           SIGNAL   vme_slv_out    : IN vme_slv_out_type;
                                    irq            : IN integer range 7 DOWNTO 0;
                                    dat            : IN std_logic_vector(7 DOWNTO 0)
                                    ) IS
   BEGIN
      vme_slv_in.req_type <= 2;
      vme_slv_in.irq <= irq;
      vme_slv_in.wr_dat(7 DOWNTO 0) <= dat;
      vme_slv_in.conf_req <= NOT vme_slv_out.conf_ack;
      WAIT on vme_slv_out.conf_ack;
   END PROCEDURE irq_vme_slv;

--------------------------------------------------------------------------------------------
   PROCEDURE wr_vme_slv (  SIGNAL   vme_slv_in     : OUT vme_slv_in_type;
                        SIGNAL   vme_slv_out    : IN vme_slv_out_type;
                                 adr            : IN std_logic_vector(31 DOWNTO 0);
                                 dat            : IN std_logic_vector(31 DOWNTO 0)
                                 ) IS
   BEGIN
      vme_slv_in.req_type <= 0;
      vme_slv_in.wr_dat <= dat;
      vme_slv_in.adr <= adr;
      vme_slv_in.conf_req <= NOT vme_slv_out.conf_ack;
      WAIT on vme_slv_out.conf_ack;
   END PROCEDURE wr_vme_slv;
--------------------------------------------------------------------------------------------


   PROCEDURE am_vme_slv (  
      SIGNAL   vme_slv_in     : OUT vme_slv_in_type;
      SIGNAL   vme_slv_out    : IN vme_slv_out_type;
               am             : OUT std_logic_vector(5 DOWNTO 0)
               ) is
   BEGIN
      vme_slv_in.req_type <= 3;
      vme_slv_in.conf_req <= NOT vme_slv_out.conf_ack;
      WAIT on vme_slv_out.conf_ack;
      am := vme_slv_out.rd_am;
   END PROCEDURE am_vme_slv;

--------------------------------------------------------------------------------------------
   PROCEDURE rd_vme_slv (  SIGNAL   vme_slv_in     : OUT vme_slv_in_type;
                        SIGNAL   vme_slv_out    : IN vme_slv_out_type;
                                 adr            : IN std_logic_vector(31 DOWNTO 0);
                                 dat            : OUT std_logic_vector(31 DOWNTO 0)
                                 ) IS
   BEGIN
      vme_slv_in.req_type <= 1;
      vme_slv_in.adr <= adr;
      vme_slv_in.conf_req <= NOT vme_slv_out.conf_ack;
      WAIT on vme_slv_out.conf_ack;
      dat := vme_slv_out.rd_dat;
   END PROCEDURE rd_vme_slv;
--------------------------------------------------------------------------------------------
   PROCEDURE wr_data (
      CONSTANT location : IN integer;
      CONSTANT data     : IN std_logic_vector;
      CONSTANT byte     : IN std_logic_vector(3 DOWNTO 0);
      VARIABLE first    : INOUT head_ptr
      ) IS
      VARIABLE temp_ptr : entry_ptr;
      VARIABLE new_ptr  : entry_ptr;
      VARIABLE prev_ptr : entry_ptr;
      VARIABLE done     : boolean:=FALSE;
   BEGIN
      done:= FALSE;                                      -- set done to true when allocation occurs
      IF first.num_entries = 0 THEN                      -- first access to memory
         first.list_ptr := new mem_entry;
         first.num_entries := 1;
         first.list_ptr.address := location;
         IF byte(0) = '1' THEN 
            first.list_ptr.data(7 DOWNTO 0) := data(7 DOWNTO 0);
         END IF;
         IF byte(1) = '1' THEN 
            first.list_ptr.data(15 DOWNTO 8) := data(15 DOWNTO 8);
         END IF;
         IF byte(2) = '1' THEN 
            first.list_ptr.data(23 DOWNTO 16) := data(23 DOWNTO 16);
         END IF;
         IF byte(3) = '1' THEN 
            first.list_ptr.data(31 DOWNTO 24) := data(31 DOWNTO 24);
         END IF;
         first.list_ptr.nxt := null;
         done := TRUE;
      ELSIF location < first.list_ptr.address THEN       -- address is lowest value so far in allocation to put at head of list
         new_ptr := new mem_entry;
         IF byte(0) = '1' THEN 
            new_ptr.data(7 DOWNTO 0) := data(7 DOWNTO 0);
         END IF;
         IF byte(1) = '1' THEN 
            new_ptr.data(15 DOWNTO 8) := data(15 DOWNTO 8);
         END IF;
         IF byte(2) = '1' THEN 
            new_ptr.data(23 DOWNTO 16) := data(23 DOWNTO 16);
         END IF;
         IF byte(3) = '1' THEN 
            new_ptr.data(31 DOWNTO 24) := data(31 DOWNTO 24);
         END IF;
         new_ptr.nxt := first.list_ptr;
         new_ptr.address := location;
         first.list_ptr := new_ptr;
         first.num_entries := first.num_entries + 1;
         done := TRUE;
      ELSE                                               -- location must be >= first.list_ptr.address
         temp_ptr := first.list_ptr;
         while temp_ptr /= null AND NOT done LOOP
            IF temp_ptr.address = location THEN          -- address already allocated
               IF byte(0) = '1' THEN 
                  temp_ptr.data(7 DOWNTO 0) := data(7 DOWNTO 0);
               END IF;
               IF byte(1) = '1' THEN 
                  temp_ptr.data(15 DOWNTO 8) := data(15 DOWNTO 8);
               END IF;
               IF byte(2) = '1' THEN 
                  temp_ptr.data(23 DOWNTO 16) := data(23 DOWNTO 16);
               END IF;
               IF byte(3) = '1' THEN 
                  temp_ptr.data(31 DOWNTO 24) := data(31 DOWNTO 24);
               END IF;
               done := TRUE;
            ELSIF temp_ptr.address > location THEN
               new_ptr := new mem_entry;
               new_ptr.address := location;
               IF byte(0) = '1' THEN 
                  new_ptr.data(7 DOWNTO 0) := data(7 DOWNTO 0);
               END IF;
               IF byte(1) = '1' THEN 
                  new_ptr.data(15 DOWNTO 8) := data(15 DOWNTO 8);
               END IF;
               IF byte(2) = '1' THEN 
                  new_ptr.data(23 DOWNTO 16) := data(23 DOWNTO 16);
               END IF;
               IF byte(3) = '1' THEN 
                  new_ptr.data(31 DOWNTO 24) := data(31 DOWNTO 24);
               END IF;
               new_ptr.nxt := temp_ptr;
               prev_ptr.nxt := new_ptr;                  -- break pointer chain and insert new_ptr               
               first.num_entries := first.num_entries + 1;
               done := TRUE;
            ELSE
               prev_ptr := temp_ptr;
               temp_ptr := temp_ptr.nxt;
            END IF;
         END LOOP;
      
         IF NOT done THEN
            new_ptr := new mem_entry;
            new_ptr.address := location;
            IF byte(0) = '1' THEN 
               new_ptr.data(7 DOWNTO 0) := data(7 DOWNTO 0);
            END IF;
            IF byte(1) = '1' THEN 
               new_ptr.data(15 DOWNTO 8) := data(15 DOWNTO 8);
            END IF;
            IF byte(2) = '1' THEN 
               new_ptr.data(23 DOWNTO 16) := data(23 DOWNTO 16);
            END IF;
            IF byte(3) = '1' THEN 
               new_ptr.data(31 DOWNTO 24) := data(31 DOWNTO 24);
            END IF;
            new_ptr.nxt := null;                            -- add new_ptr TO END OF chain
            prev_ptr.nxt := new_ptr;
            first.num_entries := first.num_entries + 1;
            done := TRUE;
         END IF;
      END IF;
      WAIT FOR 0 ns;
   END wr_data;
   
--------------------------------------------------------------------------------------------
   PROCEDURE rd_data (      
      CONSTANT location    : IN integer;
      VARIABLE data        : OUT std_logic_vector;
      VARIABLE allocated   : OUT boolean;
      VARIABLE first       : INOUT head_ptr
      ) IS
      VARIABLE temp_ptr    : entry_ptr;
      VARIABLE is_allocated : boolean;
   BEGIN
      -- set allocated to true when read hits already allocated spot
      is_allocated := FALSE;
      IF (first.list_ptr /= null AND first.num_entries /= 0 AND location >= first.list_ptr.address) THEN
         temp_ptr := first.list_ptr;
         while (temp_ptr /= null AND NOT is_allocated AND location >= temp_ptr.address) LOOP
            IF temp_ptr.address = location THEN          -- address has been allocated
               data := temp_ptr.data;
               is_allocated := TRUE;
            ELSE
               temp_ptr := temp_ptr.nxt;
            END IF;
         END LOOP;
      END IF;
      IF NOT is_allocated THEN
         data := (data'range => '1');
      END IF;
      allocated := is_allocated;
      WAIT FOR 0 ns;
   END rd_data;


   FUNCTION hex_to_character (hex_value : std_logic_vector(3 downto 0)) 
      return character is 
   begin 
      case hex_value is 
         when "0000" => return '0'; 
         when "0001" => return '1'; 
         when "0010" => return '2'; 
         when "0011" => return '3'; 
         when "0100" => return '4'; 
         when "0101" => return '5'; 
         when "0110" => return '6'; 
         when "0111" => return '7'; 
         when "1000" => return '8'; 
         when "1001" => return '9'; 
         when "1010" => return 'A'; 
         when "1011" => return 'B'; 
         when "1100" => return 'C'; 
         when "1101" => return 'D'; 
         when "1110" => return 'E'; 
         when "1111" => return 'F'; 
  when "ZZZZ" => return 'Z'; 
  when others => return 'U'; 
      end case; 
   end hex_to_character; 
   -------------------------------------------------------------------------------- 
         -- the function can take multiple of 4 bits, upto 32 bits as input 
   function TO_HEX_STRING(val : std_logic_vector) return string is 
      variable temp : string(VAL'length / 4 downto 1); 
      alias valalias : std_logic_vector(VAL'length-1 downto 0) is val; 
      variable val32 : std_logic_vector(31 downto 0); 
      variable num   : integer; 
   begin 
      -- temp := "        "; 
      val32 := (others => '0'); 
      val32(val'length-1 downto 0) := valalias; 

      for i in 1 to VAL'length / 4 loop 
          temp(i) := ' '; 
        temp(i) := hex_to_character(val32(i*4-1 downto i*4-4)); 
      end loop; 
      return temp; 
   end TO_HEX_STRING; 
   -------------------------------------------------------------------------------- 
   
FUNCTION hex_to_bit_vect (char_code : character) RETURN vec4 IS
   VARIABLE result          : std_logic_vector(3 DOWNTO 0);
BEGIN
   CASE char_code IS
      WHEN '0' => result := "0000";
      WHEN '1' => result := "0001";
      WHEN '2' => result := "0010";
      WHEN '3' => result := "0011";
      WHEN '4' => result := "0100";
      WHEN '5' => result := "0101";
      WHEN '6' => result := "0110";
      WHEN '7' => result := "0111";
      WHEN '8' => result := "1000";
      WHEN '9' => result := "1001";
      WHEN 'a' => result := "1010";
      WHEN 'b' => result := "1011";
      WHEN 'c' => result := "1100";
      WHEN 'd' => result := "1101";
      WHEN 'e' => result := "1110";
      WHEN 'f' => result := "1111";
      WHEN OTHERS => result := "0000";
   END CASE;
   RETURN result;
END hex_to_bit_vect;   

FUNCTION conv_addr (addr : adr_type2) RETURN adr_type IS
   VARIABLE result          : std_logic_vector(31 DOWNTO 0);
BEGIN
   result(3 DOWNTO 0) := hex_to_bit_vect(addr(1));
   result(7 DOWNTO 4) := hex_to_bit_vect(addr(2));
   result(11 DOWNTO 8) := hex_to_bit_vect(addr(3));
   result(15 DOWNTO 12) := hex_to_bit_vect(addr(4));
   result(19 DOWNTO 16) := hex_to_bit_vect(addr(5));
   result(23 DOWNTO 20) := hex_to_bit_vect(addr(6));
   result(27 DOWNTO 24) := hex_to_bit_vect(addr(7));
   result(31 DOWNTO 28) := hex_to_bit_vect(addr(8));
   RETURN result;
END conv_addr;


FUNCTION conv_data2 (data : data_type2; adr : adr_type) RETURN data_type IS
   VARIABLE result          : std_logic_vector(31 DOWNTO 0);
BEGIN
   result := (OTHERS => '0');
   CASE adr(1 DOWNTO 0) IS
      WHEN "00" =>    result(3 DOWNTO 0) := hex_to_bit_vect(data(1));
                  result(7 DOWNTO 4) := hex_to_bit_vect(data(2));
      WHEN "01" =>    result(11 DOWNTO 8) := hex_to_bit_vect(data(1));
                  result(15 DOWNTO 12) := hex_to_bit_vect(data(2));
      WHEN "10" =>    result(19 DOWNTO 16) := hex_to_bit_vect(data(1));
                  result(23 DOWNTO 20) := hex_to_bit_vect(data(2));
      WHEN OTHERS =>    result(27 DOWNTO 24) := hex_to_bit_vect(data(1));
                  result(31 DOWNTO 28) := hex_to_bit_vect(data(2));
   END CASE;
   RETURN result;
END conv_data2;

FUNCTION conv_am (data : data_type2) RETURN am_type IS
   VARIABLE result          : std_logic_vector(7 DOWNTO 0);
BEGIN
   result(3 DOWNTO 0) := hex_to_bit_vect(data(1));
   result(7 DOWNTO 4) := hex_to_bit_vect(data(2));
   RETURN result(5 DOWNTO 0);
END conv_am;

FUNCTION conv_data4 (data : data_type4; adr : adr_type) RETURN data_type IS
   VARIABLE result          : std_logic_vector(31 DOWNTO 0);
BEGIN
   result := (OTHERS => '0');
   CASE adr(1) IS
      WHEN '0' => 
               result(3 DOWNTO 0) := hex_to_bit_vect(data(1));
               result(7 DOWNTO 4) := hex_to_bit_vect(data(2));
               result(11 DOWNTO 8) := hex_to_bit_vect(data(3));
               result(15 DOWNTO 12) := hex_to_bit_vect(data(4));
      WHEN OTHERS =>
               result(19 DOWNTO 16) := hex_to_bit_vect(data(1));
               result(23 DOWNTO 20) := hex_to_bit_vect(data(2));
               result(27 DOWNTO 24) := hex_to_bit_vect(data(3));
               result(31 DOWNTO 28) := hex_to_bit_vect(data(4));
   END CASE;
   RETURN result;
END conv_data4;

FUNCTION conv_data8 (data : data_type8) RETURN data_type IS
   VARIABLE result          : std_logic_vector(31 DOWNTO 0);
BEGIN
   result(3 DOWNTO 0) := hex_to_bit_vect(data(1));
   result(7 DOWNTO 4) := hex_to_bit_vect(data(2));
   result(11 DOWNTO 8) := hex_to_bit_vect(data(3));
   result(15 DOWNTO 12) := hex_to_bit_vect(data(4));
   result(19 DOWNTO 16) := hex_to_bit_vect(data(5));
   result(23 DOWNTO 20) := hex_to_bit_vect(data(6));
   result(27 DOWNTO 24) := hex_to_bit_vect(data(7));
   result(31 DOWNTO 28) := hex_to_bit_vect(data(8));
   RETURN result;
END conv_data8;

END vme_sim_pack;
      
   
      





   

