---------------------------------------------------------------
-- Title         : Bus Buffer Gates with 3-state outputs
-- Project       : 
---------------------------------------------------------------
-- File          : SN74ABT125.vhd
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
-- $Log: SN74ABT125.vhd,v $
-- Revision 1.1  2012/03/29 10:28:41  MMiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY SN74ABT125 IS
GENERIC (
   OP_COND  : integer:=1;                                   -- 0=min, 1=typ, 2=max
   WIDTH    : integer:=8
   );
PORT (
   oe_n     : IN std_logic_vector(WIDTH-1 DOWNTO 0);        -- output enable: 0= driver is active, 1= tri-state
   a        : IN std_logic_vector(WIDTH-1 DOWNTO 0);        -- port A
   b        : OUT std_logic_vector(WIDTH-1 DOWNTO 0)        -- port B
   );
END SN74ABT125;

ARCHITECTURE SN74ABT125_arch OF SN74ABT125 IS 
   CONSTANT tPLH_max       : time:= 4.9 ns;
   CONSTANT tPHL_max       : time:= 4.9 ns;
   CONSTANT tPZH_max       : time:= 5.9 ns;
   CONSTANT tPZL_max       : time:= 6.8 ns;
   CONSTANT tPHZ_max       : time:= 6.2 ns;
   CONSTANT tPLZ_max       : time:= 6.2 ns;

   CONSTANT tPLH_min       : time:= 1 ns;
   CONSTANT tPHL_min       : time:= 1 ns;
   CONSTANT tPZH_min       : time:= 1 ns;
   CONSTANT tPZL_min       : time:= 1 ns;
   CONSTANT tPHZ_min       : time:= 1 ns;
   CONSTANT tPLZ_min       : time:= 1 ns;

   CONSTANT tPLH_typ       : time:= 3.2 ns;
   CONSTANT tPHL_typ       : time:= 2.5 ns;
   CONSTANT tPZH_typ       : time:= 3.6 ns;
   CONSTANT tPZL_typ       : time:= 2.5 ns;
   CONSTANT tPHZ_typ       : time:= 3.8 ns;
   CONSTANT tPLZ_typ       : time:= 3.3 ns;

   SIGNAL b_out      : std_logic_vector(WIDTH-1 DOWNTO 0);     
   SIGNAL oe_n_in    : std_logic_vector(WIDTH-1 DOWNTO 0);
   SIGNAL a_in       : std_logic_vector(WIDTH-1 DOWNTO 0);

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
   
   oe_n_in <= to_x01(oe_n);
   a_in <= to_x01(a);

   pwr_rst <= '1', '0' AFTER 2 ps;
   
   b <= b_out;

gen: FOR i IN 0 TO WIDTH-1 GENERATE
   PROCESS(pwr_rst, oe_n_in(i), a_in(i), b_out(i))
   BEGIN
      IF pwr_rst'event AND oe_n_in(i) = '1' THEN
         b_out(i) <= 'H';
      ELSIF pwr_rst'event AND oe_n_in(i) = '0' THEN
         b_out(i) <= a_in(i);
      ELSIF (a_in(i)'event AND a_in(i) = '1' AND oe_n_in(i) = '0' ) THEN          -- a 0->1
         b_out(i) <= transport a_in(i) AFTER tPLH;
      ELSIF (a_in(i)'event AND a_in(i) = '0' AND oe_n_in(i) = '0') THEN         -- a 1->0
         b_out(i) <= transport a_in(i) AFTER tPHL;
   
      ELSIF (oe_n_in'event AND oe_n_in(i) = '0' AND a_in(i) = '1') THEN        -- oe_n_in 1->0 a=1
         b_out(i) <= transport a_in(i) AFTER tPZH;
      ELSIF (oe_n_in'event AND oe_n_in(i) = '0' AND a(i) = '0') THEN        -- oe_n_in 1->0 a=0
         b_out(i) <= transport a_in(i) AFTER tPZL;
   
      ELSIF (oe_n_in'event AND oe_n_in(i) = '1' AND b_out(i) = '1') THEN    -- oe_n_in 0->1 b=1
         b_out(i) <= transport 'H' AFTER tPHZ;
      ELSIF (oe_n_in'event AND oe_n_in(i) = '1' AND b_out(i) = '0') THEN    -- oe_n_in 0->1 b=0
         b_out(i) <= transport 'H' AFTER tPLZ;
      END IF;
      
   END PROCESS;
END GENERATE gen;

END SN74ABT125_arch;
