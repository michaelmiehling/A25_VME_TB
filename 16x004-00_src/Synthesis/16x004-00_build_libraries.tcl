global env

## set path to Quartus install dir: "C:/altera/11.0/quartus"
set PathToQuartus $env(QUARTUS_ROOTDIR)
## set path to Riviera PRO: "C:/Aldec/Riviera-PRO-2011.06-x64"
set simulator_root $env(ALDEC_PATH)
## set path to modelsim_lib
set modelSimLib "../Testbench2"
## set path to 16x004-00 BFM
set pathToBFM "../../../16/16x004-00"
## set path to PLDA simulation library
set pathToPLDAsimlib "./PLDA"
set force_lib_compile 0

## 0 = RivieraPRO, 1 = ModelSim
if {[string compare [lindex $tmp_list 2] "ModelSim"] == 0} {
   set ModelSim 1
} else {
   set ModelSim 0
}

## if an Altera simulator is used no Altera libraries must be compiled
if {[string compare [lindex $tmp_list 3] "ALTERA"] == 0} {
   set setup_altera_lib 0
} else {
   set setup_altera_lib 1
}

## quit current simulation
if {$ModelSim} {
   quit -sim
} else {
   endsim;
   clear;
}

#># define library and work directory structure -----------------------------------------------
set  vsimversion [regsub -all { } [vsim -version] ""]
set  libdir  "lib/$vsimversion"
set  workdir  "lib/$vsimversion/work"
#<#

#># compile sources and test bench ------------------------------------------------------------

#># create directory work ---------------------------------------------------------------------
if {![file isdirectory $workdir]} {
   echo "Creating Library Work"
   file mkdir $workdir
   vlib $workdir
   vmap work $workdir
}
#<# -------------------------------------------------------------------------------------------

