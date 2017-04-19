+-----------------------------------------+
| 16x004-00 Bus Functional Model for PCIe |
+-----------------------------------------+
General description:
This simulation model implements root port functionality for PCIe simulation. 


Integration advice:
------------------

This is a short explanation of the constants, functions and procedures provided by the PCIe simulation model.
The simulatin model consists of
   - pcie_sim.vhd
     -> the PLDA BFM is included here
   - pcie_pkg.vhd

----------------------
|    pcie_x1_sim.vhd    |
----------------------
The included BFM provides a x1 lane functionality. As a maximum of 4 BFM instances can be used, the pcie_sim 
entity can be used four times in a component instantiation. Thus the instances can be controlled using 
seperate terminal record connections.

------------------
|    pcie_x1_pkg    |
------------------
constants:
   - use IO_TRANSFER, MEM32_TRANSFER and CONFIG_TRANSFER in tga[1:0] for all terminal procedure calls to define
     the type of transfer that should be executed
   - use BFM_NBR0 ... BFM_NBR_3 in tga[3:2] for all terminal calls to define the BFM instance that should
     execute the transfer
   - use DONT_CHECK32 as reference data value for every read request t should not check the read value
     automatically, the check will be skipped then

functions:
   - calc_last_dw
      @param first_dw first enabled bytes of this transfer
      @param byte_count amount of bytes for this transfer
      @return last_dw(3 downto 0) last enabled bytes for this transfer
      @detail This function takes the first enabled bytes of a transfer and the amount of bytes that should
         be transferred  as arguments and calculates the last byte enables. The return value is
         std_logic_vector(3 downto 0)

