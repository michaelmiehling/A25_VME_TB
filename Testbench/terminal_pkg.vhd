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
-- Revision 1.4  2017/06/13 07:00:00  mmiehling
-- reworked comments in vme_dma_sram2a32d64
--
-- Revision 1.3  2013/07/15 13:14:22  mmiehling
-- adopted testcases
--
-- Revision 1.2  2013/04/18 15:11:10  MMiehling
-- rework
--
-- Revision 1.1  2012/03/29 10:28:45  MMiehling
-- Initial Revision
--
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
USE ieee.std_logic_arith.CONV_STD_LOGIC_VECTOR;
USE work.print_pkg.all;
USE work.vme_sim_pack.all;
USE work.iram32_pkg.all;
USE work.pcie_sim_pkg.ALL;
LIBRARY modelsim_lib;
USE modelsim_lib.util.all;
USE std.textio.all;

PACKAGE terminal_pkg IS
     
   CONSTANT SIM_BAR0  : std_logic_vector(31 DOWNTO 0):= x"0000_0000";

   CONSTANT BAR0           : std_logic_vector(31 DOWNTO 0):=x"8000_0000";
   CONSTANT BAR1           : std_logic_vector(31 DOWNTO 0):=x"9000_0000";
   CONSTANT BAR2           : std_logic_vector(31 DOWNTO 0):= x"a000_0000";
   CONSTANT BAR3           : std_logic_vector(31 DOWNTO 0):= x"e000_0000";
   CONSTANT BAR4           : std_logic_vector(31 DOWNTO 0):= x"0000_0000";
   CONSTANT BAR5           : std_logic_vector(31 DOWNTO 0):= x"0000_0000";
   
-- +-Module Name--------------+-cyc-+---offset-+-----size-+-bar-+
-- |     Chameleon Table      |  0  |        0 |      200 |   0 |
-- |     16Z126_SERFLASH      |  1  |      200 |       20 |   0 |
-- |       16z002-01 VME      |  2  |    10000 |    10000 |   0 |
-- |16z002-01 VME A16D16      |  3  |    20000 |    10000 |   0 |
-- |16z002-01 VME A16D32      |  4  |    30000 |    10000 |   0 |
-- |  16z002-01 VME SRAM      |  5  |        0 |   100000 |   1 |
-- |16z002-01 VME A24D16      |  6  |        0 |  1000000 |   2 |
-- |16z002-01 VME A24D32      |  7  |  1000000 |  1000000 |   2 |
-- |   16z002-01 VME A32      |  8  |        0 | 20000000 |   3 |
-- +--------------------------+-----+----------+----------+-----+

  CONSTANT VME_REGS       : std_logic_vector(31 DOWNTO 0):=x"0001_0000" + BAR0;
  CONSTANT VME_IACK       : std_logic_vector(31 DOWNTO 0):=x"0001_0100" + BAR0;
  CONSTANT VME_A16D16     : std_logic_vector(31 DOWNTO 0):=x"0002_0000" + BAR0;
  CONSTANT VME_A16D32     : std_logic_vector(31 DOWNTO 0):=x"0003_0000" + BAR0;
  CONSTANT VME_A24D16     : std_logic_vector(31 DOWNTO 0):=x"0000_0000" + BAR2;
  CONSTANT VME_A24D32     : std_logic_vector(31 DOWNTO 0):=x"0100_0000" + BAR2;
  CONSTANT VME_CRCSR      : std_logic_vector(31 DOWNTO 0):=x"0000_0000" + BAR4;
  CONSTANT VME_A32D32     : std_logic_vector(31 DOWNTO 0):=x"0000_0000" + BAR3;

  CONSTANT SRAM           : std_logic_vector(31 DOWNTO 0):=x"0000_0000" + BAR1;


   TYPE terminal_in_type IS record
      done   : boolean;                           -- edge indicates end of transfer
      busy   : std_logic;                        -- indicates status of master
      err   : natural;                           -- number of errors occured
      irq   : std_logic;                        -- interrupt request
      dat   : std_logic_vector(31 DOWNTO 0);    -- Input data
   END record;
   TYPE terminal_out_type IS record
      adr   : std_logic_vector(31 DOWNTO 0);      -- address
      tga   : std_logic_vector(5 DOWNTO 0);      -- 
      dat   : std_logic_vector(31 DOWNTO 0);      -- write data
      wr      : natural;                           -- 0=read, 1=write, 2=wait for numb cycles
      typ   : natural;                           -- 0=b, w=1, l=2, dl=3
      numb   : natural;                           -- number of transactions (1=single, >1=burst)
      start   : boolean;                           -- edge starts transfer
      txt   : integer;                           -- enables info messages -- 0=quiet, 1=only errors, 2=all
   END record;
   
   -- Bus Accesses
   PROCEDURE init(   SIGNAL    terminal_out   : OUT terminal_out_type);

   PROCEDURE wait_for(   SIGNAL    terminal_in      : IN terminal_in_type;
                        SIGNAL    terminal_out   : OUT terminal_out_type;
                                 numb            : natural;
                                 woe            : boolean
                                 );
   PROCEDURE rd32(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector;
                              err            : INOUT natural
                              );
   PROCEDURE rd64(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector;
                              err            : INOUT natural
                              );
   PROCEDURE rd16(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector;
                              err            : INOUT natural
                              );
   PROCEDURE rd8(      SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector;
                              err            : INOUT natural
                              );
   PROCEDURE rd8_iack(      SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector;
                              err            : INOUT natural
                              );
   PROCEDURE wr32(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector
                              );
   PROCEDURE wr64(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector
                              );
   PROCEDURE wr16(      SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector
                              );
   PROCEDURE wr8(      SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector
                              );

   PROCEDURE mtest(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              adr_end         : std_logic_vector;             -- = end address
                              typ            : natural;                     -- 0=l, 1=w, 2=b
                              numb            : natural;                     -- = number of cycles
                              txt_out         : integer;
                              tga            : std_logic_vector;
                              err            : INOUT natural
                              ) ;
                              
   PROCEDURE mtest(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              adr_end         : std_logic_vector;             -- = end address
                              typ            : natural;                     -- 0=l, 1=w, 2=b
                              numb            : natural;                     -- = number of cycles
                              txt_out         : integer;
                              tga            : std_logic_vector;
                              seed            : natural;
                              err            : INOUT natural
                              ) ;

   PROCEDURE vme_ga_test(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   vme_ga         : OUT std_logic_vector(4 DOWNTO 0);
      SIGNAL   vme_gap        : OUT std_logic;
               en_msg_0       : integer;
               err            : OUT natural
               );

   PROCEDURE vme_dma_sram2a24d32(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               );

   PROCEDURE vme_slave_a242sram(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               );
   PROCEDURE vme_slave_a242pci(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               );
   PROCEDURE vme_reset(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   slot1          : OUT boolean;
      SIGNAL   hreset_n       : OUT std_logic;
      SIGNAL   v2p_rstn       : IN std_logic;
      SIGNAL   vb_sysresn     : IN std_logic;
               en_msg_0       : integer;
               err            : OUT natural
               );
 
   PROCEDURE vme_slave_a322sram(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               );
               
   PROCEDURE vme_slave_a322pci(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               );

 
   PROCEDURE cham_test(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               );
 
   PROCEDURE vme_slave_a162regs(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               );
 
   PROCEDURE vme_dma_sram2sram(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               );       
               
   PROCEDURE vme_dma_sram2pci(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               );

   PROCEDURE vme_dma_sram2a32d32(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               );               

   PROCEDURE vme_dma_sram2a32d64(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               );

   PROCEDURE vme_buserror(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               );
               
   PROCEDURE vme_master_windows(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               );

   PROCEDURE vme_arbitration(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   hreset_n       : OUT std_logic;
      SIGNAL   slot1          : OUT boolean;
      SIGNAL   en_clk         : OUT boolean;
               en_msg_0       : integer;
               err            : OUT natural
               ) ;

   PROCEDURE vme_arbiter(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               );

   PROCEDURE vme_irq_rcv(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   vme_slv_in     : OUT vme_slv_in_type;
      SIGNAL   vme_slv_out    : IN vme_slv_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               );

   PROCEDURE vme_irq_trans(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   vme_slv_in     : OUT vme_slv_in_type;
      SIGNAL   vme_slv_out    : IN vme_slv_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               );

               
   PROCEDURE rd_iram_bfm(
         adr      : std_logic_vector(31 DOWNTO 0);          -- address
         exp_dat  : std_logic_vector(31 DOWNTO 0);          -- expected data
         txt_out  : integer;                                -- 0= no message, 1=only errors, 2=all
         err      : OUT integer                             -- 1 if exp_dat /= read data
         );
   PROCEDURE wr_iram_bfm(
         adr      : std_logic_vector(31 DOWNTO 0);          -- address
         dat      : std_logic_vector(31 DOWNTO 0);          -- data
         txt_out  : integer;                                -- 0= no message, 1=only errors, 2=all
         err      : OUT integer                             
         );
   PROCEDURE print_err(s: in string; err: in integer);

   procedure configure_bfm(
      signal terminal_in  : in terminal_in_type;
      signal terminal_out : out terminal_out_type;
      bar0_addr : std_logic_vector(31 downto 0);
      bar1_addr : std_logic_vector(31 downto 0);
      bar2_addr : std_logic_vector(31 downto 0);
      bar3_addr : std_logic_vector(31 downto 0);
      bar4_addr : std_logic_vector(31 downto 0);
      bar5_addr : std_logic_vector(31 downto 0);
      txt_out   : integer
   );

END terminal_pkg;

PACKAGE BODY terminal_pkg IS 

