-------------------------------------------------------------------------------
--
--    File Name: MT58L512L18F.VHD
--     Revision: 2.0
--         Date: April 3rd, 2002
--        Model: Bus Functional
--    Simulator: Aldec, ModemSim, NCDesktop
--
-- Dependencies: None
--
--       Author: Son P. Huynh
--        Email: sphuynh@micron.com
--        Phone: (208) 368-3825
--      Company: Micron Technology, Inc.
--       Part #: MT58L512L18F
--
--  Description: Micron 8 Meg SyncBurst SRAM (Flow-through)
--
--   Disclaimer: THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY 
--               WHATSOEVER AND MICRON SPECIFICALLY DISCLAIMS ANY 
--               IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
--               A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.
--
--               Copyright (c) 1997 Micron Semiconductor Products, Inc.
--               All rights researved
--
-- Rev  Author          Phone         Date        Changes
-- ---  --------------  ------------  ----------  -----------------------------
-- 2.0  Son P. Huynh    208-368-3825  04/03/2002  - Fix Burst counter
--      Micron Technology, Inc.
--
-------------------------------------------------------------------------------

LIBRARY ieee, std, work;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.standard.ALL;
USE std.textio.all;


ENTITY MT58L512L18F IS
    GENERIC (
        -- Clock
        tKC       : TIME    :=  8.0 ns;  -- Timing are for -6.8
        tKH       : TIME    :=  1.8 ns;
        tKL       : TIME    :=  1.8 ns;
        -- Output Times
        tKQHZ     : TIME    :=  3.8 ns;
        -- Setup Times
        tAS       : TIME    :=  1.8 ns;
        tADSS     : TIME    :=  1.8 ns;
        tAAS      : TIME    :=  1.8 ns;
        tWS       : TIME    :=  1.8 ns;
        tDS       : TIME    :=  1.8 ns;
        tCES      : TIME    :=  1.8 ns;
        -- Hold Times
        tAH       : TIME    :=  0.5 ns;
        tADSH     : TIME    :=  0.5 ns;
        tAAH      : TIME    :=  0.5 ns;
        tWH       : TIME    :=  0.5 ns;
        tDH       : TIME    :=  0.5 ns;
        tCEH      : TIME    :=  0.5 ns;
        -- Bus Width and Data Bus
        addr_bits : INTEGER := 19;
        data_bits : INTEGER := 16
    );
    PORT (
        Dq        : INOUT STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');
        Addr      : IN    STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);
        Mode      : IN    STD_LOGIC;
        Adv_n     : IN    STD_LOGIC;
        Clk       : IN    STD_LOGIC;
        Adsc_n    : IN    STD_LOGIC;
        Adsp_n    : IN    STD_LOGIC;
        Bwa_n     : IN    STD_LOGIC;
        Bwb_n     : IN    STD_LOGIC;
        Bwe_n     : IN    STD_LOGIC;
        Gw_n      : IN    STD_LOGIC;
        Ce_n      : IN    STD_LOGIC;
        Ce2       : IN    STD_LOGIC;
        Ce2_n     : IN    STD_LOGIC;
        Oe_n      : IN    STD_LOGIC;
        Zz        : IN    STD_LOGIC
    );
END MT58L512L18F;

ARCHITECTURE behave OF MT58L512L18F IS
    TYPE   memory IS ARRAY (2 ** addr_bits - 1 DOWNTO 0) OF STD_LOGIC_VECTOR (data_bits / 2 - 1 DOWNTO 0);

    SIGNAL doe : STD_LOGIC;
    SIGNAL dout : STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');
    SIGNAL bwan, bwbn, ce, clr : STD_LOGIC;

--FILE outfile: TEXT IS OUT "sram_outfile.txt";

