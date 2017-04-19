---------------------------------------------------------------
-- Title         : Wishbone RAM for simulation
-- Project       : -
---------------------------------------------------------------
-- File          : iram32_sim.vhd
-- Author        : michael.miehling@men.de
-- Organization  : MEN Mikro Elektronik GmbH
-- Created       : 13.12.2007
---------------------------------------------------------------
-- Simulator     : Modelsim PE 6.6
-- Synthesis     : -
---------------------------------------------------------------
-- Description :
--
-- Simulation Model of a dynamic internal 64-bit wide RAM with wishbone slave interface for single and burst accesses.
-- 
-- Features:
-- 1. Functions
-- This sim-model provides the following functions: conf_iram, wr_iram, rd_iram and deallocate_iram.
-- 1.1 conf_iram:       configure the following parameters: startdelay of address and data phase, waitstates of address and data 
--                      phase, break delay of address and data phase, enable external waitstate interface
-- 1.2 wr_iram:         write data directly to the IRAM (the wishbone interface will not be used). 
-- 1.3 rd_iram:         read data directly from the IRAM (the wishbone interface will not be used). 
-- 1.4 deallocate_iram: free the memory of the IRAM (clear the whole content). The depth of the RAM is 0 afterwards.
-- 
-- 2. Split transactions
-- The IRAM supports split transactions. Therefore the address phases and the dataphases are seperated (separate acknowledge for address 
-- phase and for data phase). To use the IRAM for regular transactions (not split transactions) the address acknowledge shall be used as 
-- acknowledge and all data waitstates have to be configured to 0. 
-- 
-- 3. External waitstate interface
-- When the external waitstate interface is enabled by the conf_iram function, the parameters for start delay, waitstates and break delay 
-- are not considered. Instead the external waitstate interface is used in the following way. 
-- 3.1 Waitstate for one address / data phase are requested by the iram (*_ws_req = true).
-- 3.2 Number of waitstates is provided to the IRAM (*_ws_in). 
-- 3.3 Waitstate is acknowledged to the IRAM (*_ws_ack = true). 
-- 3.4 Waitstate interface is reset (*_ws_req = false, *_ws_ack = false). 
-- 
-- 4. Internal waitstate generation
-- When the external waitstate interface is disabled by the conf_iram function, the parameters for start delay, waitstates and break delay 
-- are considered for address and data acknowledge generation. 
-- 4.1 Address startdelay:    The address startdelay is the amount of clock cycles from the time where wishbone strobe and cycle are both 
--                            be active till the first rising edge of the address acknowledge (this is usable for single as well as for 
--                            burst accesses). The value 0 is invalid for the address startdelay and will be treated as 1. 
-- 4.2 Address waitstates:    The amount of address waitstates represents the amount of clock cycles between a falling edge of wishbone 
--                            address acknowledge and the rising edge of wishbone address acknowledge of the next data phase of a burst 
--                            (this is usable for burst accesses only). 
-- 4.3 Address break delay:   The address break delay has two parameter for configuration: length and position. The position parameter 
--                            specifies the amount of dataphases (of a burst) where the break-delay shall appear. The length-parameter is 
--                            comparative with the waitstates (0 = break delay disabled). If the break-delay is enabled (break delay 
--                            length > 0) and appears within a burst, no additional waitstates will be produced (even if they are different 
--                            from 0).
-- 4.4 Data startdelay:       The data startdelay is the amount of clock cycles from the time where wishbone address acknowledge is active 
--                            for the first time till the first rising edge of the data acknowledge (this is usable for single as well as 
--                            for burst accesses). The value 0 is valid for the address startdelay. 
-- 4.5 Data waitstates:       The amount of data waitstates represents the amount of clock cycles between a falling edge of wishbone data 
--                            acknowledge and the rising edge of wishbone data acknowledge of the next data phase of a burst (this is 
--                            usable for burst accesses only). 
-- 4.6 Data break delay:      The address break delay has two parameter for configuration: length and position. The position parameter 
--                            specifies the amount of dataphases (of a burst) where the break-delay shall appear. The length-parameter is 
--                            comparative with the waitstates (0 = break delay disabled). If the break-delay is enabled (break delay 
--                            length > 0) and appears within a burst, no additional waitstates will be produced (even if they are different 
--                            from 0).
--
--
--
--
-- Generation of acknowledge:
--
--                                    external_ws                                                                                           
--                                         |                                                                                                
--                 +------------+          |                                                                                                
--                 | Address    |       +-----+         +-------------+                                                                     
--                 | Waitstate  |------>| MUX |-------->| Address     |-----+-------------------------------------------------------> aack  
--                 | Generation |       |     |         | Acknowledge |     |                                                               
--                 +------------+       |     |         | Generation  |     |                                                               
--                                      |     |         +-------------+     |                                                               
--       ext. address waitstates ------>|     |                             |                                                               
--                                      +-----+                             |   +-------------+                                             
--                                                                          |   | Data        |                                             
--                                                                          +-->| Phase       |                                             
--                                                                              | FIFO        |                                             
--                                                                              +-------------+                                             
--                                                                                  |                                                       
--                                                                                  |                                                       
--                                                                                  |                                                       
--                                    external_ws                                   |                                                       
--                                         |                                        |  +-------------+                                      
--                 +------------+          |                                        +->| Data        |-----+------------------------> ack   
--                 | Data       |       +-----+                                        | Acknowledge |     |                                
--                 | Waitstates |------>| MUX |--------------------------------------->| Generation  |     |                                
--                 | Generation |       |     |                                        +-------------+     |                                
--                 +------------+       |     |                                                            |                                
--                                      |     |                                                            |   +-------------+              
--          ext. data waitstates ------>|     |                                        +-------------+     +-->| Process     |------> dat_o 
--                                      +-----+                                        | Internal    |         | Data        |              
--                                                                                     | Memory      |<--------| Phase       |<------ dat_i 
--                                                                                     |             |         +-------------+              
--                                                                                     +-------------+                                      
--                                                                                                                           
--
--
---------------------------------------------------------------
-- Hierarchy:
--
-- iram32_sim.vhd
-- iram_pkg.vhd
---------------------------------------------------------------
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
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.all;
USE ieee.std_logic_textio.all;
USE work.print_pkg.all;
USE work.conversions.to_hex_str;
USE work.iram32_pkg.all;

