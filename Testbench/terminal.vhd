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
--      terminal
--      wb_test
---------------------------------------------------------------
-- Copyright (C) 2001, MEN Mikroelektronik Nuernberg GmbH
--
--   All rights reserved. Reproduction in whole or part is 
--      prohibited without the written permission of the 
--                    copyright owner.           
---------------------------------------------------------------
--                         History                                    
---------------------------------------------------------------
-- $Revision: 1.3 $
--
-- $Log: terminal.vhd,v $
-- Revision 1.3  2013/07/15 13:14:20  mmiehling
-- adopted testcases
--
-- Revision 1.2  2013/04/18 15:11:08  MMiehling
-- support of pcie model
--
-- Revision 1.1  2012/03/29 10:28:43  MMiehling
-- Initial Revision
--
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
USE ieee.std_logic_unsigned.ALL;
USE work.print_pkg.all;
USE work.terminal_pkg.ALL;
USE work.vme_sim_pack.all;
USE work.pcie_sim_pkg.ALL;
LIBRARY modelsim_lib;
USE modelsim_lib.util.all;
USE std.textio.all;

ENTITY terminal IS
PORT (
   hreset_n          : OUT std_logic;
   
   slot1             : OUT boolean:=TRUE;                     -- if true dut is in slot1
   en_clk            : OUT boolean:=TRUE;                     -- if true dut is supplied with 16 mhz clk
   terminal_in_0     : IN terminal_in_type;     -- PCIe Master Model
   terminal_out_0    : OUT terminal_out_type;
   terminal_in_1     : IN terminal_in_type;     -- VMEbus Master Model
   terminal_out_1    : OUT terminal_out_type;

   vme_slv_in        : OUT vme_slv_in_type;
   vme_slv_out       : IN vme_slv_out_type;
   vme_mon_out       : IN vme_mon_out_type;
   
   v2p_rstn          : IN std_logic;                       -- connected to hreset_req1_n
   vme_ga            : OUT std_logic_vector(4 DOWNTO 0);     -- geographical addresses
   vme_gap           : OUT std_logic                       -- geographical addresses
  
     );
END terminal;

ARCHITECTURE terminal_arch OF terminal IS 

   SIGNAL terminal_err_0   : integer:=0;
   SIGNAL end_of_tests      : boolean;
   SIGNAL vb_sysresn          : std_logic;
   SIGNAL irq_req       : std_logic_vector(16 DOWNTO 0);

   CONSTANT en_msg_0       : integer:= 2;
   
BEGIN



term_0: PROCESS
   VARIABLE err : integer:=0;
   VARIABLE dat : std_logic_vector(31 DOWNTO 0);
  BEGIN
   hreset_n <= '0';
   en_clk <= TRUE;
   vme_ga <= (OTHERS => '0');
   vme_gap <= '0';
   --init_signal_spy("/a25_tb/a25/pcie/irq_req","irq_req",1,1);
   init_signal_spy("/a25_tb/vb_sysresn","vb_sysresn",1,1);
   init(terminal_out_0);
   init(terminal_out_1);
   init_vme_slv(vme_slv_in);

   -- powerup board
   -- shorten reset time on vme bus
   signal_force("/a25_tb/a25/vme/vmectrl/bustimer/pre_cnt_max_sig", "0000001000", 0 ns, freeze, -1 ns, 1);
   signal_force("/a25_tb/a25/vme/vmectrl/bustimer/main_cnt_max_sig", "000000000000011", 0 ns, freeze, -1 ns, 1);
   --signal_force("/a25_tb/a25/pcie/test_pcie_core", "0000000000000001", 0 ns, freeze, -1 ns, 1);
   --signal_force("/a25_tb/a25/pcie/test_rs_serdes", "1", 0 ns, freeze, -1 ns, 1);
   slot1 <= TRUE;
   WAIT FOR 100 ns;
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
   

   print("***************************************************");
   print("                Start of Tests");
   print("***************************************************");
   -- Reset:
   vme_reset(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, slot1, hreset_n, v2p_rstn, vb_sysresn, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   -- VME Buserror:
   vme_buserror(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, irq_req, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   -- chameleon
   cham_test(terminal_in_0, terminal_out_0, en_msg_0, err);    
   terminal_err_0 <= terminal_err_0 + err;    

   -- geographical address test
   vme_ga_test(terminal_in_0, terminal_out_0, vme_ga, vme_gap, en_msg_0, err);    
   terminal_err_0 <= terminal_err_0 + err;    

   -- VME Slave:
   vme_slave_a242sram(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   vme_slave_a242pci(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   vme_slave_a322sram(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   vme_slave_a322pci(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   vme_slave_a162regs(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   -- VME Master:
   vme_master_windows(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   -- VME Interrupt Handler:
   vme_irq_rcv(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, vme_slv_in, vme_slv_out, irq_req, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   -- VME Interrupter:
   vme_irq_trans(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, vme_slv_in, vme_slv_out, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   -- VME DMA:
   vme_dma_boundaries(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, irq_req, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err; 
   
   vme_dma_fifo(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, irq_req, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;
   vme_dma_sram2a24d32(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, irq_req, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;
   vme_dma_sram2sram(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, irq_req, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;
   vme_dma_sram2a32d32(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, irq_req, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   vme_dma_sram2a32d64(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, irq_req, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   vme_dma_sram2pci(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, irq_req, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   vme_arbitration(terminal_in_0, terminal_out_0, terminal_in_1, terminal_out_1, hreset_n, slot1, en_clk, en_msg_0, err);
   terminal_err_0 <= terminal_err_0 + err;

   WAIT FOR 1 us;

   print("***************************************************");
   print("  Test Summary:");
   print_s_i("  Number of errors:             ", terminal_err_0);
   print("***************************************************");
   ASSERT FALSE REPORT "--- END OF SIMULATION ---" SEVERITY failure;
   WAIT;
   END PROCESS term_0;

END terminal_arch;
