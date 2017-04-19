---------------------------------------------------------------
-- Title         : VME bus monitor
-- Project       : A15
---------------------------------------------------------------
-- File          : vme_sim_mon.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 02/09/03
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
-- Copyright (C) 2001, MEN Mikroelektronik Nuernberg GmbH
--
--   All rights reserved. Reproduction in whole or part is 
--      prohibited without the written permission of the 
--                    copyright owner.           
---------------------------------------------------------------
--                         History                                    
---------------------------------------------------------------
-- $Revision: 1.1 $
--
-- $Log: vme_sim_mon.vhd,v $
-- Revision 1.1  2012/03/29 10:28:46  MMiehling
-- Initial Revision
--
-- Revision 1.2  2006/05/18 14:31:24  MMiehling
-- changed comment
--
-- Revision 1.1  2005/10/28 17:52:14  mmiehling
-- Initial Revision
--
-- Revision 1.1  2004/07/27 17:28:12  mmiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee,work;
USE ieee.std_logic_1164.ALL;
USE work.vme_sim_pack.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.all;
USE work.print_pkg.all;

ENTITY vme_sim_mon IS
PORT (
   rstn           : IN std_logic;
   asn_in         : IN std_logic;
   dsan_in        : IN std_logic;
   dsbn_in        : IN std_logic;
   writen_in      : IN std_logic;
   dtackn_in      : IN std_logic;
   berrn_in       : IN std_logic;
   addr_in        : IN std_logic_vector(31 DOWNTO 0);
   data_in        : IN std_logic_vector(31 DOWNTO 0);
   am_in          : IN std_logic_vector(5 DOWNTO 0);
   iackn          : IN std_logic;
   vb_irq1n       : IN std_logic;         
   vb_irq2n       : IN std_logic;         
   vb_irq3n       : IN std_logic;         
   vb_irq4n       : IN std_logic;         
   vb_irq5n       : IN std_logic;         
   vb_irq6n       : IN std_logic;         
   vb_irq7n       : IN std_logic;         
   bbsyn_in       : IN std_logic;
   
   vme_mon_out    : OUT vme_mon_out_type

  );
END vme_sim_mon;

ARCHITECTURE vme_sim_mon_arch OF vme_sim_mon IS 

BEGIN
   vme_mon_out.err <= 0;

irq_1 : PROCESS
  BEGIN
     WAIT until falling_edge(vb_irq1n);
     print_time("vme_sim_mon: IRQ1 was asserted");
     WAIT until rising_edge(vb_irq1n);
     print_time("vme_sim_mon: IRQ1 was deasserted");
  END PROCESS irq_1;

irq_2 : PROCESS
  BEGIN
     WAIT until falling_edge(vb_irq2n);
     print_time("vme_sim_mon: IRQ2 was asserted");
     WAIT until rising_edge(vb_irq2n);
     print_time("vme_sim_mon: IRQ2 was deasserted");
  END PROCESS irq_2;

irq_3 : PROCESS
  BEGIN
     WAIT until falling_edge(vb_irq3n);
     print_time("vme_sim_mon: IRQ3 was asserted");
     WAIT until rising_edge(vb_irq3n);
     print_time("vme_sim_mon: IRQ3 was deasserted");
  END PROCESS irq_3;

irq_4 : PROCESS
  BEGIN
     WAIT until falling_edge(vb_irq4n);
     print_time("vme_sim_mon: IRQ4 was asserted");
     WAIT until rising_edge(vb_irq4n);
     print_time("vme_sim_mon: IRQ4 was deasserted");
  END PROCESS irq_4;

irq_5 : PROCESS
  BEGIN
     WAIT until falling_edge(vb_irq5n);
     print_time("vme_sim_mon: IRQ5 was asserted");
     WAIT until rising_edge(vb_irq5n);
     print_time("vme_sim_mon: IRQ5 was deasserted");
  END PROCESS irq_5;

irq_6 : PROCESS
  BEGIN
     WAIT until falling_edge(vb_irq6n);
     print_time("vme_sim_mon: IRQ6 was asserted");
     WAIT until rising_edge(vb_irq6n);
     print_time("vme_sim_mon: IRQ6 was deasserted");
  END PROCESS irq_6;

irq_7 : PROCESS
  BEGIN
     WAIT until falling_edge(vb_irq7n);
     print_time("vme_sim_mon: IRQ7 was asserted");
     WAIT until rising_edge(vb_irq7n);
     print_time("vme_sim_mon: IRQ7 was deasserted");
  END PROCESS irq_7;

d_timing : PROCESS
   VARIABLE zeit : time;
  BEGIN
     WAIT until rstn = '1';
     LOOP
        WAIT until falling_edge(dtackn_in);
        IF writen_in = '1' THEN                     -- read
           IF NOT data_in'stable(time_27) THEN 
            print_time("vme_sim_mon: Data[31:0] was not stable for time(27)!");
           END IF;
           zeit:=now;
         WAIT until rising_edge(dsan_in) OR rising_edge(dsbn_in);
         IF data_in'last_active > (now-zeit) THEN
            print_time("vme_sim_mon: Data[31:0] was not stable for time(20)!");
           END IF;
           WAIT until rising_edge(dtackn_in);
           IF NOT is_x(data_in)THEN
            print_time("vme_sim_mon: Data[31:0] was not 'Z' (time(31))!");
           END IF;
        ELSE
           IF NOT data_in'stable(time_28) THEN
            print_time("vme_sim_mon: Data[31:0] was not stable for time(28)!");
           END IF;
           IF NOT dsan_in'stable(time_28) THEN
            print_time("vme_sim_mon: dsan was not stable for time(28)!");
           END IF;
           IF NOT dsbn_in'stable(time_28) THEN
            print_time("vme_sim_mon: dsbn was not stable for time(28)!");
           END IF;
           IF NOT data_in'stable(time_28 + time_8) THEN
            print_time("vme_sim_mon: dsbn was not stable for time(28)!");
           END IF;
           IF NOT (dsan_in = '0' OR dsbn_in = '0') THEN
            print_time("vme_sim_mon: dsan or dsbn must be asserted!");
           END IF;
        END IF;
   END LOOP;     
  END PROCESS d_timing;
  
