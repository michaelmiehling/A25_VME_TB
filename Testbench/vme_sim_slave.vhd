---------------------------------------------------------------
-- Title         : VME bus slave simmodel
-- Project       : A15
---------------------------------------------------------------
-- File          : vme_sim_slave.vhd
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
-- $Revision: 1.2 $
--
-- $Log: vme_sim_slave.vhd,v $
-- Revision 1.2  2013/04/18 15:11:16  MMiehling
-- added irq
--
-- Revision 1.1  2012/03/29 10:28:50  MMiehling
-- Initial Revision
--
-- Revision 1.3  2006/05/18 14:31:30  MMiehling
-- correct behaviour of iack
--
-- Revision 1.2  2006/05/15 10:36:23  MMiehling
-- now support of 0x0B, 0x0F, 0x3B, 0x3F => 32Bit Block Transfer
--
-- Revision 1.1  2005/10/28 17:52:18  mmiehling
-- Initial Revision
--
-- Revision 1.2  2004/08/13 15:36:06  mmiehling
-- updated
--
-- Revision 1.1  2004/07/27 17:28:15  mmiehling
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

ENTITY vme_sim_slave IS
PORT (
   sysresin       : IN std_logic;
   asn_in         : IN std_logic;
   dsan_in        : IN std_logic;
   dsbn_in        : IN std_logic;
   writen_in      : IN std_logic;
   berrn_in       : IN std_logic;
   addr           : INOUT std_logic_vector(31 DOWNTO 0);
   data_in        : IN std_logic_vector(31 DOWNTO 0);
   am_in          : IN std_logic_vector(5 DOWNTO 0);
   iackn_in       : IN std_logic;   -- daisy-chain
   iackn          : IN std_logic;   -- bussignal
   irq_out        : OUT std_logic_vector(7 DOWNTO 1);
   dtackn_out     : OUT std_logic;
   data_out       : OUT std_logic_vector(31 DOWNTO 0);
   vb_irq1n       : IN std_logic;         
   vb_irq2n       : IN std_logic;         
   vb_irq3n       : IN std_logic;         
   vb_irq4n       : IN std_logic;         
   vb_irq5n       : IN std_logic;         
   vb_irq6n       : IN std_logic;         
   vb_irq7n       : IN std_logic;         
   
   vme_slv_in     : IN vme_slv_in_type;
   vme_slv_out    : OUT vme_slv_out_type
   );
END vme_sim_slave;

ARCHITECTURE vme_sim_slave_arch OF vme_sim_slave IS 
   SUBTYPE irq_vec IS std_logic_vector(7 DOWNTO 0);
   TYPE irq_id_type IS array (7 DOWNTO 1) OF irq_vec;
   SIGNAL sim_slave_active : std_logic;
   SIGNAL iackn_in_int   : std_logic;
   SIGNAL conf_ack  : boolean;

BEGIN
   iackn_in_int <= '0' WHEN iackn_in = '0' AND (dsan_in = '0' OR dsbn_in = '0') ELSE '1';
   vme_slv_out.conf_ack <= conf_ack;       
   vme_slv_out.irq(1) <= vb_irq1n;
   vme_slv_out.irq(2) <= vb_irq2n;
   vme_slv_out.irq(3) <= vb_irq3n;
   vme_slv_out.irq(4) <= vb_irq4n;
   vme_slv_out.irq(5) <= vb_irq5n;
   vme_slv_out.irq(6) <= vb_irq6n;
   vme_slv_out.irq(7) <= vb_irq7n;


slave : PROCESS
   VARIABLE asn_time      : time;
   VARIABLE zeit         : time;
   VARIABLE addr_int      : std_logic_vector(31 DOWNTO 0);
   VARIABLE first_d64_cycle : boolean;
   VARIABLE am_int      : std_logic_vector(5 DOWNTO 0);

   VARIABLE i   : integer;
   VARIABLE ws, sd : integer;
   VARIABLE lin:line;
   VARIABLE data : std_logic_vector(31 DOWNTO 0);
   VARIABLE check:boolean;
   VARIABLE adr_int : std_logic_vector(31 DOWNTO 3);
   VARIABLE end_of_acc : std_logic;
   VARIABLE mem_head : head_ptr;
   VARIABLE allocated : boolean;
   VARIABLE irq_id : irq_id_type;
   VARIABLE irq : integer;
   
