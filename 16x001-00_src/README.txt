+--------------------------------+
| 16x001-00 test bench framework |
+--------------------------------+
Description :

Simulation Model of a dynamic internal 64-bit wide RAM with wishbone slave interface for single and burst accesses.

Features:
1. Functions
This sim-model provides the following functions: conf_iram, wr_iram, rd_iram and deallocate_iram.
1.1 conf_iram:       configure the following parameters: startdelay of address and data phase, waitstates of address and data 
                     phase, break delay of address and data phase, enable external waitstate interface
1.2 wr_iram:         write data directly to the IRAM (the wishbone interface will not be used). 
1.3 rd_iram:         read data directly from the IRAM (the wishbone interface will not be used). 
1.4 deallocate_iram: free the memory of the IRAM (clear the whole content). The depth of the RAM is 0 afterwards.

2. Split transactions
The IRAM supports split transactions. Therefore the address phases and the dataphases are seperated (separate acknowledge for address 
phase and for data phase). To use the IRAM for regular transactions (not split transactions) the address acknowledge shall be used as 
acknowledge and all data waitstates have to be configured to 0. 

3. External waitstate interface
When the external waitstate interface is enabled by the conf_iram function, the parameters for start delay, waitstates and break delay 
are not considered. Instead the external waitstate interface is used in the following way. 
3.1 Waitstate for one address / data phase are requested by the iram (*_ws_req = true).
3.2 Number of waitstates is provided to the IRAM (*_ws_in). 
3.3 Waitstate is acknowledged to the IRAM (*_ws_ack = true). 
3.4 Waitstate interface is reset (*_ws_req = false, *_ws_ack = false). 

4. Internal waitstate generation
When the external waitstate interface is disabled by the conf_iram function, the parameters for start delay, waitstates and break delay 
are considered for address and data acknowledge generation. 
4.1 Address startdelay:    The address startdelay is the amount of clock cycles from the time where wishbone strobe and cycle are both 
                           be active till the first rising edge of the address acknowledge (this is usable for single as well as for 
                           burst accesses). The value 0 is invalid for the address startdelay and will be treated as 1. 
4.2 Address waitstates:    The amount of address waitstates represents the amount of clock cycles between a falling edge of wishbone 
                           address acknowledge and the rising edge of wishbone address acknowledge of the next data phase of a burst 
                           (this is usable for burst accesses only). 
4.3 Address break delay:   The address break delay has two parameter for configuration: length and position. The position parameter 
                           specifies the amount of dataphases (of a burst) where the break-delay shall appear. The length-parameter is 
                           comparative with the waitstates (0 = break delay disabled). If the break-delay is enabled (break delay 
                           length > 0) and appears within a burst, no additional waitstates will be produced (even if they are different 
                           from 0).
4.4 Data startdelay:       The data startdelay is the amount of clock cycles from the time where wishbone address acknowledge is active 
                           for the first time till the first rising edge of the data acknowledge (this is usable for single as well as 
                           for burst accesses). The value 0 is valid for the address startdelay. 
4.5 Data waitstates:       The amount of data waitstates represents the amount of clock cycles between a falling edge of wishbone data 
                           acknowledge and the rising edge of wishbone data acknowledge of the next data phase of a burst (this is 
                           usable for burst accesses only). 
4.6 Data break delay:      The address break delay has two parameter for configuration: length and position. The position parameter 
                           specifies the amount of dataphases (of a burst) where the break-delay shall appear. The length-parameter is 
                           comparative with the waitstates (0 = break delay disabled). If the break-delay is enabled (break delay 
                           length > 0) and appears within a burst, no additional waitstates will be produced (even if they are different 
                           from 0).




Generation of acknowledge:

                                   external_ws                                                                                           
                                        |                                                                                                
                +------------+          |                                                                                                
                | Address    |       +-----+         +-------------+                                                                     
                | Waitstate  |------>| MUX |-------->| Address     |-----+-------------------------------------------------------> aack  
                | Generation |       |     |         | Acknowledge |     |                                                               
                +------------+       |     |         | Generation  |     |                                                               
                                     |     |         +-------------+     |                                                               
      ext. address waitstates ------>|     |                             |                                                               
                                     +-----+                             |   +-------------+                                             
                                                                         |   | Data        |                                             
                                                                         +-->| Phase       |                                             
                                                                             | FIFO        |                                             
                                                                             +-------------+                                             
                                                                                 |                                                       
                                                                                 |                                                       
                                                                                 |                                                       
                                   external_ws                                   |                                                       
                                        |                                        |  +-------------+                                      
                +------------+          |                                        +->| Data        |-----+------------------------> ack   
                | Data       |       +-----+                                        | Acknowledge |     |                                
                | Waitstates |------>| MUX |--------------------------------------->| Generation  |     |                                
                | Generation |       |     |                                        +-------------+     |                                
                +------------+       |     |                                                            |                                
                                     |     |                                                            |   +-------------+              
         ext. data waitstates ------>|     |                                        +-------------+     +-->| Process     |------> dat_o 
                                     +-----+                                        | Internal    |         | Data        |              
                                                                                    | Memory      |<--------| Phase       |<------ dat_i 
                                                                                    |             |         +-------------+              
                                                                                    +-------------+                                      
                                                                                                                          