adr_timing : PROCESS
   VARIABLE zeit : time;
  BEGIN
     WAIT until rstn = '1';
     LOOP
        WAIT until falling_edge(asn_in);
        zeit := now;
        WAIT until falling_edge(dtackn_in);
        IF addr_in'last_active > (now-zeit + time_4) THEN
         print_time("vme_sim_mon: addr_in was not stable for time(4) or time(14)!");
        END IF;

        WAIT until rising_edge(asn_in);
     
     END LOOP;
  END PROCESS adr_timing;  
  

--adr_x : PROCESS
--  BEGIN
--   LOOP
--        WAIT on addr_in;
--        IF is_x(addr_in)THEN
--         print_time("vme_sim_mon: addr_in[31:0] was  'X'!");
--        END IF;
--     END LOOP;
--  END PROCESS adr_x;  
--
--dat_x : PROCESS
--  BEGIN
--   LOOP
--        WAIT on data_in;
--        IF is_x(data_in)THEN
--         print_time("vme_sim_mon: data_in[31:0] was  'X'!");
--        END IF;
--     END LOOP;
--  END PROCESS dat_x;  

asn_timing : PROCESS
  BEGIN
     WAIT until rstn = '1';
     LOOP
        IF asn_in /= '0' THEN
           WAIT until asn_in = '0';
        END IF;
        WAIT FOR time_19;
        IF NOT asn_in'stable(time_19) then
         print_time("vme_sim_mon: ASn was not long enough asserted (time(19))!");
        END IF;
        IF asn_in = '0' THEN
           WAIT until asn_in /= '0';
        END IF;
     END LOOP;
  END PROCESS asn_timing;

am_timing : PROCESS
   VARIABLE am_time      : time;
  BEGIN
     WAIT until rstn = '1';
     LOOP
        IF asn_in /= '0' THEN
           WAIT until asn_in = '0';
        END IF;
        am_time := now;
      IF is_x(am_in) THEN
         print_time("vme_sim_mon: AM[5:0] is not a real value ('0' or '1')!");
      END IF;
        IF NOT am_in'stable(time_4) then
           print_time("vme_sim_mon: AM[5:0] was not stable for time(4)!");
         ASSERT FALSE REPORT " Timingfehler! " SEVERITY error;
        END IF;
      IF is_x(addr_in) THEN
         print_time("vme_sim_mon: AM[5:0] is not a real value ('0' or '1')!");
      END IF;
        IF NOT addr_in'stable(time_4) then
           print_time("vme_sim_mon: ADDR[31:0] was not stable for time(4)!");
        END IF;
      IF dtackn_in /= '0' THEN
         WAIT until dtackn_in = '0';
      END IF;
        IF am_in'last_active < (time_4 + (now - am_time)) then
           print_time("vme_sim_mon: AM[5:0] was not stable during access (time(4), time(16))!");
        END IF;
        IF addr_in'last_active < (time_4 + (now - am_time)) then
           print_time("vme_sim_mon: ADDR[31:0] was not stable during access (time(4), time(16))!");
        END IF;
        IF asn_in = '0' THEN
           WAIT until asn_in /= '0';
        END IF;
--        WAIT FOR 5 ns;   -- this time is not allowed!!!
       IF NOT is_x(addr_in) THEN
         print("vme_sim_mon: Adr[31:0] is not 'Z' after asn goes high (time(24a))!");
         ASSERT FALSE REPORT " Timingfehler! " SEVERITY warning;
      END IF;
       IF NOT is_x(am_in)  THEN
         print("vme_sim_mon: AM[5:0] is not 'Z' after asn goes high (time(24a))!");
         ASSERT FALSE REPORT " Timingfehler! " SEVERITY warning;
      END IF;
       IF NOT is_x(data_in)  THEN
         print("vme_sim_mon: Data_in[31:0] is not 'Z' after asn goes high (time(24a))!");
         ASSERT FALSE REPORT " Timingfehler! " SEVERITY warning;
      END IF;
     END LOOP;
   END PROCESS am_timing;

--write_timing : PROCESS
--   VARIABLE write_time      : time;
--  BEGIN
--      IF arst_sig = '1' THEN
--     IF dsan_in = '1' THEN
--        WAIT until dsan_in = '0';
--        write_time := now;
--        IF NOT writen_in'stable(time_12) then
--           print("vme_sim_mon: WRITEN was not stable for time(12)!");
--         ASSERT FALSE REPORT " Timingfehler! " SEVERITY error;
--        END IF;
--        IF dsan_in = '0' THEN
--           WAIT until dsan_in = '1';
--        END IF;
--        IF dsbn_in = '0' THEN
--           WAIT until dsbn_in = '1';
--        END IF;
--      WAIT FOR time_23;
--        IF writen_in'last_active > (time_12 + (now - write_time)) then
--           print("vme_sim_mon: WRITEN was not stable during access (time(12), time(23))!");
--         ASSERT FALSE REPORT " Timingfehler! " SEVERITY error;
--        END IF;
--     END IF;
--      end if;
--  END PROCESS write_timing;

   


END vme_sim_mon_arch;