----------------------------------------------------------------------------------------------------------
	PROCEDURE print_err(s: in string; err: in integer) is
	    variable l: line;
	BEGIN 
	    write(l, ' ');
	    WRITELINE(output,l);
	
	    WRITE(l, string'("   Testcase: "));
	    write(l, s);
	    WRITE(l, string'("   Error Sum: "));
	    write(l, err);
	    writeline(output,l);
	
	    write(l, ' ');
	    WRITELINE(output,l);
	END print_err;
	
   PROCEDURE wr_iram_bfm(
         adr      : std_logic_vector(31 DOWNTO 0);          -- address
         dat      : std_logic_vector(31 DOWNTO 0);          -- data
         txt_out  : integer;                                -- 0= no message, 1=only errors, 2=all
         err      : OUT integer                             
         ) IS
   BEGIN
      --! procedure to write values to the BFM internal memory
      --! @param bfm_inst_nbr number of the BFM instance that will be used
      --! @param nbr_of_dw number of DWORDS that will be written
      --! @param io_space set to true is I/O space is targeted
      --! @param mem32 set to true is MEM32 space is targeted, otherwise MEM64 space is used
      --! @param mem_addr offset for internal memory space, start at x"0000_0000"
      --! @param start_data_val first data value to write, other values are defined by data_inc
      --! @param data_inc defines the data increment added to start_data_val for DW 2 to nbr_of_dw
      --set_bfm_memory(0, 1, FALSE, TRUE, adr, dat, 1);
      set_bfm_memory(nbr_of_dw => 1, mem_addr => adr, start_data_val => dat, data_inc => 1);
      IF txt_out > 1 THEN 
         print_cycle("BFM SET: ", adr, dat, "1111", "");
      END IF;
      err := 0;
   END PROCEDURE;
   

   PROCEDURE rd_iram_bfm(
         adr      : std_logic_vector(31 DOWNTO 0);          -- address
         exp_dat  : std_logic_vector(31 DOWNTO 0);          -- expected data
         txt_out  : integer;                                -- 0= no message, 1=only errors, 2=all
         err      : OUT integer                             -- 1 if exp_dat /= read data
         ) IS
      VARIABLE databuf_out    : dword_vector(BFM_BUFFER_MAX_SIZE downto 0);
   BEGIN
      --! procedure to read from BFM internal memory
      --! @param bfm_inst_nbr number of the BFM instance that will be used
      --! @param nbr_of_dw number of DWORDS that will be written
      --! @param io_space set to true is I/O space is targeted
      --! @param mem32 set to true is MEM32 space is targeted, otherwise MEM64 space is used
      --! @param mem_addr offset for internal memory space, start at x"0000_0000"
      --! @return databuf_out returns a dword_vector that contains all data read from BFM internal memory
      --get_bfm_memory(0, 1, FALSE, TRUE,  adr, databuf_out);
      get_bfm_memory(nbr_of_dw => 1, mem_addr => adr, databuf_out => databuf_out);
      IF databuf_out(0) /= exp_dat THEN
         IF txt_out > 0 THEN 
            print_mtest("ERROR: ", adr, databuf_out(0), exp_dat, FALSE);
         END IF;
         err := 1;
      ELSIF txt_out > 1 THEN
         print_mtest("RD_IRAM_BFM: ", adr, databuf_out(0), exp_dat, TRUE);
         err := 0;
      END IF;
   END PROCEDURE;


   PROCEDURE init(   SIGNAL    terminal_out   : OUT terminal_out_type) IS
   BEGIN
      terminal_out.adr   <= (OTHERS => '0');
      terminal_out.tga   <= (OTHERS => '0');
      terminal_out.dat   <= (OTHERS => '0');
      terminal_out.wr   <= 0;
      terminal_out.typ   <= 0;
      terminal_out.numb   <= 0;
      terminal_out.txt   <= 0;
      terminal_out.start   <= TRUE;
   END PROCEDURE init;

   PROCEDURE wait_for(   SIGNAL    terminal_in      : IN terminal_in_type;
                        SIGNAL    terminal_out   : OUT terminal_out_type;
                                 numb            : natural;
                                 woe            : boolean
                                 ) IS
   BEGIN
      terminal_out.wr   <= 2;
      terminal_out.numb      <= numb;
      terminal_out.txt   <= 0;
      terminal_out.start   <= NOT terminal_in.done;
      IF woe THEN
         WAIT on terminal_in.done;
      END IF;
   END PROCEDURE;

   PROCEDURE rd32(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector;
                              err            : INOUT natural
                              ) IS
   BEGIN
      terminal_out.adr <= adr;
      terminal_out.dat <= dat;
      terminal_out.tga <= tga;
      terminal_out.numb <= numb;
      terminal_out.wr <= 0;
      terminal_out.typ <= 2;
      terminal_out.txt   <= txt_out;
      terminal_out.start <= NOT terminal_in.done;
      IF woe THEN
         WAIT on terminal_in.done;
      END IF;
      err := err + terminal_in.err;
   END PROCEDURE;

   PROCEDURE rd64(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector;
                              err            : INOUT natural
                              ) IS
   BEGIN
      terminal_out.adr <= adr;
      terminal_out.dat <= dat;
      terminal_out.tga <= tga;
      terminal_out.numb <= numb;
      terminal_out.wr <= 0;
      terminal_out.typ <= 3;
      terminal_out.txt   <= txt_out;
      terminal_out.start <= NOT terminal_in.done;
      IF woe THEN
         WAIT on terminal_in.done;
      END IF;
      err := err + terminal_in.err;
   END PROCEDURE;

   PROCEDURE rd16(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector;
                              err            : INOUT natural
                              ) IS
   BEGIN
      terminal_out.adr <= adr;
      terminal_out.dat <= dat;
      terminal_out.tga <= tga;
      terminal_out.numb <= numb;
      terminal_out.wr <= 0;
      terminal_out.typ <= 1;
      terminal_out.txt   <= txt_out;
      terminal_out.start <= NOT terminal_in.done;
      IF woe THEN
         WAIT on terminal_in.done;
      END IF;
      err := err + terminal_in.err;
   END PROCEDURE;

   PROCEDURE rd8(      SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector;
                              err            : INOUT natural
                              ) IS
   BEGIN
      terminal_out.adr <= adr;
      terminal_out.dat <= dat;
      terminal_out.tga <= tga;
      terminal_out.numb <= numb;
      terminal_out.wr <= 0;
      terminal_out.typ <= 0;
      terminal_out.txt   <= txt_out;
      terminal_out.start <= NOT terminal_in.done;
      IF woe THEN
         WAIT on terminal_in.done;
      END IF;
      err := err + terminal_in.err;
   END PROCEDURE;

   PROCEDURE rd8_iack(
                     SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector;
                              err            : INOUT natural
                              ) IS
   BEGIN
      terminal_out.adr <= adr;
      terminal_out.dat <= dat;
      terminal_out.tga <= tga;
      terminal_out.numb <= numb;
      terminal_out.wr <= 0;
      terminal_out.typ <= 4;  -- indicate iack
      terminal_out.txt   <= txt_out;
      terminal_out.start <= NOT terminal_in.done;
      IF woe THEN
         WAIT on terminal_in.done;
      END IF;
      err := err + terminal_in.err;
   END PROCEDURE;

   PROCEDURE wr32(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector
                              ) IS
   BEGIN
      terminal_out.adr <= adr;
      terminal_out.dat <= dat;
      terminal_out.tga <= tga;
      terminal_out.numb <= numb;
      terminal_out.wr <= 1;
      terminal_out.typ <= 2;
      terminal_out.txt   <= txt_out;
      terminal_out.start <= NOT terminal_in.done;
      IF woe THEN
         WAIT on terminal_in.done;
      END IF;
   END PROCEDURE;
   
   PROCEDURE wr64(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector
                              ) IS
   BEGIN
      terminal_out.adr <= adr;
      terminal_out.dat <= dat;
      terminal_out.tga <= tga;
      terminal_out.numb <= numb;
      terminal_out.wr <= 1;
      terminal_out.typ <= 3;
      terminal_out.txt   <= txt_out;
      terminal_out.start <= NOT terminal_in.done;
      IF woe THEN
         WAIT on terminal_in.done;
      END IF;
   END PROCEDURE;
   
   PROCEDURE wr8(      SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector
                              ) IS
   BEGIN
      terminal_out.adr <= adr;
      terminal_out.dat <= dat;
      terminal_out.tga <= tga;
      terminal_out.numb <= numb;
      terminal_out.wr <= 1;
      terminal_out.typ <= 0;
      terminal_out.txt   <= txt_out;
      terminal_out.start <= NOT terminal_in.done;
      IF woe THEN
         WAIT on terminal_in.done;
      END IF;   
   END PROCEDURE;

   PROCEDURE wr16(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              dat            : std_logic_vector; 
                              numb            : natural;
                              txt_out         : integer;
                              woe            : boolean;
                              tga            : std_logic_vector
                              ) IS
   BEGIN
      terminal_out.adr <= adr;
      terminal_out.dat <= dat;
      terminal_out.tga <= tga;
      terminal_out.numb <= numb;
      terminal_out.wr <= 1;
      terminal_out.typ <= 1;
      terminal_out.txt   <= txt_out;
      terminal_out.start <= NOT terminal_in.done;
      IF woe THEN
         WAIT on terminal_in.done;
      END IF;   
   END PROCEDURE;


   -- This is the legacy MTEST (without seed)
   PROCEDURE mtest(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              adr_end         : std_logic_vector;             -- = end address
                              typ            : natural;                     -- 0=l, 1=w, 2=b
                              numb            : natural;                     -- = number of cycles
                              txt_out         : integer;
                              tga            : std_logic_vector;
                              err            : INOUT natural
                              ) IS
   BEGIN
      mtest(terminal_in, terminal_out, adr, adr_end, typ, numb, txt_out, tga, 0, err);
   END PROCEDURE;


   -- This is an overloaded MTEST which accepts a seed number as an input,
   -- which can be used to generate the pseudo-random data in different ways
   PROCEDURE mtest(   SIGNAL    terminal_in      : IN terminal_in_type;
                     SIGNAL    terminal_out   : OUT terminal_out_type;
                              adr            : std_logic_vector;
                              adr_end         : std_logic_vector;             -- = end address
                              typ            : natural;                     -- 0=l, 1=w, 2=b
                              numb            : natural;                     -- = number of cycles
                              txt_out         : integer;
                              tga            : std_logic_vector;
                              seed            : natural;
                              err            : INOUT natural
                              ) IS
      VARIABLE loc_err      : natural;
      VARIABLE loc_adr      : std_logic_vector(31 DOWNTO 0);
      VARIABLE loc_dat      : std_logic_vector(31 DOWNTO 0);
      VARIABLE numb_cnt      : natural;
      
   BEGIN
      loc_adr := adr;
      numb_cnt := 0;
      loc_err := 0;
      loc_dat := adr;
      while NOT(numb_cnt = numb) LOOP
         CASE typ IS
            WHEN 0 =>   -- long
                        while NOT (loc_adr = adr_end) LOOP
                           loc_dat := (loc_dat(15 DOWNTO 0) & loc_dat(31 DOWNTO 16)) + 305419896 + seed;
                           wr32(terminal_in, terminal_out, loc_adr, loc_dat, 1, txt_out, TRUE, tga);
                           rd32(terminal_in, terminal_out, loc_adr, loc_dat, 1, txt_out, TRUE, tga, loc_err);
                           loc_adr := loc_adr + x"4";
                        END LOOP;
            WHEN 1 =>    -- word
                        while NOT (loc_adr = adr_end) LOOP
                           loc_dat := (loc_dat(15 DOWNTO 0) & loc_dat(31 DOWNTO 16)) + 305419896 + seed;
                           wr16(terminal_in, terminal_out, loc_adr, loc_dat, 1, txt_out, TRUE, tga);
                           rd16(terminal_in, terminal_out, loc_adr, loc_dat, 1, txt_out, TRUE, tga, loc_err);
                           loc_adr := loc_adr + x"2";
                        END LOOP;
            WHEN 2 =>    -- byte
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


------------------------------------------------------------------------------------------
   PROCEDURE vme_ga_test(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   vme_ga         : OUT std_logic_vector(4 DOWNTO 0);
      SIGNAL   vme_gap        : OUT std_logic;
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      VARIABLE vme_ga_int : std_logic_vector(4 DOWNTO 0);
      VARIABLE vme_gap_int : std_logic;
   BEGIN
      print("Test MEN_01A021_00_IT_xxxx: VME graphical address test");
         -- reset value shall be 0x0
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0050", x"0000_1e00", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;

         print_time("Check Slot Number detection by using corresponding VME_GA/VME_GAP settings");
         FOR i IN 1 TO 21 LOOP
            print_s_i("Slot Number ",i);
            vme_ga_int := NOT (conv_std_logic_vector(i,5));   -- inverted number
            vme_gap_int := NOT (vme_ga_int(4) XOR vme_ga_int(3) XOR vme_ga_int(2) XOR vme_ga_int(1) XOR vme_ga_int(0));
            vme_ga <= vme_ga_int;
            vme_gap <= vme_gap_int;
            rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0050", x"0000" & conv_std_logic_vector(i,8) & "00" & vme_gap_int & vme_ga_int, 1, en_msg_0, TRUE, "000001", loc_err);
            err_sum := err_sum + loc_err;
         END LOOP;
         
         WAIT FOR 1 us;

         print_time("Check Slot Number detection by using incorrect VME_GAP settings => Slot Number shall be always 30");
         FOR i IN 1 TO 21 LOOP
            print_s_i("Slot Number ",i);
            vme_ga_int := NOT (conv_std_logic_vector(i,5));   -- inverted number
            vme_gap_int :=  (vme_ga_int(4) XOR vme_ga_int(3) XOR vme_ga_int(2) XOR vme_ga_int(1) XOR vme_ga_int(0));
            vme_ga <= vme_ga_int;
            vme_gap <= vme_gap_int;
            rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0050", x"0000" & x"1e" & "00" & vme_gap_int & vme_ga_int, 1, en_msg_0, TRUE, "000001", loc_err);
            err_sum := err_sum + loc_err;
         END LOOP;

         WAIT FOR 1 us;

         print_time("Check Slot Number detection by using incorrect VME_GA/VME_GAP settings => Slot Number shall be always 30");
         FOR i IN 22 TO 31 LOOP
            vme_ga_int := NOT (conv_std_logic_vector(i,5));   -- inverted number
            vme_gap_int := NOT (vme_ga_int(4) XOR vme_ga_int(3) XOR vme_ga_int(2) XOR vme_ga_int(1) XOR vme_ga_int(0));
            print_s_std("VME_GAP & VME_GA setting = ", "00" & vme_gap_int & vme_ga_int);
            vme_ga <= vme_ga_int;
            vme_gap <= vme_gap_int;
            rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0050", x"0000" & x"1e" & "00" & vme_gap_int & vme_ga_int, 1, en_msg_0, TRUE, "000001", loc_err);
            err_sum := err_sum + loc_err;
         END LOOP;


         err := err_sum;
         print_err("vme_ga_test", err_sum);
   END PROCEDURE;

------------------------------------------------------------------------------------------
   PROCEDURE vme_dma_sram2a24d32(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      variable var_msi_expected  : std_logic_vector(31 downto 0) := (others => '0');
      variable var_success       : boolean := false;
      variable var_msi_allocated : std_logic_vector(2 downto 0) := (others => '0');
      variable var_check_msi_nbr : natural := 0;
      constant MSI_SHMEM_ADDR    : natural := 2096896; -- := x"1FFF00" at upper end of shared memory
      constant MSI_DATA_VAL      : std_logic_vector(15 downto 0) := x"3210";
   BEGIN
      print("Test MEN_01A021_00_IT_0110: VME DMA: SRAM TO VME A24D32 AND back");
      var_success := false;
      bfm_configure_msi(
         msi_addr       => MSI_SHMEM_ADDR,
         msi_data       => MSI_DATA_VAL,
         msi_allocated  => var_msi_allocated,
         success        => var_success
      );
      if not var_success then 
         err_sum := err_sum +1;
         if en_msg_0 >= 1 then 
            print_now("ERROR(vme_dma_sram2a24d32): error while executing bfm_configure_msi() - MSI NOT configured, MSI behavior is UNDEFINED!");
            print("   ---> test case skipped");
         end if;
      else
         -- test data in sram
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0008", x"1111_1111", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0008", x"1111_1111", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_000c", x"2222_2222", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_000c", x"2222_2222", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0010", x"3333_3333", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0010", x"3333_3333", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0014", x"4444_4444", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0014", x"4444_4444", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         -- clear destination in VME_A24D32
         wr32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0000", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0004", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0008", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_000c", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0010", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0014", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0018", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         -- clear destination in SRAM
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0100", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0104", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0108", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_010c", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0110", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0114", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_00fc", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         -- config buffer descriptor #1 SRAM => VME_A24D32
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F900", x"0020_0004", 1, en_msg_0, TRUE, "000001");  -- dest adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F900", x"0020_0004", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F904", x"0000_0008", 1, en_msg_0, TRUE, "000001");  -- source adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F904", x"0000_0008", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F908", x"0000_0003", 1, en_msg_0, TRUE, "000001");  -- size
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F908", x"0000_0003", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F90c", x"0001_2040", 1, en_msg_0, TRUE, "000001");  -- source=sram dest=A24D32 inc
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F90c", x"0001_2040", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
   
         -- config buffer descriptor #2 VME_A24D32 => SRAM
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F910", x"0000_0100", 1, en_msg_0, TRUE, "000001");  -- dest adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F910", x"0000_0100", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F914", x"0020_0004", 1, en_msg_0, TRUE, "000001");  -- source adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F914", x"0020_0004", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F918", x"0000_0003", 1, en_msg_0, TRUE, "000001");  -- size
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F918", x"0000_0003", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F91c", x"0002_1041", 1, en_msg_0, TRUE, "000001");  -- source=A24D32 dest=sram inc
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F91c", x"0002_1041", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0003", 1, en_msg_0, TRUE, "000001");  -- start transfer
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0003", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
      
         var_check_msi_nbr := 9;
         bfm_calc_msi_expected(
            msi_allocated => var_msi_allocated,
            msi_data      => MSI_DATA_VAL,
            msi_nbr       => var_check_msi_nbr,
            msi_expected  => var_msi_expected
         );
         var_success := false;
         bfm_poll_msi(
            track_msi    => 1,
            msi_addr     => MSI_SHMEM_ADDR,
            msi_expected => var_msi_expected,
            txt_out      => en_msg_0,
            success      => var_success
         );
         if not var_success then 
            err_sum := err_sum +1;
            if en_msg_0 >= 1 then print_now("ERROR(vme_dma_sram2a24d32): error while executing bfm_poll_msi()"); end if;
         end if;

         IF irq_req(13) = '0' THEN  
            print_time("ERROR vme_dma_sram2a24d32: dma irq NOT asserted");
         END IF;
         -- check control reg for irq asserted
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0006", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         -- check destination VME_A24D32
         rd32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0000", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0004", x"1111_1111", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0008", x"2222_2222", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_000c", x"3333_3333", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0010", x"4444_4444", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0014", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0018", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         -- check destination SRAM
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_00fc", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0100", x"1111_1111", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0104", x"2222_2222", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0108", x"3333_3333", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_010c", x"4444_4444", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0110", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         -- check irq
         IF irq_req(13) = '0' THEN  
            print_time("ERROR vme_dma_sram2a24d32: dma irq NOT asserted");
         END IF;
         -- clear irq request
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0004", 1, en_msg_0, TRUE, "000001");
         IF irq_req(13) = '1' THEN  
            print_time("ERROR vme_dma_sram2a24d32: dma irq asserted");
         END IF;
         -- check control reg for end of dma
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
      end if;
      WAIT FOR 500 ns;
      err := err_sum;
      print_err("vme_dma_sram2a24d32", err_sum);
   END PROCEDURE;

----------------------------------------------------------------------------------------------
   PROCEDURE vme_reset(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   slot1          : OUT boolean;
      SIGNAL   hreset_n       : OUT std_logic;
      SIGNAL   v2p_rstn       : IN std_logic;
      SIGNAL   vb_sysresn     : IN std_logic;
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      VARIABLE dat     : std_logic_vector(31 DOWNTO 0);
   BEGIN
      print("Test MEN_01A021_00_IT_0010: VME Reset (there might be WBB bus errors indicated");

      print("NOT Slot1");
         -- powerup board
         -- shorten reset time on vme bus
         hreset_n <= '0';
         signal_force("/a25_tb/a25/pll/areset", "1", 0 ns, freeze, 100 ns, 1);
         signal_force("/a25_tb/a25/vme/vmectrl/bustimer/pre_cnt_max_sig", "0000001000", 0 ns, freeze, -1 ns, 1);
         signal_force("/a25_tb/a25/vme/vmectrl/bustimer/main_cnt_max_sig", "000000000000011", 0 ns, freeze, -1 ns, 1);
--         signal_force("/a25_tb/a25/pcie/test_pcie_core", "0000000000000001", 0 ns, freeze, -1 ns, 1);
--         signal_force("/a25_tb/a25/pcie/test_rs_serdes", "1", 0 ns, freeze, -1 ns, 1);
         slot1 <= FALSE;
         WAIT FOR 100 ns;
         IF vb_sysresn /= '0' THEN
            print_time(" ERROR: SIGNAL vb_sysresn should be active");
            err_sum := err_sum + 1;
         END IF;
         hreset_n <= '1';
         WAIT FOR 1 us;
         IF vb_sysresn = '0' THEN
            print_time(" ERROR: SIGNAL vb_sysresn should be inactive");
            err_sum := err_sum + 1;
         END IF;
         WAIT FOR 1 us;
         init_bfm(0, x"0000_0000", SIM_BAR0, x"0000_0000_0000_0000", x"0000", 256);
         configure_bfm(terminal_in => terminal_in_0, terminal_out => terminal_out_0, bar0_addr => BAR0, bar1_addr => BAR1, bar2_addr => BAR2, bar3_addr => BAR3, bar4_addr => BAR4, bar5_addr => BAR5, txt_out => en_msg_0);
         WAIT FOR 3 us;
      
      print_time("check result of slot1 detection");
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0018", x"00000000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      
      print_time(" vb_sysresn inactive?");
      IF vb_sysresn = '0' THEN
         print_time(" ERROR: SIGNAL vb_sysresn should be inactive");
         err_sum := err_sum + 1;
      END IF;
      WAIT FOR 1 us;

      print_time(" force vb_sysresn TO 0");
      signal_force("/a25_tb/vb_sysresn", "0", 0 ns, freeze, 1000 ns, 1);
      WAIT FOR 200 ns;
      print_time(" v2p_rstn active?");
      IF v2p_rstn /= '0' THEN
         print_time(" ERROR: SIGNAL v2p_rstn should be active");
         err_sum := err_sum + 1;
      END IF;

      WAIT FOR 1 us; 
      print_time(" v2p_rstn inactive?");
      IF v2p_rstn = '0' THEN
         print_time(" ERROR: SIGNAL v2p_rstn should be inactive");
         err_sum := err_sum + 1;
      END IF;
      hreset_n <= '1';
      WAIT FOR 1 us; 
      
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0018", x"00000000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      

      
----------------------------      
      print("Slot1");
         -- powerup board
         -- shorten reset time on vme bus
         hreset_n <= '0';
         signal_force("/a25_tb/a25/pll/areset", "1", 0 ns, freeze, 100 ns, 1);
         signal_force("/a25_tb/a25/vme/vmectrl/bustimer/pre_cnt_max_sig", "0000001000", 0 ns, freeze, -1 ns, 1);
         signal_force("/a25_tb/a25/vme/vmectrl/bustimer/main_cnt_max_sig", "000000000000011", 0 ns, freeze, -1 ns, 1);
--         signal_force("/a25_tb/a25/pcie/test_pcie_core", "0000000000000001", 0 ns, freeze, -1 ns, 1);
--         signal_force("/a25_tb/a25/pcie/test_rs_serdes", "1", 0 ns, freeze, -1 ns, 1);
         slot1 <= TRUE;
         WAIT FOR 100 ns;
         IF vb_sysresn /= '0' THEN
            print_time(" ERROR: SIGNAL vb_sysresn should be active");
            err_sum := err_sum + 1;
         END IF;
         hreset_n <= '1';
         WAIT FOR 1 us;
         IF vb_sysresn = '0' THEN
            print_time(" ERROR: SIGNAL vb_sysresn should be inactive");
            err_sum := err_sum + 1;
         END IF;
         WAIT FOR 1 us;
         init_bfm(0, x"0000_0000", SIM_BAR0, x"0000_0000_0000_0000", x"0000", 256);
         configure_bfm(terminal_in => terminal_in_0, terminal_out => terminal_out_0, bar0_addr => BAR0, bar1_addr => BAR1, bar2_addr => BAR2, bar3_addr => BAR3, bar4_addr => BAR4, bar5_addr => BAR5, txt_out => en_msg_0);
         WAIT FOR 3 us;
      
      print_time("check result of slot1 detection");
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0018", x"00000001", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      
      print_time(" vb_sysresn inactive?");
      IF vb_sysresn = '0' THEN
         print_time(" ERROR: SIGNAL vb_sysresn should be inactive");
         err_sum := err_sum + 1;
      END IF;
      WAIT FOR 1 us;

      print_time(" force vb_sysresn TO 0");
      signal_force("/a25_tb/vb_sysresn", "0", 0 ns, freeze, 1000 ns, 1);
      WAIT FOR 200 ns;
      print_time(" v2p_rstn active?");
      IF v2p_rstn /= '0' THEN
         print_time(" ERROR: SIGNAL v2p_rstn should be active");
         err_sum := err_sum + 1;
      END IF;

      WAIT FOR 1 us; 
      print_time(" v2p_rstn inactive?");
      IF v2p_rstn = '0' THEN
         print_time(" ERROR: SIGNAL v2p_rstn should be inactive");
         err_sum := err_sum + 1;
      END IF;
      hreset_n <= '1';
      WAIT FOR 1 us; 
      
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0018", x"00000001", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      


      err := err_sum;
      print_err("vme_reset", err_sum);
   END PROCEDURE;

----------------------------------------------------------------------------------------------
   PROCEDURE vme_slave_a242sram(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      VARIABLE dat     : std_logic_vector(31 DOWNTO 0);
   BEGIN
      print("Test MEN_01A021_00_IT_0030: VME A24 TO SRAM WRITE");
         -- write to a24 vme slave (supervisory data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0014", x"0000_0013", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0030_0000
         WAIT FOR 1 us;
         wr32(terminal_in_1, terminal_out_1, x"0030_0104", x"cafe_affe", 1, en_msg_0, TRUE, "111101");
         wr32(terminal_in_1, terminal_out_1, x"0030_0108", x"1111_2222", 1, en_msg_0, TRUE, "111101");
         WAIT FOR 100 ns;
         wr16(terminal_in_1, terminal_out_1, x"0030_0130", x"1112_1314", 1, en_msg_0, TRUE, "111101");
         wr16(terminal_in_1, terminal_out_1, x"0030_0132", x"1516_1718", 1, en_msg_0, TRUE, "111101");
         WAIT FOR 100 ns;
         wr8(terminal_in_1, terminal_out_1, x"0030_0140", x"1111_11aa", 1, en_msg_0, TRUE, "111101");
         wr8(terminal_in_1, terminal_out_1, x"0030_0141", x"1111_bb11", 1, en_msg_0, TRUE, "111101");
         wr8(terminal_in_1, terminal_out_1, x"0030_0142", x"11cc_1111", 1, en_msg_0, TRUE, "111101");
         wr8(terminal_in_1, terminal_out_1, x"0030_0143", x"dd11_1111", 1, en_msg_0, TRUE, "111101");

         -- write to a24 vme slave (non privileged data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0014", x"0000_0014", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0040_0000
         WAIT FOR 1 us;
         wr32(terminal_in_1, terminal_out_1, x"0040_0304", x"cafe_affe", 1, en_msg_0, TRUE, "111001");
         wr32(terminal_in_1, terminal_out_1, x"0040_0308", x"1111_2222", 1, en_msg_0, TRUE, "111001");
         WAIT FOR 100 ns;
         wr16(terminal_in_1, terminal_out_1, x"0040_0330", x"1112_1314", 1, en_msg_0, TRUE, "111001");
         wr16(terminal_in_1, terminal_out_1, x"0040_0332", x"1516_1718", 1, en_msg_0, TRUE, "111001");
         WAIT FOR 100 ns;
         wr8(terminal_in_1, terminal_out_1, x"0040_0340", x"1111_11aa", 1, en_msg_0, TRUE, "111001");
         wr8(terminal_in_1, terminal_out_1, x"0040_0341", x"1111_bb11", 1, en_msg_0, TRUE, "111001");
         wr8(terminal_in_1, terminal_out_1, x"0040_0342", x"11cc_1111", 1, en_msg_0, TRUE, "111001");
         wr8(terminal_in_1, terminal_out_1, x"0040_0343", x"dd11_1111", 1, en_msg_0, TRUE, "111001");

         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0014", x"0000_0015", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0050_0000
         WAIT FOR 1 us;
         -- non privileged block transfer
         wr32(terminal_in_1, terminal_out_1, x"0050_0410", x"3333_4444", 2, en_msg_0, TRUE, "111011");
         WAIT FOR 100 ns;
         -- supervisory block transfer
         wr32(terminal_in_1, terminal_out_1, x"0050_0420", x"5555_5555", 3, en_msg_0, TRUE, "111111");
         WAIT FOR 100 ns;
         -- non privileged 64-bit block transfer
         wr64(terminal_in_1, terminal_out_1, x"0050_0450", x"1234_5678", 2, en_msg_0, TRUE, "111000");
         WAIT FOR 100 ns;
         -- supervisory 64-bit block transfer
         wr64(terminal_in_1, terminal_out_1, x"0050_0470", x"cafe_affe", 3, en_msg_0, TRUE, "111100");
         WAIT FOR 100 ns;
         -- read from sram
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0104", x"cafe_affe", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0108", x"1111_2222", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0132", x"1516_1314", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0140", x"ddcc_bbaa", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0304", x"cafe_affe", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0308", x"1111_2222", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0332", x"1516_1314", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0340", x"ddcc_bbaa", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0410", x"3333_4444", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0414", x"3433_4444", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;

         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0420", x"5555_5555", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0424", x"5655_5555", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0428", x"5755_5555", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;

         dat := x"1234_5678";
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0454", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := NOT dat;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0450", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := (NOT dat) + x"10_00000";
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_045c", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := NOT dat;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0458", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;

         dat := x"cafe_affe";
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0474", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := NOT dat;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0470", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := (NOT dat) + x"10_00000";
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_047c", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := NOT dat;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0478", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := (NOT dat) + x"10_00000";
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0484", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := NOT dat;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0480", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
   
      print("Test: VME A24 TO SRAM READ");
         -- prepare data in sram
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0004", x"cafe_affe", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0008", x"1111_2222", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0030", x"1516_1314", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0034", x"1234_5678", 1, en_msg_0, TRUE, "000001");
         dat := x"1234_5678";
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0044", dat, 1, en_msg_0, TRUE, "000001");  
         dat := NOT dat;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0040", dat, 1, en_msg_0, TRUE, "000001");
         dat := (NOT dat) + x"10_00000";
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_004c", dat, 1, en_msg_0, TRUE, "000001");
         dat := NOT dat;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0048", dat, 1, en_msg_0, TRUE, "000001");
         dat := (NOT dat) + x"10_00000";
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0054", dat, 1, en_msg_0, TRUE, "000001");
         dat := NOT dat;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0050", dat, 1, en_msg_0, TRUE, "000001");
         dat := (NOT dat) + x"10_00000";
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_005c", dat, 1, en_msg_0, TRUE, "000001");

         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0080", x"abcd_ef01", 1, en_msg_0, TRUE, "000001");  
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0084", x"accd_ef01", 1, en_msg_0, TRUE, "000001");  
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0088", x"adcd_ef01", 1, en_msg_0, TRUE, "000001");  
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_008c", x"aecd_ef01", 1, en_msg_0, TRUE, "000001");  

         -- read from a24 vme slave (supervisory data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0014", x"0000_0017", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0070_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"0070_0008", x"1111_2222", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd16(terminal_in_1, terminal_out_1, x"0070_0030", x"1112_1314", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         rd16(terminal_in_1, terminal_out_1, x"0070_0032", x"1516_1718", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd8(terminal_in_1, terminal_out_1, x"0070_0034", x"1111_1178", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"0070_0035", x"1111_5611", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"0070_0036", x"1134_1111", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"0070_0037", x"1211_1111", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         rd32(terminal_in_1, terminal_out_1, x"0070_0004", x"cafe_affe", 1, en_msg_0, TRUE, "111101", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a24 vme slave (non privileged data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0014", x"0000_0015", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0050_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"0050_0008", x"1111_2222", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd16(terminal_in_1, terminal_out_1, x"0050_0030", x"1112_1314", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         rd16(terminal_in_1, terminal_out_1, x"0050_0032", x"1516_1718", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd8(terminal_in_1, terminal_out_1, x"0050_0034", x"1111_1178", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"0050_0035", x"1111_5611", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"0050_0036", x"1134_1111", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"0050_0037", x"1211_1111", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         rd32(terminal_in_1, terminal_out_1, x"0050_0004", x"cafe_affe", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 

         -- read from a24 vme slave (supervisory block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0014", x"0000_0018", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0080_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"0080_0080", x"abcd_ef01", 2, en_msg_0, TRUE, "111111", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a24 vme slave (non privileged block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0014", x"0000_0019", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0090_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"0090_0080", x"abcd_ef01", 3, en_msg_0, TRUE, "111011", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a24 vme slave (supervisory 64-bit block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0014", x"0000_001a", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x00a0_0000
         WAIT FOR 1 us;
         rd64(terminal_in_1, terminal_out_1, x"00a0_0040", x"1234_5678", 2, en_msg_0, TRUE, "111100", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a24 vme slave (supervisory 64-bit block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0014", x"0000_001b", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x00b0_0000
         WAIT FOR 1 us;
         rd64(terminal_in_1, terminal_out_1, x"00b0_0040", x"1234_5678", 3, en_msg_0, TRUE, "111000", loc_err);         
         err_sum := err_sum + loc_err; 

         err := err_sum;
         print_err("vme_slave_a242sram", err_sum);
   END PROCEDURE;
   
----------------------------------------------------------------------------------------------
   PROCEDURE vme_slave_a242pci(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      VARIABLE dat     : std_logic_vector(31 DOWNTO 0);
      VARIABLE ex_dat     : std_logic_vector(31 DOWNTO 0);
      CONSTANT OFFSET  : std_logic_vector(31 DOWNTO 0):=x"1000_0000";
   BEGIN
      print("Test MEN_01A021_00_IT_0040: VME A24 TO PCI WRITE");
         -- set pci offset
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0028", x"0000_0100", 1, en_msg_0, TRUE, "000001"); -- set pci offset to 0x1000_0000
         -- write to a24 vme slave (supervisory data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0048", x"0000_0013", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0030_0000
         WAIT FOR 1 us;
         wr32(terminal_in_1, terminal_out_1, x"0030_0104", x"cafe_affe", 1, en_msg_0, TRUE, "111101");
         wr32(terminal_in_1, terminal_out_1, x"0030_0108", x"1111_2222", 1, en_msg_0, TRUE, "111101");
         WAIT FOR 100 ns;
         wr16(terminal_in_1, terminal_out_1, x"0030_0130", x"1112_1314", 1, en_msg_0, TRUE, "111101");
         wr16(terminal_in_1, terminal_out_1, x"0030_0132", x"1516_1718", 1, en_msg_0, TRUE, "111101");
         WAIT FOR 100 ns;
         wr8(terminal_in_1, terminal_out_1, x"0030_0140", x"1111_11aa", 1, en_msg_0, TRUE, "111101");
         wr8(terminal_in_1, terminal_out_1, x"0030_0141", x"1111_bb11", 1, en_msg_0, TRUE, "111101");
         wr8(terminal_in_1, terminal_out_1, x"0030_0142", x"11cc_1111", 1, en_msg_0, TRUE, "111101");
         wr8(terminal_in_1, terminal_out_1, x"0030_0143", x"dd11_1111", 1, en_msg_0, TRUE, "111101");

         -- write to a24 vme slave (non privileged data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0048", x"0000_0014", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0040_0000
         WAIT FOR 1 us;
         wr32(terminal_in_1, terminal_out_1, x"0040_0304", x"cafe_affe", 1, en_msg_0, TRUE, "111001");
         wr32(terminal_in_1, terminal_out_1, x"0040_0308", x"1111_2222", 1, en_msg_0, TRUE, "111001");
         WAIT FOR 100 ns;
         wr16(terminal_in_1, terminal_out_1, x"0040_0330", x"1112_1314", 1, en_msg_0, TRUE, "111001");
         wr16(terminal_in_1, terminal_out_1, x"0040_0332", x"1516_1718", 1, en_msg_0, TRUE, "111001");
         WAIT FOR 100 ns;
         wr8(terminal_in_1, terminal_out_1, x"0040_0340", x"1111_11aa", 1, en_msg_0, TRUE, "111001");
         wr8(terminal_in_1, terminal_out_1, x"0040_0341", x"1111_bb11", 1, en_msg_0, TRUE, "111001");
         wr8(terminal_in_1, terminal_out_1, x"0040_0342", x"11cc_1111", 1, en_msg_0, TRUE, "111001");
         wr8(terminal_in_1, terminal_out_1, x"0040_0343", x"dd11_1111", 1, en_msg_0, TRUE, "111001");

         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0048", x"0000_0015", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0050_0000
         WAIT FOR 1 us;
         -- non privileged block transfer
         wr32(terminal_in_1, terminal_out_1, x"0050_0410", x"3333_4444", 2, en_msg_0, TRUE, "111011");
         WAIT FOR 100 ns;
         -- supervisory block transfer
         wr32(terminal_in_1, terminal_out_1, x"0050_0420", x"5555_5555", 3, en_msg_0, TRUE, "111111");
         WAIT FOR 100 ns;
         -- non privileged 64-bit block transfer
         wr64(terminal_in_1, terminal_out_1, x"0050_0450", x"1234_5678", 2, en_msg_0, TRUE, "111000");
         WAIT FOR 100 ns;
         -- supervisory 64-bit block transfer
         wr64(terminal_in_1, terminal_out_1, x"0050_0470", x"cafe_affe", 3, en_msg_0, TRUE, "111100");
         WAIT FOR 2 us;
         -- read from sram
         rd_iram_bfm(x"0000_0104", x"cafe_affe", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0108", x"1111_2222", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0130", x"1516_1314", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0140", x"ddcc_bbaa", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0304", x"cafe_affe", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0308", x"1111_2222", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0330", x"1516_1314", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0340", x"ddcc_bbaa", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0410", x"3333_4444", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0414", x"3433_4444", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0420", x"5555_5555", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0424", x"5655_5555", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0428", x"5755_5555", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         
         ex_dat := x"1234_5678";
         rd_iram_bfm(x"0000_0454", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := NOT ex_dat;
         rd_iram_bfm(x"0000_0450", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := (NOT ex_dat) + x"10_00000";
         rd_iram_bfm(x"0000_045c", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := NOT ex_dat;
         rd_iram_bfm(x"0000_0458", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;

         ex_dat := x"cafe_affe";
         rd_iram_bfm(x"0000_0474", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := NOT ex_dat;
         rd_iram_bfm(x"0000_0470", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := (NOT ex_dat) + x"10_00000";
         rd_iram_bfm(x"0000_047c", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := NOT ex_dat;
         rd_iram_bfm(x"0000_0478", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := (NOT ex_dat) + x"10_00000";
         rd_iram_bfm(x"0000_0484", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := NOT ex_dat;
         rd_iram_bfm(x"0000_0480", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;


   
      print("Test: VME A24 TO PCI READ");
         -- prepare data in sram
         wr_iram_bfm(x"0000_0004", x"cafe_affe", en_msg_0, loc_err);
         wr_iram_bfm(x"0000_0008", x"1111_2222", en_msg_0, loc_err);
         wr_iram_bfm(x"0000_0030", x"1516_1314", en_msg_0, loc_err);
         wr_iram_bfm(x"0000_0034", x"1234_5678", en_msg_0, loc_err);
         dat := x"1234_5678";
         wr_iram_bfm(x"0000_0044", dat, en_msg_0, loc_err);  
         dat := NOT dat;
         wr_iram_bfm(x"0000_0040", dat, en_msg_0, loc_err);
         dat := (NOT dat) + x"10_00000";
         wr_iram_bfm(x"0000_004c", dat, en_msg_0, loc_err);
         dat := NOT dat;
         wr_iram_bfm(x"0000_0048", dat, en_msg_0, loc_err);
         dat := (NOT dat) + x"10_00000";
         wr_iram_bfm(x"0000_0054", dat, en_msg_0, loc_err);
         dat := NOT dat;
         wr_iram_bfm(x"0000_0050", dat, en_msg_0, loc_err);
         dat := (NOT dat) + x"10_00000";
         wr_iram_bfm(x"0000_005c", dat, en_msg_0, loc_err);

         wr_iram_bfm(x"0000_0080", x"abcd_ef01", en_msg_0, loc_err);  
         wr_iram_bfm(x"0000_0084", x"accd_ef01", en_msg_0, loc_err);  
         wr_iram_bfm(x"0000_0088", x"adcd_ef01", en_msg_0, loc_err);  
         wr_iram_bfm(x"0000_008c", x"aecd_ef01", en_msg_0, loc_err);  

         -- read from a24 vme slave (supervisory data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0048", x"0000_0017", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0070_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"0070_0008", x"1111_2222", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd16(terminal_in_1, terminal_out_1, x"0070_0030", x"1112_1314", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         rd16(terminal_in_1, terminal_out_1, x"0070_0032", x"1516_1718", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd8(terminal_in_1, terminal_out_1, x"0070_0034", x"1111_1178", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"0070_0035", x"1111_5611", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"0070_0036", x"1134_1111", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"0070_0037", x"1211_1111", 1, en_msg_0, TRUE, "111101", loc_err);
         err_sum := err_sum + loc_err; 
         rd32(terminal_in_1, terminal_out_1, x"0070_0004", x"cafe_affe", 1, en_msg_0, TRUE, "111101", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a24 vme slave (non privileged data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0048", x"0000_0015", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0050_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"0050_0008", x"1111_2222", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd16(terminal_in_1, terminal_out_1, x"0050_0030", x"1112_1314", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         rd16(terminal_in_1, terminal_out_1, x"0050_0032", x"1516_1718", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd8(terminal_in_1, terminal_out_1, x"0050_0034", x"1111_1178", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"0050_0035", x"1111_5611", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"0050_0036", x"1134_1111", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"0050_0037", x"1211_1111", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 
         rd32(terminal_in_1, terminal_out_1, x"0050_0004", x"cafe_affe", 1, en_msg_0, TRUE, "111001", loc_err);
         err_sum := err_sum + loc_err; 

         -- read from a24 vme slave (supervisory block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0048", x"0000_0018", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0080_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"0080_0080", x"abcd_ef01", 2, en_msg_0, TRUE, "111111", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a24 vme slave (non privileged block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0048", x"0000_0019", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0090_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"0090_0080", x"abcd_ef01", 3, en_msg_0, TRUE, "111011", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a24 vme slave (supervisory 64-bit block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0048", x"0000_001a", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x00a0_0000
         WAIT FOR 1 us;
         rd64(terminal_in_1, terminal_out_1, x"00a0_0040", x"1234_5678", 2, en_msg_0, TRUE, "111100", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a24 vme slave (supervisory 64-bit block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0048", x"0000_001b", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x00b0_0000
         WAIT FOR 1 us;
         rd64(terminal_in_1, terminal_out_1, x"00b0_0040", x"1234_5678", 3, en_msg_0, TRUE, "111000", loc_err);         
         err_sum := err_sum + loc_err; 

         err := err_sum;
         print_err("vme_slave_a242pci", err_sum);
   END PROCEDURE;
   
----------------------------------------------------------------------------------------------
   PROCEDURE cham_test(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      VARIABLE dat     : std_logic_vector(31 DOWNTO 0);
   BEGIN
      print("Test MEN_01A021_00_IT_0210: Chameleon Table");
      rd32(terminal_in_0, terminal_out_0, BAR0 + x"0000_0000", x"00034102", 1, en_msg_0, TRUE, "000001", loc_err); 
      rd32(terminal_in_0, terminal_out_0, BAR0 + x"0000_0004", x"0000abce", 1, en_msg_0, TRUE, "000001", loc_err); 
      rd32(terminal_in_0, terminal_out_0, BAR0 + x"0000_0008", x"00000000", 1, en_msg_0, TRUE, "000001", loc_err); 
      rd32(terminal_in_0, terminal_out_0, BAR0 + x"0000_000c", x"32304100", 1, en_msg_0, TRUE, "000001", loc_err); 
      rd32(terminal_in_0, terminal_out_0, BAR0 + x"0000_0010", x"30302d35", 1, en_msg_0, TRUE, "000001", loc_err); 
      rd32(terminal_in_0, terminal_out_0, BAR0 + x"0000_0014", x"006013ff", 1, en_msg_0, TRUE, "000001", loc_err); 
      rd32(terminal_in_0, terminal_out_0, BAR0 + x"0000_0018", x"00000000", 1, en_msg_0, TRUE, "000001", loc_err); 
      rd32(terminal_in_0, terminal_out_0, BAR0 + x"0000_001c", x"00000000", 1, en_msg_0, TRUE, "000001", loc_err); 
      rd32(terminal_in_0, terminal_out_0, BAR0 + x"0000_0020", x"00000200", 1, en_msg_0, TRUE, "000001", loc_err); 
      err_sum := err_sum + loc_err; 

      err := err_sum;
      print_err("cham_test", err_sum);
   END PROCEDURE;

----------------------------------------------------------------------------------------------
   PROCEDURE vme_slave_a322sram(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      VARIABLE dat     : std_logic_vector(31 DOWNTO 0);
   BEGIN
      print("Test MEN_01A021_00_IT_0020: VME A32 TO SRAM WRITE");
         -- write to a32 vme slave (supervisory data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0034", x"0000_0012", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x2000_0000
         WAIT FOR 1 us;
         wr32(terminal_in_1, terminal_out_1, x"2000_0104", x"cafe_affe", 1, en_msg_0, TRUE, "001101");
         wr32(terminal_in_1, terminal_out_1, x"2000_0108", x"1111_2222", 1, en_msg_0, TRUE, "001101");
         WAIT FOR 100 ns;
         wr16(terminal_in_1, terminal_out_1, x"2000_0130", x"1112_1314", 1, en_msg_0, TRUE, "001101");
         wr16(terminal_in_1, terminal_out_1, x"2000_0132", x"1516_1718", 1, en_msg_0, TRUE, "001101");
         WAIT FOR 100 ns;
         wr8(terminal_in_1, terminal_out_1, x"2000_0140", x"1111_11aa", 1, en_msg_0, TRUE, "001101");
         wr8(terminal_in_1, terminal_out_1, x"2000_0141", x"1111_bb11", 1, en_msg_0, TRUE, "001101");
         wr8(terminal_in_1, terminal_out_1, x"2000_0142", x"11cc_1111", 1, en_msg_0, TRUE, "001101");
         wr8(terminal_in_1, terminal_out_1, x"2000_0143", x"dd11_1111", 1, en_msg_0, TRUE, "001101");

         -- write to a32 vme slave (non privileged data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0034", x"0000_0014", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x4000_0000
         WAIT FOR 1 us;
         wr32(terminal_in_1, terminal_out_1, x"4000_0304", x"cafe_affe", 1, en_msg_0, TRUE, "001001");
         wr32(terminal_in_1, terminal_out_1, x"4000_0308", x"1111_2222", 1, en_msg_0, TRUE, "001001");
         WAIT FOR 100 ns;
         wr16(terminal_in_1, terminal_out_1, x"4000_0330", x"1112_1314", 1, en_msg_0, TRUE, "001001");
         wr16(terminal_in_1, terminal_out_1, x"4000_0332", x"1516_1718", 1, en_msg_0, TRUE, "001001");
         WAIT FOR 100 ns;
         wr8(terminal_in_1, terminal_out_1, x"4000_0340", x"1111_11aa", 1, en_msg_0, TRUE, "001001");
         wr8(terminal_in_1, terminal_out_1, x"4000_0341", x"1111_bb11", 1, en_msg_0, TRUE, "001001");
         wr8(terminal_in_1, terminal_out_1, x"4000_0342", x"11cc_1111", 1, en_msg_0, TRUE, "001001");
         wr8(terminal_in_1, terminal_out_1, x"4000_0343", x"dd11_1111", 1, en_msg_0, TRUE, "001001");

         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0034", x"0000_0015", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x5000_0000
         WAIT FOR 1 us;
         -- non privileged block transfer
         wr32(terminal_in_1, terminal_out_1, x"5000_0410", x"3333_4444", 2, en_msg_0, TRUE, "001011");
         WAIT FOR 100 ns;
         -- supervisory block transfer
         wr32(terminal_in_1, terminal_out_1, x"5000_0420", x"5555_5555", 3, en_msg_0, TRUE, "001111");
         WAIT FOR 100 ns;
         -- non privileged 64-bit block transfer
         wr64(terminal_in_1, terminal_out_1, x"5000_0450", x"1234_5678", 2, en_msg_0, TRUE, "001000");
         WAIT FOR 100 ns;
         -- supervisory 64-bit block transfer
         wr64(terminal_in_1, terminal_out_1, x"5000_0470", x"cafe_affe", 3, en_msg_0, TRUE, "001100");
         WAIT FOR 100 ns;
         -- read from sram
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0104", x"cafe_affe", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0108", x"1111_2222", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0132", x"1516_1314", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0140", x"ddcc_bbaa", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0304", x"cafe_affe", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0308", x"1111_2222", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0332", x"1516_1314", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0340", x"ddcc_bbaa", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0410", x"3333_4444", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0414", x"3433_4444", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;

         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0420", x"5555_5555", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0424", x"5655_5555", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0428", x"5755_5555", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;

         dat := x"1234_5678";
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0454", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := NOT dat;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0450", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := (NOT dat) + x"10_00000";
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_045c", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := NOT dat;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0458", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;

         dat := x"cafe_affe";
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0474", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := NOT dat;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0470", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := (NOT dat) + x"10_00000";
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_047c", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := NOT dat;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0478", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := (NOT dat) + x"10_00000";
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0484", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         dat := NOT dat;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0480", dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
   
      print("Test: VME A32 TO SRAM READ");
         -- prepare data in sram
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0004", x"cafe_affe", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0008", x"1111_2222", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0030", x"1516_1314", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0034", x"1234_5678", 1, en_msg_0, TRUE, "000001");
         dat := x"1234_5678";
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0044", dat, 1, en_msg_0, TRUE, "000001");  
         dat := NOT dat;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0040", dat, 1, en_msg_0, TRUE, "000001");
         dat := (NOT dat) + x"10_00000";
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_004c", dat, 1, en_msg_0, TRUE, "000001");
         dat := NOT dat;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0048", dat, 1, en_msg_0, TRUE, "000001");
         dat := (NOT dat) + x"10_00000";
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0054", dat, 1, en_msg_0, TRUE, "000001");
         dat := NOT dat;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0050", dat, 1, en_msg_0, TRUE, "000001");
         dat := (NOT dat) + x"10_00000";
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_005c", dat, 1, en_msg_0, TRUE, "000001");

         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0080", x"abcd_ef01", 1, en_msg_0, TRUE, "000001");  
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0084", x"accd_ef01", 1, en_msg_0, TRUE, "000001");  
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0088", x"adcd_ef01", 1, en_msg_0, TRUE, "000001");  
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_008c", x"aecd_ef01", 1, en_msg_0, TRUE, "000001");  

         -- read from a32 vme slave (supervisory data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0034", x"0000_0017", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x7000_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"7000_0008", x"1111_2222", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd16(terminal_in_1, terminal_out_1, x"7000_0030", x"1112_1314", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         rd16(terminal_in_1, terminal_out_1, x"7000_0032", x"1516_1718", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd8(terminal_in_1, terminal_out_1, x"7000_0034", x"1111_1178", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"7000_0035", x"1111_5611", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"7000_0036", x"1134_1111", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"7000_0037", x"1211_1111", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         rd32(terminal_in_1, terminal_out_1, x"7000_0004", x"cafe_affe", 1, en_msg_0, TRUE, "001101", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a32 vme slave (non privileged data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0034", x"0000_0015", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x5000_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"5000_0008", x"1111_2222", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd16(terminal_in_1, terminal_out_1, x"5000_0030", x"1112_1314", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         rd16(terminal_in_1, terminal_out_1, x"5000_0032", x"1516_1718", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd8(terminal_in_1, terminal_out_1, x"5000_0034", x"1111_1178", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"5000_0035", x"1111_5611", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"5000_0036", x"1134_1111", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"5000_0037", x"1211_1111", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         rd32(terminal_in_1, terminal_out_1, x"5000_0004", x"cafe_affe", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 

         -- read from a32 vme slave (supervisory block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0034", x"0000_0018", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x8000_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"8000_0080", x"abcd_ef01", 2, en_msg_0, TRUE, "001111", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a32 vme slave (non privileged block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0034", x"0000_0019", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x9000_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"9000_0080", x"abcd_ef01", 3, en_msg_0, TRUE, "001011", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a32 vme slave (supervisory 64-bit block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0034", x"0000_001a", 1, en_msg_0, TRUE, "000001"); -- set base address to 0xa000_0000
         WAIT FOR 1 us;
         rd64(terminal_in_1, terminal_out_1, x"a000_0040", x"1234_5678", 2, en_msg_0, TRUE, "001100", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a32 vme slave (supervisory 64-bit block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0034", x"0000_001b", 1, en_msg_0, TRUE, "000001"); -- set base address to 0xb000_0000
         WAIT FOR 1 us;
         rd64(terminal_in_1, terminal_out_1, x"b000_0040", x"1234_5678", 3, en_msg_0, TRUE, "001000", loc_err);         
         err_sum := err_sum + loc_err; 

         err := err_sum;
         print_err("vme_slave_a322sram", err_sum);
   END PROCEDURE;
   
--------------------------------------------------------------------------------------------
   PROCEDURE vme_slave_a322pci(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      VARIABLE dat     : std_logic_vector(31 DOWNTO 0);
      VARIABLE ex_dat     : std_logic_vector(31 DOWNTO 0);
      CONSTANT OFFSET  : std_logic_vector(31 DOWNTO 0):=x"2000_0000";
   BEGIN
      print("Test MEN_01A021_00_IT_0050: VME A32 TO PCI WRITE");
         -- set bar0 offset of bfm to 0x2000_0000
         init_bfm(0, x"0000_0000", x"0000_0000", x"0000_0000_0000_0000", x"0000", 256);
         -- set pci offset
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0028", x"0000_0000", 1, en_msg_0, TRUE, "000001"); -- set pci offset to 0x0000_0000
         -- write to a32 vme slave (supervisory data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_004c", x"0000_0012", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x2000_0000
         WAIT FOR 1 us;
         wr32(terminal_in_1, terminal_out_1, x"2000_0104", x"cafe_affe", 1, en_msg_0, TRUE, "001101");
         wr32(terminal_in_1, terminal_out_1, x"2000_0108", x"1111_2222", 1, en_msg_0, TRUE, "001101");
         WAIT FOR 100 ns;
         wr16(terminal_in_1, terminal_out_1, x"2000_0130", x"1112_1314", 1, en_msg_0, TRUE, "001101");
         wr16(terminal_in_1, terminal_out_1, x"2000_0132", x"1516_1718", 1, en_msg_0, TRUE, "001101");
         WAIT FOR 100 ns;
         wr8(terminal_in_1, terminal_out_1, x"2000_0140", x"1111_11aa", 1, en_msg_0, TRUE, "001101");
         wr8(terminal_in_1, terminal_out_1, x"2000_0141", x"1111_bb11", 1, en_msg_0, TRUE, "001101");
         wr8(terminal_in_1, terminal_out_1, x"2000_0142", x"11cc_1111", 1, en_msg_0, TRUE, "001101");
         wr8(terminal_in_1, terminal_out_1, x"2000_0143", x"dd11_1111", 1, en_msg_0, TRUE, "001101");

         -- write to a32 vme slave (non privileged data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_004c", x"0000_0014", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x4000_0000
         WAIT FOR 1 us;
         wr32(terminal_in_1, terminal_out_1, x"4000_0304", x"cafe_affe", 1, en_msg_0, TRUE, "001001");
         wr32(terminal_in_1, terminal_out_1, x"4000_0308", x"1111_2222", 1, en_msg_0, TRUE, "001001");
         WAIT FOR 100 ns;
         wr16(terminal_in_1, terminal_out_1, x"4000_0330", x"1112_1314", 1, en_msg_0, TRUE, "001001");
         wr16(terminal_in_1, terminal_out_1, x"4000_0332", x"1516_1718", 1, en_msg_0, TRUE, "001001");
         WAIT FOR 100 ns;
         wr8(terminal_in_1, terminal_out_1, x"4000_0340", x"1111_11aa", 1, en_msg_0, TRUE, "001001");
         wr8(terminal_in_1, terminal_out_1, x"4000_0341", x"1111_bb11", 1, en_msg_0, TRUE, "001001");
         wr8(terminal_in_1, terminal_out_1, x"4000_0342", x"11cc_1111", 1, en_msg_0, TRUE, "001001");
         wr8(terminal_in_1, terminal_out_1, x"4000_0343", x"dd11_1111", 1, en_msg_0, TRUE, "001001");

         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_004c", x"0000_0015", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x5000_0000
         WAIT FOR 1 us;
         -- non privileged block transfer
         wr32(terminal_in_1, terminal_out_1, x"5000_0410", x"3333_4444", 2, en_msg_0, TRUE, "001011");
         WAIT FOR 100 ns;
         -- supervisory block transfer
         wr32(terminal_in_1, terminal_out_1, x"5000_0420", x"5555_5555", 3, en_msg_0, TRUE, "001111");
         WAIT FOR 100 ns;
         -- non privileged 64-bit block transfer
         wr64(terminal_in_1, terminal_out_1, x"5000_0450", x"1234_5678", 2, en_msg_0, TRUE, "001000");
         WAIT FOR 100 ns;
         -- supervisory 64-bit block transfer
         wr64(terminal_in_1, terminal_out_1, x"5000_0470", x"cafe_affe", 3, en_msg_0, TRUE, "001100");
         WAIT FOR 1 us;
         -- read from sram
         rd_iram_bfm(x"0000_0104", x"cafe_affe", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0108", x"1111_2222", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         --rd_iram_bfm(x"0000_0132", x"1516_1314", en_msg_0, loc_err); 
         rd_iram_bfm(x"0000_0130", x"1516_1314", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0140", x"ddcc_bbaa", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         
         rd_iram_bfm(x"0000_0304", x"cafe_affe", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0308", x"1111_2222", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         --rd_iram_bfm(x"0000_0332", x"1516_1314", en_msg_0, loc_err); 
         rd_iram_bfm(x"0000_0330", x"1516_1314", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0340", x"ddcc_bbaa", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         
         rd_iram_bfm(x"0000_0410", x"3333_4444", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0414", x"3433_4444", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;

         rd_iram_bfm(x"0000_0420", x"5555_5555", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0424", x"5655_5555", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         rd_iram_bfm(x"0000_0428", x"5755_5555", en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;

         ex_dat := x"1234_5678";
         rd_iram_bfm(x"0000_0454", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := NOT ex_dat;
         rd_iram_bfm(x"0000_0450", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := (NOT ex_dat) + x"10_00000";
         rd_iram_bfm(x"0000_045c", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := NOT ex_dat;
         rd_iram_bfm(x"0000_0458", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;

         ex_dat := x"cafe_affe";
         rd_iram_bfm(x"0000_0474", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := NOT ex_dat;
         rd_iram_bfm(x"0000_0470", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := (NOT ex_dat) + x"10_00000";
         rd_iram_bfm(x"0000_047c", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := NOT ex_dat;
         rd_iram_bfm(x"0000_0478", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := (NOT ex_dat) + x"10_00000";
         rd_iram_bfm(x"0000_0484", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
         ex_dat := NOT ex_dat;
         rd_iram_bfm(x"0000_0480", ex_dat, en_msg_0, loc_err); 
         err_sum := err_sum + loc_err;
   
      print("Test: VME A32 TO PCI READ");
         -- prepare data in sram
         wr_iram_bfm(x"0000_0004", x"cafe_affe", en_msg_0, loc_err);
         wr_iram_bfm(x"0000_0008", x"1111_2222", en_msg_0, loc_err);
         wr_iram_bfm(x"0000_0030", x"1516_1314", en_msg_0, loc_err);
         wr_iram_bfm(x"0000_0034", x"1234_5678", en_msg_0, loc_err);
         dat := x"1234_5678";
         wr_iram_bfm(x"0000_0044", dat, en_msg_0, loc_err);  
         dat := NOT dat;
         wr_iram_bfm(x"0000_0040", dat, en_msg_0, loc_err);
         dat := (NOT dat) + x"10_00000";
         wr_iram_bfm(x"0000_004c", dat, en_msg_0, loc_err);
         dat := NOT dat;
         wr_iram_bfm(x"0000_0048", dat, en_msg_0, loc_err);
         dat := (NOT dat) + x"10_00000";
         wr_iram_bfm(x"0000_0054", dat, en_msg_0, loc_err);
         dat := NOT dat;
         wr_iram_bfm(x"0000_0050", dat, en_msg_0, loc_err);
         dat := (NOT dat) + x"10_00000";
         wr_iram_bfm(x"0000_005c", dat, en_msg_0, loc_err);

         wr_iram_bfm(x"0000_0080", x"abcd_ef01", en_msg_0, loc_err);  
         wr_iram_bfm(x"0000_0084", x"accd_ef01", en_msg_0, loc_err);  
         wr_iram_bfm(x"0000_0088", x"adcd_ef01", en_msg_0, loc_err);  
         wr_iram_bfm(x"0000_008c", x"aecd_ef01", en_msg_0, loc_err);  


         -- read from a32 vme slave (supervisory data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_004c", x"0000_0017", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x7000_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"7000_0008", x"1111_2222", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd16(terminal_in_1, terminal_out_1, x"7000_0030", x"1112_1314", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         rd16(terminal_in_1, terminal_out_1, x"7000_0032", x"1516_1718", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd8(terminal_in_1, terminal_out_1, x"7000_0034", x"1111_1178", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"7000_0035", x"1111_5611", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"7000_0036", x"1134_1111", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"7000_0037", x"1211_1111", 1, en_msg_0, TRUE, "001101", loc_err);
         err_sum := err_sum + loc_err; 
         rd32(terminal_in_1, terminal_out_1, x"7000_0004", x"cafe_affe", 1, en_msg_0, TRUE, "001101", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a32 vme slave (non privileged data access)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_004c", x"0000_0015", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x5000_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"5000_0008", x"1111_2222", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd16(terminal_in_1, terminal_out_1, x"5000_0030", x"1112_1314", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         rd16(terminal_in_1, terminal_out_1, x"5000_0032", x"1516_1718", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         WAIT FOR 100 ns;
         rd8(terminal_in_1, terminal_out_1, x"5000_0034", x"1111_1178", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"5000_0035", x"1111_5611", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"5000_0036", x"1134_1111", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         rd8(terminal_in_1, terminal_out_1, x"5000_0037", x"1211_1111", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 
         rd32(terminal_in_1, terminal_out_1, x"5000_0004", x"cafe_affe", 1, en_msg_0, TRUE, "001001", loc_err);
         err_sum := err_sum + loc_err; 

         -- read from a32 vme slave (supervisory block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_004c", x"0000_0018", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x8000_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"8000_0080", x"abcd_ef01", 2, en_msg_0, TRUE, "001111", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a32 vme slave (non privileged block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_004c", x"0000_0019", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x9000_0000
         WAIT FOR 1 us;
         rd32(terminal_in_1, terminal_out_1, x"9000_0080", x"abcd_ef01", 3, en_msg_0, TRUE, "001011", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a32 vme slave (supervisory 64-bit block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_004c", x"0000_001a", 1, en_msg_0, TRUE, "000001"); -- set base address to 0xa000_0000
         WAIT FOR 1 us;
         rd64(terminal_in_1, terminal_out_1, x"a000_0040", x"1234_5678", 2, en_msg_0, TRUE, "001100", loc_err);         
         err_sum := err_sum + loc_err; 

         -- read from a32 vme slave (supervisory 64-bit block transfer)
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_004c", x"0000_001b", 1, en_msg_0, TRUE, "000001"); -- set base address to 0xb000_0000
         WAIT FOR 1 us;
         rd64(terminal_in_1, terminal_out_1, x"b000_0040", x"1234_5678", 3, en_msg_0, TRUE, "001000", loc_err);         
         err_sum := err_sum + loc_err; 

         err := err_sum;
         print_err("vme_slave_a322pcie", err_sum);
   END PROCEDURE;
   
 --------------------------------------------------------------------------------------------
   PROCEDURE vme_slave_a162regs(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      VARIABLE dat     : std_logic_vector(31 DOWNTO 0);
      VARIABLE am      : std_logic_vector(5 DOWNTO 0);
   BEGIN
      print("Test MEN_01A021_00_IT_0060: VME A16 TO REGS");
      -- A16 supervisory access
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_0012", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_2000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_2014", x"0000_3412", 1, en_msg_0, TRUE, "101101");
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_0013", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_3000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_3034", x"00ab_cd1f", 1, en_msg_0, TRUE, "101101");
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_0014", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_4000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_4048", x"0000_7914", 1, en_msg_0, TRUE, "101101");
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_0015", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_5000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_500c", x"0000_005a", 1, en_msg_0, TRUE, "101101");
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_0016", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_6000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_6004", x"0000_00ab", 1, en_msg_0, TRUE, "101101");
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_0017", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_7000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_701c", x"0000_0007", 1, en_msg_0, TRUE, "101101");
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_0018", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_8000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_8028", x"ffff_f000", 1, en_msg_0, TRUE, "101101");
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_0019", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_9000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_9000", x"0000_0007", 1, en_msg_0, TRUE, "101101");
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_001a", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_a000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_a020", x"0000_0056", 1, en_msg_0, TRUE, "101101");
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_001b", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_b000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_b038", x"0000_0037", 1, en_msg_0, TRUE, "101101");
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_001c", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_c000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_c03c", x"0000_0037", 1, en_msg_0, TRUE, "101101");
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_001d", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_d000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_d040", x"1234_5678", 1, en_msg_0, TRUE, "101101");
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_001e", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_e000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_e044", x"9abc_def0", 1, en_msg_0, TRUE, "101101");

      -- read back 
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_001e", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0014", x"0000_3412", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0034", x"00ab_cd1f", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0048", x"0000_7914", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_000c", x"0000_005a", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0004", x"0000_00ab", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_001c", x"0000_0007", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0028", x"ffff_f000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0000", x"0000_0007", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0020", x"0000_0056", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0038", x"0000_0037", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_003c", x"0000_0037", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0040", x"1234_5678", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0044", x"9abc_def0", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;

      -- A16 non-privileged access
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_001f", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_f000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_f014", x"0000_1214", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_f030", x"0000_0010", 1, en_msg_0, TRUE, "101001");-- set base address to 0x0000_0000
      wr32(terminal_in_1, terminal_out_1, x"0000_0034", x"00ab_ab0d", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_0048", x"0000_6508", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_000c", x"0000_004b", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_0004", x"0000_003c", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_001c", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_0028", x"5678_9000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_0000", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_0020", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_0038", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_003c", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_0040", x"8765_4321", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_0044", x"0fed_cba9", 1, en_msg_0, TRUE, "101001");

      -- read back 
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_0010", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0014", x"0000_1214", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0034", x"00ab_ab0d", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0048", x"0000_6508", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_000c", x"0000_004b", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0004", x"0000_003c", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_001c", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0028", x"5678_9000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0000", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0020", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0038", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_003c", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0040", x"8765_4321", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0044", x"0fed_cba9", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;

      -- A16 non-privileged access
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0030", x"0000_0012", 1, en_msg_0, TRUE, "000001"); -- set base address to 0x0000_2000
      WAIT FOR 1 us;
      wr32(terminal_in_1, terminal_out_1, x"0000_2014", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_2034", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_2048", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_200c", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_2004", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_201c", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_2028", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_2000", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_2020", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_2038", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_203c", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_2040", x"0000_0000", 1, en_msg_0, TRUE, "101001");
      wr32(terminal_in_1, terminal_out_1, x"0000_2044", x"0000_0000", 1, en_msg_0, TRUE, "101001");

      err := err_sum;
      print_err("vme_slave_a162regs", err_sum);
   END PROCEDURE;
   
  
----------------------------------------------------------------------------------------------
   PROCEDURE vme_dma_sram2sram(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      variable var_msi_expected  : std_logic_vector(31 downto 0) := (others => '0');
      variable var_success       : boolean := false;
      variable var_msi_allocated : std_logic_vector(2 downto 0) := (others => '0');
      variable var_check_msi_nbr : natural := 0;
      constant MSI_SHMEM_ADDR    : natural := 2096896; -- := x"1FFF00" at upper end of shared memory
      constant MSI_DATA_VAL      : std_logic_vector(15 downto 0) := x"3210";
   BEGIN
      print("Test MEN_01A021_00_IT_0140: VME DMA: SRAM TO SRAM ");
      var_success := false;
      bfm_configure_msi(
         msi_addr       => MSI_SHMEM_ADDR,
         msi_data       => MSI_DATA_VAL,
         msi_allocated  => var_msi_allocated,
         success        => var_success
      );
      if not var_success then 
         err_sum := err_sum +1;
         if en_msg_0 >= 1 then 
            print_now("ERROR(vme_dma_sram2sram): error while executing bfm_configure_msi() - MSI NOT configured, MSI behavior is UNDEFINED!");
            print("   ---> test case skipped");
         end if;
      else
         -- test data in sram
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0004", x"1111_1111", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0004", x"1111_1111", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0008", x"2222_2222", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0008", x"2222_2222", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_000c", x"3333_3333", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_000c", x"3333_3333", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0010", x"4444_4444", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0010", x"4444_4444", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         -- clear destination in sram
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0100", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0104", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0108", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_010c", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0110", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0114", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0118", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         -- config buffer descriptor
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F900", x"0000_0108", 1, en_msg_0, TRUE, "000001");  -- dest adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F900", x"0000_0108", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F904", x"0000_0004", 1, en_msg_0, TRUE, "000001");  -- source adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F904", x"0000_0004", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F908", x"0000_0003", 1, en_msg_0, TRUE, "000001");  -- size
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F908", x"0000_0003", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F90c", x"0001_1001", 1, en_msg_0, TRUE, "000001");  -- source=sram dest=sram inc
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F90c", x"0001_1001", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0003", 1, en_msg_0, TRUE, "000001");  -- start transfer
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0003", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
      
         var_check_msi_nbr := 9;
         bfm_calc_msi_expected(
            msi_allocated => var_msi_allocated,
            msi_data      => MSI_DATA_VAL,
            msi_nbr       => var_check_msi_nbr,
            msi_expected  => var_msi_expected
         );
         var_success := false;
         bfm_poll_msi(
            track_msi    => 1,
            msi_addr     => MSI_SHMEM_ADDR,
            msi_expected => var_msi_expected,
            txt_out      => en_msg_0,
            success      => var_success
         );
         if not var_success then 
            err_sum := err_sum +1;
            if en_msg_0 >= 1 then print_now("ERROR(vme_dma_sram2sram): error while executing bfm_poll_msi()"); end if;
         end if;

         IF irq_req(13) = '0' THEN  
            print_time("ERROR vme_dma_sram2sram: dma irq NOT asserted");
         END IF;
         -- check destination
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0100", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0104", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0108", x"1111_1111", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_010c", x"2222_2222", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0110", x"3333_3333", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0114", x"4444_4444", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0118", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         -- check control reg for irq asserted
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0006", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         -- clear irq request
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0004", 1, en_msg_0, TRUE, "000001");
         IF irq_req(13) = '1' THEN  
            print_time("ERROR vme_dma_sram2sram: dma irq asserted");
         END IF;
         -- check control reg for end of dma
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
      end if;
      WAIT FOR 500 ns;
      err := err_sum;
      print_err("vme_dma_sram2sram", err_sum);
   END PROCEDURE;
       

----------------------------------------------------------------------------------------------
   PROCEDURE vme_dma_sram2pci(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      VARIABLE adr : std_logic_vector(31 DOWNTO 0);
      VARIABLE dat : std_logic_vector(31 DOWNTO 0);
      variable var_msi_expected  : std_logic_vector(31 downto 0) := (others => '0');
      variable var_success       : boolean := false;
      variable var_msi_allocated : std_logic_vector(2 downto 0) := (others => '0');
      variable var_check_msi_nbr : natural := 0;
      constant MSI_SHMEM_ADDR    : natural := 2096896; -- := x"1FFF00" at upper end of shared memory
      constant MSI_DATA_VAL      : std_logic_vector(15 downto 0) := x"3210";
   BEGIN
      print("Test MEN_01A021_00_IT_0150: DMA: SRAM TO PCIe AND back");
      var_success := false;
      bfm_configure_msi(
         msi_addr       => MSI_SHMEM_ADDR,
         msi_data       => MSI_DATA_VAL,
         msi_allocated  => var_msi_allocated,
         success        => var_success
      );
      if not var_success then 
         err_sum := err_sum +1;
         if en_msg_0 >= 1 then 
            print_now("ERROR(vme_dma_sram2pci): error while executing bfm_configure_msi() - MSI NOT configured, MSI behavior is UNDEFINED!");
            print("   ---> test case skipped");
         end if;
      else
         -- test data in sram
         FOR i IN 0 TO 255 LOOP
            wr32(terminal_in_0, terminal_out_0, SRAM + (4*i), x"00000000" + (4*i), 1, en_msg_0, TRUE, "000001");
         END LOOP;
         
         -- program dma: sram2pci
         adr := x"000f_f900";
         dat := x"00000000";
         FOR i IN 0 TO 15 LOOP
            wr32(terminal_in_0, terminal_out_0, SRAM + adr+ x"0", dat, 1, en_msg_0, TRUE, "000001");
            wr32(terminal_in_0, terminal_out_0, SRAM + adr+ x"4", dat, 1, en_msg_0, TRUE, "000001");
            wr32(terminal_in_0, terminal_out_0, SRAM + adr+ x"8", x"0000000f", 1, en_msg_0, TRUE, "000001");
            wr32(terminal_in_0, terminal_out_0, SRAM + adr+ x"c", x"00014000", 1, en_msg_0, TRUE, "000001");
            dat := dat + x"40";
            adr := adr + x"10";
            
         END LOOP;
         wr32(terminal_in_0, terminal_out_0, SRAM + adr - x"10" + x"c", x"00014001", 1, en_msg_0, TRUE, "000001");
      
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"2c", x"00000003", 1, en_msg_0, TRUE, "000001");
      
         var_check_msi_nbr := 9;
         bfm_calc_msi_expected(
            msi_allocated => var_msi_allocated,
            msi_data      => MSI_DATA_VAL,
            msi_nbr       => var_check_msi_nbr,
            msi_expected  => var_msi_expected
         );
         var_success := false;
         bfm_poll_msi(
            track_msi    => 1,
            msi_addr     => MSI_SHMEM_ADDR,
            msi_expected => var_msi_expected,
            txt_out      => en_msg_0,
            success      => var_success
         );
         if not var_success then 
            err_sum := err_sum +1;
            if en_msg_0 >= 1 then print_now("ERROR(vme_dma_sram2pci): error while executing bfm_poll_msi()"); end if;
         end if;

         IF irq_req(13) = '0' THEN  
            print_time("ERROR vme_dma_sram2pci: dma irq NOT asserted");
         END IF;
         -- clear irq request
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0004", 1, en_msg_0, TRUE, "000001");
         IF irq_req(13) = '1' THEN  
            print_time("ERROR vme_dma_sram2pci: dma irq asserted");
         END IF;
         -- check control reg for end of dma
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;

         -----------------------------------------------------
         -- program dma: sram2pci
         adr := x"000f_f900";
         dat := x"00000000";
         FOR i IN 0 TO 15 LOOP
            wr32(terminal_in_0, terminal_out_0, SRAM + adr+ x"0", x"0000_0100" + dat, 1, en_msg_0, TRUE, "000001");
            wr32(terminal_in_0, terminal_out_0, SRAM + adr+ x"4", dat, 1, en_msg_0, TRUE, "000001");
            wr32(terminal_in_0, terminal_out_0, SRAM + adr+ x"8", x"0000000f", 1, en_msg_0, TRUE, "000001");
            wr32(terminal_in_0, terminal_out_0, SRAM + adr+ x"c", x"00041000", 1, en_msg_0, TRUE, "000001");
            dat := dat + x"40";
            adr := adr + x"10";
            
         END LOOP;
         wr32(terminal_in_0, terminal_out_0, SRAM + adr - x"10" + x"c", x"00041001", 1, en_msg_0, TRUE, "000001");
      
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"2c", x"00000003", 1, en_msg_0, TRUE, "000001");
      
         var_check_msi_nbr := 9;
         bfm_calc_msi_expected(
            msi_allocated => var_msi_allocated,
            msi_data      => MSI_DATA_VAL,
            msi_nbr       => var_check_msi_nbr,
            msi_expected  => var_msi_expected
         );
         var_success := false;
         bfm_poll_msi(
            track_msi    => 1,
            msi_addr     => MSI_SHMEM_ADDR,
            msi_expected => var_msi_expected,
            txt_out      => en_msg_0,
            success      => var_success
         );
         if not var_success then 
            err_sum := err_sum +1;
            if en_msg_0 >= 1 then print_now("ERROR(vme_dma_sram2pci): error while executing bfm_poll_msi()"); end if;
         end if;

         IF irq_req(13) = '0' THEN  
            print_time("ERROR vme_dma_sram2pci: dma irq NOT asserted");
         END IF;
         -- clear irq request
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0004", 1, en_msg_0, TRUE, "000001");
         IF irq_req(13) = '1' THEN  
            print_time("ERROR vme_dma_sram2pci: dma irq asserted");
         END IF;
         -- check control reg for end of dma
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
      end if;

      err := err_sum;
      print_err("vme_dma_sram2pci", err_sum);
   END PROCEDURE;

----------------------------------------------------------------------------------------------
   PROCEDURE vme_dma_sram2a32d32(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      variable var_msi_expected  : std_logic_vector(31 downto 0) := (others => '0');
      variable var_success       : boolean := false;
      variable var_msi_allocated : std_logic_vector(2 downto 0) := (others => '0');
      variable var_check_msi_nbr : natural := 0;
      constant MSI_SHMEM_ADDR    : natural := 2096896; -- := x"1FFF00" at upper end of shared memory
      constant MSI_DATA_VAL      : std_logic_vector(15 downto 0) := x"3210";
   BEGIN
      print("Test MEN_01A021_00_IT_0120: VME DMA: SRAM TO VME A32D32 AND back");
      var_success := false;
      bfm_configure_msi(
         msi_addr       => MSI_SHMEM_ADDR,
         msi_data       => MSI_DATA_VAL,
         msi_allocated  => var_msi_allocated,
         success        => var_success
      );
      if not var_success then 
         err_sum := err_sum +1;
         if en_msg_0 >= 1 then 
            print_now("ERROR(vme_dma_sram2a32d32): error while executing bfm_configure_msi() - MSI NOT configured, MSI behavior is UNDEFINED!");
            print("   ---> test case skipped");
         end if;
      else
         -- test data in sram
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0208", x"3121_1101", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0208", x"3121_1101", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_020c", x"3222_1202", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_020c", x"3222_1202", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0210", x"3323_1303", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0210", x"3323_1303", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0214", x"3424_1404", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0214", x"3424_1404", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         -- set A32 address extension
--         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_001c", x"0000_0001", 1, en_msg_0, TRUE, "000001");  				-- if generic USE_LONGADD=false
--         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_001c", x"0000_0001", 1, en_msg_0, TRUE, "000001", loc_err);
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_001c", x"0000_0020", 1, en_msg_0, TRUE, "000001");  
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_001c", x"0000_0020", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         -- clear destination in VME_A24D32
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0000", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0004", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0008", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_000c", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0010", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0014", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0018", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         -- clear destination in SRAM
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0300", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0304", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0308", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_030c", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0310", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0314", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_02fc", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         -- config buffer descriptor #1 SRAM => VME_A24D32
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F900", x"3000_0004", 1, en_msg_0, TRUE, "000001");  -- dest adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F900", x"3000_0004", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F904", x"0000_0208", 1, en_msg_0, TRUE, "000001");  -- source adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F904", x"0000_0208", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F908", x"0000_0003", 1, en_msg_0, TRUE, "000001");  -- size
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F908", x"0000_0003", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F90c", x"0001_2060", 1, en_msg_0, TRUE, "000001");  -- source=sram dest=A24D32 inc
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F90c", x"0001_2060", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
   
         -- config buffer descriptor #2 VME_A24D32 => SRAM
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F910", x"0000_0300", 1, en_msg_0, TRUE, "000001");  -- dest adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F910", x"0000_0300", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F914", x"3000_0004", 1, en_msg_0, TRUE, "000001");  -- source adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F914", x"3000_0004", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F918", x"0000_0003", 1, en_msg_0, TRUE, "000001");  -- size
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F918", x"0000_0003", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F91c", x"0002_1061", 1, en_msg_0, TRUE, "000001");  -- source=A24D32 dest=sram inc
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F91c", x"0002_1061", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0003", 1, en_msg_0, TRUE, "000001");  -- start transfer
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0003", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
      
         var_check_msi_nbr := 9;
         bfm_calc_msi_expected(
            msi_allocated => var_msi_allocated,
            msi_data      => MSI_DATA_VAL,
            msi_nbr       => var_check_msi_nbr,
            msi_expected  => var_msi_expected
         );
         var_success := false;
         bfm_poll_msi(
            track_msi    => 1,
            msi_addr     => MSI_SHMEM_ADDR,
            msi_expected => var_msi_expected,
            txt_out      => en_msg_0,
            success      => var_success
         );
         if not var_success then 
            err_sum := err_sum +1;
            if en_msg_0 >= 1 then print_now("ERROR(vme_dma_sram2a32d32): error while executing bfm_poll_msi()"); end if;
         end if;

         IF irq_req(13) = '0' THEN  
            print_time("ERROR vme_dma_sram2a32d32: dma irq NOT asserted");
         END IF;
         -- check control reg for irq asserted
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0006", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         -- check destination VME_A24D32
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0000", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0004", x"3121_1101", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0008", x"3222_1202", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_000c", x"3323_1303", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0010", x"3424_1404", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0014", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0018", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         -- check destination SRAM
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_02fc", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0300", x"3121_1101", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0304", x"3222_1202", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0308", x"3323_1303", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_030c", x"3424_1404", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0310", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         -- clear irq request
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0004", 1, en_msg_0, TRUE, "000001");
         IF irq_req(13) = '1' THEN  
            print_time("ERROR vme_dma_sram2a32d32: dma irq asserted");
         END IF;
         -- check control reg for end of dma
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
      end if;
      WAIT FOR 500 ns;
      err := err_sum;
      print_err("vme_dma_sram2a32d32", err_sum);
   END PROCEDURE;


--------------------------------------------------------------------------------------------
   PROCEDURE vme_dma_sram2a32d64(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      variable var_msi_expected  : std_logic_vector(31 downto 0) := (others => '0');
      variable var_success       : boolean := false;
      variable var_msi_allocated : std_logic_vector(2 downto 0) := (others => '0');
      variable var_check_msi_nbr : natural := 0;
      constant MSI_SHMEM_ADDR    : natural := 2096896; -- := x"1FFF00" at upper end of shared memory
      constant MSI_DATA_VAL      : std_logic_vector(15 downto 0) := x"3210";
   BEGIN
      print("Test MEN_01A021_00_IT_0130: VME DMA: SRAM TO VME A32D64 AND back");
      var_success := false;
      bfm_configure_msi(
         msi_addr       => MSI_SHMEM_ADDR,
         msi_data       => MSI_DATA_VAL,
         msi_allocated  => var_msi_allocated,
         success        => var_success
      );
      if not var_success then 
         err_sum := err_sum +1;
         if en_msg_0 >= 1 then 
            print_now("ERROR(vme_dma_sram2a32d64): error while executing bfm_configure_msi() - MSI NOT configured, MSI behavior is UNDEFINED!");
            print("   ---> test case skipped");
         end if;
      else
         print(" test data in sram");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0208", x"3121_1101", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0208", x"3121_1101", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_020c", x"3222_1202", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_020c", x"3222_1202", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0210", x"3323_1303", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0210", x"3323_1303", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0214", x"3424_1404", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0214", x"3424_1404", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         print(" set A32 address extension");
--         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_001c", x"0000_0001", 1, en_msg_0, TRUE, "000001");  				-- if generic USE_LONGADD=false
--         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_001c", x"0000_0001", 1, en_msg_0, TRUE, "000001", loc_err);
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_001c", x"0000_0020", 1, en_msg_0, TRUE, "000001");  
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_001c", x"0000_0020", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         print(" clear destination in VME_A32D32");
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0000", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0004", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0008", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_000c", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0010", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0014", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0018", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         print(" clear destination in SRAM");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0300", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0304", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0308", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_030c", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0310", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_0314", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"0000_02fc", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         print(" config buffer descriptor #1 SRAM => VME_A32D64");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F900", x"3000_0008", 1, en_msg_0, TRUE, "000001");  -- dest adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F900", x"3000_0008", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F904", x"0000_0208", 1, en_msg_0, TRUE, "000001");  -- source adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F904", x"0000_0208", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F908", x"0000_0003", 1, en_msg_0, TRUE, "000001");  -- size
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F908", x"0000_0003", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F90c", x"0001_20e0", 1, en_msg_0, TRUE, "000001");  -- source=sram dest=A32D64 inc
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F90c", x"0001_20e0", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
   
         print(" config buffer descriptor #2 VME_A32D64 => SRAM");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F910", x"0000_0300", 1, en_msg_0, TRUE, "000001");  -- dest adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F910", x"0000_0300", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F914", x"3000_0008", 1, en_msg_0, TRUE, "000001");  -- source adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F914", x"3000_0008", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F918", x"0000_0003", 1, en_msg_0, TRUE, "000001");  -- size
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F918", x"0000_0003", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F91c", x"0002_10e1", 1, en_msg_0, TRUE, "000001");  -- source=A32D64 dest=sram inc
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F91c", x"0002_10e1", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         print(" start DMA transfer");
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0003", 1, en_msg_0, TRUE, "000001");  -- start transfer
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0003", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
      
         --wait_on_irq_assert(0);
         var_check_msi_nbr := 9;
         bfm_calc_msi_expected(
            msi_allocated => var_msi_allocated,
            msi_data      => MSI_DATA_VAL,
            msi_nbr       => var_check_msi_nbr,
            msi_expected  => var_msi_expected
         );
         var_success := false;
         bfm_poll_msi(
            track_msi    => 1,
            msi_addr     => MSI_SHMEM_ADDR,
            msi_expected => var_msi_expected,
            txt_out      => en_msg_0,
            success      => var_success
         );
         if not var_success then 
            err_sum := err_sum +1;
            if en_msg_0 >= 1 then print_now("ERROR(vme_dma_sram2a32d64): error while executing bfm_poll_msi()"); end if;
         end if;

         IF irq_req(13) = '0' THEN  
            print_time("ERROR vme_dma_sram2a32d64: dma irq NOT asserted");
         END IF;
         print(" check control reg for irq asserted");
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0006", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         print(" check destination VME_A32D32");
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0000", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0004", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0008", x"3121_1101", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_000c", x"3222_1202", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0010", x"3323_1303", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0014", x"3424_1404", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0018", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         print(" check destination SRAM");
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_02fc", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0300", x"3121_1101", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0304", x"3222_1202", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0308", x"3323_1303", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_030c", x"3424_1404", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, SRAM + x"0000_0310", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         print(" clear irq request");
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0004", 1, en_msg_0, TRUE, "000001");
         IF irq_req(13) = '0' THEN  
            print_time("ERROR vme_dma_sram2a32d64: dma irq asserted");
         END IF;
         print(" check control reg for end of dma");
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
      end if;
      WAIT FOR 500 ns;
      err := err_sum;
      print_err("vme_dma_sram2a32d64", err_sum);
   END PROCEDURE;
   

----------------------------------------------------------------------------------------------
   PROCEDURE vme_buserror(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err           : integer:=0;
      VARIABLE err_sum           : integer:=0;
      VARIABLE irq_req_berr      : integer;
      VARIABLE irq_req_dma       : integer;
      variable var_msi_expected  : std_logic_vector(31 downto 0) := (others => '0');
      variable var_success       : boolean := false;
      variable var_msi_allocated : std_logic_vector(2 downto 0) := (others => '0');
      constant MSI_SHMEM_ADDR    : natural := 2096896; -- := x"1FFF00" at upper end of shared memory
      constant MSI_DATA_VAL      : std_logic_vector(15 downto 0) := x"3210";
   BEGIN
      print("Test MEN_01A021_00_IT_0160: VME Bus Error");
      var_success := false;
      bfm_configure_msi(
         msi_addr       => MSI_SHMEM_ADDR,
         msi_data       => MSI_DATA_VAL,
         msi_allocated  => var_msi_allocated,
         success        => var_success
      );
      if not var_success then 
         err_sum := err_sum +1;
         if en_msg_0 >= 1 then 
            print_now("ERROR(vme_buserror): error while executing bfm_configure_msi() - MSI NOT configured, MSI behavior is UNDEFINED!");
            print("   ---> test case skipped");
         end if;
      else
         irq_req_berr := 12;    
         irq_req_dma := 13;
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_0008", 1, en_msg_0, TRUE, "000001");
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_0008", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;

         print (" VME A16/D16 single access");
         rd32(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_0000", x"0000_ffff", 1, en_msg_0, FALSE, "000001", loc_err);
         --wait_on_irq_assert(0);
         bfm_calc_msi_expected(
            msi_allocated => var_msi_allocated,
            msi_data      => MSI_DATA_VAL,
            msi_nbr       => irq_req_berr,
            msi_expected  => var_msi_expected
         );
         var_success := false;
         bfm_poll_msi(
            track_msi    => 1,
            msi_addr     => MSI_SHMEM_ADDR,
            msi_expected => var_msi_expected,
            txt_out      => en_msg_0,
            success      => var_success
         );
         if not var_success then 
            err_sum := err_sum +1;
            if en_msg_0 >= 1 then print_now("ERROR(vme_buserror): error while executing bfm_poll_msi()"); end if;
         end if;

         IF irq_req(irq_req_berr) = '0' THEN  
            print_time("ERROR vme_dma_sram2pci: dma irq NOT asserted");
         END IF;
         WAIT FOR 1 us;
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_000c", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_000c", 1, en_msg_0, TRUE, "000001");
         --wait_on_irq_deassert(0);
         IF irq_req(irq_req_berr) = '1' THEN  
            print_time("ERROR vme_dma_sram2pci: dma irq asserted");
         END IF;
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_0008", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
       
         
         print (" VME A24/D16 single access");
         rd32(terminal_in_0, terminal_out_0, VME_A24D16 + x"0000_0000", x"0000_ffff", 1, en_msg_0, FALSE, "000001", loc_err);
         --wait_on_irq_assert(0);
         bfm_calc_msi_expected(
            msi_allocated => var_msi_allocated,
            msi_data      => MSI_DATA_VAL,
            msi_nbr       => irq_req_berr,
            msi_expected  => var_msi_expected
         );
         var_success := false;
         bfm_poll_msi(
            track_msi    => 1,
            msi_addr     => MSI_SHMEM_ADDR,
            msi_expected => var_msi_expected,
            txt_out      => en_msg_0,
            success      => var_success
         );
         if not var_success then 
            err_sum := err_sum +1;
            if en_msg_0 >= 1 then print_now("ERROR(vme_buserror): error while executing bfm_poll_msi()"); end if;
         end if;

         IF irq_req(irq_req_berr) = '0' THEN  
            print_time("ERROR vme_dma_sram2pci: dma irq NOT asserted");
         END IF;
         WAIT FOR 1 us;
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_000c", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_000c", 1, en_msg_0, TRUE, "000001");
         --wait_on_irq_deassert(0);
         IF irq_req(irq_req_berr) = '1' THEN  
            print_time("ERROR vme_dma_sram2pci: dma irq asserted");
         END IF;
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_0008", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;

         print (" VME A32/D32 single access");
         rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"0000_0000", x"ffff_ffff", 1, en_msg_0, FALSE, "000001", loc_err);
         --wait_on_irq_assert(0);
         bfm_calc_msi_expected(
            msi_allocated => var_msi_allocated,
            msi_data      => MSI_DATA_VAL,
            msi_nbr       => irq_req_berr,
            msi_expected  => var_msi_expected
         );
         var_success := false;
         bfm_poll_msi(
            track_msi    => 1,
            msi_addr     => MSI_SHMEM_ADDR,
            msi_expected => var_msi_expected,
            txt_out      => en_msg_0,
            success      => var_success
         );
         if not var_success then 
            err_sum := err_sum +1;
            if en_msg_0 >= 1 then print_now("ERROR(vme_buserror): error while executing bfm_poll_msi()"); end if;
         end if;

         IF irq_req(irq_req_berr) = '0' THEN  
            print_time("ERROR vme_dma_sram2pci: dma irq NOT asserted");
         END IF;
         WAIT FOR 1 us;
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_000c", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_000c", 1, en_msg_0, TRUE, "000001");
         --wait_on_irq_deassert(0);
         IF irq_req(irq_req_berr) = '1' THEN  
            print_time("ERROR vme_dma_sram2pci: dma irq asserted");
         END IF;
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_0008", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;

         print (" VME DMA");
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F900", x"0000_0000", 1, en_msg_0, TRUE, "000001");  -- dest adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F900", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F904", x"0000_0000", 1, en_msg_0, TRUE, "000001");  -- source adr
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F904", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F908", x"0000_0003", 1, en_msg_0, TRUE, "000001");  -- size
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F908", x"0000_0003", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, SRAM + x"000F_F90c", x"0002_10e1", 1, en_msg_0, TRUE, "000001");  -- source=A24D32 dest=sram inc
         rd32(terminal_in_0, terminal_out_0, SRAM + x"000F_F90c", x"0002_10e1", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         print(" start DMA transfer");
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0003", 1, en_msg_0, TRUE, "000001");  -- start transfer

         --wait_on_irq_assert(0);
         bfm_calc_msi_expected(
            msi_allocated => var_msi_allocated,
            msi_data      => MSI_DATA_VAL,
            msi_nbr       => irq_req_dma,
            msi_expected  => var_msi_expected
         );
         var_success := false;
         bfm_poll_msi(
            track_msi    => 1,
            msi_addr     => MSI_SHMEM_ADDR,
            msi_expected => var_msi_expected,
            txt_out      => en_msg_0,
            success      => var_success
         );
         if not var_success then 
            err_sum := err_sum +1;
            if en_msg_0 >= 1 then print_now("ERROR(vme_buserror): error while executing bfm_poll_msi()"); end if;
         end if;

         IF irq_req(irq_req_dma) = '0' THEN  
            print_time("ERROR vme_dma_sram2pci: dma irq NOT asserted");
         END IF;
         WAIT FOR 1 us;
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_0008", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_001e", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_000c", 1, en_msg_0, TRUE, "000001");
         wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_000c", 1, en_msg_0, TRUE, "000001");
         --wait_on_irq_deassert(0);
         IF irq_req(irq_req_dma) = '1' THEN  
            print_time("ERROR vme_dma_sram2pci: dma irq asserted");
         END IF;
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_0008", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         rd32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_002c", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
      end if;

      err := err_sum;
      print_err("vme_buserror", err_sum);
   END PROCEDURE;
 
----------------------------------------------------------------------------------------------
   PROCEDURE vme_master_windows(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
   BEGIN
      print("Test MEN_01A021_00_IT_0070: VME A16D16");
      wr16(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1000", x"0000_1111", 1, en_msg_0, TRUE, "000001");
      wr16(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1002", x"2222_0000", 1, en_msg_0, TRUE, "000001");
      wr32(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1010", x"aa88_11ff", 1, en_msg_0, TRUE, "000001");
      wr32(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1100", x"1234_5678", 10, en_msg_0, TRUE, "000001");
      rd32(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1010", x"aa88_11ff", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1100", x"1234_5678", 10, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1002", x"2222_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1000", x"0000_1111", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wait_for(terminal_in_1, terminal_out_1, 10, TRUE);
   
      print("Test: VME A16D32");
      wr16(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1004", x"0000_1131", 1, en_msg_0, TRUE, "000001");
      wr16(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1006", x"2232_0000", 1, en_msg_0, TRUE, "000001");
      wr32(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1020", x"cafe_affe", 1, en_msg_0, TRUE, "000001");
      rd32(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1020", x"cafe_affe", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wr32(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1200", x"cafe_affe", 12, en_msg_0, TRUE, "000001");
      rd32(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1200", x"cafe_affe", 12, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1006", x"2232_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1004", x"0000_1131", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wait_for(terminal_in_1, terminal_out_1, 10, TRUE);
   
      print("Test: VME A24D16");
      wr16(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_0008", x"0000_4455", 1, en_msg_0, TRUE, "000001");
      wr16(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_000a", x"6677_0000", 1, en_msg_0, TRUE, "000001");
      wr32(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_0030", x"1234_5678", 1, en_msg_0, TRUE, "000001");
      rd32(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_0030", x"1234_5678", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wr32(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_0040", x"1234_5678", 14, en_msg_0, TRUE, "000001");
      rd32(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_0040", x"1234_5678", 14, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_000a", x"6677_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_0008", x"0000_4455", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wait_for(terminal_in_1, terminal_out_1, 10, TRUE);
   
      print("Test: VME A24D32");
      wr16(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0008", x"0000_7878", 1, en_msg_0, TRUE, "000001");
      wr16(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_000a", x"3434_0000", 1, en_msg_0, TRUE, "000001");
      wr32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0030", x"5555_6666", 1, en_msg_0, TRUE, "000001");
      rd32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0030", x"5555_6666", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wr32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0300", x"cafe_affe", 8, en_msg_0, TRUE, "000001");
      rd32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0300", x"cafe_affe", 8, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_000a", x"3434_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0008", x"0000_7878", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wait_for(terminal_in_1, terminal_out_1, 10, TRUE);
   
      print("Test: VME A32D32");                  
      -- access to vme slave simmodel offset 0x3000_0000
      -- depending on the generic settings, register LONGADD will be used differently:
--	      -- Generic USE_LONGADD=false
--	      wr8(terminal_in_0, terminal_out_0, VME_REGS + x"0000_001c", x"0000_0001", 1, en_msg_0, TRUE, "000001");
	      -- Generic USE_LONGADD=true and LONGADD_SIZE=3
	      wr8(terminal_in_0, terminal_out_0, VME_REGS + x"0000_001c", x"0000_0020", 1, en_msg_0, TRUE, "000001");
	      	
      wr16(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0008", x"0000_7878", 1, en_msg_0, TRUE, "000001");
      wr16(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_000a", x"3434_0000", 1, en_msg_0, TRUE, "000001");
      wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0030", x"5555_6666", 1, en_msg_0, TRUE, "000001");
      rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0030", x"5555_6666", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wr32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0300", x"cafe_affe", 8, en_msg_0, TRUE, "000001");
      rd32(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0300", x"cafe_affe", 8, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_000a", x"3434_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A32D32 + x"1000_0008", x"0000_7878", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wait_for(terminal_in_1, terminal_out_1, 10, TRUE);

      print("Test: VME CR/CSR");
      wr16(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0008", x"0000_7878", 1, en_msg_0, TRUE, "000001");
      wr16(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_000a", x"3434_0000", 1, en_msg_0, TRUE, "000001");
      wr32(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0030", x"5555_6666", 1, en_msg_0, TRUE, "000001");
      rd32(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0030", x"5555_6666", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wr32(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0300", x"cafe_affe", 8, en_msg_0, TRUE, "000001");
      wr8(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0100", x"4433_2211", 1, en_msg_0, TRUE, "000001");
      wr8(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0101", x"0000_2200", 1, en_msg_0, TRUE, "000001");
      wr8(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0102", x"0033_0000", 1, en_msg_0, TRUE, "000001");
      wr8(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0103", x"4400_0000", 1, en_msg_0, TRUE, "000001");
      rd32(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0300", x"cafe_affe", 8, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd8(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0100", x"0000_0011", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd8(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0101", x"0000_2200", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd8(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0102", x"0033_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd8(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0103", x"4400_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_000a", x"3434_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_CRCSR + x"0040_0008", x"0000_7878", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wait_for(terminal_in_1, terminal_out_1, 10, TRUE);
   
      err := err_sum;
         print_err("vme_master_windows", err_sum);
   END PROCEDURE;
   
----------------------------------------------------------------------------------------------
   PROCEDURE vme_arbitration(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   hreset_n       : OUT std_logic;
      SIGNAL   slot1          : OUT boolean;
      SIGNAL   en_clk         : OUT boolean;
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
   BEGIN
      print("Test MEN_01A021_00_IT_0100: VME vme_arbitration ");
   

   -- VME Arbitration:
      -- powerup board
      slot1 <= TRUE;
      hreset_n <= '0';
      en_clk <= FALSE;     -- switch off clk in order to let the PLL relock => startup reset will be generated which clears sysc bit
      WAIT FOR 500 ns;
      en_clk <= TRUE;
      WAIT FOR 50 ns;
      hreset_n <= '1';
      WAIT FOR 2 us;
      --! procedure to initialize the BFM
      --! @param bfm_inst_nbr number of the BFM instance that will be initialized
      --! @param io_add start address for the BFM internal I/O space
      --! @param mem32_addr start address for the BFM internal MEM32 space
      --! @param mem64_addr start address for the BFM internal MEM64 space
      --! @param requester_id defines the requester ID that is used for every BFM transfer
      --! @param max_payloadsize defines the maximum payload size for every write request
      init_bfm(0, x"0000_0000", SIM_BAR0, x"0000_0000_0000_0000", x"0000", 256);

      --! procedure to configure the BFM
      --! @param bfm_inst_nbr number of the BFM instance that will be configured
      --! @param max_payload_size maximum payload size for write requests
      --! @param max_read_size maximum payload size for read requests
      --! @param bar0 BAR0 settings
      --! @param bar1 BAR1 settings
      --! @param bar2 BAR2 settings
      --! @param bar3 BAR3 settings
      --! @param bar4 BAR4 settings
      --! @param bar5 BAR5 settings
      --! @param cmd_status_reg settings for the command status register
      --! @param  ctrl_status_reg settings for the control status register
      configure_bfm(terminal_in => terminal_in_0, terminal_out => terminal_out_0, bar0_addr => BAR0, bar1_addr => BAR1, bar2_addr => BAR2, bar3_addr => BAR3, bar4_addr => BAR4, bar5_addr => BAR5, txt_out => en_msg_0);
      
      WAIT FOR 3 us;
      wr8(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_0002", 1, en_msg_0, TRUE, "000001");  -- set RWD
      vme_arbiter(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, en_msg_0, loc_err);
      err_sum := err_sum + loc_err;

      -- powerup board
      slot1 <= FALSE;
      hreset_n <= '0';
      en_clk <= FALSE;     -- switch off clk in order to let the PLL relock => startup reset will be generated which clears sysc bit
      WAIT FOR 500 ns;
      en_clk <= TRUE;
      WAIT FOR 50 ns;
      hreset_n <= '1';
      WAIT FOR 2 us;
      --! procedure to initialize the BFM
      --! @param bfm_inst_nbr number of the BFM instance that will be initialized
      --! @param io_add start address for the BFM internal I/O space
      --! @param mem32_addr start address for the BFM internal MEM32 space
      --! @param mem64_addr start address for the BFM internal MEM64 space
      --! @param requester_id defines the requester ID that is used for every BFM transfer
      --! @param max_payloadsize defines the maximum payload size for every write request
      init_bfm(0, x"0000_0000", SIM_BAR0, x"0000_0000_0000_0000", x"0000", 256);

      --! procedure to configure the BFM
      --! @param bfm_inst_nbr number of the BFM instance that will be configured
      --! @param max_payload_size maximum payload size for write requests
      --! @param max_read_size maximum payload size for read requests
      --! @param bar0 BAR0 settings
      --! @param bar1 BAR1 settings
      --! @param bar2 BAR2 settings
      --! @param bar3 BAR3 settings
      --! @param bar4 BAR4 settings
      --! @param bar5 BAR5 settings
      --! @param cmd_status_reg settings for the command status register
      --! @param  ctrl_status_reg settings for the control status register
      configure_bfm(terminal_in => terminal_in_0, terminal_out => terminal_out_0, bar0_addr => BAR0, bar1_addr => BAR1, bar2_addr => BAR2, bar3_addr => BAR3, bar4_addr => BAR4, bar5_addr => BAR5, txt_out => en_msg_0);
      WAIT FOR 3 us;
      wr8(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_0002", 1, en_msg_0, TRUE, "000001");  -- set RWD
      vme_arbiter(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, en_msg_0, loc_err);
      err_sum := err_sum + loc_err;
--
   -- VME Arbitration:
      -- powerup board
      slot1 <= TRUE;
      hreset_n <= '0';
      en_clk <= FALSE;     -- switch off clk in order to let the PLL relock => startup reset will be generated which clears sysc bit
      WAIT FOR 500 ns;
      en_clk <= TRUE;
      WAIT FOR 50 ns;
      hreset_n <= '1';
      WAIT FOR 2 us;
      --! procedure to initialize the BFM
      --! @param bfm_inst_nbr number of the BFM instance that will be initialized
      --! @param io_add start address for the BFM internal I/O space
      --! @param mem32_addr start address for the BFM internal MEM32 space
      --! @param mem64_addr start address for the BFM internal MEM64 space
      --! @param requester_id defines the requester ID that is used for every BFM transfer
      --! @param max_payloadsize defines the maximum payload size for every write request
      init_bfm(0, x"0000_0000", SIM_BAR0, x"0000_0000_0000_0000", x"0000", 256);

      --! procedure to configure the BFM
      --! @param bfm_inst_nbr number of the BFM instance that will be configured
      --! @param max_payload_size maximum payload size for write requests
      --! @param max_read_size maximum payload size for read requests
      --! @param bar0 BAR0 settings
      --! @param bar1 BAR1 settings
      --! @param bar2 BAR2 settings
      --! @param bar3 BAR3 settings
      --! @param bar4 BAR4 settings
      --! @param bar5 BAR5 settings
      --! @param cmd_status_reg settings for the command status register
      --! @param  ctrl_status_reg settings for the control status register
      configure_bfm(terminal_in => terminal_in_0, terminal_out => terminal_out_0, bar0_addr => BAR0, bar1_addr => BAR1, bar2_addr => BAR2, bar3_addr => BAR3, bar4_addr => BAR4, bar5_addr => BAR5, txt_out => en_msg_0);
      WAIT FOR 3 us;
      wr8(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_0000", 1, en_msg_0, TRUE, "000001");  -- clear RWD
      vme_arbiter(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, en_msg_0, loc_err);
      err_sum := err_sum + loc_err;

      -- powerup board
      slot1 <= FALSE;
      hreset_n <= '0';
      en_clk <= FALSE;     -- switch off clk in order to let the PLL relock => startup reset will be generated which clears sysc bit
      WAIT FOR 500 ns;
      en_clk <= TRUE;
      WAIT FOR 50 ns;
      hreset_n <= '1';
      WAIT FOR 2 us;
      --! procedure to initialize the BFM
      --! @param bfm_inst_nbr number of the BFM instance that will be initialized
      --! @param io_add start address for the BFM internal I/O space
      --! @param mem32_addr start address for the BFM internal MEM32 space
      --! @param mem64_addr start address for the BFM internal MEM64 space
      --! @param requester_id defines the requester ID that is used for every BFM transfer
      --! @param max_payloadsize defines the maximum payload size for every write request
      init_bfm(0, x"0000_0000", SIM_BAR0, x"0000_0000_0000_0000", x"0000", 256);

      --! procedure to configure the BFM
      --! @param bfm_inst_nbr number of the BFM instance that will be configured
      --! @param max_payload_size maximum payload size for write requests
      --! @param max_read_size maximum payload size for read requests
      --! @param bar0 BAR0 settings
      --! @param bar1 BAR1 settings
      --! @param bar2 BAR2 settings
      --! @param bar3 BAR3 settings
      --! @param bar4 BAR4 settings
      --! @param bar5 BAR5 settings
      --! @param cmd_status_reg settings for the command status register
      --! @param  ctrl_status_reg settings for the control status register
      configure_bfm(terminal_in => terminal_in_0, terminal_out => terminal_out_0, bar0_addr => BAR0, bar1_addr => BAR1, bar2_addr => BAR2, bar3_addr => BAR3, bar4_addr => BAR4, bar5_addr => BAR5, txt_out => en_msg_0);
      WAIT FOR 3 us;
      wr8(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0010", x"0000_0000", 1, en_msg_0, TRUE, "000001");  -- set RWD
      vme_arbiter(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, en_msg_0, loc_err);
      err_sum := err_sum + loc_err;
   
      err := err_sum;
         print_err("vme_arbitration", err_sum);
   END PROCEDURE;
----------------------------------------------------------------------------------------------
   PROCEDURE vme_arbiter(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
   BEGIN
      print("Test MEN_01A021_00_IT_0100: VME Arbitration ");
         
      wr32(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0014", x"0000_1010", 1, en_msg_0, TRUE, "000001"); -- activate A24 vme slave
      WAIT FOR 1 us;

      print("Test: VME A16D16");
      wr16(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1000", x"0000_1111", 1, en_msg_0, TRUE, "000001");
      wr32(terminal_in_1, terminal_out_1, x"0100_0004", x"cafe_affe", 1, en_msg_0, TRUE, "111001");                  -- write to a24 vme slave
      wr16(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1002", x"2222_0000", 1, en_msg_0, TRUE, "000001");
      wr32(terminal_in_1, terminal_out_1, x"0100_0008", x"1111_1111", 1, en_msg_0, TRUE, "111001");                  -- write to a24 vme slave
      wr32(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1010", x"aa88_11ff", 1, en_msg_0, TRUE, "000001");
      rd32(terminal_in_1, terminal_out_1, x"0100_0004", x"cafe_affe", 1, en_msg_0, TRUE, "111001", loc_err);                  -- read from a24 vme slave
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1010", x"aa88_11ff", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1002", x"2222_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_1, terminal_out_1, x"0100_0008", x"1111_1111", 1, en_msg_0, TRUE, "111001", loc_err);                  -- read from a24 vme slave
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A16D16 + x"0000_1000", x"0000_1111", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wait_for(terminal_in_1, terminal_out_1, 10, TRUE);
   
      print("Test: VME A16D32");
      wr16(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1004", x"0000_1131", 1, en_msg_0, TRUE, "000001");
      wr32(terminal_in_1, terminal_out_1, x"0100_0014", x"2222_2222", 1, en_msg_0, TRUE, "111001");                  -- write to a24 vme slave
      wr16(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1006", x"2232_0000", 1, en_msg_0, TRUE, "000001");
      wr32(terminal_in_1, terminal_out_1, x"0100_0018", x"3333_3333", 1, en_msg_0, TRUE, "111001");                  -- write to a24 vme slave
      wr32(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1020", x"cafe_affe", 1, en_msg_0, TRUE, "000001");
      rd32(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1020", x"cafe_affe", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wr32(terminal_in_1, terminal_out_1, x"0100_001c", x"4444_4444", 1, en_msg_0, TRUE, "111001");                  -- write to a24 vme slave
      rd16(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1006", x"2232_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wr32(terminal_in_1, terminal_out_1, x"0100_0020", x"5555_5555", 1, en_msg_0, TRUE, "111001");                  -- write to a24 vme slave
      rd16(terminal_in_0, terminal_out_0, VME_A16D32 + x"0000_1004", x"0000_1131", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wr32(terminal_in_1, terminal_out_1, x"0100_0024", x"6666_6666", 1, en_msg_0, TRUE, "111001");                  -- write to a24 vme slave
      wr32(terminal_in_1, terminal_out_1, x"0100_0028", x"7777_7777", 1, en_msg_0, TRUE, "111001");                  -- write to a24 vme slave
      wait_for(terminal_in_1, terminal_out_1, 10, TRUE);
   
      print("Test: VME A24D16");
      wr16(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_0008", x"0000_4455", 1, en_msg_0, TRUE, "000001");
      rd32(terminal_in_1, terminal_out_1, x"0100_0014", x"2222_2222", 1, en_msg_0, TRUE, "111001", loc_err);                  -- write to a24 vme slave
      err_sum := err_sum + loc_err;
      wr16(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_000a", x"6677_0000", 1, en_msg_0, TRUE, "000001");
      rd32(terminal_in_1, terminal_out_1, x"0100_0018", x"3333_3333", 1, en_msg_0, TRUE, "111001", loc_err);                  -- write to a24 vme slave
      err_sum := err_sum + loc_err;
      wr32(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_0030", x"1234_5678", 1, en_msg_0, TRUE, "000001");
      rd32(terminal_in_1, terminal_out_1, x"0100_001c", x"4444_4444", 1, en_msg_0, TRUE, "111001", loc_err);                  -- write to a24 vme slave
      err_sum := err_sum + loc_err;
      rd32(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_0030", x"1234_5678", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_1, terminal_out_1, x"0100_0020", x"5555_5555", 1, en_msg_0, TRUE, "111001", loc_err);                  -- write to a24 vme slave
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_000a", x"6677_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_1, terminal_out_1, x"0100_0024", x"6666_6666", 1, en_msg_0, TRUE, "111001", loc_err);                  -- write to a24 vme slave
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A24D16 + x"0020_0008", x"0000_4455", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd32(terminal_in_1, terminal_out_1, x"0100_0028", x"7777_7777", 1, en_msg_0, TRUE, "111001", loc_err);                  -- write to a24 vme slave
      err_sum := err_sum + loc_err;
      wait_for(terminal_in_1, terminal_out_1, 10, TRUE);
   
      print("Test: VME A24D32");
      wr16(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0008", x"0000_7878", 1, en_msg_0, TRUE, "000001");
      wr16(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_000a", x"3434_0000", 1, en_msg_0, TRUE, "000001");
      wr32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0030", x"5555_6666", 1, en_msg_0, TRUE, "000001");
      rd32(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0030", x"5555_6666", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_000a", x"3434_0000", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      rd16(terminal_in_0, terminal_out_0, VME_A24D32 + x"0020_0008", x"0000_7878", 1, en_msg_0, TRUE, "000001", loc_err);
      err_sum := err_sum + loc_err;
      wait_for(terminal_in_1, terminal_out_1, 10, TRUE);
   
      err := err_sum;
         print_err("vme_arbiter", err_sum);
   END PROCEDURE;
   

--------------------------------------------------------------------------------------------
   PROCEDURE vme_irq_rcv(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   vme_slv_in     : OUT vme_slv_in_type;
      SIGNAL   vme_slv_out    : IN vme_slv_out_type;
      SIGNAL   irq_req        : IN std_logic_vector(16 DOWNTO 0);
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err           : integer:=0;
      VARIABLE err_sum           : integer:=0;
      VARIABLE dat               : std_logic_vector(31 DOWNTO 0);
      variable var_msi_expected  : std_logic_vector(31 downto 0) := (others => '0');
      variable var_success       : boolean := false;
      variable var_msi_allocated : std_logic_vector(2 downto 0) := (others => '0');
      constant MSI_SHMEM_ADDR    : natural := 2096896; -- := x"1FFF00" at upper end of shared memory
      constant MSI_DATA_VAL      : std_logic_vector(15 downto 0) := x"3210";
   BEGIN
      print("Test MEN_01A021_00_IT_0090: Interrupt Handler");
      var_success := false;
      bfm_configure_msi(
         msi_addr       => MSI_SHMEM_ADDR,
         msi_data       => MSI_DATA_VAL,
         msi_allocated  => var_msi_allocated,
         success        => var_success
      );
      if not var_success then 
         err_sum := err_sum +1;
         if en_msg_0 >= 1 then 
            print_now("ERROR(vme_irq_rcv): error while executing bfm_configure_msi() - MSI NOT configured, MSI behavior is UNDEFINED!");
            print("   ---> test case skipped");
         end if;
      else
         -- enable receiving interrupts
         wr8(terminal_in_0, terminal_out_0, VME_REGS + x"0000_000c", x"0000_00ff", 1, en_msg_0, TRUE, "000001");
         rd8(terminal_in_0, terminal_out_0, VME_REGS + x"0000_000c", x"0000_00ff", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         WAIT FOR 150 ns;
      
         FOR i IN 1 TO 7 LOOP
            bfm_calc_msi_expected(
               msi_allocated => var_msi_allocated,
               msi_data      => MSI_DATA_VAL,
               msi_nbr       => i,
               msi_expected  => var_msi_expected
            );

            irq_vme_slv (vme_slv_in, vme_slv_out, i, x"00"+i);
            var_success := false;
            bfm_poll_msi(
               track_msi    => 1,
               msi_addr     => MSI_SHMEM_ADDR,
               msi_expected => var_msi_expected,
               txt_out      => en_msg_0,
               success      => var_success
            );
            if not var_success then 
               err_sum := err_sum +1;
               if en_msg_0 >= 1 then print_now("ERROR(vme_irq_rcv): error while executing bfm_poll_msi()"); end if;
            end if;
            IF irq_req(i+4) = '0' THEN    -- acfail + vme_irq is irq_req(11:5)
               print_time("ERROR vme_irq_rcv: wrong irq asserted");
            END IF;
            dat:=x"00"+i & x"00"+i & x"00"+i & x"00"+i;
            rd8(terminal_in_0, terminal_out_0, VME_IACK + (2*i) + 1, dat, 1, en_msg_0, TRUE, "000001", loc_err);
            err_sum := err_sum + loc_err;
            WAIT FOR 300 ns;
         END LOOP;
         -- disable receiving interrupts
         wr8(terminal_in_0, terminal_out_0, VME_REGS + x"0000_000c", x"0000_0000", 1, en_msg_0, TRUE, "000001");
         rd8(terminal_in_0, terminal_out_0, VME_REGS + x"0000_000c", x"0000_0000", 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
      end if;

      err := err_sum;
      print_err("vme_irq_rcv", err_sum);
   END PROCEDURE;

------------------------------------------------------------------------------------------
   PROCEDURE vme_irq_trans(   
      SIGNAL   terminal_in_0  : IN terminal_in_type;
      SIGNAL   terminal_out_0 : OUT terminal_out_type;
      SIGNAL   terminal_in_1  : IN terminal_in_type;
      SIGNAL   terminal_out_1 : OUT terminal_out_type;
      SIGNAL   vme_slv_in     : OUT vme_slv_in_type;
      SIGNAL   vme_slv_out    : IN vme_slv_out_type;
               en_msg_0       : integer;
               err            : OUT natural
               ) IS
      VARIABLE loc_err : integer:=0;
      VARIABLE err_sum : integer:=0;
      VARIABLE dat : std_logic_vector(31 DOWNTO 0);
   BEGIN
      print("Test MEN_01A021_00_IT_0080: Interrupter");
      FOR i IN 1 TO 7 LOOP
         IF vme_slv_out.irq(i) = '0' THEN
            print_time("ERROR: VME irqs should NOT be active!");
         END IF;
         wr8(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0000", x"0000_0008" + i, 1, en_msg_0, TRUE, "000001"); -- set interrupt request on line x
         wr8(terminal_in_0, terminal_out_0, VME_REGS + x"0000_0004", x"0000_0000" + i, 1, en_msg_0, TRUE, "000001"); -- set interrupt id
         wl: FOR j IN 0 TO 1000 LOOP
            IF vme_slv_out.irq(i) = '0' THEN
               print_time("exit");
               exit wl;
            END IF;
            WAIT FOR 10 ns;
         END LOOP;
         dat:=x"00"+i & x"00"+i & x"00"+i & x"00"+i;
         rd8_iack(terminal_in_1, terminal_out_1, VME_IACK + (2*i), dat, 1, en_msg_0, TRUE, "000001", loc_err);
         err_sum := err_sum + loc_err;
         WAIT FOR 100 ns;
      END LOOP;
      err := err_sum;
         print_err("vme_irq_trans", err_sum);
   END PROCEDURE;
   
   procedure configure_bfm(
      signal terminal_in  : in terminal_in_type;
      signal terminal_out : out terminal_out_type;
      bar0_addr : std_logic_vector(31 downto 0);
      bar1_addr : std_logic_vector(31 downto 0);
      bar2_addr : std_logic_vector(31 downto 0);
      bar3_addr : std_logic_vector(31 downto 0);
      bar4_addr : std_logic_vector(31 downto 0);
      bar5_addr : std_logic_vector(31 downto 0);
      txt_out   : integer
   ) is
   begin
      if txt_out >= 2 then -- print info
         print("terminal_pkg->configure_bfm(): set address for BAR0");
      end if;
      wr32(terminal_in, terminal_out, x"0000_0000", bar0_addr, 1, txt_out, TRUE, "000011");

      if txt_out >= 2 then -- print info
         print("terminal_pkg->configure_bfm(): set address for BAR1");
      end if;
      wr32(terminal_in, terminal_out, x"0000_0001", bar1_addr, 1, txt_out, TRUE, "000011");

      if txt_out >= 2 then -- print info
         print("terminal_pkg->configure_bfm(): set address for BAR2");
      end if;
      wr32(terminal_in, terminal_out, x"0000_0002", bar2_addr, 1, txt_out, TRUE, "000011");

      if txt_out >= 2 then -- print info
         print("terminal_pkg->configure_bfm(): set address for BAR3");
      end if;
      wr32(terminal_in, terminal_out, x"0000_0003", bar3_addr, 1, txt_out, TRUE, "000011");

      if txt_out >= 2 then -- print info
         print("terminal_pkg->configure_bfm(): set address for BAR4");
      end if;
      wr32(terminal_in, terminal_out, x"0000_0004", bar4_addr, 1, txt_out, TRUE, "000011");

      if txt_out >= 2 then -- print info
         print("terminal_pkg->configure_bfm(): set address for BAR5");
      end if;
      wr32(terminal_in, terminal_out, x"0000_0005", bar5_addr, 1, txt_out, TRUE, "000011");

   end procedure configure_bfm;
END;
