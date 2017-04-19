---------------------------------------------------------------
-- Title         :
-- Project       : 
---------------------------------------------------------------
-- File          : SN74LVTH245.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 09/02/12
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
-- $Log: SN74LVTH245.vhd,v $
-- Revision 1.1  2012/03/29 10:28:42  MMiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY SN74LVTH245 IS
GENERIC (
   OP_COND  : integer:=1;                                      -- 0=min, 1=typ, 2=max
   WIDTH    : integer:=8
   );
PORT (
   dir      : IN std_logic;                                    -- direction: 0= B data to A, 1= A data to B
   oe_n     : IN std_logic;                                    -- output enable: 0= driver is active, 1= tri-state
   a        : INOUT std_logic_vector(WIDTH-1 DOWNTO 0);        -- port A
   b        : INOUT std_logic_vector(WIDTH-1 DOWNTO 0)         -- port B
   );
END SN74LVTH245;

ARCHITECTURE SN74LVTH245_arch OF SN74LVTH245 IS 
   CONSTANT tPLH_max       : time:= 3.5 ns;
   CONSTANT tPHL_max       : time:= 3.5 ns;
   CONSTANT tPZH_max       : time:= 5.5 ns;
   CONSTANT tPZL_max       : time:= 5.5 ns;
   CONSTANT tPHZ_max       : time:= 5.9 ns;
   CONSTANT tPLZ_max       : time:= 5.0 ns;

   CONSTANT tPLH_min       : time:= 1.2 ns;
   CONSTANT tPHL_min       : time:= 1.2 ns;
   CONSTANT tPZH_min       : time:= 1.3 ns;
   CONSTANT tPZL_min       : time:= 1.7 ns;
   CONSTANT tPHZ_min       : time:= 2.2 ns;
   CONSTANT tPLZ_min       : time:= 2.2 ns;

   CONSTANT tPLH_typ       : time:= 2.3 ns;
   CONSTANT tPHL_typ       : time:= 2.1 ns;
   CONSTANT tPZH_typ       : time:= 3.2 ns;
   CONSTANT tPZL_typ       : time:= 3.4 ns;
   CONSTANT tPHZ_typ       : time:= 3.5 ns;
   CONSTANT tPLZ_typ       : time:= 3.4 ns;

   SIGNAL oe_n_in : std_logic;
   SIGNAL dir_in  : std_logic;
   SIGNAL a_out : std_logic_vector(WIDTH-1 DOWNTO 0);
   SIGNAL b_out : std_logic_vector(WIDTH-1 DOWNTO 0);     
   SIGNAL a_int : std_logic_vector(WIDTH-1 DOWNTO 0);
   SIGNAL b_int : std_logic_vector(WIDTH-1 DOWNTO 0);     

   SIGNAL tPLH           : time;
   SIGNAL tPHL           : time;
   SIGNAL tPZH           : time;
   SIGNAL tPZL           : time;
   SIGNAL tPHZ           : time;
   SIGNAL tPLZ           : time;

   SIGNAL pwr_rst        : std_logic;
   
BEGIN          
   tPLH <=  tPLH_min WHEN OP_COND = 0 ELSE
            tPLH_typ WHEN OP_COND = 1 ELSE
            tPLH_max;
   tPHL <=  tPHL_min WHEN OP_COND = 0 ELSE
            tPHL_typ WHEN OP_COND = 1 ELSE
            tPHL_max;
   tPZH <=  tPZH_min WHEN OP_COND = 0 ELSE
            tPZH_typ WHEN OP_COND = 1 ELSE
            tPZH_max;
   tPZL <=  tPZL_min WHEN OP_COND = 0 ELSE
            tPZL_typ WHEN OP_COND = 1 ELSE
            tPZL_max;
   tPHZ <=  tPHZ_min WHEN OP_COND = 0 ELSE
            tPHZ_typ WHEN OP_COND = 1 ELSE
            tPHZ_max;
   tPLZ <=  tPLZ_min WHEN OP_COND = 0 ELSE
            tPLZ_typ WHEN OP_COND = 1 ELSE
            tPLZ_max;
                       
   a <= a_out;
   b <= b_out;
   a_int <= transport to_x01(a) after 1 ps;
   b_int <= transport to_x01(b) after 1 ps;  
   oe_n_in <= to_x01(oe_n);
   dir_in <= to_x01(dir);
   pwr_rst <= '1', '0' AFTER 2 ps;