procedures:
   - check_val
      @param caller_proc string argument which is used in error messages to define the position where
         this procedure was called from
      @param ref_val 32bit reference value
      @param check_val 32bit value that is checked against ref_val
      @param byte_valid defines which byte of check_val is valid, invalid bytes are not compared
      @return check_ok boolean argument which states whether the check was ok (=true) or not

   - init_bfm
      @param bfm_inst_nbr number of the BFM instance that will be initialized
      @param io_add start address for the BFM internal I/O space
      @param mem32_addr start address for the BFM internal MEM32 space
      @param mem64_addr start address for the BFM internal MEM64 space
      @param requester_id defines the requester ID that is used for every BFM transfer
      @param max_payloadsize defines the maximum payload size for every write request

   - configure_bfm (for record)
      @param cfg_i input record of type cfg_in_type
      @return cfg_o returns record of cfg_out_type

   - configure_bfm
      @param bfm_inst_nbr number of the BFM instance that will be configured
      @param max_payload_size maximum payload size for write requests
      @param max_read_size maximum payload size for read requests
      @param bar0 BAR0 settings
      @param bar1 BAR1 settings
      @param bar2 BAR2 settings
      @param bar3 BAR3 settings
      @param bar4 BAR4 settings
      @param bar5 BAR5 settings
      @param cmd_status_reg settings for the command status register
      @param  ctrl_status_reg settings for the control status register

   - set_bfm_memory
      @param bfm_inst_nbr number of the BFM instance that will be used
      @param nbr_of_dw number of DWORDS that will be written
      @param io_space set to true is I/O space is targeted
      @param mem32 set to true is MEM32 space is targeted, otherwise MEM64 space is used
      @param mem_addr offset for internal memory space, start at x"0000_0000"
      @param start_data_val first data value to write, other values are defined by data_inc
      @param data_inc defines the data increment added to start_data_val for DW 2 to nbr_of_dw

   - get_bfm_memory
      @param bfm_inst_nbr number of the BFM instance that will be used
      @param nbr_of_dw number of DWORDS that will be written
      @param io_space set to true is I/O space is targeted
      @param mem32 set to true is MEM32 space is targeted, otherwise MEM64 space is used
      @param mem_addr offset for internal memory space, start at x"0000_0000"
      @return databuf_out returns a dword_vector that contains all data read from BFM internal memory

   - bfm_wr_io
      @param bfm_inst_nbr number of the BFM instance that will be used
      @param byte_en bytes enables for this transfer
      @param pcie_addr address at DUT to write to
      @param data32 32bit data value to write
      @param wait_end set to true to wait until transfer is finished and check for transfer errors
      @return success returns true if transfer is done and finished without errors (if wait_end = true)

   bfm_rd_io
      @param bfm_inst_nbr number of the BFM instance that will be used
      @param byte_en bytes enables for this transfer
      @param pcie_addr address at DUT to read from
      @param ref_data32 reference data value for read data check, use DONT_CHECK to skip check
      @param wait_end set to true to wait until transfer is finished and check for transfer errors
      @return data32_out 32bit data value returned from read
      @return success returns true if transfer is done and finished without errors (if wait_end = true)

   - bfm_wr_mem32
      @param bfm_inst_nbr number of the BFM instance that will be used
      @param byte_en bytes enables for this transfer
      @param pcie_addr address at DUT to write to
      @param data32 32bit data value to write
      @param wait_end set to true to wait until transfer is finished and check for transfer errors
      @return success returns true if transfer is done and finished without errors (if wait_end = true)

   - bfm_wr_mem32
      @param bfm_inst_nbr number of the BFM instance that will be used
      @param byte_count amount of bytes that shall be transferred
      @param pcie_addr address at DUT to write to
      @param data32 dword_vector that contains all data values to write
      @param t_class defines the traffic class this transfer shall have, use "000" as default
      @param attributes defines the attributes this transfer shall have, use "00" as default
      @param wait_end set to true to wait until transfer is finished and check for transfer errors
      @return success returns true if transfer is done and finished without errors (if wait_end = true)

   - bfm_rd_mem32
      @param bfm_inst_nbr number of the BFM instance that will be used
      @param byte_en bytes enables for this transfer
      @param pcie_addr address at DUT to read from
      @param ref_data32 reference data value for read data check, use DONT_CHECK to skip check
      @param wait_end set to true to wait until transfer is finished and check for transfer errors
      @return data32_out 32bit data value returned from read
      @return success returns true if transfer is done and finished without errors (if wait_end = true)

   - bfm_rd_mem32
      @param bfm_inst_nbr number of the BFM instance that will be used
      @param byte_count amount of bytes that shall be transferred
      @param pcie_addr address at DUT to read from
      @param ref_data32 dword_vector that contains the reference data values for read data check, use DONT_CHECK to skip check
      @param t_class defines the traffic class this transfer shall have, use "000" as default
      @param attributes defines the attributes this transfer shall have, use "00" as default
      @param wait_end set to true to wait until transfer is finished and check for transfer errors
      @return data32_out dword_vector that contains the data values returned from read
      @return success returns true if transfer is done and finished without errors (if wait_end = true)

   - bfm_wr_config
      @param bfm_inst_nbr number of the BFM instance that will be used
      @param byte_en bytes enables for this transfer
      @param pcie_addr address at DUT to write to
      @param data32 32bit data value to write
      @param wait_end set to true to wait until transfer is finished and check for transfer errors
      @return success returns true if transfer is done and finished without errors (if wait_end = true)

   - bfm_rd_config
      @param bfm_inst_nbr number of the BFM instance that will be used
      @param byte_en bytes enables for this transfer
      @param pcie_addr address at DUT to read from
      @param ref_data32 reference data value for read data check, use DONT_CHECK to skip check
      @param wait_end set to true to wait until transfer is finished and check for transfer errors
      @return data32_out 32bit data value returned from read
      @return success returns true if transfer is done and finished without errors (if wait_end = true)







IMPORTANT: add to vsim!! (Path may need adaption)

# Adapt all your paths:
# ---------------------
set modelSimLib "<your path to modelsim_lib.vhd>"     e.g. "../16/16zxy/Testbench/modelsim_lib.vhd"
set pathToBFM "<your path to  16>/16/16x004-00"       e.g. "../../../16/16x004-00"
set pathToPLDAsimlib "<your path to PLDA simlib/PLDA" e.g. "./PLDA"

# adapt your simulation call:
# ---------------------------
vsim < put all your options here> \
-L altera \
-L altera_mf \
-L lpm \
-L sgate \
-L arriagx_hssi \
-L arriaii_hssi \
-L stratixiv_hssi \
-L cycloneiv_hssi \
-L stratixiigx_hssi \
-L phypcs_altera_lib \
-L pciebfm_lib \
-voptargs=+acc \
work.<add your test bench name here>









   - configure_msi
      @param bfm_inst_nbr number of the BFM instance that will be used
      @param msi_allowed number of MSI that are allowed, coded vector as defined by PCIe spec
      @return returns true is the configuration was successful
