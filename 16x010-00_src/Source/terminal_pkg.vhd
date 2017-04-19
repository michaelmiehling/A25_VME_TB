---------------------------------------------------------------
-- Title         : Package for simulation terminal
-- Project       : -
---------------------------------------------------------------
-- File          : terminal_pkg.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 22/09/03
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
-- $Revision: 1.9 $
--
-- $Log: terminal_pkg.vhd,v $
-- Revision 1.9  2010/08/16 12:57:16  FLenhardt
-- Added an overloaded MTEST which accepts a seed number as an input
--
-- Revision 1.8  2009/01/13 10:57:52  FLenhardt
-- Defined that TGA=2 means configuration access
--
-- Revision 1.7  2008/09/10 17:26:45  MSchindler
-- added flash_mtest_indirect procedure
--
-- Revision 1.6  2007/07/26 07:48:15  FLenhardt
-- Defined usage of TGA
--
-- Revision 1.5  2007/07/18 10:53:34  FLenhardt
-- Fixed bug regarding MTEST printout
--
-- Revision 1.4  2007/07/18 10:28:35  mernst
-- - Changed err to sum up errors instead of setting a specific value
-- - Added dat vector to terminal_in record
--
-- Revision 1.3  2006/08/24 08:52:02  mmiehling
-- changed txt_out to integer
--
-- Revision 1.1  2006/06/23 16:33:04  MMiehling
-- Initial Revision
--
-- Revision 1.2  2006/05/12 10:49:17  MMiehling
-- initialization of iram now with mem_init (back)
-- added testcase 14
--
-- Revision 1.1  2006/05/09 16:51:16  MMiehling
-- Initial Revision
--
-- Revision 1.2  2005/10/27 08:35:35  flenhardt
-- Added IRQ to TERMINAL_IN_TYPE record
--
-- Revision 1.1  2005/08/23 15:21:07  MMiehling
-- Initial Revision
--
-- Revision 1.1  2005/07/01 15:47:38  MMiehling
-- Initial Revision
--
-- Revision 1.2  2005/01/31 16:28:59  mmiehling
-- updated
--
-- Revision 1.1  2004/11/16 12:09:07  mmiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.print_pkg.all;
USE ieee.std_logic_arith.ALL;

PACKAGE terminal_pkg IS
     
	TYPE terminal_in_type IS record
		done	: boolean;									-- edge indicates end of transfer
		busy	: std_logic;								-- indicates status of master
		err	: natural;									-- number of errors occured
		irq	: std_logic;								-- interrupt request
		dat   : std_logic_vector(31 DOWNTO 0);    -- Input data
	END record;
	TYPE terminal_out_type IS record
		adr	: std_logic_vector(31 DOWNTO 0);		-- address
		tga	: std_logic_vector(5 DOWNTO 0);		-- 0=mem, 1=io, 2=conf
		dat	: std_logic_vector(31 DOWNTO 0);		-- write data
		wr		: natural;									-- 0=read, 1=write, 2=wait for numb cycles
		typ	: natural;									-- 0=b, w=1, l=2
		numb	: natural;									-- number of transactions (1=single, >1=burst)
		start	: boolean;									-- edge starts transfer
		txt	: integer;									-- enables info messages -- 0=quiet, 1=only errors, 2=all
	END record;
	
   -- Bus Accesses
	PROCEDURE init(	SIGNAL 	terminal_out	: OUT terminal_out_type);

	PROCEDURE wait_for(	SIGNAL 	terminal_in		: IN terminal_in_type;
								SIGNAL 	terminal_out	: OUT terminal_out_type;
											numb				: natural;
											woe				: boolean
											);
	PROCEDURE rd32(	SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										dat				: std_logic_vector; 
										numb				: natural;
										txt_out			: integer;
										woe				: boolean;
										tga				: std_logic_vector;
							         err				: INOUT natural
										);
	PROCEDURE rd16(	SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										dat				: std_logic_vector; 
										numb				: natural;
										txt_out			: integer;
										woe				: boolean;
										tga				: std_logic_vector;
							         err				: INOUT natural
										);
	PROCEDURE rd8(		SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										dat				: std_logic_vector; 
										numb				: natural;
										txt_out			: integer;
										woe				: boolean;
										tga				: std_logic_vector;
							         err				: INOUT natural
										);
	PROCEDURE wr32(	SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										dat				: std_logic_vector; 
										numb				: natural;
										txt_out			: integer;
										woe				: boolean;
										tga				: std_logic_vector
										);
	PROCEDURE wr16(		SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										dat				: std_logic_vector; 
										numb				: natural;
										txt_out			: integer;
										woe				: boolean;
										tga				: std_logic_vector
										);
	PROCEDURE wr8(		SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										dat				: std_logic_vector; 
										numb				: natural;
										txt_out			: integer;
										woe				: boolean;
										tga				: std_logic_vector
										);

	PROCEDURE mtest(	SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										adr_end			: std_logic_vector; 				-- = end address
										typ				: natural;							-- 0=l, 1=w, 2=b
										numb				: natural;							-- = number of cycles
										txt_out			: integer;
										tga				: std_logic_vector;
							         err				: INOUT natural
										) ;
										
	PROCEDURE mtest(	SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										adr_end			: std_logic_vector; 				-- = end address
										typ				: natural;							-- 0=l, 1=w, 2=b
										numb				: natural;							-- = number of cycles
										txt_out			: integer;
										tga				: std_logic_vector;
										seed				: natural;
							         err				: INOUT natural
										) ;

	PROCEDURE flash_mtest_indirect(	SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										adr_end			: std_logic_vector; 				-- = end address
										typ				: natural;							-- 0=l, 1=w, 2=b
										numb				: natural;							-- = number of cycles
										adr_if			: std_logic_vector; 				-- = address of indirect interface
										txt_out			: integer;
										tga				: std_logic_vector;
										err				: OUT natural
										) ;

  
