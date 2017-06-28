# A25\_VME Testbench
VHDL source for A25 simulation environment and test cases

Contents of this repository:

16x001-00\_src: Simulation Model of a dynamic 32-bit wide RAM with wishbone slave interface for single and burst accesses.

16x004-00\_src: PCIe x1 master simulation model

16x010-00\_src:	Helper functions for simulation environment

Testbench:     Main VHDL sources for A25 test bench

               Hierarchy of the bench:
               a25_tb.vhd
                  |- terminal				main control module of the test bench
                  |- mt58l512l18f			simulation model of external SRAM
                  |- SN74ABT125				simulation model of external bus driver
                  |- SN74LVTH245			simulation model of external bus driver
                  |- vmebus				simulation model of VMEbus
                   |- vme_sim_mon			VMEbus timing monitor
                   |- vme_sim_mstr			simulation model of VMEbus master
                   |- vme_sim_slave			simulation model of VMEbus slave

		Packages:
                  terminal_pkg				package with all test case implementations
                  vme_sim_pack				package for vmebus internal definitions

Simulation:		Work folder of simulator Modelsim (PE 6.6)

		a25.mpf				Modelsim project file
        	build_all_a25.do		main do file to run the simulation
        	test_report.txt			Modelsim log
        	wbm_x_transcript.txt		Access log of Wishbone master #x
        	wbs_x_transcript.txt		Access log of Wishbone slave #x

Folder setup:
    your_root_folder
     +- 16a025-00_src
        +- [...]
     +- 16a025-00_tb
        +- [...]
        +- Altera_src                                      <- shall include BFM files
           +- altpcietb_bfm_common.vhd
           +- altpcietb_bfm_constants.vhd
           +- altpcietb_bfm_log.vhd
           +- altpcietb_bfm_shmem.vhd
           +- altpcietb_bfm_req_intf.vhd
           +- altpcietb_bfm_rdwr.vhd
           +- altpcietb_bfm_configure.vhd
           +- altpcietb_pipe_xtx2yrx.vhd
           +- altpcietb_pipe_phy.vhd
           +- altpcietb_ltssm_mon.vhd
           +- altpcietb_bfm_rp_top_x8_pipen1b.vhd
           +- altpcietb_bfm_rpvar_64b_x8_gen1_pipen1b.vho
           +- altpcietb_bfm_rpvar_64b_x8_gen2_pipen1b.vho
           +- altpcietb_bfm_vc_intf.vhd
        +- Simulation 
           +- build_all_a25.do                             <- to start simulation, only prepared for x1 - add x2/x4 sources
           +- [...]
        +- Testbench
           +- [...]
     +- Altera_src                                         <- shall include Hard IP sources
        +- x1
           +- Hard_IP_x1.vhd
           +- Hard_IP_x1_core.vhd
           +- Hard_IP_x1_core.vho
           +- Hard_IP_x1_serdes.vhd
           +- Hard_IP_x1_plus.vhd
        +- x2
           +- Hard_IP_x2.vhd
           +- Hard_IP_x2_core.vhd
           +- Hard_IP_x2_core.vho
           +- Hard_IP_x2_serdes.vhd
           +- Hard_IP_x2_plus.vhd
        +- x4
           +- Hard_IP_x4.vhd
           +- Hard_IP_x4_core.vhd
           +- Hard_IP_x4_core.vho
           +- Hard_IP_x4_serdes.vhd
           +- Hard_IP_x4_plus.vhd

                  

## Preliminaries to simulation
Prior to simulation some files must be generated and/or copied to specific locations within the working directory. Follow the steps
described below:
1. Generate all Hard\_IP\_xy with y being either 1, 2 or 4 and generate the simulation model for VHDL.  
2. Open the Hard\_IP\_xy.vhd file and add these generics
     generic(
       VENDOR_ID           : natural := 16#1A88#;
       DEVICE_ID           : natural := 16#4D45#;
       REVISION_ID         : natural := 16#0#;
       CLASS_CODE          : natural := 16#068000#;
       SUBSYSTEM_VENDOR_ID : natural := 16#9B#;
       SUBSYSTEM_DEVICE_ID : natural := 16#5A91#;

       IO_SPACE_BAR_0  : string  := "false";
       PREFETCH_BAR_0  : string  := "true";
       SIZE_MASK_BAR_0 : natural := 28;
       
       IO_SPACE_BAR_1  : string  := "false";
       PREFETCH_BAR_1  : string  := "true";
       SIZE_MASK_BAR_1 : natural := 18;
       
       IO_SPACE_BAR_2  : string  := "false";
       PREFETCH_BAR_2  : string  := "false";
       SIZE_MASK_BAR_2 : natural := 19;
       
       IO_SPACE_BAR_3  : string  := "false";
       PREFETCH_BAR_3  : string  := "false";
       SIZE_MASK_BAR_3 : natural := 7;
       
       IO_SPACE_BAR_4  : string  := "true";
       PREFETCH_BAR_4  : string  := "false";
       SIZE_MASK_BAR_4 : natural := 5;
       
       IO_SPACE_BAR_5  : string  := "true";
       PREFETCH_BAR_5  : string  := "false";
       SIZE_MASK_BAR_5 : natural := 6      
    );
