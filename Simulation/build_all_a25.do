## Altera Simulation Libraries:
##
# set paths for library compilation out of quartus files
set PathToQuartus $env(QUARTUS_ROOTDIR)
set PathToOldQuartus C:/altera/12.1/quartus

# manage paths for libraries and working directory for easy adaption
set vsimversion [regsub -all { } [vsim -version] ""]
set libdir  "lib/$vsimversion"
set workdir "lib/$vsimversion/work"

# create working directory if not present yet
if {![file isdirectory $workdir]} {
   puts "VSIM_COMPILE: creating working library"
   file mkdir $workdir
   vlib $workdir
   vmap work $workdir
}

# compile libraries
if [file exists "$libdir\\libs"] {
} else {file mkdir "$libdir\\libs"}

if {![file isdirectory "$libdir/libs/altera"]} {
   vlib "$libdir/libs/altera"
   vmap altera "$libdir/libs/altera"
   vcom -work altera \
      $PathToQuartus/eda/sim_lib/altera_europa_support_lib.vhd \
      $PathToQuartus/eda/sim_lib/altera_primitives_components.vhd \
      $PathToQuartus/eda/sim_lib/altera_primitives.vhd
}

if {![file isdirectory "$libdir/libs/altera_mf"]} {
   vlib "$libdir/libs/altera_mf"
   vmap altera_mf "$libdir/libs/altera_mf"
   vcom -work altera_mf \
      $PathToQuartus/eda/sim_lib/altera_mf_components.vhd \
      $PathToQuartus/eda/sim_lib/altera_mf.vhd
}