BEGIN
   mem_head          := new head'(0,null);
   sim_slave_active <= '0';
   data_out <= (OTHERS => 'Z');
   am_int := (others => '0');
   first_d64_cycle := TRUE;
   conf_ack <= vme_slv_in.conf_req;
   addr <= (OTHERS => 'H');
   dtackn_out <= 'H';
   irq_out <= (OTHERS => 'H');
   irq := 0;
   WAIT UNTIL sysresin /= '0';   --ohne EVENT
   
   
   gen_loop: LOOP   -- main loop
      data_out <= (OTHERS => 'Z');
      IF asn_in /= '0' OR (vme_slv_in.conf_req/= conf_ack) THEN
         WAIT until falling_edge(asn_in) OR vme_slv_in.conf_req'event;
      END IF;

      ----------------------------------------------------------------------------------------
      -- config access         
      ----------------------------------------------------------------------------------------
         IF vme_slv_in.conf_req /= conf_ack THEN
            IF vme_slv_in.req_type = 1 THEN
               --WRITE
               adr_int:=vme_slv_in.adr(31 DOWNTO 3);

               wr_data(conv_integer(adr_int), vme_slv_in.wr_dat, "1111", mem_head);
            ELSIF vme_slv_in.req_type = 0 THEN
               -- read from iram
               rd_data(conv_integer(vme_slv_in.adr(31 DOWNTO 3)), data, allocated, mem_head);
               vme_slv_out.rd_dat <= data;
            ELSIF vme_slv_in.req_type = 2 THEN
               -- set irq request
               irq_out(vme_slv_in.irq) <= '0';
               irq := vme_slv_in.irq;
               irq_id(irq) := vme_slv_in.wr_dat(7 DOWNTO 0);
            ELSIF vme_slv_in.req_type = 3 THEN
               -- request of last address modifier used
               vme_slv_out.rd_am <= am_int;
            END IF;
            conf_ack <= vme_slv_in.conf_req; -- handshake acknowledge
            next gen_loop;
         END IF;
         

      ----------------------------------------------------------------------------------------
      -- vme access         
      ----------------------------------------------------------------------------------------
      addr_int := addr;
      am_int := am_in;
      first_d64_cycle := TRUE;
      LOOP
         asn_time := now;
         IF NOT (dsan_in = '0' OR dsbn_in = '0') AND asn_in = '0' THEN
            WAIT until (dsan_in = '0' OR dsbn_in = '0' OR asn_in /= '0');
         END IF;
         IF asn_in /= '0' THEN 
            exit;
         END IF;
                  
         -- D64 burst         
         IF iackn /= '0' AND (
            (addr_int(31 DOWNTO 28) = sl_base_A32 AND (am_int(5 DOWNTO 0) = AM_A32_NONPRIV_MBLT OR am_int(5 DOWNTO 0) = AM_A32_SUPER_MBLT)) or
            (addr_int(23 DOWNTO 20) = sl_base_A24 AND (am_int(5 DOWNTO 0) = AM_A24_NONPRIV_MBLT OR am_int(5 DOWNTO 0) = AM_A24_SUPER_MBLT))) THEN
            sim_slave_active <= '1';
            IF writen_in = '1' THEN                                    -- READ
               WAIT FOR time_26;
               IF first_d64_cycle = FALSE THEN
                  rd_data(conv_integer(addr_int(11 DOWNTO 2)), data, allocated, mem_head);
                  addr(31 DOWNTO 24) <= data(31 DOWNTO 24);
                  addr(23 DOWNTO 16) <= data(23 DOWNTO 16);
                  addr(15 DOWNTO 8)  <= data(15 DOWNTO 8);
                  addr(7 DOWNTO 0)   <= data(7 DOWNTO 0);
                  rd_data(conv_integer(addr_int(11 DOWNTO 2)+1), data, allocated, mem_head);
                  data_out(31 DOWNTO 24) <= data(31 DOWNTO 24); 
                  data_out(23 DOWNTO 16) <= data(23 DOWNTO 16); 
                  data_out(15 DOWNTO 8)  <= data(15 DOWNTO 8);  
                  data_out(7 DOWNTO 0)   <= data(7 DOWNTO 0);   
                  addr_int := addr_int + 8;
               END IF;
               WAIT FOR time_27;
               dtackn_out <= '0';
               IF dsan_in = '0' THEN
                  WAIT until rising_edge(dsan_in);
               END IF;
               IF dsbn_in = '0' THEN
                  WAIT until rising_edge(dsbn_in);
               END IF;
               data_out <= (OTHERS => 'H');
               addr <= (OTHERS => 'H');
               WAIT FOR 10 ns;
