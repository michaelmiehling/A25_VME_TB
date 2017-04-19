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
--
---------------------------------------------------------------
-- Hierarchy:
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
USE ieee.std_logic_arith.ALL;
USE work.print_pkg.all;
USE work.conversions.to_hex_str;

PACKAGE iram32_pkg IS
   CONSTANT ADR_BITS : integer := 32;
   CONSTANT DAT_BITS : integer := 32;
   CONSTANT SEL_BITS : integer := DAT_BITS/8;

   CONSTANT ACC_REQ_BUFFER_SIZE : integer:=1000;
   CONSTANT WRDAT_BUFFER_SIZE   : integer:=1000;
   CONSTANT WRADR_BUFFER_SIZE   : integer:=1000;

   CONSTANT DISABLE_DATA_WAITSTATES_FOR_NON_SPLIT_TRANSACTION: boolean := TRUE;


   TYPE iram32_in_type IS record
      d_waitstates            : integer;                 -- number of waitstates for data phases
      d_startdelay            : integer;                 -- number of additional waitstates for first data phase acknowledge (a_startdelay will be added)
      d_break_delay_position  : integer;                 -- number of data phases of one access after which the break delay appears
      d_break_delay_length    : integer;                 -- number of clock cycles as length of break delay
      a_waitstates            : integer;                 -- number of waitstates for address phases
      a_startdelay            : integer;                 -- number of additional waitstates for first address phase acknowledge
      a_break_delay_position  : integer;                 -- number of data phases of one access after which the break delay appears
      a_break_delay_length    : integer;                 -- number of clock cycles as length of break delay

      config         : boolean;                          -- enable iram configuration
      err_answer     : boolean;                          -- if true, requests will be answered with error

      conf_req       : boolean;                          -- changes on signal will call iram subfunctions
      write_req      : boolean;                          -- if TRUE during conf_req state changes, write request to iram is requested
                                                         -- if FALSE during conf_req state changes, read request from iram is requested
      adr            : std_logic_vector(ADR_BITS-1 DOWNTO 0);    -- address for config read write access
      wr_dat         : std_logic_vector(DAT_BITS-1 DOWNTO 0);    -- write data to iram
      dealloc_iram   : boolean;                          -- if TRUE during conf_req state changes, iram contents will be cleared
      external_ws    : boolean;                          -- if TRUE, external waitstate interface is used for generation of waitstates
                                                         -- if FALSE, iram parameters a_waitstates, a_startdelay, d_waitstates, d_startdelay, 
                                                         -- break_delay_position, break_delay_lengthare used for generation of waitstates
   END record;


   TYPE iram32_out_type IS record
      conf_ack    : boolean;                          -- if conf_req has changed state, subfunction end will result in conf_ack state change
      rd_dat      : std_logic_vector(DAT_BITS-1 DOWNTO 0);    -- read data to iram
   END record;


   TYPE iram32_acc_req_type IS record
      we       : std_logic;
      adr      : std_logic_vector(ADR_BITS-1 DOWNTO 0);
      cti      : std_logic_vector(2 DOWNTO 0);
      time_cnt : natural;
      st_flag  : boolean;
      eob_flag : boolean;
   END record;
   TYPE iram32_acc_req_buffer IS array (0 TO ACC_REQ_BUFFER_SIZE-1) OF iram32_acc_req_type;

   TYPE iram32_wrdat_type IS record
      dat      : std_logic_vector(DAT_BITS-1 DOWNTO 0);
      sel      : std_logic_vector((DAT_BITS/8)-1 DOWNTO 0);
   END record;
   TYPE iram32_wrdat_buffer IS array (0 TO ACC_REQ_BUFFER_SIZE-1) OF iram32_wrdat_type;

   TYPE iram32_wradr_type IS record
      adr      : std_logic_vector(ADR_BITS-1 DOWNTO 0);
   END record;
   TYPE iram32_wradr_buffer IS array (0 TO ACC_REQ_BUFFER_SIZE-1) OF iram32_wradr_type;

   TYPE iram32_mem_entry;
   TYPE iram32_entry_ptr IS access iram32_mem_entry;

   TYPE iram32_mem_entry IS record
      address  : integer;
      data     : std_logic_vector(DAT_BITS-1 DOWNTO 0);
      nxt      : iram32_entry_ptr;
   END record;

   TYPE iram32_head IS record
      num_entries    : integer;
      list_ptr       : iram32_entry_ptr;
   END record;

   TYPE iram32_head_ptr IS access iram32_head;



   TYPE protected_shared_variable_natural IS protected
      PROCEDURE set(value : natural);
      impure FUNCTION get RETURN natural;
   END protected protected_shared_variable_natural;




   PROCEDURE incr(      value          : INOUT natural;
                        limit          : IN natural;
                        wrap           : IN boolean
                        ) ;
   CONSTANT WRAP_ON : boolean := TRUE;
   CONSTANT WRAP_OFF: boolean := FALSE;
   

   PROCEDURE gen_req(  
                        SIGNAL req     : OUT boolean;
                        SIGNAL ack     : IN  boolean
                        );   
   PROCEDURE gen_ack(  
                        SIGNAL req     : IN  boolean;
                        SIGNAL ack     : OUT boolean
                        );




   PROCEDURE wr_data (
                        CONSTANT location    : IN integer;
                        CONSTANT data        : IN std_logic_vector(DAT_BITS-1 DOWNTO 0);
                        CONSTANT byte        : IN std_logic_vector(SEL_BITS-1 DOWNTO 0);
                        VARIABLE first       : INOUT iram32_head_ptr;
                        VARIABLE msg_on      : IN boolean
                     );
   PROCEDURE rd_data (
                        CONSTANT location    : IN integer;
                        VARIABLE data        : OUT std_logic_vector(DAT_BITS-1 DOWNTO 0);
                        VARIABLE allocated   : OUT boolean;
                        VARIABLE first       : INOUT iram32_head_ptr;
                        VARIABLE msg_on      : IN boolean
                     );
   PROCEDURE dealloc_data (
                        VARIABLE first       : INOUT iram32_head_ptr
                     ) ;




   PROCEDURE rd_iram (  SIGNAL   iram_in        : OUT iram32_in_type;
                        SIGNAL   iram_out       : IN iram32_out_type;
                                 adr            : IN std_logic_vector(ADR_BITS-1 DOWNTO 0);
                                 dat            : OUT std_logic_vector(DAT_BITS-1 DOWNTO 0)
                                 );
   PROCEDURE wr_iram (  SIGNAL   iram_in        : OUT iram32_in_type;
                        SIGNAL   iram_out       : IN iram32_out_type;
                                 adr            : IN std_logic_vector(ADR_BITS-1 DOWNTO 0);
                                 dat            : IN std_logic_vector(DAT_BITS-1 DOWNTO 0)
                                 ) ;
   PROCEDURE deallocate_iram ( 
                        SIGNAL   iram_in        : OUT iram32_in_type;
                        SIGNAL   iram_out       : IN iram32_out_type
                                 ) ;
   PROCEDURE conf_iram32 ( SIGNAL iram_in           : OUT iram32_in_type;
                           SIGNAL iram_out          : IN iram32_out_type;
                                  external_ws       : IN boolean;
                                  a_startdelay      : IN integer;
                                  a_waitstates      : IN integer;
                                  d_startdelay      : IN integer;
                                  d_waitstates      : IN integer;
                                  a_break_delay_pos : IN integer;
                                  a_break_delay_len : IN integer;
                                  d_break_delay_pos : IN integer;
                                  d_break_delay_len : IN integer
                        );