BEGIN
    bwan <= ((Bwa_n OR Bwe_n) AND Gw_n) OR (NOT(Ce_n) AND NOT(Adsp_n));
    bwbn <= ((Bwb_n OR Bwe_n) AND Gw_n) OR (NOT(Ce_n) AND NOT(Adsp_n));
    ce   <= NOT(Ce_n) AND Ce2 AND NOT(Ce2_n);
    clr  <= NOT(Adsc_n) OR (NOT(Adsp_n) AND NOT(Ce_n));

    main : PROCESS
        -- Memory Array
        VARIABLE bank0, bank1 : memory;
    
        -- Address Registers
        VARIABLE addr_reg_in  : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0) := (OTHERS => '0');
        VARIABLE addr_reg_out : STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0) := (OTHERS => '0');

        -- Burst Counter
        VARIABLE bcount : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
        VARIABLE baddr0 : STD_LOGIC;
        VARIABLE baddr1 : STD_LOGIC;

        -- Other Registers
        VARIABLE din     : STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');
        VARIABLE ce_reg  : STD_LOGIC;
        VARIABLE bwa_reg : STD_LOGIC;
        VARIABLE bwb_reg : STD_LOGIC;
		VARIABLE write_line			: line;
		
		VARIABLE i,j			: integer;
		VARIABLE dat		: STD_LOGIC_VECTOR (data_bits*2 - 1 DOWNTO 0);
    BEGIN
    		i := 0;
    		j := 0;
    		LOOP
    			dat := conv_std_logic_vector(j,data_bits*2);
				bank0(i) := dat(data_bits/2 -1 DOWNTO 0);
				bank1(i) := dat(data_bits-1 DOWNTO data_bits/2);
				bank0(i+1) := dat(3*data_bits/2 -1 DOWNTO data_bits);
				bank1(i+1) := dat(2*data_bits-1 DOWNTO 3*data_bits/2);
	    		i := i + 2;
	    		j := j + 1;
	    		IF i = 2 ** addr_bits THEN
	    			exit;
	    		END IF;
    		END LOOP;
    		
    		LOOP
	        WAIT ON Clk;
	        IF Clk'EVENT AND Clk = '1' AND Zz = '0' THEN
	            -- Address Register
	            IF clr = '1' THEN
	                addr_reg_in := Addr;
	            END IF;
	    
	            -- Binary Counter and Logic
	            IF Mode = '1' AND clr = '1' THEN
	                bcount := "00";
	            ELSIF Mode = '0' AND clr = '1' THEN
	                bcount := Addr(1 DOWNTO 0);
	            ELSIF Adv_n = '0' AND clr = '0' THEN
	                bcount(1) := bcount(0) XOR bcount(1);
	                bcount(0) := NOT(bcount(0));
	            END IF;
	    
	            -- Burst Address Decode
	            IF Mode = '1' THEN
	                baddr0 := bcount(0) XOR addr_reg_in(0);
	                baddr1 := bcount(1) XOR addr_reg_in(1);
	            ELSE
	                baddr0 := bcount(0);
	                baddr1 := bcount(1);
	            END IF;
	
	            -- Output Address
	            addr_reg_out (addr_bits - 1 DOWNTO 2) := addr_reg_in (addr_bits - 1 DOWNTO 2);
	            addr_reg_out (1) := baddr1;
	            addr_reg_out (0) := baddr0;
	    
	            -- Byte Write Register
	            bwa_reg := NOT(bwan);
	            bwb_reg := NOT(bwbn);
	    
	            -- Enable Register
	            IF clr = '1' THEN
	                ce_reg := ce;
	            END IF;
	    
	            -- Input Register
	            IF (ce_reg = '1' AND (bwa_reg = '1' OR bwb_reg = '1')) THEN
	                din := Dq;
	            ELSE
	                din := (OTHERS => 'Z');
	            END IF;
	            
	            -- Byte Write Driver
	            IF ce_reg = '1' AND bwa_reg = '1' THEN
	                bank0 (CONV_INTEGER(addr_reg_out)) := din ( 7 DOWNTO 0);
	--					WRITE(write_line, 'W');
	--					WRITE(write_line, 'L');
	--					WRITE(write_line, ' ');
	--					WRITE(write_line, TO_HEX_STRING(addr_reg_out));
	--					WRITE(write_line, ' ');
	--             WRITE(write_line, TO_HEX_STRING(din(7 DOWNTO 0)));
	--					WRITELINE(outfile, write_line);
	            END IF;
	            IF ce_reg = '1' AND bwb_reg = '1' THEN
	                bank1 (CONV_INTEGER(addr_reg_out)) := din (15 DOWNTO 8);
	--					WRITE(write_line, 'W');
	--					WRITE(write_line, 'H');
	--					WRITE(write_line, ' ');
	--					WRITE(write_line, TO_HEX_STRING(addr_reg_out));
	--					WRITE(write_line, ' ');
	--               WRITE(write_line, TO_HEX_STRING(din(15 DOWNTO 8)));
	--					WRITELINE(outfile, write_line);
	            END IF;
	
	            -- Output Register
	            IF (NOT(bwa_reg = '1' OR bwb_reg = '1')) THEN
	                dout ( 7 DOWNTO 0) <= bank0 (CONV_INTEGER(addr_reg_out));
	                dout (15 DOWNTO 8) <= bank1 (CONV_INTEGER(addr_reg_out));
	--					WRITE(write_line, 'R');
	--					WRITE(write_line, ' ');
	--					WRITE(write_line, TO_HEX_STRING(addr_reg_out));
	--					WRITE(write_line, ' ');
	--               WRITE(write_line, TO_HEX_STRING(bank1 (CONV_INTEGER(addr_reg_out))));
	--               WRITE(write_line, TO_HEX_STRING(bank0 (CONV_INTEGER(addr_reg_out))));
	--					WRITELINE(outfile, write_line);
	            END IF;
	
	            -- Data Out Enable
	            doe <= ce_reg AND (NOT(bwa_reg OR bwb_reg));
	        END IF;
			END LOOP;
    END PROCESS main;

    -- Output buffer
    WITH (NOT(Oe_n) AND NOT(Zz) AND doe) SELECT
        Dq <= TRANSPORT dout AFTER tKQHZ WHEN '1',
             (OTHERS => 'Z') AFTER tKQHZ WHEN '0',
             (OTHERS => 'Z') AFTER tKQHZ WHEN OTHERS;

    -- Checking for setup time violation
    Setup_check : PROCESS
    BEGIN
        WAIT ON Clk;
        IF Clk'EVENT AND Clk = '1' THEN
            ASSERT(Addr'LAST_EVENT >= tAS)
                REPORT "Addr Setup time violation -- tAS"
                SEVERITY WARNING;
            ASSERT(Adsc_n'LAST_EVENT >= tADSS)
                REPORT "Adsc_n Setup time violation -- tADSS"
                SEVERITY WARNING;
            ASSERT(Adsp_n'LAST_EVENT >= tADSS)
                REPORT "Adsp_n Setup time violation -- tADSS"
                SEVERITY WARNING;
            ASSERT(Adv_n'LAST_EVENT >= tAAS)
                REPORT "Adv_n Setup time violation -- tAAS"
                SEVERITY WARNING;
            ASSERT(Bwa_n'LAST_EVENT >= tWS)
                REPORT "Bwa_n Setup time violation -- tWS"
                SEVERITY WARNING;
            ASSERT(Bwb_n'LAST_EVENT >= tWS)
                REPORT "Bwb_n Setup time violation -- tWS"
                SEVERITY WARNING;
            ASSERT(Bwe_n'LAST_EVENT >= tWS)
                REPORT "Bwe_n Setup time violation -- tWS"
                SEVERITY WARNING;
            ASSERT(Gw_n'LAST_EVENT >= tWS)
                REPORT "Gw_n Setup time violation -- tWS"
                SEVERITY WARNING;
            ASSERT(Ce_n'LAST_EVENT >= tCES)
                REPORT "Ce_n Setup time violation -- tCES"
                SEVERITY WARNING;
            ASSERT(Ce2_n'LAST_EVENT >= tCES)
                REPORT "Ce2_n Setup time violation -- tCES"
                SEVERITY WARNING;
            ASSERT(Ce2'LAST_EVENT >= tCES)
                REPORT "Ce2 Setup time violation -- tCES"
                SEVERITY WARNING;
        END IF;
    END PROCESS;

    -- Checking for hold time violation
    Hold_check : PROCESS
    BEGIN
        WAIT ON Clk'DELAYED(tAH), Clk'DELAYED(tADSH), Clk'DELAYED(tAAH), Clk'DELAYED(tWH), Clk'DELAYED(tCEH);
        IF Clk'DELAYED(tAH)'EVENT AND Clk'DELAYED(tAH) = '1' THEN
            ASSERT(Addr'LAST_EVENT > tAH)
                REPORT "Addr Hold time violation -- tAH"
                SEVERITY WARNING;
        END IF;
        IF Clk'DELAYED(tADSH)'EVENT AND Clk'DELAYED(tADSH) = '1' THEN
            ASSERT(Adsc_n'LAST_EVENT > tADSH)
                REPORT "Adsc_n Hold time violation -- tADSH"
                SEVERITY WARNING;
            ASSERT(Adsp_n'LAST_EVENT > tADSH)
                REPORT "Adsp_n Hold time violation -- tADSH"
                SEVERITY WARNING;
        END IF;
        IF Clk'DELAYED(tAAH)'EVENT AND Clk'DELAYED(tAAH) = '1' THEN
            ASSERT(Adv_n'LAST_EVENT > tAAH)
                REPORT "Adv_n Hold time violation -- tAAH"
                SEVERITY WARNING;
        END IF;
        IF Clk'DELAYED(tWH)'EVENT AND Clk'DELAYED(tWH) = '1' THEN
            ASSERT(Bwa_n'LAST_EVENT > tWH)
                REPORT "Bwa_n Hold time violation -- tWH"
                SEVERITY WARNING;
            ASSERT(Bwb_n'LAST_EVENT > tWH)
                REPORT "Bwb_n Hold time violation -- tWH"
                SEVERITY WARNING;
            ASSERT(Bwe_n'LAST_EVENT > tWH)
                REPORT "Bwe_n Hold time violation -- tWH"
                SEVERITY WARNING;
            ASSERT(Gw_n'LAST_EVENT > tWH)
                REPORT "Gw_n Hold time violation -- tWH"
                SEVERITY WARNING;
        END IF;
        IF Clk'DELAYED(tCEH)'EVENT AND Clk'DELAYED(tCEH) = '1' THEN
            ASSERT(Ce_n'LAST_EVENT > tCEH)
                REPORT "Ce_n Hold time violation -- tCEH"
                SEVERITY WARNING;
            ASSERT(Ce2_n'LAST_EVENT > tCEH)
                REPORT "Ce2_n Hold time violation -- tCEH"
                SEVERITY WARNING;
            ASSERT(Ce2'LAST_EVENT > tCEH)
                REPORT "Ce2 Hold time violation -- tCEH"
                SEVERITY WARNING;
        END IF;
    END PROCESS;

END behave;