ENTITY iram32_sim IS
GENERIC (
   rddata_sel  : boolean := TRUE; -- use wishbone byte select signal for read data
   wbname      : string := "wbmon";
   sets        : std_logic_vector(3 DOWNTO 0) := "1110";
                                             --   1110
                                             --   ||||
                                             --   |||+- write notes to Modelsim out
                                             --   ||+-- write errors to Modelsim out
                                             --   |+--- write notes to file out
                                             --   +---- write errors to file out
   timeout     : integer := 100;
   file_name   : string :="iram.txt"
   );
PORT (
   iram_in     : IN iram32_in_type;
   iram_out    : OUT iram32_out_type;
   clk         : IN std_logic;
   rst         : IN std_logic;

   stb_i       : IN std_logic;
   ack_o       : OUT std_logic;
   aack_o      : OUT std_logic;
   err_o       : OUT std_logic;
   we_i        : IN std_logic;
   sel_i       : IN std_logic_vector((DAT_BITS/8)-1 DOWNTO 0);
   cti_i       : IN std_logic_vector(2 DOWNTO 0);
   bte_i       : IN std_logic_vector(1 DOWNTO 0);
   cyc_i       : IN std_logic;
   dat_o       : OUT std_logic_vector(DAT_BITS-1 DOWNTO 0);
   dat_i       : IN std_logic_vector(DAT_BITS-1 DOWNTO 0);
   adr_i       : IN std_logic_vector(ADR_BITS-1 DOWNTO 0);

   a_ws_req    : OUT boolean;
   a_ws_ack    : IN  boolean;
   a_ws_in     : IN  natural;
   d_ws_req    : OUT boolean;
   d_ws_ack    : IN  boolean;
   d_ws_in     : IN  natural
  );
END iram32_sim;

