---------------------------------------------------------------
-- Title         : Simulation Terminal
-- Project       : -
---------------------------------------------------------------
-- File          : terminal.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 10/11/04
---------------------------------------------------------------
-- Simulator     : Modelsim PE 5.7g
-- Synthesis     : Quartus II 3.0
---------------------------------------------------------------
-- Description :
--
-- Application Layer for simulation stimuli
---------------------------------------------------------------
-- Hierarchy:
--
-- testbench
--		terminal
--		wb_test
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
-- $Log: terminal.vhd,v $
-- Revision 1.2  2006/03/15 14:21:54  mmiehling
-- extended tga
-- removed "use work.vme_pkg.all"
--
-- Revision 1.1  2005/08/23 15:21:05  MMiehling
-- Initial Revision
--
-- Revision 1.3  2005/03/18 15:14:18  MMiehling
-- changed
--
-- Revision 1.2  2005/01/31 16:28:56  mmiehling
-- updated
--
-- Revision 1.1  2004/11/16 12:09:06  mmiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.print_pkg.all;
USE work.terminal_pkg.ALL;

ENTITY terminal IS
PORT (
	rst			: IN std_logic;
	
	terminal_in_0	: IN terminal_in_type;
	terminal_out_0	: OUT terminal_out_type;
	terminal_in_1	: IN terminal_in_type;
	terminal_out_1	: OUT terminal_out_type

     );
END terminal;

ARCHITECTURE terminal_arch OF terminal IS 
	SIGNAL terminal_err_0	: integer:=0;
	SIGNAL terminal_err_1	: integer:=0;
	SIGNAL end_of_tests		: boolean;

	CONSTANT en_msg_0	: boolean:= false;
	CONSTANT en_msg_1	: boolean:= false;

BEGIN

term_0: PROCESS
	VARIABLE err : integer;
  BEGIN
	init(terminal_out_0);
	IF rst /= '0' THEN
		WAIT until rst = '0';
	END IF;
	WAIT FOR 1000 ns;
	print("***************************************************");
	print("                Start of Tests");
	print("***************************************************");

--	wr32(terminal_in_0, terminal_out_0, x"0000_0050", x"1234_5678", 1, en_msg_0, TRUE, "000000");
--	wait_for(terminal_in_0, terminal_out_0, 5, TRUE);
--	rd32(terminal_in_0, terminal_out_0, x"0000_0050", x"1234_5678", 1, en_msg_0, TRUE, "000000", err);
--	terminal_err_0 <= terminal_err_0 + err;
--	
--	wait_for(terminal_in_0, terminal_out_0, 5, TRUE);


	wr32(terminal_in_0, terminal_out_0, x"0000_0000", x"0000_0000", 3000, en_msg_0, TRUE, "000000");
	rd32(terminal_in_0, terminal_out_0, x"0000_0000", x"0000_0000", 3000, en_msg_0, TRUE, "000000", err);
	terminal_err_0 <= terminal_err_0 + err;

	wr32(terminal_in_0, terminal_out_0, x"0000_0000", x"0000_0000", 500, en_msg_0, TRUE, "000000");
	rd32(terminal_in_0, terminal_out_0, x"0000_0000", x"0000_0000", 500, en_msg_0, TRUE, "000000", err);
	terminal_err_0 <= terminal_err_0 + err;

	sdram_burst(terminal_in_0, terminal_out_0, x"0000_0000", en_msg_0, terminal_err_0);

	wr32(terminal_in_0, terminal_out_0, x"0000_0100", x"0000_0100", 500, en_msg_0, TRUE, "000000");
	rd32(terminal_in_0, terminal_out_0, x"0000_0100", x"0000_0100", 500, en_msg_0, TRUE, "000000", err);
	terminal_err_0 <= terminal_err_0 + err;

	wr32(terminal_in_0, terminal_out_0, x"0000_0200", x"0000_0200", 500, en_msg_0, TRUE, "000000");
	rd32(terminal_in_0, terminal_out_0, x"0000_0200", x"0000_0200", 500, en_msg_0, TRUE, "000000", err);
	terminal_err_0 <= terminal_err_0 + err;

	wr32(terminal_in_0, terminal_out_0, x"0000_0300", x"0000_0300", 500, en_msg_0, TRUE, "000000");
	rd32(terminal_in_0, terminal_out_0, x"0000_0300", x"0000_0300", 500, en_msg_0, TRUE, "000000", err);
	terminal_err_0 <= terminal_err_0 + err;



	IF end_of_tests = FALSE THEN
		WAIT on end_of_tests;
	END IF;
	WAIT FOR 2000 ns;
	print("***************************************************");
	print("  Test Summary:");
	print_s_i("  Number of errors:             ", terminal_err_0);
	print_s_i("  Number of errors:             ", terminal_err_1);
	print("***************************************************");
	ASSERT FALSE REPORT "--- END OF SIMULATION ---" SEVERITY failure;

	END PROCESS term_0;

term_1: PROCESS
	VARIABLE err : integer;
  BEGIN
	init(terminal_out_1);
	end_of_tests <= FALSE;
	
	IF rst /= '0' THEN
		WAIT until rst = '0';
	END IF;
	WAIT FOR 1000 ns;

	sdram_burst(terminal_in_1, terminal_out_1, x"0000_5000", en_msg_1, terminal_err_1);

	wr32(terminal_in_1, terminal_out_1, x"0000_0060", x"abcd_ef01", 1, en_msg_1, TRUE, "000000");
	rd32(terminal_in_1, terminal_out_1, x"0000_0060", x"abcd_ef01", 1, en_msg_1, TRUE, "000000", err);
	terminal_err_1 <= terminal_err_1 + err;

	wr32(terminal_in_1, terminal_out_1, x"0000_5000", x"0000_0000", 2000, en_msg_1, TRUE, "000000");
	rd32(terminal_in_1, terminal_out_1, x"0000_5000", x"0000_0000", 2000, en_msg_1, TRUE, "000000", err);
	terminal_err_1 <= terminal_err_1 + err;

	end_of_tests <= TRUE;
	WAIT;

	END PROCESS term_1;
END terminal_arch;