--               WAIT FOR 120 ns;  -- extended to simulate slow slave with long dtackn active
               dtackn_out <= 'H';
            ELSE                                                -- WRITE
               IF first_d64_cycle = FALSE THEN
                  IF NOT (data_in'stable(time_8)) then
                     print("vme_sim: Data[31:0] was not stable for time(8)!");
                     ASSERT FALSE REPORT " Timingfehler! " SEVERITY error;
                  END IF;
                  IF NOT (addr'stable(time_8)) then
                     print("vme_sim: Addr[31:0] was not stable for time(8)!");
                     ASSERT FALSE REPORT " Timingfehler! " SEVERITY error;
                  END IF;
                  WAIT FOR time_28;
                  wr_data(conv_integer(addr_int(11 DOWNTO 2)), addr, "1111", mem_head);
                  wr_data(conv_integer(addr_int(11 DOWNTO 2)+1), data_in, "1111", mem_head);
                  addr_int := addr_int + 8;
               ELSE
                  WAIT FOR time_28;
               END IF;                  
               dtackn_out <= '0';
               IF dsan_in = '0' THEN
                  WAIT until rising_edge(dsan_in);
               END IF;
               IF dsbn_in = '0' THEN
                  WAIT until rising_edge(dsbn_in);
               END IF;
               WAIT FOR 10 ns;
--               WAIT FOR 120 ns;  -- extended to simulate slow slave with long dtackn active
               dtackn_out <= 'H';
            END IF;
            first_d64_cycle := FALSE;
              
         -- all normal accesses   
         ELSIF iackn /= '0' AND ( (addr_int(15 DOWNTO 12) = sl_base_A16 AND am_int(5 DOWNTO 4) = "10") OR
            (addr_int(23 DOWNTO 20) = sl_base_A24 AND am_int(5 DOWNTO 4) = "11") OR
            (addr_int(23 DOWNTO 20) = sl_base_CRCSR AND am_int(5 DOWNTO 0) = AM_CRCSR) OR
            (addr_int(31 DOWNTO 28) = sl_base_A32 AND am_int(5 DOWNTO 4) = "00") )THEN
              
            sim_slave_active <= '1';
            IF writen_in = '1' THEN                                    -- READ
               WAIT FOR (time_28 - time_27);
               dtackn_out <= '0';
               IF (dsbn_in = '0' AND dsan_in = '0' AND addr_int(1 DOWNTO 0) = "01") OR   
                  (dsbn_in = '0' AND dsan_in /= '0' AND addr_int(1 DOWNTO 0) = "01") OR   
                  (dsbn_in /= '0' AND dsan_in = '0' AND addr_int(1 DOWNTO 0) = "01") THEN
                  rd_data(conv_integer(addr_int(11 DOWNTO 2)), data, allocated, mem_head);
                  data_out(15 DOWNTO 0)    <= data(31 DOWNTO 16);
                  data_out(31 DOWNTO 16)   <= data(15 DOWNTO 0);
               ELSE
                  rd_data(conv_integer(addr_int(11 DOWNTO 2)), data, allocated, mem_head);
                  data_out <= data;
               END IF;
               IF dsan_in = '0' THEN
                  WAIT until rising_edge(dsan_in);
               END IF;
               IF dsbn_in = '0' THEN
                  WAIT until rising_edge(dsbn_in);
               END IF;
               data_out <= (OTHERS => 'H');
               WAIT FOR 10 ns;
               dtackn_out <= 'H';
            ELSE                                                -- WRITE
               IF NOT (data_in'stable(time_8)) then
                  print("vme_sim: Data[31:0] was not stable for time(8)!");
                  ASSERT FALSE REPORT " Timingfehler! " SEVERITY error;
               END IF;
               WAIT FOR time_28;
               IF addr_int(0) = '1' THEN   -- lwordn = '1' => D16
                  data := data_in(15 DOWNTO 8) & data_in(7 DOWNTO 0) & data_in(15 DOWNTO 8) & data_in(7 DOWNTO 0);
                  IF dsan_in /= '0' AND dsbn_in = '0' AND addr_int(1) = '0' THEN
                     wr_data(conv_integer(addr_int(11 DOWNTO 2)), data, "1000", mem_head);
                  ELSIF dsan_in = '0' AND dsbn_in /= '0' AND addr_int(1) = '0' THEN
                     wr_data(conv_integer(addr_int(11 DOWNTO 2)), data, "0100", mem_head);
                  ELSIF dsan_in /= '0' AND dsbn_in = '0' AND addr_int(1) = '1' THEN
                     wr_data(conv_integer(addr_int(11 DOWNTO 2)), data, "0010", mem_head);
                  ELSIF dsan_in = '0' AND dsbn_in /= '0' AND addr_int(1) = '1' THEN
                     wr_data(conv_integer(addr_int(11 DOWNTO 2)), data, "0001", mem_head);
                  ELSIF dsan_in = '0' AND dsbn_in = '0' AND addr_int(1) = '0' THEN
                     wr_data(conv_integer(addr_int(11 DOWNTO 2)), data, "1100", mem_head);
                  ELSIF dsan_in = '0' AND dsbn_in = '0' AND addr_int(1) = '1' THEN
                     wr_data(conv_integer(addr_int(11 DOWNTO 2)), data, "0011", mem_head);
                  END IF;
               ELSE
                  data := data_in;
                  IF dsan_in = '0' AND dsbn_in = '0' AND addr_int(1) = '0' THEN
                     wr_data(conv_integer(addr_int(11 DOWNTO 2)), data, "1111", mem_head);
                  END IF;
               END IF;
               dtackn_out <= '0';
                 IF dsan_in = '0' THEN
                    WAIT until rising_edge(dsan_in);
                 END IF;
                 IF dsbn_in = '0' THEN
                    WAIT until rising_edge(dsbn_in);
                 END IF;
                 WAIT FOR 10 ns;
                 dtackn_out <= 'H';
            END IF;
            -- 0x0B, 0x0F, 0x3B, 0x3F => 32Bit Block Transfer 
            IF am_int = AM_A32_NONPRIV_BLT OR am_int = AM_A32_SUPER_BLT OR am_int = AM_A24_NONPRIV_BLT OR am_int = AM_A24_SUPER_BLT THEN
               IF addr_int(0) = '0' THEN
                  addr_int := addr_int + 4;
               ELSE
                  addr_int := addr_int + 2;
               END IF;
            END IF;
            
         -- IACK-Cycle
         ELSIF iackn = '0' THEN
            IF iackn_in_int = '1' THEN
               WAIT until (falling_edge(iackn_in_int) OR rising_edge(asn_in));
               IF asn_in /= '0' THEN
                  exit;
               END IF;
            END IF;
            sim_slave_active <= '1';
            IF writen_in = '1' AND dsan_in = '0' AND dsbn_in /= '0' AND addr_int(0) = '1' THEN -- read iack D08
               IF ((irq = 1 AND addr_int(3 DOWNTO 1) = "001") OR
                (irq = 2 AND addr_int(3 DOWNTO 1) = "010") OR
                (irq = 3 AND addr_int(3 DOWNTO 1) = "011") OR
                (irq = 4 AND addr_int(3 DOWNTO 1) = "100") OR
                (irq = 5 AND addr_int(3 DOWNTO 1) = "101") OR
                (irq = 6 AND addr_int(3 DOWNTO 1) = "110") OR
                (irq = 7 AND addr_int(3 DOWNTO 1) = "111")) THEN
                  WAIT FOR time_26;
                  data_out(7 DOWNTO 0) <= irq_id(irq); -- B(0)
                  data_out(31 DOWNTO 8) <= (OTHERS => '0');
                  WAIT FOR time_27;
                  irq_out <= (OTHERS => 'H');
                  irq := 0;
                  dtackn_out <= '0';
                  IF dsan_in = '0' THEN
                     WAIT until rising_edge(dsan_in);
                  END IF;
                  data_out <= (OTHERS => 'H');
                  WAIT FOR 10 ns;
                  dtackn_out <= 'H';
               ELSE
                  WAIT until rising_edge(asn_in);
               END IF;
            ELSIF writen_in = '1' AND dsan_in = '0' AND dsbn_in = '0' AND addr_int(0) = '1' THEN -- read iack D16
               IF ((irq = 1 AND addr_int(3 DOWNTO 1) = "001") OR
                (irq = 2 AND addr_int(3 DOWNTO 1) = "010") OR
                (irq = 3 AND addr_int(3 DOWNTO 1) = "011") OR
                (irq = 4 AND addr_int(3 DOWNTO 1) = "100") OR
                (irq = 5 AND addr_int(3 DOWNTO 1) = "101") OR
                (irq = 6 AND addr_int(3 DOWNTO 1) = "110") OR
                (irq = 7 AND addr_int(3 DOWNTO 1) = "111")) THEN
                  WAIT FOR time_26;
                  data_out(7 DOWNTO 0) <= irq_id(irq); -- B(0)
                  data_out(15 DOWNTO 8) <= irq_id(irq); -- B(0)
                  data_out(31 DOWNTO 16) <= (OTHERS => '0');
                  WAIT FOR time_27;
                  irq_out <= (OTHERS => 'H');
                  irq := 0;
                  dtackn_out <= '0';
                  IF dsan_in = '0' THEN
                     WAIT until rising_edge(dsan_in);
                  END IF;
                  data_out <= (OTHERS => 'H');
                  WAIT FOR 10 ns;
                  dtackn_out <= 'H';
               ELSE
                  WAIT until rising_edge(asn_in);
               END IF;
            ELSIF writen_in = '1' AND dsan_in = '0' AND dsbn_in = '0' AND addr_int(0) = '1' THEN -- read iack D32
               IF ((irq = 1 AND addr_int(3 DOWNTO 1) = "001") OR
                (irq = 2 AND addr_int(3 DOWNTO 1) = "010") OR
                (irq = 3 AND addr_int(3 DOWNTO 1) = "011") OR
                (irq = 4 AND addr_int(3 DOWNTO 1) = "100") OR
                (irq = 5 AND addr_int(3 DOWNTO 1) = "101") OR
                (irq = 6 AND addr_int(3 DOWNTO 1) = "110") OR
                (irq = 7 AND addr_int(3 DOWNTO 1) = "111")) THEN
                  WAIT FOR time_26;
                  data_out(7 DOWNTO 0) <= irq_id(irq); -- B(0)
                  data_out(15 DOWNTO 8) <= irq_id(irq); -- B(0)
                  data_out(23 DOWNTO 16) <= irq_id(irq); -- B(0)
                  data_out(31 DOWNTO 24) <= irq_id(irq); -- B(0)
                  WAIT FOR time_27;
                  irq_out <= (OTHERS => 'H');
                  irq := 0;
                  dtackn_out <= '0';
                  IF dsan_in = '0' THEN
                     WAIT until rising_edge(dsan_in);
                  END IF;
                  data_out <= (OTHERS => 'H');
                  WAIT FOR 10 ns;
                  dtackn_out <= 'H';
               ELSE
                  WAIT until rising_edge(asn_in);
               END IF;
            ELSE
               print("vme_sim: For IRQH D08(O) dsan=0, dsbn=1, writen=1, lwordn=1!");
               ASSERT FALSE REPORT " Funktionsfehler! " SEVERITY error;
            END IF;      
         ELSE   -- if this slave is not addressed
            WAIT until rising_edge(asn_in);
         END IF;
            sim_slave_active <= '0';
      END LOOP;
   END LOOP;
END PROCESS slave;
    
END vme_sim_slave_arch;