END terminal_pkg;

PACKAGE BODY terminal_pkg IS 

----------------------------------------------------------------------------------------------------------

	PROCEDURE init(	SIGNAL 	terminal_out	: OUT terminal_out_type) IS
	BEGIN
		terminal_out.adr	<= (OTHERS => '0');
		terminal_out.tga	<= (OTHERS => '0');
		terminal_out.dat	<= (OTHERS => '0');
		terminal_out.wr	<= 0;
		terminal_out.typ	<= 0;
		terminal_out.numb	<= 0;
		terminal_out.txt	<= 0;
		terminal_out.start	<= TRUE;
	END PROCEDURE init;

	PROCEDURE wait_for(	SIGNAL 	terminal_in		: IN terminal_in_type;
								SIGNAL 	terminal_out	: OUT terminal_out_type;
											numb				: natural;
											woe				: boolean
											) IS
	BEGIN
		terminal_out.wr	<= 2;
		terminal_out.numb		<= numb;
		terminal_out.txt	<= 0;
		terminal_out.start	<= NOT terminal_in.done;
		IF woe THEN
			WAIT on terminal_in.done;
		END IF;
	END PROCEDURE;

	PROCEDURE rd32(	SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										dat				: std_logic_vector; 
										numb				: natural;
										txt_out			: integer;
										woe				: boolean;
										tga				: std_logic_vector;
							         err				: INOUT natural
										) IS
	BEGIN
		terminal_out.adr <= adr;
		terminal_out.dat <= dat;
		terminal_out.tga <= tga;
		terminal_out.numb <= numb;
		terminal_out.wr <= 0;
		terminal_out.typ <= 2;
		terminal_out.txt	<= txt_out;
		terminal_out.start <= NOT terminal_in.done;
		IF woe THEN
			WAIT on terminal_in.done;
		END IF;
		err := err + terminal_in.err;
	END PROCEDURE;

	PROCEDURE rd16(	SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										dat				: std_logic_vector; 
										numb				: natural;
										txt_out			: integer;
										woe				: boolean;
										tga				: std_logic_vector;
							         err				: INOUT natural
										) IS
	BEGIN
		terminal_out.adr <= adr;
		terminal_out.dat <= dat;
		terminal_out.tga <= tga;
		terminal_out.numb <= numb;
		terminal_out.wr <= 0;
		terminal_out.typ <= 1;
		terminal_out.txt	<= txt_out;
		terminal_out.start <= NOT terminal_in.done;
		IF woe THEN
			WAIT on terminal_in.done;
		END IF;
		err := err + terminal_in.err;
	END PROCEDURE;

	PROCEDURE rd8(		SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										dat				: std_logic_vector; 
										numb				: natural;
										txt_out			: integer;
										woe				: boolean;
										tga				: std_logic_vector;
							         err				: INOUT natural
										) IS
	BEGIN
		terminal_out.adr <= adr;
		terminal_out.dat <= dat;
		terminal_out.tga <= tga;
		terminal_out.numb <= numb;
		terminal_out.wr <= 0;
		terminal_out.typ <= 0;
		terminal_out.txt	<= txt_out;
		terminal_out.start <= NOT terminal_in.done;
		IF woe THEN
			WAIT on terminal_in.done;
		END IF;
		err := err + terminal_in.err;
	END PROCEDURE;

	PROCEDURE wr32(	SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										dat				: std_logic_vector; 
										numb				: natural;
										txt_out			: integer;
										woe				: boolean;
										tga				: std_logic_vector
										) IS
	BEGIN
		terminal_out.adr <= adr;
		terminal_out.dat <= dat;
		terminal_out.tga <= tga;
		terminal_out.numb <= numb;
		terminal_out.wr <= 1;
		terminal_out.typ <= 2;
		terminal_out.txt	<= txt_out;
		terminal_out.start <= NOT terminal_in.done;
		IF woe THEN
			WAIT on terminal_in.done;
		END IF;
	END PROCEDURE;
	
	PROCEDURE wr8(		SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										dat				: std_logic_vector; 
										numb				: natural;
										txt_out			: integer;
										woe				: boolean;
										tga				: std_logic_vector
										) IS
	BEGIN
		terminal_out.adr <= adr;
		terminal_out.dat <= dat;
		terminal_out.tga <= tga;
		terminal_out.numb <= numb;
		terminal_out.wr <= 1;
		terminal_out.typ <= 0;
		terminal_out.txt	<= txt_out;
		terminal_out.start <= NOT terminal_in.done;
		IF woe THEN
			WAIT on terminal_in.done;
		END IF;	
	END PROCEDURE;

	PROCEDURE wr16(	SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										dat				: std_logic_vector; 
										numb				: natural;
										txt_out			: integer;
										woe				: boolean;
										tga				: std_logic_vector
										) IS
	BEGIN
		terminal_out.adr <= adr;
		terminal_out.dat <= dat;
		terminal_out.tga <= tga;
		terminal_out.numb <= numb;
		terminal_out.wr <= 1;
		terminal_out.typ <= 1;
		terminal_out.txt	<= txt_out;
		terminal_out.start <= NOT terminal_in.done;
		IF woe THEN
			WAIT on terminal_in.done;
		END IF;	
	END PROCEDURE;


   -- This is the legacy MTEST (without seed)
	PROCEDURE mtest(	SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										adr_end			: std_logic_vector; 				-- = end address
										typ				: natural;							-- 0=l, 1=w, 2=b
										numb				: natural;							-- = number of cycles
										txt_out			: integer;
										tga				: std_logic_vector;
							         err				: INOUT natural
										) IS
	BEGIN
		mtest(terminal_in, terminal_out, adr, adr_end, typ, numb, txt_out, tga, 0, err);
	END PROCEDURE;


   -- This is an overloaded MTEST which accepts a seed number as an input,
   -- which can be used to generate the pseudo-random data in different ways
	PROCEDURE mtest(	SIGNAL 	terminal_in		: IN terminal_in_type;
							SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										adr_end			: std_logic_vector; 				-- = end address
										typ				: natural;							-- 0=l, 1=w, 2=b
										numb				: natural;							-- = number of cycles
										txt_out			: integer;
										tga				: std_logic_vector;
										seed				: natural;
							         err				: INOUT natural
										) IS
		VARIABLE loc_err		: natural;
		VARIABLE loc_adr		: std_logic_vector(31 DOWNTO 0);
		VARIABLE loc_dat		: std_logic_vector(31 DOWNTO 0);
		VARIABLE numb_cnt		: natural;
		
	BEGIN
		loc_adr := adr;
		numb_cnt := 0;
		loc_err := 0;
		loc_dat := adr;
		while NOT(numb_cnt = numb) LOOP
			CASE typ IS
				WHEN 0 =>	-- long
								while NOT (loc_adr = adr_end) LOOP
									loc_dat := (loc_dat(15 DOWNTO 0) & loc_dat(31 DOWNTO 16)) + 305419896 + seed;
									wr32(terminal_in, terminal_out, loc_adr, loc_dat, 1, txt_out, TRUE, tga);
									rd32(terminal_in, terminal_out, loc_adr, loc_dat, 1, txt_out, TRUE, tga, loc_err);
									loc_adr := loc_adr + x"4";
								END LOOP;
				WHEN 1 => 	-- word
								while NOT (loc_adr = adr_end) LOOP
									loc_dat := (loc_dat(15 DOWNTO 0) & loc_dat(31 DOWNTO 16)) + 305419896 + seed;
									wr16(terminal_in, terminal_out, loc_adr, loc_dat, 1, txt_out, TRUE, tga);
									rd16(terminal_in, terminal_out, loc_adr, loc_dat, 1, txt_out, TRUE, tga, loc_err);
									loc_adr := loc_adr + x"2";
								END LOOP;
				WHEN 2 => 	-- byte
								while NOT (loc_adr = adr_end) LOOP
									loc_dat := (loc_dat(15 DOWNTO 0) & loc_dat(31 DOWNTO 16)) + 305419896 + seed;
									wr8(terminal_in, terminal_out, loc_adr, loc_dat, 1, txt_out, TRUE, tga);
									rd8(terminal_in, terminal_out, loc_adr, loc_dat, 1, txt_out, TRUE, tga, loc_err);
									loc_adr := loc_adr + x"1";
								END LOOP;
				WHEN OTHERS => 
								print("ERROR terminal_pkg: typ IS NOT defined!");
			END CASE;
			numb_cnt := numb_cnt + 1;
		END LOOP;				
		IF loc_err > 0 THEN
			print_s_i(" mtest FAIL errors:  ", loc_err);
		ELSE
			print(" mtest PASS");
		END IF;
		err := err + loc_err;
	END PROCEDURE;


	PROCEDURE flash_mtest_indirect(	SIGNAL 	terminal_in		: IN terminal_in_type;
							    SIGNAL 	terminal_out	: OUT terminal_out_type;
										adr				: std_logic_vector;
										adr_end			: std_logic_vector; 				-- = end address
										typ				: natural;							-- 0=l, 1=w, 2=b
										numb				: natural;							-- = number of cycles
										adr_if			: std_logic_vector; 				-- = address of indirect interface
										txt_out			: integer;
										tga				: std_logic_vector;
										err				: OUT natural
										) IS
		VARIABLE loc_err		: natural;
		VARIABLE loc_err2		: natural;
		VARIABLE loc_adr		: std_logic_vector(31 DOWNTO 0);
		VARIABLE loc_dat		: std_logic_vector(31 DOWNTO 0);
		VARIABLE numb_cnt		: natural;
	BEGIN
		--loc_adr := adr;
		numb_cnt := 0;
		loc_err := 0;
		loc_dat := adr;
		while NOT(numb_cnt = numb) LOOP
			CASE typ IS
				WHEN 0 =>	-- long
						loc_adr := conv_std_logic_vector((conv_integer(adr)/4),32);
						print("Flash Address OF the address register will be autoincremented");
						print("Writing 32-bit data into Data Register => 32-bit Flash Memory access with indirect addressing");
						print("Reading 32-bit-Address Register IN order TO control exact address register content");
						while NOT (loc_adr = conv_std_logic_vector((conv_integer(adr_end)/4),32)) LOOP
							loc_dat := (loc_dat(15 DOWNTO 0) & loc_dat(31 DOWNTO 16)) + 305419896;
							wr32(terminal_in, terminal_out, adr_if + x"0000_0000", loc_adr, 1, txt_out, TRUE, tga);
							wr32(terminal_in, terminal_out, adr_if + x"0000_0004", loc_dat(31 DOWNTO 0), 1, txt_out, TRUE, tga);
							rd32(terminal_in, terminal_out, adr_if + x"0000_0000", "001" & loc_adr(28 DOWNTO 0), 1, txt_out, TRUE, tga, loc_err2);
							IF loc_err2 = 1 THEN
								print("ERROR WHEN reading address register: other value expected");
							END IF;
							loc_adr := loc_adr + x"1";
							loc_err := loc_err + loc_err2;
						END LOOP;	
						
						print("Reading Data Register from Memory using indirect addressing");
						loc_adr := conv_std_logic_vector((conv_integer(adr)/4),32);
						loc_dat := adr;
						while NOT (loc_adr = conv_std_logic_vector((conv_integer(adr_end)/4),32)) LOOP
							loc_dat := (loc_dat(15 DOWNTO 0) & loc_dat(31 DOWNTO 16)) + 305419896;
							wr32(terminal_in, terminal_out, adr_if + x"0000_0000", loc_adr, 1, txt_out, TRUE, tga);
							rd32(terminal_in, terminal_out, adr_if + x"0000_0004", loc_dat(31 DOWNTO 0), 1, txt_out, TRUE, tga, loc_err2);
							IF loc_err2 = 1 THEN
								print("ERROR WHEN reading data register: value READ from memory isn´t expected value");
							END IF;
							loc_err := loc_err + loc_err2;
							loc_adr := loc_adr + x"1";
						END LOOP;		
						
				WHEN 1 => 	-- word
						loc_adr := conv_std_logic_vector((conv_integer(adr)/2),32);
						print("Flash Address OF the address register will be autoincremented");
						print("Writing 16-bit data into Data Register => 16-bit Flash Memory access with indirect addressing");
						print("Reading 32-bit-Address Register IN order TO control exact address register content");
						while NOT (loc_adr = conv_std_logic_vector((conv_integer(adr_end)/2),32)) LOOP
							loc_dat := (loc_dat(15 DOWNTO 0) & loc_dat(31 DOWNTO 16)) + 305419896;
							wr32(terminal_in, terminal_out, adr_if + x"0000_0000", loc_adr, 1, txt_out, TRUE, tga);
							wr32(terminal_in, terminal_out, adr_if + x"0000_0004", x"0000" & loc_dat(15 DOWNTO 0), 1, txt_out, TRUE, tga);
							rd32(terminal_in, terminal_out, adr_if + x"0000_0000", "010" & loc_adr(28 DOWNTO 0), 1, txt_out, TRUE, tga, loc_err2);
							IF loc_err2 = 1 THEN
								print("ERROR WHEN reading address register: other value expected");
							END IF;
							loc_adr := loc_adr + x"1";
							loc_err := loc_err + loc_err2;
						END LOOP;
						
						print("READ AND Check 16-bit-Data from Memory using indirect addressing");
						loc_adr := conv_std_logic_vector((conv_integer(adr)/2),32);
						loc_dat := adr;
						while NOT (loc_adr = conv_std_logic_vector((conv_integer(adr_end)/2),32)) LOOP
							loc_dat := (loc_dat(15 DOWNTO 0) & loc_dat(31 DOWNTO 16)) + 305419896;
							wr32(terminal_in, terminal_out, adr_if + x"0000_0000", loc_adr, 1, txt_out, TRUE, tga);
							rd32(terminal_in, terminal_out, adr_if + x"0000_0004", x"0000" & loc_dat(15 DOWNTO 0), 1, txt_out, TRUE, tga, loc_err2);
							IF loc_err2 = 1 THEN
								print("ERROR WHEN reading data register: value READ from memory isn´t expected value");
							END IF;
							loc_err := loc_err + loc_err2;
							loc_adr := loc_adr + x"1";
						END LOOP;
						
				WHEN 2 => 	-- byte
						loc_adr := adr;
						print("Flash Address OF the address register will be autoincremented");
						print("Writing 8-bit data into Data Register => 8-bit Flash Memory access with indirect addressing");
						print("Reading 32-bit-Address Register IN order TO control exact address register content");
						while NOT (loc_adr = adr_end) LOOP
							loc_dat := (loc_dat(15 DOWNTO 0) & loc_dat(31 DOWNTO 16)) + 305419896;
							wr32(terminal_in, terminal_out, adr_if + x"0000_0000", loc_adr, 1, txt_out, TRUE, tga);
							wr32(terminal_in, terminal_out, adr_if + x"0000_0004", x"000000" & loc_dat(7 DOWNTO 0), 1, txt_out, TRUE, tga);
							rd32(terminal_in, terminal_out, adr_if + x"0000_0000", "000" & loc_adr(28 DOWNTO 0), 1, txt_out, TRUE, tga, loc_err2);
							IF loc_err2 = 1 THEN
								print("ERROR WHEN reading address register: other value expected");
							END IF;
							loc_adr := loc_adr + x"1";
							loc_err := loc_err + loc_err2;
						END LOOP;
						
						print("READ AND Check 8-bit-Data from Memory using indirect addressing");
						loc_adr := adr;
						loc_dat := adr;
						while NOT (loc_adr = adr_end) LOOP
							loc_dat := (loc_dat(15 DOWNTO 0) & loc_dat(31 DOWNTO 16)) + 305419896;
							wr32(terminal_in, terminal_out, adr_if + x"0000_0000", loc_adr, 1, txt_out, TRUE, tga);
							rd32(terminal_in, terminal_out, adr_if + x"0000_0004", x"000000" & loc_dat(7 DOWNTO 0), 1, txt_out, TRUE, tga, loc_err2);
							IF loc_err2 = 1 THEN
								print("ERROR WHEN reading data register: value READ from memory isn´t expected value");
							END IF;
							loc_err := loc_err + loc_err2;
							loc_adr := loc_adr + x"1";
						END LOOP;
				WHEN OTHERS => 
								print("ERROR terminal_pkg: typ IS NOT defined!");
			END CASE;
							numb_cnt := numb_cnt + 1;
		END LOOP;				
		IF loc_err > 0 THEN
			print_s_i(" mtest_indirect FAIL errors:  ", loc_err);
		ELSE
			print(" mtest_indirect PASS");
		END IF;
		err := loc_err;
	END PROCEDURE;

--------------------------------------------------------------------------------------------
END;