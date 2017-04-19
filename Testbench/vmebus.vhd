---------------------------------------------------------------
-- Title         : External driver simulation model
-- Project       : A15
---------------------------------------------------------------
-- File          : vmebus.vhd
-- Author        : Michael Miehling
-- Email         : miehling@men.de
-- Organization  : MEN Mikroelektronik Nuernberg GmbH
-- Created       : 03/02/03
---------------------------------------------------------------
-- Simulator     : Modelsim
-- Synthesis     : -
---------------------------------------------------------------
-- Description :
--
-- 
---------------------------------------------------------------
-- Hierarchy:
--
-- tb_vme_ctrl
--      vmebus
--         vme_sim_mstr
--         vme_sim_slave
--         vme_sim_mon
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
-- $Log: vmebus.vhd,v $
-- Revision 1.2  2013/04/18 15:11:19  MMiehling
-- added slot 1/x support
--
-- Revision 1.1  2012/03/29 10:28:51  MMiehling
-- Initial Revision
--
-- Revision 1.2  2006/05/18 14:30:46  MMiehling
-- changed iack connection
--
-- Revision 1.1  2005/10/28 17:52:09  mmiehling
-- Initial Revision
--
-- Revision 1.1  2004/07/27 17:27:56  mmiehling
-- Initial Revision
--
--
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.vme_sim_pack.ALL;
USE work.terminal_pkg.all;

ENTITY vmebus IS
PORT (
   slot1          : boolean:=TRUE;                     -- if true dut is in slot1
   vme_slv_in     : IN vme_slv_in_type;
   vme_slv_out    : OUT vme_slv_out_type;
   vme_mon_out    : OUT vme_mon_out_type;
   terminal_in_x  : OUT terminal_in_type;
   terminal_out_x : IN terminal_out_type;
   
    -- the VME signals:
   vb_am          : INOUT std_logic_vector(5 DOWNTO 0);   
   vb_data        : INOUT std_logic_vector(31 DOWNTO 0);   
   vb_adr         : INOUT std_logic_vector(31 DOWNTO 0);   
   vb_writen      : INOUT std_logic;            
   vb_iackn       : INOUT std_logic;            
   vb_asn         : INOUT std_logic;            
   vb_dsan        : INOUT std_logic;            
   vb_dsbn        : INOUT std_logic;            
   vb_bbsyn       : INOUT std_logic;            
   vb_berrn       : INOUT std_logic;            
   vb_brn         : INOUT std_logic_vector(3 DOWNTO 0);            
   vb_dtackn      : INOUT std_logic;            
   vb_sysresn     : INOUT std_logic;            
   vb_irq1n       : INOUT std_logic;         
   vb_irq2n       : INOUT std_logic;         
   vb_irq3n       : INOUT std_logic;         
   vb_irq4n       : INOUT std_logic;         
   vb_irq5n       : INOUT std_logic;         
   vb_irq6n       : INOUT std_logic;         
   vb_irq7n       : INOUT std_logic;         
   vb_bgin        : OUT std_logic_vector(3 DOWNTO 0);            
   vb_bgout       : IN std_logic_vector(3 DOWNTO 0);             
   vb_iackin      : OUT std_logic;            
   vb_iackout     : IN std_logic;            
   vb_acfailn     : INOUT std_logic

     );
END vmebus;

ARCHITECTURE vmebus_arch OF vmebus IS 
COMPONENT vme_sim_mstr
PORT (
   sysresn        : INOUT std_logic;
   asn            : INOUT std_logic;
   dsan           : INOUT std_logic;
   dsbn           : INOUT std_logic;
   writen         : INOUT std_logic;
   dtackn         : IN std_logic;
   berrn          : INOUT std_logic;
   addr           : INOUT std_logic_vector(31 DOWNTO 0);
   data           : INOUT std_logic_vector(31 DOWNTO 0);
   am             : INOUT std_logic_vector(5 DOWNTO 0);
   iackn          : INOUT std_logic;
   iackout        : OUT std_logic;
   iackin         : IN std_logic;
   vb_irq1n       : INOUT std_logic;         
   vb_irq2n       : INOUT std_logic;         
   vb_irq3n       : INOUT std_logic;         
   vb_irq4n       : INOUT std_logic;         
   vb_irq5n       : INOUT std_logic;         
   vb_irq6n       : INOUT std_logic;         
   vb_irq7n       : INOUT std_logic;         
   vb_acfailn     : INOUT std_logic;
   bg3n_in        : IN std_logic;
   bg3n_out       : OUT std_logic;
   brn            : INOUT std_logic_vector(3 DOWNTO 0);
   bbsyn          : INOUT std_logic;

   terminal_in_x  : OUT terminal_in_type;
   terminal_out_x : IN terminal_out_type
   );