ARCHITECTURE iram32_sim_arch OF iram32_sim IS

   SIGNAL dat_o_int : std_logic_vector(dat_o'range);
   SIGNAL ack_o_int : std_logic;
   SIGNAL aack_o_int : std_logic;
   SIGNAL err_o_int : std_logic;
   SIGNAL conf_ack  : boolean;

   SIGNAL a_ws_req_int: boolean;
   SIGNAL a_ws_ack_internal: boolean;
   SIGNAL a_ws_ack_int: boolean;
   SIGNAL a_ws_end_acc: boolean;
   SIGNAL a_ws_int: natural;
   SIGNAL a_ws_internal: natural;

   SIGNAL d_ws_req_int: boolean;
   SIGNAL d_ws_ack_internal: boolean;
   SIGNAL d_ws_ack_int: boolean;
   SIGNAL d_ws_end_acc: boolean;
   SIGNAL d_ws_int: natural;
   SIGNAL d_ws_internal: natural;
   
   SIGNAL external_ws: boolean;
   SIGNAL aack_enable : boolean;
   
   shared VARIABLE a_sd_stored      : protected_shared_variable_natural ;
   shared VARIABLE a_ws_stored      : protected_shared_variable_natural ;
   shared VARIABLE d_sd_stored      : protected_shared_variable_natural ;
   shared VARIABLE d_ws_stored      : protected_shared_variable_natural ;
   shared VARIABLE a_bd_pos_stored  : protected_shared_variable_natural ;
   shared VARIABLE a_bd_len_stored  : protected_shared_variable_natural ;
   shared VARIABLE d_bd_pos_stored  : protected_shared_variable_natural ;
   shared VARIABLE d_bd_len_stored  : protected_shared_variable_natural ;
   
   CONSTANT DEBUG_MEM_ADR_PHASE        : boolean := FALSE;
   CONSTANT DEBUG_FIFO_ENTRY           : boolean := FALSE;
   CONSTANT DEBUG_MEM_DAT_PHASE        : boolean := FALSE;
   CONSTANT DEBUG_MEM_DATA             : boolean := FALSE;

   CONSTANT DEBUG_ACK_CHECK            : boolean := FALSE;

   SIGNAL err: std_logic_vector(2 DOWNTO 0) := (OTHERS => '0');

   SIGNAL dbg_a_sd: integer := 0;
   SIGNAL dbg_a_ws: integer := 0;

   SIGNAL dbg_a_sd_valid: boolean := FALSE;
   SIGNAL dbg_a_ws_valid: boolean := FALSE;
   SIGNAL time_cnt_sig: natural := 0;
   SIGNAL dgb_ack: std_logic;
   SIGNAL dgb_ack_dut: std_logic;
   
   SIGNAL dbg_a_ws_dat_cnt: integer := 0;

BEGIN

   dat_o <= dat_o_int;
   ack_o <= ack_o_int;
   aack_o <= aack_o_int;
   err_o <= err_o_int;
   iram_out.conf_ack <= conf_ack;

----------------------------------------------------------------------------------------
-- map internal / external waitstate generation
----------------------------------------------------------------------------------------
   a_ws_req       <= a_ws_req_int   WHEN external_ws ELSE FALSE;
   a_ws_ack_int   <= a_ws_ack       WHEN external_ws ELSE a_ws_ack_internal;
   a_ws_int       <= a_ws_in        WHEN external_ws ELSE a_ws_internal;
   d_ws_req       <= d_ws_req_int   WHEN external_ws ELSE FALSE;
   d_ws_ack_int   <= d_ws_ack       WHEN external_ws ELSE d_ws_ack_internal;
   d_ws_int       <= d_ws_in        WHEN external_ws ELSE d_ws_internal;
   

----------------------------------------------------------------------------------------
-- internal address waitstate generation
----------------------------------------------------------------------------------------
address_waitstates: PROCESS
   VARIABLE dat_cnt : natural;
BEGIN
   dat_cnt := 0;
   a_ws_ack_internal <= FALSE;
   a_ws_internal <= 0;
   LOOP
      WAIT until a_ws_req_int'event;
      
      IF a_ws_req_int'event AND a_ws_req_int AND NOT external_ws THEN
         
         IF a_ws_end_acc THEN 
            dat_cnt := 0; 
         END IF;

         IF dat_cnt = 0 THEN
            a_ws_internal <= a_sd_stored.get;
         ELSIF dat_cnt = a_bd_pos_stored.get AND a_bd_pos_stored.get > 0 AND a_bd_len_stored.get > 0 THEN
            a_ws_internal <= a_bd_len_stored.get;
         ELSE
            a_ws_internal <= a_ws_stored.get;
         END IF;
         dat_cnt := dat_cnt + 1;
         gen_ack(a_ws_req_int, a_ws_ack_internal);
      END IF;
      dbg_a_ws_dat_cnt <= dat_cnt;
   END LOOP;
END PROCESS;


----------------------------------------------------------------------------------------
-- internal data waitstate generation
----------------------------------------------------------------------------------------
data_waitstates: PROCESS
   VARIABLE dat_cnt : natural;
BEGIN
   dat_cnt := 0;
   d_ws_ack_internal <= FALSE;
   d_ws_internal <= 0;
   LOOP
      WAIT until d_ws_req_int'event;
      
      IF d_ws_end_acc THEN 
         dat_cnt := 0;
      END IF;

      IF d_ws_req_int'event AND d_ws_req_int AND NOT external_ws THEN
         IF dat_cnt = 0 THEN
            d_ws_internal <= d_sd_stored.get;
         ELSIF dat_cnt = d_bd_pos_stored.get AND d_bd_pos_stored.get > 0 AND d_bd_len_stored.get > 0 THEN
            d_ws_internal <= d_bd_len_stored.get;
         ELSE
            d_ws_internal <= d_ws_stored.get;
         END IF;
         dat_cnt := dat_cnt + 1;
         gen_ack(d_ws_req_int, d_ws_ack_internal);
      END IF;
   END LOOP;
END PROCESS;


----------------------------------------------------------------------------------------
-- main 
----------------------------------------------------------------------------------------
PROCESS
   VARIABLE data : std_logic_vector(dat_o'range);
   VARIABLE astart_done, dstart_done :boolean;
   VARIABLE mem_head : iram32_head_ptr;
   VARIABLE allocated : boolean;
   VARIABLE acc_req_buf : iram32_acc_req_buffer;
   VARIABLE acc_req_wrptr : integer:=0;
   VARIABLE acc_req_rdptr : integer:=0;
   VARIABLE wradr_buf : iram32_wradr_buffer;
   VARIABLE wradr_wrptr : integer:=0;
   VARIABLE wradr_rdptr : integer:=0;
   VARIABLE wrdat_buf : iram32_wrdat_buffer;
   VARIABLE wrdat_wrptr : integer:=0;
   VARIABLE wrdat_rdptr : integer:=0;
   VARIABLE msg_rd : boolean := FALSE;
   VARIABLE msg_wr : boolean := FALSE;
   VARIABLE conf_ack_int : boolean;
   
   VARIABLE a_ws_cnt : integer := 0;
   VARIABLE d_ws_cnt : integer := 0;

   VARIABLE temp_stb_i       : std_logic;
   VARIABLE temp_ack_o       : std_logic;
   VARIABLE temp_aack_o      : std_logic;
   VARIABLE temp_err_o       : std_logic;
   VARIABLE temp_we_i        : std_logic;
   VARIABLE temp_sel_i       : std_logic_vector(sel_i'range);
   VARIABLE temp_cti_i       : std_logic_vector(cti_i'range);
   VARIABLE temp_bte_i       : std_logic_vector(bte_i'range);
   VARIABLE temp_cyc_i       : std_logic;
   VARIABLE temp_dat_o       : std_logic_vector(dat_o'range);
   VARIABLE temp_dat_i       : std_logic_vector(dat_i'range);
   VARIABLE temp_adr_i       : std_logic_vector(adr_i'range);

   
   VARIABLE aack_o_int_var   : std_logic;
   VARIABLE ack_o_int_var    : std_logic;
   VARIABLE adr_int_read     : std_logic_vector(adr_i'range);
   
   VARIABLE acc_running      : boolean;
   VARIABLE time_cnt_var: natural := 0;
   VARIABLE st_flag           : boolean;
   VARIABLE rising_edge_clk: boolean;
   
   BEGIN
      mem_head := new iram32_head'(0,null);
      IF sets(0) = '1' THEN
         msg_rd := TRUE;
         msg_wr := TRUE;
      END IF;
      ack_o_int <= '0';
      aack_o_int <= '0';
      err_o_int <= '0';
      dat_o_int <= (OTHERS => '0');
      conf_ack <= iram_in.conf_req;
      iram_out.rd_dat <= (OTHERS => '0');
      a_ws_req_int <= FALSE;
      a_ws_end_acc <= FALSE;
      d_ws_req_int <= FALSE;
      d_ws_end_acc <= FALSE;
      acc_running := FALSE;
      acc_req_wrptr  := 0;
      acc_req_rdptr  := 0;
      wradr_wrptr    := 0;
      wradr_rdptr    := 0;
      wrdat_wrptr    := 0;
      wrdat_rdptr    := 0;
      a_ws_cnt       := 0;
      d_ws_cnt       := 0;
      astart_done := FALSE;
      dstart_done := FALSE;
      conf_ack_int := FALSE;

      WAIT until rising_edge(clk) AND rst = '0';   -- wait until bus has initialized


      a_ws_cnt := 0;
      gen_loop: LOOP

         -- access running indication (used to delay config accesses when whishbone access is being performed)
         IF acc_req_wrptr /= acc_req_rdptr OR (temp_stb_i = '1' AND temp_cyc_i = '1') THEN
            acc_running := TRUE;
         ELSE
            acc_running := FALSE;
         END IF;
   

         rising_edge_clk := FALSE;
         IF rising_edge(clk) THEN
            WAIT FOR 1 ps;
            -- store Wishbone signals at delayed rising edge of clk
            temp_stb_i  := stb_i  ;
            temp_ack_o  := ack_o_int  ;
            temp_aack_o := aack_o_int ;
            temp_err_o  := err_o_int  ;
            temp_we_i   := we_i   ;
            temp_sel_i  := sel_i  ;
            temp_cti_i  := cti_i  ;
            temp_bte_i  := bte_i  ;
            temp_cyc_i  := cyc_i  ;
            temp_dat_o  := dat_o_int  ;
            temp_dat_i  := dat_i  ;
            temp_adr_i  := adr_i  ;  
            rising_edge_clk := TRUE;
         END IF;




         --**************************************************************************************
         -- Config Access
         --
         -- Wait until running accesses have finished and handle config request. 
         --**************************************************************************************
         IF iram_in.conf_req = TRUE AND conf_ack_int = FALSE AND acc_running = FALSE THEN -- config access is only performed when no access is running
            IF iram_in.config = TRUE THEN
               a_sd_stored.set(iram_in.a_startdelay);
               a_ws_stored.set(iram_in.a_waitstates);
               d_sd_stored.set(iram_in.d_startdelay);
               d_ws_stored.set(iram_in.d_waitstates);
               a_bd_pos_stored.set(iram_in.a_break_delay_position);
               a_bd_len_stored.set(iram_in.a_break_delay_length);
               d_bd_pos_stored.set(iram_in.d_break_delay_position);
               d_bd_len_stored.set(iram_in.d_break_delay_length);
               external_ws <= iram_in.external_ws;
            ELSIF iram_in.write_req = TRUE THEN
               -- write to iram
               wr_data(to_integer(signed(iram_in.adr)), iram_in.wr_dat, "1111", mem_head, msg_wr);
            ELSE
               -- read from iram
               rd_data(to_integer(signed(iram_in.adr)), data, allocated, mem_head, msg_rd);
               iram_out.rd_dat <= data;
            END IF;
            conf_ack_int := TRUE; -- handshake acknowledge
            conf_ack <= conf_ack_int;
            WAIT until iram_in.conf_req = FALSE;
            conf_ack_int := FALSE; -- handshake acknowledge
            conf_ack <= conf_ack_int;
            
         END IF;








         IF rising_edge_clk THEN

            time_cnt_var := time_cnt_var + 1;


            --**************************************************************************************
            -- Wishbone Access
            --
            --**************************************************************************************
            IF temp_stb_i = '1' AND temp_cyc_i = '1' THEN







               --**************************************************************************************
               -- Generate Address Acknowledge
               --
               -- Detect start of Wishbone access. Request waitstates for the current data phase. 
               -- Generate address acknowledge after the waitstates have been processed. 
               -- Indicate the end of an access to the address waitstate generation engine. 
               --**************************************************************************************
               IF temp_we_i = '0' OR (temp_we_i = '1' AND acc_req_wrptr = acc_req_rdptr) THEN
               IF NOT astart_done THEN                                    -- detected start of burst
                  IF DEBUG_MEM_ADR_PHASE THEN REPORT "DEBUG_MEM_ADR_PHASE 1: first address phase detected" SEVERITY NOTE; END IF;
                  astart_done := TRUE;                                     -- mark start of burst as done
                  gen_req(a_ws_req_int, a_ws_ack_int);                  -- get address waitstates
                  a_ws_end_acc <= FALSE; -- acknowledged by gen_req()
                  a_ws_cnt := 0;                                        -- set address waitstate counter 
                  adr_int_read := temp_adr_i;                           -- store address because internally incremented

                  IF temp_cti_i = "001" OR temp_cti_i = "011" THEN
                     st_flag := TRUE;
                  ELSE
                     st_flag := FALSE;
                  END IF;

               ELSIF temp_aack_o = '1' THEN                             -- end of burst and acknowledge was set for the last clock cycle
                  IF DEBUG_MEM_ADR_PHASE THEN REPORT "DEBUG_MEM_ADR_PHASE 2: address phase finished" SEVERITY NOTE; END IF;
                  gen_req(a_ws_req_int, a_ws_ack_int);                  -- get address waitstates
--                  a_ws_end_acc <= FALSE; -- acknowledged by gen_req()
                  a_ws_cnt := 0;                                        -- set address waitstate counter 
               ELSE                                                        -- insert waitstate
                  IF DEBUG_MEM_ADR_PHASE THEN REPORT "DEBUG_MEM_ADR_PHASE 5: ELSE" SEVERITY NOTE; END IF;
                  IF a_ws_cnt < a_ws_int THEN
                     a_ws_cnt := a_ws_cnt + 1;                                -- increment waitstate counter
                  END IF;
               END IF;
            END IF;
            END IF;
            --IF DEBUG_MEM_ADR_PHASE THEN REPORT "DEBUG_MEM_ADR_PHASE 8: a_ws_cnt=" & integer'image(a_ws_cnt) & " a_ws_int=" & integer'image(a_ws_int) SEVERITY NOTE; END IF;

            IF astart_done AND a_ws_cnt >= a_ws_int THEN
               aack_o_int_var := '1';
            ELSE 
               aack_o_int_var := '0';
            END IF;
            

            -- handle end of access for address phase
            IF temp_stb_i = '0' OR temp_cyc_i = '0' THEN -- previous clock cycle was idle
               astart_done := FALSE;
               a_ws_end_acc <= TRUE;
               --IF DEBUG_MEM_ADR_PHASE THEN REPORT "DEBUG_MEM_ADR_PHASE 6: set astart_done=false" SEVERITY NOTE; END IF;
            ELSIF temp_stb_i = '1' AND temp_cyc_i = '1'AND aack_o_int_var = '1' AND (temp_cti_i = "000" OR temp_cti_i = "111" OR temp_cti_i = "001") THEN -- clock cycle is access and last data phase
               astart_done := FALSE;
               a_ws_end_acc <= TRUE;
               --IF DEBUG_MEM_ADR_PHASE THEN REPORT "DEBUG_MEM_ADR_PHASE 7: set astart_done=false" SEVERITY NOTE; END IF;
            END IF;

            aack_o_int <= aack_o_int_var;
            












            --**************************************************************************************
            -- Store address phase into data phase FIFO
            --
            -- Store the current address phase. 
            --**************************************************************************************
            IF aack_o_int_var = '1' THEN

               IF temp_we_i = '1' THEN                -- store address phase in FIFO in case of address acknowledge (write access)
                  -- store address phase to WRADR FIFO
                  IF DEBUG_FIFO_ENTRY THEN REPORT "DEBUG_FIFO_ENTRY 1: write: address phase = " & to_hex_str(adr_int_read) SEVERITY NOTE; END IF;
                  wradr_buf(wradr_wrptr).adr    := adr_int_read;
                  incr(wradr_wrptr, WRDAT_BUFFER_SIZE, WRAP_ON);
               END IF;


               IF temp_we_i = '1' AND  DEBUG_FIFO_ENTRY THEN REPORT "DEBUG_FIFO_ENTRY 2: write to adr_int_read = "     & to_hex_str(adr_int_read) SEVERITY NOTE;
               ELSIF                   DEBUG_FIFO_ENTRY THEN REPORT "DEBUG_FIFO_ENTRY 3: read from adr_int_read = " & to_hex_str(adr_int_read) SEVERITY NOTE;
               END IF;

               acc_req_buf(acc_req_wrptr).we  := temp_we_i;
               acc_req_buf(acc_req_wrptr).adr := adr_int_read;
               acc_req_buf(acc_req_wrptr).cti := temp_cti_i;
               acc_req_buf(acc_req_wrptr).eob_flag := FALSE;                  -- not end of burst delimiter
               acc_req_buf(acc_req_wrptr).st_flag := st_flag;
               acc_req_buf(acc_req_wrptr).time_cnt := time_cnt_var;
               incr(acc_req_wrptr, ACC_REQ_BUFFER_SIZE, WRAP_ON);
               IF DAT_BITS = 64 THEN
                  IF temp_cti_i = "011" AND adr_int_read(4 DOWNTO 3) = "11" THEN   -- current address is stored for Linear Incrementing / Cache Line Wrap Burst
                     adr_int_read := std_logic_vector(unsigned(adr_int_read) - 3*8);
                  ELSE
                     adr_int_read := std_logic_vector(unsigned(adr_int_read) + 8);
                  END IF;
               ELSIF DAT_BITS = 32 THEN
                  IF temp_cti_i = "011" AND adr_int_read(3 DOWNTO 2) = "11" THEN   -- current address is stored for Linear Incrementing / Cache Line Wrap Burst
                     adr_int_read := std_logic_vector(unsigned(adr_int_read) - 3*4);
                  ELSE
                     adr_int_read := std_logic_vector(unsigned(adr_int_read) + 4);
                  END IF;
               ELSE 
                  REPORT "WRONG DATA WIDTH " SEVERITY NOTE;
               END IF;
            END IF;






            --**************************************************************************************
            -- Store end of access delimiter into data phase FIFO
            --
            -- Store a delimiter entry into data phase FIFO after the last address phases of an access 
            -- was stored. 
            --**************************************************************************************
            IF aack_o_int_var = '1' AND (temp_cti_i = "000" OR temp_cti_i = "111" OR temp_cti_i = "001") THEN     -- end of burst has been reached -> store delimiter
               IF DEBUG_FIFO_ENTRY THEN REPORT "DEBUG_FIFO_ENTRY 1: write eob " SEVERITY NOTE; END IF;
               acc_req_buf(acc_req_wrptr).we  := '0';
               acc_req_buf(acc_req_wrptr).adr := adr_int_read;
               acc_req_buf(acc_req_wrptr).cti := temp_cti_i;
               acc_req_buf(acc_req_wrptr).eob_flag := TRUE;                   -- end of burst delimiter
               acc_req_buf(acc_req_wrptr).st_flag := FALSE;
               acc_req_buf(acc_req_wrptr).time_cnt := time_cnt_var;
               incr(acc_req_wrptr, ACC_REQ_BUFFER_SIZE, WRAP_ON);
            END IF;











            --**************************************************************************************
            -- Handle end of access delimiter
            --
            -- Read all delimers out of data phase FIFO. Set the generation of data acknowledges to 
            -- an initial state. 
            --**************************************************************************************
            while acc_req_wrptr /= acc_req_rdptr AND acc_req_buf(acc_req_rdptr).eob_flag LOOP              -- special buffer entry: end of burst
               IF DEBUG_MEM_DAT_PHASE THEN REPORT "DEBUG_MEM_DAT_PHASE 1: eob_flag" SEVERITY NOTE; END IF;
               d_ws_end_acc <= TRUE;                                 -- set flag d_ws_end_acc (reset automatic waitstate generation)
               dstart_done := FALSE;                                 -- indicate start of read burst is not handled yet
               incr(acc_req_rdptr, ACC_REQ_BUFFER_SIZE, WRAP_ON);
            END LOOP;




            --**************************************************************************************
            -- Generate Data Acknowledge
            --
            -- Read data phases out of data phase FIFO. Request waitstates for the current data phase. 
            -- Generate data acknowledge after the waitstates have been processed. 
            -- Indicate the end of an access to the data waitstate generation engine. 
            --**************************************************************************************
            ack_o_int_var := '0';
            IF acc_req_wrptr /= acc_req_rdptr THEN
               
               -- write access (any data phase)
               IF acc_req_buf(acc_req_rdptr).we = '1' THEN 
                  IF DEBUG_MEM_DAT_PHASE THEN REPORT "DEBUG_MEM_DAT_PHASE 2: write: ack of write access (d_ws_int = 0)" SEVERITY NOTE; END IF;
                     dstart_done := TRUE;                                     -- indicate start of access was handled
                     gen_req(d_ws_req_int, d_ws_ack_int);                     -- get waitstates
                     d_ws_end_acc <= FALSE;
                     d_ws_cnt := d_ws_int;                                    -- set waitstate counter to immediately generate the acknowledge (no waitstates for write access)

               -- read access (first or following data phase)
               ELSIF dstart_done = FALSE OR d_ws_cnt >= d_ws_int THEN
                  gen_req(d_ws_req_int, d_ws_ack_int);                        -- get waitstates
                  d_ws_end_acc <= FALSE;
                  IF acc_req_buf(acc_req_rdptr).st_flag = TRUE THEN
                     d_ws_cnt := 0;                                           -- enable data waitstates for split transaction
                  ELSE
                     d_ws_cnt := d_ws_int;                                    -- disable data waitstates for non-split transaction
                  END IF;
                  IF DEBUG_MEM_DAT_PHASE THEN REPORT "DEBUG_MEM_DAT_PHASE 3: read: dstart_done=" & boolean'image(dstart_done) & " d_ws_cnt=" & integer'image(d_ws_cnt) & ", d_ws_int=" & integer'image(d_ws_int)  SEVERITY NOTE; END IF;

                  -- ensure that data startdelay is hold
                  IF dstart_done = FALSE THEN
                     WHILE acc_req_buf(acc_req_rdptr).time_cnt /= time_cnt_var LOOP
                        d_ws_cnt := d_ws_cnt + 1;
                        acc_req_buf(acc_req_rdptr).time_cnt := acc_req_buf(acc_req_rdptr).time_cnt + 1;
                     END LOOP;
                  END IF;
                  dstart_done := TRUE;                                        -- indicate start of access was handled
                  IF DEBUG_MEM_DAT_PHASE THEN REPORT "DEBUG_MEM_DAT_PHASE 3a: read: d_ws_cnt=" & integer'image(d_ws_cnt) & ", d_ws_int=" & integer'image(d_ws_int)  SEVERITY NOTE; END IF;

               -- insert waitstates for read access
               ELSE
                  IF DEBUG_MEM_DAT_PHASE THEN REPORT "DEBUG_MEM_DAT_PHASE 4: ELSE" SEVERITY NOTE; END IF;
                  IF d_ws_cnt < d_ws_int THEN
                     d_ws_cnt := d_ws_cnt + 1;                                -- increment waitstate counter
                  END IF;
               END IF;

            END IF;


            -- set data acknowledge in case all waitstates have been processed
            IF dstart_done AND d_ws_cnt >= d_ws_int AND acc_req_wrptr /= acc_req_rdptr THEN
               ack_o_int_var := '1';
            ELSE 
               ack_o_int_var := '0';
            END IF;








            --**************************************************************************************
            -- Process Data Phase
            --
            -- Handle the current data phase when the data acknowledge is set. For write accesses 
            -- write the input data of Wishbone bus to internal memory For read accesses perform a
            -- read access to internal memory and output the read data on Wishbone interface. 
            --**************************************************************************************
            IF ack_o_int_var = '1' THEN
               IF acc_req_buf(acc_req_rdptr).we = '0' THEN 
                  IF DEBUG_MEM_DATA THEN REPORT "DEBUG_MEM_DATA 1: read data from address " & to_hex_str(acc_req_buf(acc_req_rdptr).adr) SEVERITY NOTE; END IF;
                  rd_data(to_integer(signed(acc_req_buf(acc_req_rdptr).adr)), data, allocated, mem_head, msg_rd);
                  dat_o_int <= (OTHERS => '0');
                  IF rddata_sel THEN
                     FOR i IN temp_sel_i'low TO temp_sel_i'high LOOP
                        IF temp_sel_i(i) = '1' THEN
                           dat_o_int(i*8+7 DOWNTO i*8) <= data(i*8+7 DOWNTO i*8);
                        END IF;
                     END LOOP;
                  ELSE
                     dat_o_int <= data;
                  END IF;
               ELSE
                  wr_data(to_integer(signed(acc_req_buf(acc_req_rdptr).adr)), temp_dat_i, temp_sel_i, mem_head, msg_wr);
               END IF;
               incr(acc_req_rdptr, ACC_REQ_BUFFER_SIZE, WRAP_ON);
            END IF;

            ack_o_int <= ack_o_int_var;






            --**************************************************************************************
            -- Handle end of access delimiter   (second time - if more access delimiters are stored 
            --                                  after end of access)
            --
            -- Read all delimers out of data phase FIFO. Set the generation of data acknowledges to 
            -- an initial state. 
            --**************************************************************************************
            while acc_req_wrptr /= acc_req_rdptr AND acc_req_buf(acc_req_rdptr).eob_flag LOOP              -- special buffer entry: end of burst
               IF DEBUG_MEM_DAT_PHASE THEN REPORT "DEBUG_MEM_DAT_PHASE 1: eob_flag" SEVERITY NOTE; END IF;
               d_ws_end_acc <= TRUE;                                 -- set flag d_ws_end_acc (reset automatic waitstate generation)
               dstart_done := FALSE;                                 -- indicate start of read burst is not handled yet
               incr(acc_req_rdptr, ACC_REQ_BUFFER_SIZE, WRAP_ON);
            END LOOP;



         END IF;

         IF rst /= '1' THEN
            WAIT until rising_edge(clk) OR iram_in.conf_req'event OR rst = '1';
         END IF;
         IF rst = '1' THEN
            exit gen_loop;
         END IF;




      END LOOP gen_loop;
   END PROCESS;























--**************************************************************************************
-- Acknowledge Check
--
-- Check address acknowledge: detect startdelay and waitstates and check against the 
--                            IRAM configuration
-- Check data acknowledge   : use IRAM configuration to generate a reference acknowledge 
--                            and check against data acknowledge of IRAM model
--
-- Note: The acknowledge check is disabled for external waitstates and break delay. 
--**************************************************************************************

   PROCESS
   BEGIN
      WAIT until unsigned(err) /= 0;
      WAIT until rising_edge(clk);
      WAIT until rising_edge(clk);
      WAIT until rising_edge(clk);
      WAIT until rising_edge(clk);
      WAIT until rising_edge(clk);
      REPORT "IRAM: END ON ERROR" SEVERITY failure;
   END PROCESS;


   PROCESS
      VARIABLE time_cnt: natural := 0;
      CONSTANT ACK_ARRAY_SIZE: natural := 100; 
      TYPE ack_array_type IS array (ACK_ARRAY_SIZE-1 DOWNTO 0) OF natural;
      VARIABLE ack_array: ack_array_type;
      VARIABLE ack_array_wrptr: natural;
      VARIABLE ack_array_rdptr: natural;
      VARIABLE ack_array_last_entry: natural;

      VARIABLE first_adr_phase: boolean := TRUE;
      VARIABLE a_ws: integer := 0;
      VARIABLE a_ws_cnt: integer := 0;

      VARIABLE dbg_d_sd_stored: integer;
      VARIABLE dbg_d_ws_stored: integer;
      VARIABLE st_flag: boolean;
      VARIABLE disable: boolean := FALSE;
      
      VARIABLE st_rd_access: boolean;
      VARIABLE st_rd_access_q: boolean;
   BEGIN
      -- initialize aack array   
      FOR i1 IN ACK_ARRAY_SIZE-1 DOWNTO 0 LOOP
         ack_array(i1) := 0;
      END LOOP;
      ack_array_rdptr := 0;
      ack_array_wrptr := 0;

      LOOP
      WAIT until rising_edge(clk) OR (iram_in.conf_req'event AND iram_in.conf_req = FALSE);
         
         dbg_a_sd_valid <= FALSE;
         dbg_a_ws_valid <= FALSE;

            IF iram_in.conf_req'event AND iram_in.conf_req = FALSE THEN
               dbg_d_sd_stored := iram_in.d_startdelay;
               dbg_d_ws_stored := iram_in.d_waitstates;
               IF iram_in.d_break_delay_length     /= 0 OR
                  iram_in.d_break_delay_position   /= 0 OR
                  iram_in.a_break_delay_length     /= 0 OR
                  iram_in.a_break_delay_position   /= 0 OR
                  iram_in.external_ws              /= FALSE THEN
                  disable := TRUE;
               ELSE
                  disable := FALSE;
               END IF;
                  
            END IF;

            IF rising_edge(clk) AND NOT disable THEN
      
      
   
               dgb_ack_dut <= ack_o_int;
   
   
   
      
            -- check detect aack and store expected ack in FIFO
            -- detect address phases
            IF stb_i = '1' AND cyc_i = '1' THEN


               IF aack_o_int = '1' AND first_adr_phase = TRUE THEN
                  IF DEBUG_ACK_CHECK THEN print_now("IRAM DEBUG: first address phase with aack=1, a_ws=" & integer'image(a_ws)); END IF;
                  first_adr_phase := FALSE;
                  st_rd_access_q := st_rd_access;
                  IF (cti_i = "011" OR cti_i = "001") AND we_i = '0' THEN
                     st_rd_access := TRUE;
                  ELSE
                     st_rd_access := FALSE;
                  END IF;

                  dbg_a_sd <= a_ws_cnt;
                  IF st_rd_access_q = TRUE AND we_i = '1' THEN
                     dbg_a_sd_valid <= FALSE;
                  ELSE
                     dbg_a_sd_valid <= TRUE;
                  END IF;
                  IF cti_i = "001" OR cti_i = "011" THEN
                     st_flag := TRUE;
                  ELSE 
                     st_flag := FALSE;
                  END IF;

                  IF we_i = '1' OR st_flag = FALSE THEN 
                     ack_array(ack_array_wrptr) := time_cnt;
                  ELSE
                     ack_array(ack_array_wrptr) := time_cnt + dbg_d_sd_stored;
                     ack_array_last_entry       := ack_array(ack_array_wrptr);
                  END IF;

                  IF ack_array_wrptr = ACK_ARRAY_SIZE-1 THEN 
                     ack_array_wrptr := 0;
                  ELSE
                     ack_array_wrptr := ack_array_wrptr + 1;
                  END IF;
                  IF ack_array_wrptr = ack_array_rdptr THEN REPORT "FATAL ERROR: ack_array overflow" SEVERITY failure; END IF;


               ELSIF aack_o_int = '1' THEN
                  IF DEBUG_ACK_CHECK THEN print_now("IRAM DEBUG: address phase: cti=0b010, a_ws=" & integer'image(a_ws)); END IF;
                  dbg_a_ws <= a_ws_cnt;
                  dbg_a_ws_valid <= TRUE;
                  
                  IF we_i = '1' OR st_flag = FALSE THEN 
                     ack_array(ack_array_wrptr) := time_cnt;
                  ELSE
                     IF time_cnt > ack_array_last_entry+1 THEN 
                        ack_array(ack_array_wrptr) := time_cnt + dbg_d_ws_stored;
                     ELSE 
                        ack_array(ack_array_wrptr) := ack_array_last_entry+1 + dbg_d_ws_stored;
                     END IF;
                  END IF;
                  ack_array_last_entry       := ack_array(ack_array_wrptr);
                  IF ack_array_wrptr = ACK_ARRAY_SIZE-1 THEN 
                     ack_array_wrptr := 0;
                  ELSE
                     ack_array_wrptr := ack_array_wrptr + 1;
                  END IF;
                  IF ack_array_wrptr = ack_array_rdptr THEN REPORT "FATAL ERROR: ack_array overflow" SEVERITY failure; END IF;
   
  
               ELSIF aack_o_int = '0' THEN
                  a_ws_cnt := a_ws_cnt + 1;
               END IF;
            END IF;

            IF (stb_i = '1' AND cyc_i = '1' AND aack_o_int = '1' AND (cti_i = "000" OR cti_i = "111" OR cti_i = "001") ) OR
               stb_i = '0' OR cyc_i = '0' THEN
               first_adr_phase := TRUE;
            END IF;

            IF (stb_i = '1' AND cyc_i = '1' AND aack_o_int = '1' ) OR
               stb_i = '0' OR cyc_i = '0' THEN
               a_ws_cnt := 0;
            END IF;
      
            IF stb_i = '1' AND cyc_i = '1' THEN
               IF DEBUG_ACK_CHECK THEN print_now("IRAM DEBUG: a_ws_cnt=" & integer'image(a_ws_cnt)); END IF;
            END IF;
   
   
   
   
   
   
            -- generate reference ack
            dgb_ack <= '0';
            IF ack_array_wrptr /= ack_array_rdptr THEN
               IF DEBUG_ACK_CHECK THEN print_now("ack_array_wrptr=" & integer'image(ack_array_wrptr) & ", ack_array_rdptr=" & integer'image(ack_array_rdptr)); END IF;
               IF DEBUG_ACK_CHECK THEN print_now("ack_array(ack_array_rdptr)=" & integer'image(ack_array(ack_array_rdptr)) & ", time_cnt=" & integer'image(time_cnt)); END IF;
               IF time_cnt >= ack_array(ack_array_rdptr) THEN 
                  dgb_ack <= '1';
                  IF ack_array_rdptr = ACK_ARRAY_SIZE-1 THEN 
                     ack_array_rdptr := 0;
                  ELSE
                     ack_array_rdptr := ack_array_rdptr + 1;
                  END IF;
               END IF;
            END IF;
   
   

         time_cnt := time_cnt + 1;
         time_cnt_sig <= time_cnt;
         END IF;
      END LOOP;
      
   END PROCESS;



   PROCESS
      VARIABLE disable: boolean := FALSE;
   BEGIN
      WAIT until rising_edge(clk) OR (iram_in.conf_req'event AND iram_in.conf_req = FALSE);

      IF iram_in.conf_req'event AND iram_in.conf_req = FALSE THEN
         IF iram_in.d_break_delay_length     /= 0 OR
            iram_in.d_break_delay_position   /= 0 OR
            iram_in.a_break_delay_length     /= 0 OR
            iram_in.a_break_delay_position   /= 0 OR
            iram_in.external_ws              /= FALSE THEN
            disable := TRUE;
         ELSE
            disable := FALSE;
         END IF;
      END IF;

      IF rising_edge(clk) AND NOT disable THEN
         err(2) <= '0';
         IF dgb_ack /= dgb_ack_dut THEN
            print_now("ERROR: dgb_ack_dut = " & std_logic'image(dgb_ack_dut) & " but shall be " & std_logic'image(dgb_ack));
            err(2) <= '1';
         END IF;
      END IF;
   END PROCESS;

   PROCESS
      VARIABLE disable: boolean := FALSE;
      VARIABLE dbg_a_sd_stored: integer;
   BEGIN
      WAIT until rising_edge(clk) OR (iram_in.conf_req'event AND iram_in.conf_req = FALSE);
      
      IF iram_in.conf_req'event AND iram_in.conf_req = FALSE THEN
         dbg_a_sd_stored := iram_in.a_startdelay;
         IF iram_in.d_break_delay_length     /= 0 OR
            iram_in.d_break_delay_position   /= 0 OR
            iram_in.a_break_delay_length     /= 0 OR
            iram_in.a_break_delay_position   /= 0 OR
            iram_in.external_ws              /= FALSE THEN
            disable := TRUE;
         ELSE
            disable := FALSE;
         END IF;
      END IF;
      
      IF rising_edge(clk) AND NOT disable THEN
         IF dbg_a_sd_valid THEN
            err(0) <= '0';
            IF dbg_a_sd /= dbg_a_sd_stored THEN
               print_now("ERROR: dbg_a_sd = " & integer'image(dbg_a_sd) & " but shall be " & integer'image(dbg_a_sd_stored));
               err(0) <= '1';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS
      VARIABLE disable: boolean := FALSE;
      VARIABLE dbg_a_ws_stored: integer;
   BEGIN
      WAIT until rising_edge(clk) OR (iram_in.conf_req'event AND iram_in.conf_req = FALSE);
      
      IF iram_in.conf_req'event AND iram_in.conf_req = FALSE THEN
         dbg_a_ws_stored := iram_in.a_waitstates;
         IF iram_in.d_break_delay_length     /= 0 OR
            iram_in.d_break_delay_position   /= 0 OR
            iram_in.a_break_delay_length     /= 0 OR
            iram_in.a_break_delay_position   /= 0 OR
            iram_in.external_ws              /= FALSE THEN
            disable := TRUE;
         ELSE
            disable := FALSE;
         END IF;
      END IF;
      
      IF rising_edge(clk) AND NOT disable THEN
         IF dbg_a_ws_valid THEN
            err(1) <= '0';
            IF dbg_a_ws /= dbg_a_ws_stored THEN
               print_now("ERROR: dbg_a_ws = " & integer'image(dbg_a_ws) & " but shall be " & integer'image(dbg_a_ws_stored));
               err(1) <= '1';
            END IF;
         END IF;
      END IF;
   END PROCESS;





END iram32_sim_arch;