if {![file isdirectory "$libdir/libs/lpm"]} {
   vlib "$libdir/libs/lpm"
   vmap lpm "$libdir/libs/lpm"
   vcom -93 -quiet -work lpm \
     $PathToQuartus/eda/sim_lib/220pack.vhd \
     $PathToQuartus/eda/sim_lib/220model.vhd
}
if {![file isdirectory "$libdir/libs/sgate"]} {
   vlib "$libdir/libs/sgate"
   vmap sgate "$libdir/libs/sgate"
   vcom -93 -quiet -work sgate \
      $PathToQuartus/eda/sim_lib/sgate_pack.vhd \
      $PathToQuartus/eda/sim_lib/sgate.vhd
}
if {![file isdirectory "$libdir/libs/cycloneii"]} {
   vlib "$libdir/libs/cycloneii"
   vmap cycloneii "$libdir/libs/cycloneii"
   vcom -work cycloneii \
      $PathToOldQuartus/eda/sim_lib/cycloneii_atoms.vhd \
      $PathToOldQuartus/eda/sim_lib/cycloneii_components.vhd
}
if {![file isdirectory "$libdir/libs/cycloneiv"]} {
   vlib "$libdir/libs/cycloneiv"
   vmap cycloneiv "$libdir/libs/cycloneiv"
   vcom -93 -quiet -work cycloneiv \
     $PathToQuartus/eda/sim_lib/cycloneiv_atoms.vhd \
     $PathToQuartus/eda/sim_lib/cycloneiv_components.vhd
}
if {![file isdirectory "$libdir/libs/cycloneiv_hssi"]} {
   vlib "$libdir/libs/cycloneiv_hssi"
   vmap cycloneiv_hssi "$libdir/libs/cycloneiv_hssi"
   vcom -93 -quiet -work cycloneiv_hssi \
      $PathToQuartus/eda/sim_lib/cycloneiv_hssi_components.vhd \
      $PathToQuartus/eda/sim_lib/cycloneiv_hssi_atoms.vhd
}
if {![file isdirectory "$libdir/libs/cycloneiv_pcie_hip"]} {
   vlib "$libdir/libs/cycloneiv_pcie_hip"
   vmap cycloneiv_pcie_hip "$libdir/libs/cycloneiv_pcie_hip"
   vcom -93 -quiet -work cycloneiv_pcie_hip \
      $PathToQuartus/eda/sim_lib/cycloneiv_pcie_hip_components.vhd \
      $PathToQuartus/eda/sim_lib/cycloneiv_pcie_hip_atoms.vhd 
}
if {![file isdirectory "$libdir/libs/arriagx_hssi"]} {
   vlib "$libdir/libs/arriagx_hssi"
   vmap arriagx_hssi "$libdir/libs/arriagx_hssi"
   vcom -93 -quiet -work arriagx_hssi \
      $PathToOldQuartus/eda/sim_lib/arriagx_hssi_components.vhd \
      $PathToOldQuartus/eda/sim_lib/arriagx_hssi_atoms.vhd
}
if {![file isdirectory "$libdir/libs/arriagx"]} {
   vlib "$libdir/libs/arriagx"
   vmap arriagx "$libdir/libs/arriagx"
   vcom -93 -quiet -work arriagx \
      $PathToOldQuartus/eda/sim_lib/arriagx_atoms.vhd \
      $PathToOldQuartus/eda/sim_lib/arriagx_components.vhd
}
if {![file isdirectory "$libdir/libs/arriaii_hssi"]} {
   vlib "$libdir/libs/arriaii_hssi"
   vmap arriaii_hssi "$libdir/libs/arriaii_hssi"
   vcom -93 -quiet -work arriaii_hssi \
      $PathToQuartus/eda/sim_lib/arriaii_hssi_components.vhd \
      $PathToQuartus/eda/sim_lib/arriaii_hssi_atoms.vhd
}
if {![file isdirectory "$libdir/libs/stratixiv_hssi"]} {
   vlib "$libdir/libs/stratixiv_hssi"
   vmap stratixiv_hssi "$libdir/libs/stratixiv_hssi"
   vcom -93 -quiet -work stratixiv_hssi \
      $PathToQuartus/eda/sim_lib/stratixiv_hssi_components.vhd \
      $PathToQuartus/eda/sim_lib/stratixiv_hssi_atoms.vhd
}
if {![file isdirectory "$libdir/libs/stratixiigx_hssi"]} {
   vlib "$libdir/libs/stratixiigx_hssi"
   vmap stratixiigx_hssi "$libdir/libs/stratixiigx_hssi"
   vcom -93 -quiet -work stratixiigx_hssi \
      $PathToOldQuartus/eda/sim_lib/stratixiigx_hssi_components.vhd \
      $PathToOldQuartus/eda/sim_lib/stratixiigx_hssi_atoms.vhd 
}


## Packages and Simulation Models
##
# only recompile unchanged sources if necessary, checking one folder should be enough
# recompiling Altera BFM sources is time consuming
if {![file isdirectory "$libdir/work/fpga_pkg_2"]} {
   vcom -work work -2002 ../../16a025-00_src/16z000-00_src/Source/fpga_pkg_2.vhd

   vcom -work work -2002 -explicit ../16x010-00_src/Source/conversions.vhd
   vcom -work work -2002 -explicit ../16x010-00_src/Source/print_pkg.vhd
   vcom -work work -2002 -explicit ../16x001-00_src/Source/iram32_pkg.vhd
   vcom -work work -2002 -explicit ../Testbench/vme_sim_pack.vhd
   vcom -work work -2002 -explicit ../16x001-00_src/Source/iram32_sim.vhd

   # PCIe BFM
   vcom -work work -2008 ../Altera_src/altpcietb_bfm_common.vhd
   vcom -work work -2008 ../Altera_src/altpcietb_bfm_constants.vhd
   vcom -work work -2008 ../Altera_src/altpcietb_bfm_log.vhd
   vcom -work work -2008 ../Altera_src/altpcietb_bfm_shmem.vhd
   vcom -work work -2008 ../Altera_src/altpcietb_bfm_req_intf.vhd
   vcom -work work -2008 ../Altera_src/altpcietb_bfm_rdwr.vhd
   vcom -work work -2008 ../Altera_src/altpcietb_bfm_configure.vhd
   vcom -work work -2008 ../Altera_src/altpcietb_pipe_xtx2yrx.vhd
   vcom -work work -2008 ../Altera_src/altpcietb_pipe_phy.vhd
   vcom -work work -2008 ../Altera_src/altpcietb_bfm_rp_top_x8_pipen1b.vhd
   vcom -work work -2008 ../Altera_src/altpcietb_bfm_rpvar_64b_x8_gen1_pipen1b.vho
   vcom -work work -2008 ../Altera_src/altpcietb_bfm_rpvar_64b_x8_gen2_pipen1b.vho
   vcom -work work -2008 ../Altera_src/altpcietb_bfm_vc_intf.vhd
}