END iram32_pkg;

PACKAGE BODY iram32_pkg IS
   
   TYPE protected_shared_variable_natural IS protected BODY
      VARIABLE stored: natural;

      PROCEDURE set(value : natural) IS
         BEGIN
            stored := value;
      END PROCEDURE set;

      impure FUNCTION get RETURN natural IS
         BEGIN
            RETURN stored;
      END FUNCTION get;
   END protected BODY protected_shared_variable_natural;



--------------------------------------------------------------------------------------------
   PROCEDURE incr(      value          : INOUT natural;
                        limit          : IN natural;
                        wrap           : IN boolean
                        ) IS
   BEGIN
      IF value = limit-1 THEN
         IF wrap THEN
            value := 0;
         END IF;
      ELSE 
         value := value + 1;
      END IF;
   END PROCEDURE;


--------------------------------------------------------------------------------------------
   PROCEDURE gen_req(  
                        SIGNAL req     : OUT boolean;
                        SIGNAL ack     : IN  boolean
                        ) IS
   BEGIN
      IF ack /= FALSE THEN 
         WAIT until ack = FALSE;
      END IF;
      req <= TRUE;
      WAIT until ack = TRUE;
      req <= FALSE;
   END PROCEDURE;
   
--------------------------------------------------------------------------------------------
   PROCEDURE gen_ack(  
                        SIGNAL req     : IN  boolean;
                        SIGNAL ack     : OUT boolean
                        ) IS
   BEGIN
      IF req /= TRUE THEN 
         WAIT until req = TRUE;
      END IF;
      ack <= TRUE;
      WAIT until req = FALSE;
      ack <= FALSE;
   END PROCEDURE;
   
