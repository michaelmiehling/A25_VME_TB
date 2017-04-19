--------------------------------------------------------------------------------
-- Title       : ModelSim library for Riviera-PRO
-- Project     : 
--------------------------------------------------------------------------------
-- File        : modelsim_lib.vhd
-- Author      : M. Henze
-- Email       : 
-- Organization: MEN Mikro Elektronik Nuremberg GmbH
-- Created     : 
--------------------------------------------------------------------------------
-- Simulator   : Riviera-PRO
-- Synthesis   : 
--------------------------------------------------------------------------------
-- Description : 
-- CAUTION - this file shall not be used for new designs. It is only kept
-- for compliance with old designs.
-- For new designs use VHDL2008 syntax instead.
-- 
--------------------------------------------------------------------------------
-- Hierarchy   : 
--------------------------------------------------------------------------------
-- Copyright (C) 2016, MEN Mikro Elektronik Nuremberg GmbH
--
-- All rights reserved. Reproduction in whole or part is
-- prohibited without the written permission of the
-- copyright owner.
--------------------------------------------------------------------------------
LIBRARY aldec;
USE aldec.signal_agent_pkg.ALL;
USE aldec.aldec_tools.ALL;


----------------------------------------
-- CAUTION! Don't use for new designs!
-- Use VHDL2008 instead!
----------------------------------------
PACKAGE util IS

   TYPE force_type IS (default, deposit, drive, freeze);
   type del_mode is (MTI_INERTIAL, MTI_TRANSPORT);

   PROCEDURE init_signal_spy( source      : IN string;
                              destination : IN string;
                              verbose     : IN integer;
                              control     : IN integer);

   procedure init_signal_spy(
      source : in string;
      dest   : in string
   );

   PROCEDURE signal_force( destination    : IN string;
                           value          : IN string;
                           rel_time       : IN time;
                           forcetype      : IN force_type;
                           cancel_period  : IN time;
                           verbose        : IN integer);

   PROCEDURE signal_release(  destination : IN string;
                              verbose     : IN integer);

   procedure init_signal_driver(
      src_obj    : in string;
      dest_obj   : in string;
      delay      : in time;
      delay_type : in del_mode;
      verbose    : in integer
   );

END;

PACKAGE BODY util IS

   PROCEDURE init_signal_spy( source      : IN string;
                              destination : IN string;
                              verbose     : IN integer;
                              control     : IN integer) IS
   BEGIN
      signal_agent(source, destination ,verbose);
   END PROCEDURE init_signal_spy;

   procedure init_signal_spy(
      source : in string;
      dest   : in string
   ) is
   begin
      signal_agent(source,dest,0);
   end procedure init_signal_spy;

   PROCEDURE signal_force( destination    : IN string;
                           value          : IN string;
                           rel_time       : IN time;
                           forcetype      : IN force_type;
                           cancel_period  : IN time;
                           verbose        : IN integer) IS
   BEGIN
      ------------------------------------------------
      -- in RivieraPRO2014 the force command changed
      ------------------------------------------------
      --force(force_type'image(forcetype), destination, value);
      force_signal(force_type'image(forcetype), destination, value);
   END PROCEDURE signal_force;


   PROCEDURE signal_release(  destination : IN string;
                              verbose     : IN integer) IS
   BEGIN
      ------------------------------------------------
      -- in RivieraPRO2014 the force command changed
      ------------------------------------------------
      --noforce ( destination );
      noforce_signal ( destination );
   END PROCEDURE signal_release;

   procedure init_signal_driver(
      src_obj    : in string;
      dest_obj   : in string;
      delay      : in time;
      delay_type : in del_mode;
      verbose    : in integer
   ) is
   begin
      signal_agent(src_obj, dest_obj, 0);
   end procedure init_signal_driver;


END;





