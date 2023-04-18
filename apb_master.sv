//------------------------------------------------------------------------------
//--                                                                 
//-- Copyright (c) 2016
//-- Cientra LLC 													Cientra 
//-- All Rights Reserved
//--                                                                 
//-- This work may not be copied, modified, uploaded, executed, re-published
//-- or distributed in any way, in any medium, whether in whole or in part,                                                                
//-- without prior written permission from Cientra LLC, New Jersey USA.
//-- 
//------------------------------------------------------------------------------
//-- Product Name : APB Master Bridge
//-- Copyright (C) Cientra TechSolution Pvt Ltd
//-- Proprietary and confidential to Cientra TechSolution Pvt Ltd.
//--                                                              
//--               File: apb_master
//--           Revision: 1.0
//--       Date Created:17/04/2023
//--             Author: Mahesh N
//--           Function: APB as Master
//--                                                          
//--           Generics: Size    =
//--                     Timing  =
//--                     Bus Width =
//--                                                                       
//-- Reference Material: 
//-- 
//-- Instanciated In:
//--                                                                  
//--       Verification: No
//--       Code Review : No
//--      Certification: No
//--                                                              
//-- Comments: (Synthesis specific)
//-- 
//------------------------------------------------------------------------------
//--                              Specification                
//-- 
//-- 
//-- 
//-- 
//------------------------------------------------------------------------------
//--                         Revision History                
//--                                                        
//-- Revision        
//-- No.      	Date   		Engineer        Description         
//-- -------- ----------- --------------- --------------------------------------
//-- 1.0                    Mahesh N          	Initial release
//------------------------------------------------------------------------------
//--
 
module apb_master(
     input logic [8:0]apb_write_paddr,apb_read_paddr,// where you read and write
     input logic [7:0] apb_write_data,PRDATA,//write data to send slave and PRDATA Recieved from Slave
     input logic PRESETn,PCLK,READ_WRITE,transfer,PREADY,
     output logic PSEL1,PSEL2, // for 0-255 PSEL1 and 256-511 SEL2
     output logic PENABLE,//ENABLE Happens when read opertions occurs that is after PSEL is asserted
     output logic [8:0]PADDR,//ADDr where your into your slave
     output logic PWRITE,//Tells whether writing or reading is taking place based on READ_WRITE
     output logic [7:0]PWDATA,apb_read_data_out,//PWDATA to be written on the slave and read data out from slave
     output logic PSLVERR // Slave error that occurs
 );
     // integer i,count;
     //logic [2:0] state, next_state;
     logic invalid_setup_error,setup_error,invalid_read_paddr,invalid_write_paddr,invalid_write_data;
     
    typedef enum{IDLE,SETUP,ENABLE}state;

    state cur_state,next_state;

     always_ff@(posedge PCLK)
     begin
         if(!PRESETn)
             cur_state <= IDLE;
         else
             cur_state <= next_state;
     end
     
     always_comb
     begin
         if(!PRESETn)
             next_state = IDLE;
         else
         begin
             PWRITE = ~READ_WRITE;
             case(cur_state)
                 IDLE:
                     begin
                         PENABLE =0;
                         if(!transfer)
                             next_state = IDLE ;
                         else
                             next_state = SETUP;
                     end
                 
                 SETUP:
                     begin
                         PENABLE =0;
                         if(READ_WRITE)
                         begin
                             PADDR = apb_read_paddr;
                         end

                         else
                         begin
                             PADDR = apb_write_paddr;
                             PWDATA = apb_write_data;
                         end
                         
                         if(transfer && !PSLVERR)
                             next_state = ENABLE;
                         else
                             next_state = IDLE;
                     end
                 
                 ENABLE:
                     begin
                         if(PSEL1 || PSEL2)
                             PENABLE =1;
                         if(transfer & !PSLVERR)
                         begin
                             if(PREADY)
                             begin
                                 if(!READ_WRITE)
                                 begin
                                     next_state = SETUP; 
                                 end
                                 else
                                 begin
                                     next_state = SETUP;
                                     apb_read_data_out = PRDATA;
                                 end
                             end
                             else next_state = ENABLE;
                         end
                         else next_state = IDLE;
                     end
                 default: next_state = IDLE;
             endcase
         end
     end
     
     assign {PSEL1,PSEL2} = ((cur_state != IDLE) ? (PADDR[8] ? {1'b0,1'b1} : {1'b1,1'b0}) : 2'd0);
     
     // PSLVERR LOGIC
     always_comb
     begin
         if(!PRESETn)
         begin
             setup_error =0;
             invalid_read_paddr = 0;
             invalid_write_paddr = 0;
             invalid_write_data =0 ;
         end
         
         else
         begin
             begin
                 if(cur_state == IDLE && next_state == ENABLE)
                     setup_error = 1;
                 else
                     setup_error = 0;
             end
             
             begin
                 if((apb_write_data===8'dx) && (!READ_WRITE) && (cur_state==SETUP || cur_state==ENABLE))
                     invalid_write_data =1;
                 else
                     invalid_write_data = 0;
             end
             
             begin
                 if((apb_read_paddr===9'dx) && READ_WRITE && (cur_state==SETUP || cur_state==ENABLE))
                     invalid_read_paddr = 1;
                 else
                     invalid_read_paddr = 0;
             end
             
             begin
                 if((apb_write_paddr===9'dx) && (!READ_WRITE) && (cur_state==SETUP || cur_state==ENABLE))
                     invalid_write_paddr =1;
                 else
                     invalid_write_paddr =0;
             end
             
             begin
                 if(cur_state == SETUP)
                 begin
                     if(PWRITE)
                     begin
                         if(PADDR==apb_write_paddr && PWDATA==apb_write_data)
                             setup_error=1'b0;
                         else
                             setup_error=1'b1;
                     end
                     
                     else
                     begin
                         if (PADDR==apb_read_paddr)
                             setup_error=1'b0;
                         else
                             setup_error=1'b1;
                     end
                 end
                 else
                     setup_error=1'b0;
             end
         end
         
         invalid_setup_error = setup_error ||  invalid_read_paddr || invalid_write_data || invalid_write_paddr  ;
     end
     
     assign PSLVERR =  invalid_setup_error ;
 endmodule