END COMPONENT;

COMPONENT vme_sim_slave
PORT (
   sysresin       : IN std_logic;
   asn_in         : IN std_logic;
   dsan_in        : IN std_logic;
   dsbn_in        : IN std_logic;
   writen_in      : IN std_logic;
   berrn_in       : IN std_logic;
   addr           : INOUT std_logic_vector(31 DOWNTO 0);
   data_in        : IN std_logic_vector(31 DOWNTO 0);
   am_in          : IN std_logic_vector(5 DOWNTO 0);
   iackn_in       : IN std_logic;   -- daisy-chain
   iackn          : IN std_logic;   -- bussignal
   irq_out        : OUT std_logic_vector(7 DOWNTO 1);
   dtackn_out     : OUT std_logic;
   data_out       : OUT std_logic_vector(31 DOWNTO 0);
   vb_irq1n       : IN std_logic;         
   vb_irq2n       : IN std_logic;         
   vb_irq3n       : IN std_logic;         
   vb_irq4n       : IN std_logic;         
   vb_irq5n       : IN std_logic;         
   vb_irq6n       : IN std_logic;         
   vb_irq7n       : IN std_logic;         
   
   vme_slv_in     : IN vme_slv_in_type;
   vme_slv_out    : OUT vme_slv_out_type
   );
END COMPONENT;

COMPONENT vme_sim_mon 
PORT (
   rstn           : IN std_logic;
   asn_in         : IN std_logic;
   dsan_in        : IN std_logic;
   dsbn_in        : IN std_logic;
   writen_in      : IN std_logic;
   dtackn_in      : IN std_logic;
   berrn_in       : IN std_logic;
   addr_in        : IN std_logic_vector(31 DOWNTO 0);
   data_in        : IN std_logic_vector(31 DOWNTO 0);
   am_in          : IN std_logic_vector(5 DOWNTO 0);
   iackn          : IN std_logic;
   vb_irq1n       : IN std_logic;         
   vb_irq2n       : IN std_logic;         
   vb_irq3n       : IN std_logic;         
   vb_irq4n       : IN std_logic;         
   vb_irq5n       : IN std_logic;         
   vb_irq6n       : IN std_logic;         
   vb_irq7n       : IN std_logic;         
   bbsyn_in       : IN std_logic;
   
   vme_mon_out    : OUT vme_mon_out_type
   );
END COMPONENT;


   SIGNAL bg3n_out   : std_logic;
   SIGNAL sim_iackout: std_logic;
   SIGNAL sim_iackin : std_logic;
   SIGNAL sim_bgout  : std_logic;
   SIGNAL sim_bgin   : std_logic;
                                          
BEGIN                

   vb_am          <= (OTHERS => 'H');  
   vb_data        <= (OTHERS => 'H');   
   vb_adr         <= (OTHERS => 'H');   
   vb_brn         <= (OTHERS => 'H');           
   vb_bgin        <= (OTHERS => 'H');           

   vb_writen      <= 'H';
   vb_iackn       <= 'H';
   vb_asn         <= 'H';
   vb_dsan        <= 'H';
   vb_dsbn        <= 'H';
   vb_bbsyn       <= 'H';
   vb_berrn       <= 'H';
   vb_dtackn      <= 'H';
   vb_sysresn     <= 'H';
--   vb_irq1n       <= 'H';
--   vb_irq2n       <= 'H';
--   vb_irq3n       <= 'H';
--   vb_irq4n       <= 'H';
--   vb_irq5n       <= 'H';
--   vb_irq6n       <= 'H';
--   vb_irq7n       <= 'H';
   vb_acfailn     <= 'H';
   
   
