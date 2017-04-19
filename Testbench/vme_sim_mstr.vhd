---------------------------------------------------------------
-- Title         : VME Simulation Master Model
-- Project       : 16z002-
---------------------------------------------------------------
-- File          : vme_sim_mstr.vhd
-- Author        : Michael Miehling
-- Email         : michael.miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 14/02/12
---------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : Quartus 15.1
---------------------------------------------------------------
-- Description :
--
-- Design consists of VME Master behavioral model and an arbiter.
-- The arbiter gets active if after startup the bg3n line is '0'.
-- The master model can read or write up to 32bit and 64bit 
-- data width.
-- The control of the model is via terminal connection.
---------------------------------------------------------------
-- Hierarchy:
--
-- vme_sim_pack.vhd
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
-- $Log: vme_sim_mstr.vhd,v $
-- Revision 1.2  2013/04/18 15:11:12  MMiehling
-- rework
--
-- Revision 1.1  2012/03/29 10:28:47  MMiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.terminal_pkg.all;
USE work.vme_sim_pack.all;
USE work.print_pkg.all;

ENTITY vme_sim_mstr IS
PORT (
   sysresn        : INOUT std_logic;
   asn            : INOUT std_logic;
   dsan           : INOUT std_logic;
   dsbn           : INOUT std_logic;
   writen         : INOUT std_logic;
   dtackn         : IN std_logic;
   berrn          : INOUT std_logic;
   addr           : INOUT std_logic_vector(31 DOWNTO 0);
   data           : INOUT std_logic_vector(31 DOWNTO 0);
   am             : INOUT std_logic_vector(5 DOWNTO 0);
   iackn          : INOUT std_logic;
   iackout        : OUT std_logic;
   iackin         : IN std_logic;
   vb_irq1n       : INOUT std_logic;         
   vb_irq2n       : INOUT std_logic;         
   vb_irq3n       : INOUT std_logic;         
   vb_irq4n       : INOUT std_logic;         
   vb_irq5n       : INOUT std_logic;         
   vb_irq6n       : INOUT std_logic;         
   vb_irq7n       : INOUT std_logic;         
   vb_acfailn     : INOUT std_logic;
   bg3n_in        : IN std_logic;
   bg3n_out       : OUT std_logic;
   brn            : INOUT std_logic_vector(3 DOWNTO 0);
   bbsyn          : INOUT std_logic;

   terminal_in_x  : OUT terminal_in_type;
   terminal_out_x : IN terminal_out_type
   );
END vme_sim_mstr;

ARCHITECTURE vme_sim_mstr_arch OF vme_sim_mstr IS 
   SIGNAL mstr_in    : mstr_in_type;
   SIGNAL mstr_out   : mstr_out_type;
   SIGNAL sim_slot1  : boolean;
   SIGNAL bg3n_int   : std_logic;
   SIGNAL bg3n_sim   : std_logic;
   SIGNAL busy       : std_logic;
BEGIN
   vb_irq1n       <= 'H';      
   vb_irq2n       <= 'H';      
   vb_irq3n       <= 'H';      
   vb_irq4n       <= 'H';      
   vb_irq5n       <= 'H';      
   vb_irq6n       <= 'H';      
   vb_irq7n       <= 'H';      
   vb_acfailn     <= 'H';


   mstr_in.data      <= data;
   mstr_in.addr      <= addr;
   mstr_in.dtackn    <= dtackn ;
   mstr_in.berrn     <= berrn  ;
   mstr_in.iackin    <= iackin ;
   mstr_in.bg3n_in   <= bg3n_sim;
   mstr_in.bbsyn     <= bbsyn  ;
   mstr_in.asn       <= asn    ;
   
   sysresn  <= mstr_out.sysresn ;
   asn      <= mstr_out.asn     ;
   dsan     <= mstr_out.dsan    ;
   dsbn     <= mstr_out.dsbn    ;
   writen   <= mstr_out.writen  ;
   addr     <= mstr_out.addr    ;
   data     <= mstr_out.data    ;
   am       <= mstr_out.am      ;
   iackn    <= mstr_out.iackn   ;
   iackout  <= mstr_out.iackout ;
   brn      <= mstr_out.brn     ;
   bbsyn    <= mstr_out.bbsyn   ;
   berrn    <= mstr_out.berrn   ;
   