#># setup Altera libs if necessary ------------------------------------------------------------
if {$setup_altera_lib} {
   if [file exists "$libdir\\libs"] {
   } else {file mkdir "$libdir\\libs"}
   
   if {![file isdirectory "$libdir/libs/altera"] || $force_lib_compile} {
      vlib "$libdir/libs/altera"
      vmap altera "$libdir/libs/altera"
      vcom -work altera $PathToQuartus/eda/sim_lib/altera_europa_support_lib.vhd
   }
   
   if {![file isdirectory "$libdir/libs/altera_mf"] || $force_lib_compile} {
      vlib "$libdir/libs/altera_mf"
      vmap altera_mf "$libdir/libs/altera_mf"
      vcom -work altera_mf \
         $PathToQuartus/eda/sim_lib/altera_mf_components.vhd \
         $PathToQuartus/eda/sim_lib/altera_mf.vhd
   }
      
   if {![file isdirectory "$libdir/libs/lpm"] || $force_lib_compile} {
      vlib "$libdir/libs/lpm"
      vmap lpm "$libdir/libs/lpm"
      vcom -93 -quiet -work lpm \
        $PathToQuartus/eda/sim_lib/220pack.vhd \
        $PathToQuartus/eda/sim_lib/220model.vhd
   }
  
   if {![file isdirectory "$libdir/libs/sgate"] || $force_lib_compile} {
      vlib "$libdir/libs/sgate"
      vmap sgate "$libdir/libs/sgate"
      vcom -93 -quiet -work sgate \
         $PathToQuartus/eda/sim_lib/sgate_pack.vhd \
         $PathToQuartus/eda/sim_lib/sgate.vhd
   }
      
   if {![file isdirectory "$libdir/libs/arriagx_hssi"] || $force_lib_compile} {
      vlib "$libdir/libs/arriagx_hssi"
      vmap arriagx_hssi "$libdir/libs/arriagx_hssi"
      vcom -93 -quiet -work arriagx_hssi \
         $PathToQuartus/eda/sim_lib/arriagx_hssi_components.vhd \
         $PathToQuartus/eda/sim_lib/arriagx_hssi_atoms.vhd
   }
   
   if {![file isdirectory "$libdir/libs/arriaii_hssi"] || $force_lib_compile} {
      vlib "$libdir/libs/arriaii_hssi"
      vmap arriaii_hssi "$libdir/libs/arriaii_hssi"
      vcom -93 -quiet -work arriaii_hssi \
         $PathToQuartus/eda/sim_lib/arriaii_hssi_components.vhd \
         $PathToQuartus/eda/sim_lib/arriaii_hssi_atoms.vhd
   }
   
   if {![file isdirectory "$libdir/libs/stratixiv_hssi"] || $force_lib_compile} {
      vlib "$libdir/libs/stratixiv_hssi"
      vmap stratixiv_hssi "$libdir/libs/stratixiv_hssi"
      vcom -93 -quiet -work stratixiv_hssi \
         $PathToQuartus/eda/sim_lib/stratixiv_hssi_components.vhd \
         $PathToQuartus/eda/sim_lib/stratixiv_hssi_atoms.vhd
   }
   
   if {![file isdirectory "$libdir/libs/cycloneiv_hssi"] || $force_lib_compile} {
      vlib "$libdir/libs/cycloneiv_hssi"
      vmap cycloneiv_hssi "$libdir/libs/cycloneiv_hssi"
      vcom -93 -quiet -work cycloneiv_hssi \
         $PathToQuartus/eda/sim_lib/cycloneiv_hssi_components.vhd \
         $PathToQuartus/eda/sim_lib/cycloneiv_hssi_atoms.vhd
   }
      
   if {![file isdirectory "$libdir/libs/stratixiigx_hssi"] || $force_lib_compile} {
      vlib "$libdir/libs/stratixiigx_hssi"
      vmap stratixiigx_hssi "$libdir/libs/stratixiigx_hssi"
      vcom -93 -quiet -work stratixiigx_hssi \
         $PathToQuartus/eda/sim_lib/stratixiigx_hssi_components.vhd \
         $PathToQuartus/eda/sim_lib/stratixiigx_hssi_atoms.vhd 
   }

   puts "..prepare ALTERA PHYPCS library"
#   vmap phypcs_altera_lib "./PLDA/modelsim/phypcs_altera_lib"
   vmap phypcs_altera_lib "$pathToPLDAsimlib/modelsim/phypcs_altera_lib"
   vcom -force_refresh -work phypcs_altera_lib
}
#<# -------------------------------------------------------------------------------------------

#># setup modelsim_lib with own vhd file to implement signal spy functionality in RivieraPRO --
if {!$ModelSim} {
   if {![file isdirectory "$libdir/libs/modelsim_lib"] || $force_lib_compile} {
      vlib "$libdir/libs/modelsim_lib"
      vmap modelsim_lib "$libdir/libs/modelsim_lib"
#      vcom -work modelsim_lib ../Testbench_2/modelsim_lib.vhd
      vcom -work modelsim_lib $modelSimLib/modelsim_lib.vhd
   }
}
#<# -------------------------------------------------------------------------------------------

#># setup PLDA libraries ----------------------------------------------------------------------
if {![file isdirectory "$libdir/libs/pciebfm_lib"] || $force_lib_compile} {
   if {$ModelSim} {
      puts "Creating PLDA BFM library for ModelSim"
#      vmap pciebfm_lib "../../../16/16x004-00/Source/PLDA_BFM/modelsim/pciebfm_lib"
      vmap pciebfm_lib "$pathToBFM/Source/PLDA_BFM/modelsim/pciebfm_lib"
      vcom -force_refresh -work pciebfm_lib
   } else {
      puts "Creating PLDA BFM library for Aldec"
      vlib "libs/pciebfm_lib"
      vmap pciebfm_lib "libs/pciebfm_lib"
#      vcom -93 -relax -work pciebfm_lib "../../../16/16x004-00/Source/PLDA_BFM/aldec/pciebfm_lib.vhdp"
      vcom -93 -relax -work pciebfm_lib "$pathToBFM/Source/PLDA_BFM/aldec/pciebfm_lib.vhdp"
   }
}
#<# -------------------------------------------------------------------------------------------