vmesimmstr : vme_sim_mstr     
PORT MAP (           
   sysresn        => vb_sysresn,
   asn            => vb_asn,
   dsan           => vb_dsan,
   dsbn           => vb_dsbn,
   writen         => vb_writen,
   dtackn         => vb_dtackn,
   berrn          => vb_berrn,
   addr           => vb_adr,
   data           => vb_data,
   am             => vb_am,
   iackn          => vb_iackn,
   iackout        => sim_iackout,
   iackin         => sim_iackin,
   vb_irq1n       => vb_irq1n,
   vb_irq2n       => vb_irq2n,
   vb_irq3n       => vb_irq3n,
   vb_irq4n       => vb_irq4n,
   vb_irq5n       => vb_irq5n,
   vb_irq6n       => vb_irq6n,
   vb_irq7n       => vb_irq7n,
   vb_acfailn     => vb_acfailn,
   bg3n_in        => sim_bgin,
   bg3n_out       => sim_bgout,
   brn            => vb_brn,
   bbsyn          => vb_bbsyn,
   
   terminal_in_x  => terminal_in_x  ,
   terminal_out_x => terminal_out_x 
   );

vmesimmon: vme_sim_mon 
PORT MAP(
   rstn           => vb_sysresn,  
   asn_in         => vb_asn,      
   dsan_in        => vb_dsan,     
   dsbn_in        => vb_dsbn,     
   writen_in      => vb_writen,   
   dtackn_in      => vb_dtackn,   
   berrn_in       => vb_berrn,    
   addr_in        => vb_adr,      
   data_in        => vb_data,     
   am_in          => vb_am,       
   iackn          => vb_iackn,    
   vb_irq1n       => vb_irq1n, 
   vb_irq2n       => vb_irq2n, 
   vb_irq3n       => vb_irq3n, 
   vb_irq4n       => vb_irq4n, 
   vb_irq5n       => vb_irq5n, 
   vb_irq6n       => vb_irq6n, 
   vb_irq7n       => vb_irq7n, 
   bbsyn_in       => vb_bbsyn,

   vme_mon_out    => vme_mon_out
   );    
     
vb_slave : vme_sim_slave
PORT MAP(
   sysresin       => vb_sysresn,
   asn_in         => vb_asn,
   dsan_in        => vb_dsan,
   dsbn_in        => vb_dsbn,
   writen_in      => vb_writen,
   berrn_in       => vb_berrn,
   addr           => vb_adr,
   data_in        => vb_data,
   am_in          => vb_am,
   iackn_in       => sim_iackin,
   iackn          => vb_iackn,
   dtackn_out     => vb_dtackn,
   data_out       => vb_data,
   irq_out(1)     => vb_irq1n,
   irq_out(2)     => vb_irq2n,
   irq_out(3)     => vb_irq3n,
   irq_out(4)     => vb_irq4n,
   irq_out(5)     => vb_irq5n,
   irq_out(6)     => vb_irq6n,
   irq_out(7)     => vb_irq7n,
   vb_irq1n       => vb_irq1n,         
   vb_irq2n       => vb_irq2n,         
   vb_irq3n       => vb_irq3n,         
   vb_irq4n       => vb_irq4n,         
   vb_irq5n       => vb_irq5n,         
   vb_irq6n       => vb_irq6n,         
   vb_irq7n       => vb_irq7n,         

   vme_slv_in     => vme_slv_in  ,
   vme_slv_out    => vme_slv_out 
   );
          
   
sl1: PROCESS(slot1, vb_iackn, vb_iackout, vb_bgout, sim_iackout, sim_bgout)
BEGIN
   IF slot1 THEN  
      ----------------------------------------------------------------
      -- slot  1     2     
      --      dut   sim
      ----------------------------------------------------------------
      IF vb_iackn = '0' THEN
         vb_iackin <= '0';                               -- connect vb_iackn bussignal to daisy chain slot1         
      ELSE 
         vb_iackin <= 'H';     
      END IF;
      sim_iackin <= vb_iackout;                          -- connect iack daisy chain of dut(slot1) to sim
      vb_bgin(3) <= '0';                                 -- dut is in slot1
      sim_bgin <= vb_bgout(3);                           -- connect bg daisy chain of dut(slot1) to sim
   ELSE
      ----------------------------------------------------------------
      -- slot  1     2     
      --      sim   dut
      ----------------------------------------------------------------
      vb_iackin <= sim_iackout;
      IF vb_iackn = '0' THEN
         sim_iackin <= '0';                              -- connect vb_iackn bussignal to daisy chain slot1         
      ELSE 
         sim_iackin <= 'H';
      END IF;
      vb_bgin(3) <= sim_bgout;                           -- connect bg daisy chain of sim(slot1) to dut
      sim_bgin <= '0';                                   -- sim is in slot1
   END IF;
END PROCESS sl1;
      

END vmebus_arch;