vcom -work work -2008 ../16x004-01_src/Source/utils_pkg.vhd
vcom -work work -2008 ../16x004-01_src/Source/types_pkg.vhd
vcom -work work -2008 ../16x004-01_src/Source/pcie_sim_pkg.vhd
vcom -work work -2008 -explicit ../Testbench/terminal_pkg.vhd
vcom -work work -2008 ../16x004-01_src/Source/pcie_sim.vhd

## DUT Source
##
# remote update
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_pkg.vhd
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_ru_ctrl.vhd
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_ru_ctrl_cyc5.vhd
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_ru/z126_01_ru_cycloneiv.vhd
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_wbmon.vhd
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_wb2pasmi.vhd
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_wb_pkg.vhd
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_wb_if_arbiter.vhd
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_top.vhd
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_indi_if_ctrl_regs.vhd
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_fifo_d1.vhd
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_clk_trans_wb2wb.vhd
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_switch_fab_2.vhd

# compile special files for simulation
vcom -work work -2002 ../../16a025-00_tb/Testbench/m25p32/mem_util_pkg.vhd
vcom -work work -2002 ../../16a025-00_tb/Testbench/m25p32/internal_logic.vhd     
vcom -work work -2002 ../../16a025-00_tb/Testbench/m25p32/memory_access.vhd      
vcom -work work -2002 ../../16a025-00_tb/Testbench/m25p32/acdc_check.vhd         
vcom -work work -2002 ../../16a025-00_tb/Testbench/m25p32/m25p32.vhd 
vcom -work work -2002 ../../16a025-00_tb/Testbench/z126_01_pasmi_m25p32_sim.vhd
vcom -work work -2002 ../../16a025-00_tb/Testbench/z126_01_altremote_update_sim_model.vhd

# iram
vcom -work work -2002 ../../16a025-00_src/16z024-01_src/Source/iram_acex.vhd
vcom -work work -2002 ../../16a025-00_src/16z024-01_src/Source/iram.vhd
vcom -work work -2002 ../../16a025-00_src/16z024-01_src/Source/iram_arriagx.vhd
vcom -work work -2002 ../../16a025-00_src/16z024-01_src/Source/iram_cyc2.vhd
vcom -work work -2002 ../../16a025-00_src/16z024-01_src/Source/iram_cyc3.vhd
vcom -work work -2002 ../../16a025-00_src/16z024-01_src/Source/iram_cyc4.vhd
vcom -work work -2002 ../../16a025-00_src/16z024-01_src/Source/iram_wb.vhd
vcom -work work -2002 ../../16a025-00_src/16z024-01_src/Source/iram_av.vhd



## vme
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_pkg.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/fifo_256x32bit.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_dma_arbiter.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_dma_au.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_dma_du.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_dma_fifo.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_dma_mstr.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_dma_slv.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_dma.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_arbiter.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_sys_arbiter.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_au.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_bustimer.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_ctrl.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_du.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_locmon.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_mailbox.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_master.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_requester.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_slave.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_wbm.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_wbs.vhd
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/wbb2vme_top.vhd

# pcie core simulation files
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/x1/Simulation/altpcie_rs_serdes.vhd
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/x1/Simulation/altpcie_pll_100_250.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/x1/Simulation/altpcie_pll_125_250.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/x1/Simulation/Hard_IP_x1_core.vho
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/x4/Simulation/Hard_IP_x4_core.vho