--------------------------------------------------------------------------------------------
   PROCEDURE conf_iram32 ( SIGNAL iram_in           : OUT iram32_in_type;
                           SIGNAL iram_out          : IN iram32_out_type;
                                  external_ws       : IN boolean;
                                  a_startdelay      : IN integer;
                                  a_waitstates      : IN integer;
                                  d_startdelay      : IN integer;
                                  d_waitstates      : IN integer;
                                  a_break_delay_pos : IN integer;
                                  a_break_delay_len : IN integer;
                                  d_break_delay_pos : IN integer;
                                  d_break_delay_len : IN integer
                        ) IS
   BEGIN
      IF iram_out.conf_ack /= FALSE THEN WAIT until iram_out.conf_ack = FALSE; END IF;
      iram_in.write_req                <= FALSE;
      iram_in.adr                      <= (OTHERS => '0');
      iram_in.config                   <= TRUE;
      iram_in.a_startdelay             <= a_startdelay;
      iram_in.a_waitstates             <= a_waitstates;
      iram_in.d_startdelay             <= d_startdelay;
      iram_in.d_waitstates             <= d_waitstates;
      iram_in.a_break_delay_position   <= a_break_delay_pos;
      iram_in.a_break_delay_length     <= a_break_delay_len;
      iram_in.d_break_delay_position   <= d_break_delay_pos;
      iram_in.d_break_delay_length     <= d_break_delay_len;
      iram_in.external_ws              <= external_ws;
      iram_in.conf_req <= TRUE;
      IF iram_out.conf_ack /= TRUE THEN 
         WAIT until iram_out.conf_ack = TRUE;
      END IF;
      iram_in.conf_req <= FALSE;
      IF iram_out.conf_ack /= FALSE THEN 
         WAIT until iram_out.conf_ack = FALSE;
      END IF;
      iram_in.dealloc_iram <= FALSE;
      iram_in.config                   <= FALSE;
      WAIT FOR 1 us;
   END PROCEDURE conf_iram32;


--------------------------------------------------------------------------------------------
   PROCEDURE deallocate_iram ( 
                        SIGNAL   iram_in        : OUT iram32_in_type;
                        SIGNAL   iram_out       : IN iram32_out_type
                                 ) IS
   BEGIN
      IF iram_out.conf_ack /= FALSE THEN WAIT until iram_out.conf_ack = FALSE; END IF;
      iram_in.write_req    <= FALSE;
      iram_in.wr_dat       <= (OTHERS => '0');
      iram_in.adr          <= (OTHERS => '0');
      iram_in.dealloc_iram <= TRUE;
      iram_in.conf_req <= TRUE;
      WAIT until iram_out.conf_ack = TRUE;
      iram_in.conf_req <= FALSE;
      WAIT until iram_out.conf_ack = FALSE;
      iram_in.dealloc_iram <= FALSE;
   END PROCEDURE deallocate_iram;