to the entity. Then add these generics
    generic(
       MEN_VENDOR_ID           : natural := 16#1A88#;
       MEN_DEVICE_ID           : natural := 16#4D45#;
       MEN_REVISION_ID         : natural := 16#0#;
       MEN_CLASS_CODE          : natural := 16#068000#;
       MEN_SUBSYSTEM_VENDOR_ID : natural := 16#9B#;
       MEN_SUBSYSTEM_DEVICE_ID : natural := 16#5A91#;

       MEN_IO_SPACE_BAR_0  : string  := "false";
       MEN_PREFETCH_BAR_0  : string  := "true";
       MEN_SIZE_MASK_BAR_0 : natural := 28;
       
       MEN_IO_SPACE_BAR_1  : string  := "false";
       MEN_PREFETCH_BAR_1  : string  := "true";
       MEN_SIZE_MASK_BAR_1 : natural := 18;
       
       MEN_IO_SPACE_BAR_2  : string  := "false";
       MEN_PREFETCH_BAR_2  : string  := "false";
       MEN_SIZE_MASK_BAR_2 : natural := 19;
       
       MEN_IO_SPACE_BAR_3  : string  := "false";
       MEN_PREFETCH_BAR_3  : string  := "false";
       MEN_SIZE_MASK_BAR_3 : natural := 7;
       
       MEN_IO_SPACE_BAR_4  : string  := "true";
       MEN_PREFETCH_BAR_4  : string  := "false";
       MEN_SIZE_MASK_BAR_4 : natural := 5;
       
       MEN_IO_SPACE_BAR_5  : string  := "true";
       MEN_PREFETCH_BAR_5  : string  := "false";
       MEN_SIZE_MASK_BAR_5 : natural := 6      
    );
to the Hard\_IP\_xy\_core component. Afterwards connect both generics within the generic map of the component Hard\_IP\_xy\_core.
3. Open the file Hard\_IP\_xy\_core.vhd and add the generics desribed above to the entity. Afterwards connect them to the appropriate  
ports of the generic map of the component altpcie\_hip\_pipen1b.
4. Repeat step 3 for the file Hard\_IP\_xy\_core.vho
5. Open the file Hard\_IP\_xy\_plus.vhd and add the same generics as were added to Hard\_IP\_xy.vhd to the entity. Then add these  
generics to the Hard\_IP\_xy component and connect them with the generic map.
6. Copy the Hard\_IP files to /your\_root\_folder/Altera\_src/x1 (see folder description)
7. Copy the BFM files to /your\_root\_folder/16a025-00\_tb/Altera\_src
8. Open the file /your\_root\_folder/16a025-00\_tb/Altera\_src/altpcietb\_bfm\_configure.vhd and add these lines after line 505  
    for i in 0 to 6 loop
       case i is
          when 0 =>
             temp_bar := bars(i);
             temp_bar(31 downto 20) := x"800";
             temp_bar(19 downto 18) := "00";
             bars(i) := temp_bar;
          when 1 =>
             temp_bar := bars(i);
             temp_bar(31 downto 20) := x"900";
             bars(i) := temp_bar;
          when 2 =>
             temp_bar := bars(i);
             temp_bar(31 downto 25) := "1010000";
             bars(i) := temp_bar;
          when 3 =>
             temp_bar := bars(i);
             temp_bar(31 downto 29) := "111";
             bars(i) := temp_bar;
          when 4 => 
             temp_bar := bars(i);
             temp_bar(31 downto 24) := x"00";
             bars(i) := temp_bar;
          when 5 =>
             temp_bar := bars(i);
             -- don't change
          when 6 =>
             temp_bar := bars(i);
             -- don't change
       end case;
    end loop;
Afterwards add the next line after line 392:
    variable temp_bar : std_logic_vector(63 downto 0) := (others => '0');

## How to run the simulation

1. Start Modelsim (prepared with PE 6.6) and open project file

2. Use precompiled libraries from Altera: adopt the path to the libraries by replacing "D:/modelsim\_lib/pe66\_quartus121/" in file build\_all\_a25.do

3. due to PCIe simulation model supports just x1, the A25\_top need to be adopted at instance ip\_16z091\_01\_top: USE\_LANES => "001

4. Select one or more test cases to be executed in file terminal.vhd, below "Start of Tests" by using comments for the others

4. run do file: do build\_all\_a25.do

5. each test case reports an error sum at the end of its execution => if there are no errors, test has passed

CAUTION: be aware that the BFM does issue some error messages which is assumed as normal behavior. These messages typically look  
as follows(with xy being the actual lane number):
    ERROR: TxElecIdle not asserted while reset asserted, Lane: xy, MAC: RP
    ERROR: TxElecIdle not asserted in P1 state, Lane: xy, MAC: RP

Info: Duration of test bench run with all test cases is approximately 50 min on a i7-2620M @ 2.6 GHz running Windows 7 and Modelsim PE 6.6