## pcie2wbb
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/src_utils_pkg.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/generic_dcfifo_mixedw.vhd
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/pcie_msi.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/alt_reconf.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/rx_len_cntr.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/rx_get_data.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/rx_ctrl.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/rx_module.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/z091_01_wb_master.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/error.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/tx_put_data.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/tx_compl_timeout.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/tx_ctrl.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/tx_module.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/init.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/z091_01_wb_slave.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/interrupt_core.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/interrupt_wb.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/ip_16z091_01.vhd 
vcom -2002 ../../16a025-00_src/Source/z091_01_wb_adr_dec.vhd
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/x1/Hard_IP_x1_serdes.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/x1/Hard_IP_x1.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/x4/Hard_IP_x4_serdes.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/x4/Hard_IP_x4.vhd 
vcom -2008 ../Testbench/ip_16z091_01_top_sim.vhd


# 16z100
vcom -work work -93 ../../16a025-00_src/Source/wb_pkg.vhd
vcom -work work -93 ../../16a025-00_src/16z100-00_src/Source/switch_fab_1.vhd
vcom -work work -93 ../../16a025-00_src/16z100-00_src/Source/switch_fab_2.vhd
vcom -work work -93 ../../16a025-00_src/16z100-00_src/Source/switch_fab_3.vhd
vcom -work work -93 ../../16a025-00_src/16z100-00_src/Source/switch_fab_4.vhd
vcom -work work -93 ../../16a025-00_src/16z100-00_src/Source/wbmon.vhd
vcom -work work -93 ../../16a025-00_src/16z100-00_src/Source/fifo_d1.vhd
vcom -work work -93 ../../16a025-00_src/16z100-00_src/Source/clk_trans_wb2wb.vhd
vcom -work work -93 ../../16a025-00_src/Source/wb_bus.vhd




## Toplevel
vcom -2008 ../../16a025-00_src/Source/pll_pcie.vhd
vcom -2008 ../../16a025-00_src/Source/sram.vhd
vcom -2008 ../Testbench/a25_top_sim.vhd


## Testbench
vcom -2002 ../Testbench/SN74LVTH245.vhd
vcom -2002 ../Testbench/SN74ABT125.vhd
vcom -2002 ../Testbench/MT58L512L18F.vhd

vcom -2002 ../Testbench/terminal.vhd
vcom -2002 ../Testbench/vme_sim_mon.vhd
vcom -2002 ../Testbench/vme_sim_mstr.vhd
vcom -2002 ../Testbench/vme_sim_slave.vhd
vcom -2002 ../Testbench/vmebus.vhd

vcom -2008 ../Testbench/a25_tb.vhd

vsim -t fs  \
-L altera \
-L altera_mf \
-L lpm \
-L sgate \
-L arriagx_hssi \
-L arriaii_hssi \
-L stratixiv_hssi \
-L cycloneiv_hssi \
-L stratixiigx_hssi \
-L pciebfm_lib \
-voptargs=+acc \
-l test_report.txt\
work.a25_tb_conf 

add wave sim:/a25_tb/a25/*
add wave sim:/a25_tb/a25/vme/vmedma/*
add wave sim:/a25_tb/a25/vme/vmedma/dma_mstr/*
add wave sim:/a25_tb/a25/vme/vmectrl/du/*
add wave sim:/a25_tb/a25/vme/vmectrl/au/*
add wave sim:/a25_tb/a25/vme/vmectrl/bustimer/*
add wave sim:/a25_tb/a25/vme/vmectrl/master/*
add wave sim:/a25_tb/a25/vme/vmectrl/requester/*
add wave sim:/a25_tb/a25/vme/vmectrl/arbiter/*
add wave sim:/a25_tb/vme_bus/*
add wave sim:/a25_tb/vme_bus/vmesimmstr/*
run -all