--------------------------------------------------------------------------------------------
   PROCEDURE wr_iram (  SIGNAL   iram_in        : OUT iram32_in_type;
                        SIGNAL   iram_out       : IN iram32_out_type;
                                 adr            : IN std_logic_vector(ADR_BITS-1 DOWNTO 0);
                                 dat            : IN std_logic_vector(DAT_BITS-1 DOWNTO 0)
                                 ) IS
   BEGIN
      IF iram_out.conf_ack /= FALSE THEN WAIT until iram_out.conf_ack = FALSE; END IF;
      iram_in.write_req <= TRUE;
      iram_in.wr_dat <= dat;
      iram_in.adr <= adr;
      iram_in.conf_req <= TRUE;
      WAIT until iram_out.conf_ack = TRUE;
      iram_in.conf_req <= FALSE;
      WAIT until iram_out.conf_ack = FALSE;
   END PROCEDURE wr_iram;

--------------------------------------------------------------------------------------------
   PROCEDURE rd_iram (  SIGNAL   iram_in        : OUT iram32_in_type;
                        SIGNAL   iram_out       : IN iram32_out_type;
                                 adr            : IN std_logic_vector(ADR_BITS-1 DOWNTO 0);
                                 dat            : OUT std_logic_vector(DAT_BITS-1 DOWNTO 0)
                                 ) IS
   BEGIN
      IF iram_out.conf_ack /= FALSE THEN WAIT until iram_out.conf_ack = FALSE; END IF;
      iram_in.write_req <= FALSE;
      iram_in.adr <= adr;
      iram_in.conf_req <= TRUE;
      WAIT until iram_out.conf_ack = TRUE;
      iram_in.conf_req <= FALSE;
      WAIT until iram_out.conf_ack = FALSE;
      dat := iram_out.rd_dat;
   END PROCEDURE rd_iram;