sl1_det: PROCESS(sysresn)
BEGIN
   IF rising_edge(sysresn) AND bg3n_in = '0' THEN
      sim_slot1 <= TRUE;
   ELSIF rising_edge(sysresn) AND bg3n_in = '1' THEN
      sim_slot1 <= FALSE;
   END IF;
END PROCESS sl1_det; 

sim_arbiter: PROCESS(bg3n_in, sysresn, bbsyn, brn, sim_slot1)
BEGIN
   IF sysresn = '0' THEN
     bg3n_int <= '1';
     bg3n_sim <= '0';
   ELSIF sim_slot1 = TRUE THEN                     -- sim model is in slot1
--      IF brn(3) = '0' AND bbsyn /= '0' THEN   -- there is a request
--         bg3n_int <= '0';
--      ELSE
--         bg3n_int <= '1';
--      END IF;
      IF mstr_out.brn(3) = '0' AND bbsyn /= '0' AND bg3n_int /= '0' THEN  -- there is a request from simmaster and no grant to dut
         bg3n_int <= '1';
         bg3n_sim <= '0';  -- grant TO simmaster
      ELSIF brn(3) = '0' AND bbsyn /= '0' THEN  -- there is a request from dut
         bg3n_int <= '0';  -- grant to dut
         bg3n_sim <= '1';
      ELSE
         bg3n_int <= '1';
         bg3n_sim <= '1';
      END IF;
   ELSE
      bg3n_int <= '1';
      bg3n_sim <= bg3n_in;
   END IF;

END PROCESS sim_arbiter;

   bg3n_out <= bg3n_int;


main: PROCESS 
   VARIABLE ind_err           : integer;
   VARIABLE err               : integer;
   VARIABLE vme_typ           : character;
   VARIABLE in_data           : std_logic_vector(31 DOWNTO 0);
   BEGIN
   -- reset phase
      err := 0;
      vme_mstr_init(mstr_out);
      terminal_in_x.done <= TRUE;
      terminal_in_x.busy <= '0';
      busy <= '0';
      
      LOOP
         WAIT on terminal_out_x.start;
         busy <= '1';
         terminal_in_x.busy <= '1';
         IF terminal_out_x.typ = 0 THEN
            vme_typ := 'b';
         ELSIF terminal_out_x.typ = 1 THEN
            vme_typ := 'w';
         ELSIF terminal_out_x.typ = 2 THEN
            vme_typ := 'l';
         ELSIF terminal_out_x.typ = 3 THEN
            vme_typ := 'd';
         ELSIF terminal_out_x.typ = 4 THEN
            vme_typ := 'i';
         ELSE
            print("vme_sim_mstr: wrong terminal.typ coding!");
         END IF;

         IF vme_typ = 'd' AND terminal_out_x.wr = 0 AND terminal_out_x.numb > 1 THEN      -- 64 bit read
            vme_mstr_read64(mstr_out, mstr_in, terminal_out_x.adr, terminal_out_x.dat, in_data, vme_typ, terminal_out_x.txt, terminal_out_x.numb, terminal_out_x.tga, err);
         ELSIF vme_typ = 'd' AND terminal_out_x.wr = 1 AND terminal_out_x.numb > 1 THEN   -- 64 bit write
            vme_mstr_write64(mstr_out, mstr_in, terminal_out_x.adr, terminal_out_x.dat, vme_typ, terminal_out_x.txt, terminal_out_x.numb, terminal_out_x.tga);
         ELSIF terminal_out_x.wr = 0 THEN                         -- 32 or 16 or 8 bit read
            vme_mstr_read(mstr_out, mstr_in, terminal_out_x.adr, terminal_out_x.dat, in_data, vme_typ, terminal_out_x.txt, terminal_out_x.numb, terminal_out_x.tga, err);
         ELSIF terminal_out_x.wr = 1 THEN                      -- 32 or 16 or 8 bit write
            vme_mstr_write(mstr_out, mstr_in, terminal_out_x.adr, terminal_out_x.dat, vme_typ, terminal_out_x.txt, terminal_out_x.numb, terminal_out_x.tga);
         ELSIF terminal_out_x.wr = 2 THEN    -- wait
            WAIT FOR terminal_out_x.numb * 10 ns;
         ELSE
            print("vme_sim_mstr: wrong terminal.wr coding!");
         END IF;
         terminal_in_x.dat <= in_data;
         terminal_in_x.err <= err;
         terminal_in_x.busy <= '0';
         busy <= '0';
         terminal_in_x.done <= terminal_out_x.start;
      END LOOP;
      
   END PROCESS;
END vme_sim_mstr_arch;