gen: FOR i IN 0 TO (WIDTH-1) GENERATE
   PROCESS(pwr_rst, dir_in, oe_n_in, a_int, b_int, a_out(i), b_out(i))
   BEGIN
     IF pwr_rst'event AND dir_in = '0' AND oe_n_in = '1' THEN
        a_out(i) <= 'H';
     ELSIF pwr_rst'event AND dir_in = '0' AND oe_n_in = '0' THEN
        a_out(i) <= b_int(i);
     ELSIF (pwr_rst'event OR dir_in'event) AND dir_in = '1' THEN
        a_out(i) <= 'H';
     ELSIF (b_int(i)'event AND b_int(i) = '1' AND oe_n_in = '0' AND dir_in = '0') OR                -- b 0->1
        (dir_in'event AND dir_in = '0' AND oe_n_in = '0' AND b_int(i) = '1') THEN            -- dir_in 1->0
        a_out(i) <= transport b_int(i) AFTER tPLH;
     ELSIF (b_int(i)'event AND b_int(i) = '0' AND oe_n_in = '0' AND dir_in = '0') OR             -- b 1->0
        (dir_in'event AND dir_in = '0' AND oe_n_in = '0' AND b_int(i) = '0') THEN            -- dir_in 0->1  
        a_out(i) <= transport b_int(i) AFTER tPHL;
  
     ELSIF (oe_n_in'event AND oe_n_in = '0' AND b_int(i) = '1' AND dir_in = '0') THEN        -- oe_n_in 1->0 b=1
        a_out(i) <= transport b_int(i) AFTER tPZH;
     ELSIF (oe_n_in'event AND oe_n_in = '0' AND b_int(i) = '0' AND dir_in = '0') THEN        -- oe_n_in 1->0 b=0
        a_out(i) <= transport b_int(i) AFTER tPZL;
  
     ELSIF (oe_n_in'event AND oe_n_in = '1' AND a_int(i) = '1' AND dir_in = '0') THEN    -- oe_n_in 0->1 a=1
        a_out(i) <= transport 'H' AFTER tPHZ;
     ELSIF (oe_n_in'event AND oe_n_in = '1' AND a_int(i) = '0' AND dir_in = '0') THEN    -- oe_n_in 0->1 a=0
        a_out(i) <= transport 'H' AFTER tPLZ;
     END IF;
   
      IF pwr_rst'event AND dir_in = '1' AND oe_n_in = '1' THEN
         b_out(i) <= 'H';
      ELSIF pwr_rst'event AND dir_in = '1' AND oe_n_in = '0' THEN
         b_out(i) <= a_int(i);
      ELSIF (pwr_rst'event OR dir_in'event) AND dir_in = '0' THEN
         b_out(i) <= 'H';
      ELSIF (a_int(i)'event AND a_int(i) = '1' AND oe_n_in = '0' AND dir_in = '1') OR                -- a 0->1
         (dir_in'event AND dir_in = '1' AND oe_n_in = '0' AND a_int(i) = '1') THEN            -- dir_in 0->1
         b_out(i) <= transport a_int(i) AFTER tPLH;
      ELSIF (a_int(i)'event AND a_int(i) = '0' AND oe_n_in = '0' AND dir_in = '1') OR             -- a 1->0
         (dir_in'event AND dir_in = '1' AND oe_n_in = '0' AND a_int(i) = '0') THEN            -- dir_in 1->0 
         b_out(i) <= transport a_int(i) AFTER tPHL;
   
      ELSIF (oe_n_in'event AND oe_n_in = '0' AND a_int(i) = '1' AND dir_in = '1') THEN        -- oe_n_in 1->0 a=1
         b_out(i) <= transport a_int(i) AFTER tPZH;
      ELSIF (oe_n_in'event AND oe_n_in = '0' AND a_int(i) = '0' AND dir_in = '1') THEN        -- oe_n_in 1->0 a=0
         b_out(i) <= transport a_int(i) AFTER tPZL;
   
      ELSIF (oe_n_in'event AND oe_n_in = '1' AND b_int(i) = '1' AND dir_in = '1') THEN    -- oe_n_in 0->1 b=1
         b_out(i) <= transport 'H' AFTER tPHZ;
      ELSIF (oe_n_in'event AND oe_n_in = '1' AND b_int(i) = '0' AND dir_in = '1') THEN    -- oe_n_in 0->1 b=0
         b_out(i) <= transport 'H' AFTER tPLZ;
      END IF;
      
   END PROCESS;
END GENERATE gen;

END SN74LVTH245_arch;
