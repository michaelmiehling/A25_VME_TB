---------------------------------------------------------------
-- Title         : Altera remote update controller model
-- Project       : -
---------------------------------------------------------------
-- Author        : Andreas Geissler
-- Email         : Andreas.Geissler@men.de
-- Organization  : MEN Mikro Elektronik Nuremberg GmbH
-- Created       : 05/02/14
---------------------------------------------------------------
-- Simulator     : ModelSim-Altera PE 6.4c
-- Synthesis     : Quartus II 12.1 SP2
---------------------------------------------------------------
-- Description : 
--
---------------------------------------------------------------
-- Hierarchy:
--
---------------------------------------------------------------
-- Copyright (C) 2014, MEN Mikroelektronik Nuernberg GmbH
--
--   All rights reserved. Reproduction in whole or part is
--      prohibited without the written permission of the
--                    copyright owner.
---------------------------------------------------------------
--                         History
---------------------------------------------------------------
-- $Revision: $
--
-- $Log: $
--
--
---------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY work;
USE work.fpga_pkg_2.all;

ENTITY z126_01_ru_cycloneiii IS
   PORT (
      
      clock             : IN std_logic ;
      data_in           : IN std_logic_vector (23 DOWNTO 0);
      param             : IN std_logic_vector (2 DOWNTO 0);
      read_param        : IN std_logic ;
      read_source       : IN std_logic_vector (1 DOWNTO 0);
      reconfig          : IN std_logic ;
      reset             : IN std_logic ;
      reset_timer       : IN std_logic ;
      write_param       : IN std_logic ;
      
      busy              : OUT std_logic ;
      data_out          : OUT std_logic_vector (28 DOWNTO 0)
   );
END z126_01_ru_cycloneiii;

ARCHITECTURE z126_01_ru_cycloneiii_arch OF z126_01_ru_cycloneiii IS
BEGIN
   
   busy_p: PROCESS
   BEGIN
      
      WAIT UNTIL rising_edge(clock) OR reset = '1';
      IF reset = '1' THEN
         busy  <= '0';
      ELSIF read_param = '1' OR read_param = '1'  THEN
         WAIT FOR 100 ns;
         WAIT UNTIL rising_edge(clock);
         busy  <= '1';
         WAIT FOR 600 ns;
         WAIT UNTIL rising_edge(clock);
         busy  <= '0';
      END IF;
   END PROCESS;
   
   data_out    <= (OTHERS => '0');
   
END z126_01_ru_cycloneiii_arch;