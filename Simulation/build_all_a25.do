## Altera Simulation Libraries:
##
vmap lpm D:/modelsim_lib/pe66_quartus121/lpm
vmap altera_mf D:/modelsim_lib/pe66_quartus121/altera_mf
vmap cycloneiv D:/modelsim_lib/pe66_quartus121/cycloneiv
vmap altera D:/modelsim_lib/pe66_quartus121/altera
vmap altera_mf D:/modelsim_lib/pe66_quartus121/altera_mf
vmap cycloneiv D:/modelsim_lib/pe66_quartus121/cycloneiv
vmap cycloneiv_hssi D:/modelsim_lib/pe66_quartus121/cycloneiv_hssi
vmap sgate D:/modelsim_lib/pe66_quartus121/sgate
vmap lpm D:/modelsim_lib/pe66_quartus121/lpm
vmap cycloneiv_pcie_hip D:/modelsim_lib/pe66_quartus121/cycloneiv_pcie_hip

## PLDA Simulation Libraries:
##
vmap pciebfm_lib ../16x004-00_src/Source/PLDA_BFM/modelsim/pciebfm_lib
vcom -force_refresh -work pciebfm_lib
# vcom -force_refresh -work phypcs_altera_lib

## Packages and Simulation Models
##
vcom -work work -2002 ../../16a025-00_src/16z000-00_src/Source/fpga_pkg_2.vhd

vcom -work work -2002 -explicit ../16x010-00_src/Source/conversions.vhd
vcom -work work -2002 -explicit ../16x010-00_src/Source/print_pkg.vhd
vcom -work work -2002 -explicit ../16x001-00_src/Source/iram32_pkg.vhd             
vcom -work work -2002 -explicit ../Testbench/vme_sim_pack.vhd
vcom -work work -2002 -explicit ../16x004-00_src/Source/utils_pkg.vhd             
vcom -work work -2002 -explicit ../16x004-00_src/Source/types_pkg.vhd             
vcom -work work -2002 -explicit ../16x004-00_src/Source/pcie_x1_pkg.vhd
vcom -work work -2002 -explicit ../Testbench/terminal_pkg.vhd
vcom -work work -2002 -explicit ../16x004-00_src/Source/pcie_x1_sim.vhd
vcom -work work -2002 -explicit ../16x001-00_src/Source/iram32_sim.vhd             

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
vcom -work work -2002 ../../16a025-00_src/16z126-01_src/Source/z126_01_pasmi/z126_01_pasmi_m25p32.vhd

# iram
vcom -work work -2002 ../../16a025-00_src/16z024-01_src/Source/iram_wb.vhd
vcom -work work -2002 ../../16a025-00_src/16z024-01_src/Source/iram_av.vhd



## vme
vcom -work work -2002 ../../16a025-00_src/16z002-01_src/Source/vme_pkg.vhd
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
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/x1/Hard_IP_x1_examples/common/testbench/altpcie_rs_serdes.vhd      
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/x1/Hard_IP_x1_examples/common/testbench/altpcie_pll_100_250.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/x1/Hard_IP_x1_examples/common/testbench/altpcie_pll_125_250.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/x1/Hard_IP_x1_core.vho



## pcie2wbb
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/src_utils_pkg.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/pcie_msi.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/alt_reconf/alt_reconf.vhd 
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/generic_dcfifo_mixedw.vhd
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
vcom -2002 ../../16a025-00_src/16z091-01_src/Source/ip_16z091_01_top.vhd


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
vcom -2002 ../../16a025-00_src/Source/pll_pcie/pll_pcie.vhd
vcom -2002 ../../16a025-00_src/Source/sram.vhd
vcom -2002 ../../16a025-00_src/Source/A25_top.vhd


## Testbench
vcom -2002 ../Testbench/SN74LVTH245.vhd
vcom -2002 ../Testbench/SN74ABT125.vhd
vcom -2002 ../Testbench/mt58l512l18f.vhd

vcom -2002 ../Testbench/terminal.vhd
vcom -2002 ../Testbench/vme_sim_mon.vhd
vcom -2002 ../Testbench/vme_sim_mstr.vhd
vcom -2002 ../Testbench/vme_sim_slave.vhd
vcom -2002 ../Testbench/vmebus.vhd

vcom -2002 ../Testbench/a25_tb.vhd

vsim -t fs  \
-L altera \
-L altera_mf \
-L lpm \
-L sgate \
-L cycloneiv_hssi \
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