--------------------------------------------------------------------------------------------
   PROCEDURE wr_data (
      CONSTANT location : IN integer;
      CONSTANT data     : IN std_logic_vector(DAT_BITS-1 DOWNTO 0);
      CONSTANT byte     : IN std_logic_vector(SEL_BITS-1 DOWNTO 0);
      VARIABLE first    : INOUT iram32_head_ptr;
      VARIABLE msg_on   : IN boolean
      ) IS
      VARIABLE temp_ptr : iram32_entry_ptr;
      VARIABLE new_ptr  : iram32_entry_ptr;
      VARIABLE prev_ptr : iram32_entry_ptr;
      VARIABLE done     : boolean:=FALSE;
      VARIABLE long_location: integer;
   BEGIN
      done:= FALSE;                                      -- set done to true when allocation occurs

      long_location := location/((data'high+1)/8);
      IF msg_on THEN
         print_cycle("  IRAM - wr_data: ", CONV_STD_LOGIC_VECTOR(location, ADR_BITS), data, byte(3 DOWNTO 0), " ");
      END IF;
      IF first.num_entries = 0 THEN                      -- first access to memory
         first.list_ptr := new iram32_mem_entry;
         first.num_entries := 1;
         first.list_ptr.address := long_location;
         FOR i IN byte'high DOWNTO byte'low LOOP
            IF byte(i) = '1' THEN
               first.list_ptr.data(i*8+7 DOWNTO i*8) := data(i*8+7 DOWNTO i*8);
            END IF;
         END LOOP;
         first.list_ptr.nxt := null;
         done := TRUE;
      ELSIF long_location < first.list_ptr.address THEN       -- address is lowest value so far in allocation to put at head of list
         new_ptr := new iram32_mem_entry;
         FOR i IN byte'high DOWNTO byte'low LOOP
            IF byte(i) = '1' THEN
               new_ptr.data(i*8+7 DOWNTO i*8) := data(i*8+7 DOWNTO i*8);
            END IF;
         END LOOP;
         new_ptr.nxt := first.list_ptr;
         new_ptr.address := long_location;
         first.list_ptr := new_ptr;
         first.num_entries := first.num_entries + 1;
         done := TRUE;
      ELSE                                               -- location must be >= first.list_ptr.address
         temp_ptr := first.list_ptr;
         while temp_ptr /= null AND NOT done LOOP
            IF temp_ptr.address = long_location THEN          -- address already allocated
               FOR i IN byte'high DOWNTO byte'low LOOP
                  IF byte(i) = '1' THEN
                     temp_ptr.data(i*8+7 DOWNTO i*8) := data(i*8+7 DOWNTO i*8);
                  END IF;
               END LOOP;
               done := TRUE;
            ELSIF temp_ptr.address > long_location THEN
               new_ptr := new iram32_mem_entry;
               new_ptr.address := long_location;
               FOR i IN byte'high DOWNTO byte'low LOOP
                  IF byte(i) = '1' THEN
                     new_ptr.data(i*8+7 DOWNTO i*8) := data(i*8+7 DOWNTO i*8);
                  END IF;
               END LOOP;
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
            new_ptr := new iram32_mem_entry;
            new_ptr.address := long_location;
            FOR i IN byte'high DOWNTO byte'low LOOP
               IF byte(i) = '1' THEN
                  new_ptr.data(i*8+7 DOWNTO i*8) := data(i*8+7 DOWNTO i*8);
               END IF;
            END LOOP;
            new_ptr.nxt := null;                            -- add new_ptr TO END OF chain
            prev_ptr.nxt := new_ptr;
            first.num_entries := first.num_entries + 1;
            done := TRUE;
         END IF;
      END IF;
   END wr_data;

--------------------------------------------------------------------------------------------
   PROCEDURE rd_data (
      CONSTANT location    : IN integer;
      VARIABLE data        : OUT std_logic_vector(DAT_BITS-1 DOWNTO 0);
      VARIABLE allocated   : OUT boolean;
      VARIABLE first       : INOUT iram32_head_ptr;
      VARIABLE msg_on      : IN boolean
      ) IS
      VARIABLE temp_ptr    : iram32_entry_ptr;
      VARIABLE is_allocated : boolean;
      VARIABLE data_int     : std_logic_vector(data'range);
      VARIABLE long_location: integer;
   BEGIN
      -- set allocated to true when read hits already allocated spot
      is_allocated := FALSE;
      long_location := location/((data'high+1)/8);
      IF (first.list_ptr /= null AND first.num_entries /= 0 AND long_location >= first.list_ptr.address) THEN
         temp_ptr := first.list_ptr;
         while (temp_ptr /= null AND NOT is_allocated AND long_location >= temp_ptr.address) LOOP
            IF temp_ptr.address = long_location THEN          -- address has been allocated
               data_int := temp_ptr.data;
               is_allocated := TRUE;
            ELSE
               temp_ptr := temp_ptr.nxt;
            END IF;
         END LOOP;
      END IF;
      IF NOT is_allocated THEN
         data_int := (data_int'range => '1');
      END IF;
      IF msg_on THEN
         print_cycle("  IRAM - rd_data: ", CONV_STD_LOGIC_VECTOR(location, ADR_BITS), data_int, "1111", " ");
      END IF;
      allocated := is_allocated;
      data := data_int;
   END rd_data;

--------------------------------------------------------------------------------------------
   PROCEDURE dealloc_data (
      VARIABLE first       : INOUT iram32_head_ptr
      ) IS
      VARIABLE next_ptr    : iram32_entry_ptr;
   BEGIN
      WHILE first.list_ptr.nxt /= NULL LOOP
         next_ptr       := first.list_ptr.nxt;
         deallocate(first.list_ptr);
         first.list_ptr := next_ptr;
      END LOOP;
      deallocate(first.list_ptr);
      first.num_entries := 0;
   END dealloc_data;


END;
