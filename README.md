# A25_VME Testbench
VHDL source for A25 simulation environment and test cases

Contents of this repository:

16x001-00_src: Simulation Model of a dynamic 32-bit wide RAM with wishbone slave interface for single and burst accesses.

16x004-00_src: PCIe x1 master simulation model

16x010-00_src:	Helper functions for simulation environment

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
        	pciebfm0_trans.txt		Access log of PCIe simulation model
                  

How to run the simulation:

1) Start Modelsim (prepared with PE 6.6) and open project file

2) Use precompiled libraries from Altera: adopt the path to the libraries by replacing "D:/modelsim_lib/pe66_quartus121/" in file build_all_a25.do

3) due to PCIe simulation model supports just x1, the A25_top need to be adopted at instance ip_16z091_01_top: USE_LANES => "001

4) Select one or more test cases to be executed in file terminal.vhd, below "Start of Tests" by using comments for the others

4) run do file: do build_all_a25.do

5) each test case reports an error sum at the end of its execution => if there are no errors, test has passed

Info: Duration of test bench run with all test cases is approximately 50 min on a i7-2620M @ 2.6 GHz running Windows 7 and Modelsim PE 6.6
