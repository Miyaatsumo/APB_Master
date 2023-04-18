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
//-- Product Name : 
//-- Copyright (C) Cientra TechSolution Pvt Ltd
//-- Proprietary and confidential to Cientra TechSolution Pvt Ltd.
//--                                                              
//--               File: 
//--           Revision: 1.0
//--       Date Created:
//--             Author: 
//--           Function: 
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
module ram_as_slave(
    input  logic PCLK,PRESETn,
    input  logic PSEL,PENABLE,PWRITE,
    input  logic [7:0]PADDR,PWDATA,
    output logic [7:0]PRDATA,
    output logic PREADY
);
    logic [7:0]reg_addr;
    logic [7:0] mem [0:31];
    
    assign PRDATA =  mem[reg_addr];
    
    always_comb
    begin
        if(!PRESETn)
            PREADY = 0;
        
        else
        begin
            if(PSEL && !PENABLE && !PWRITE)
                PREADY = 0;
            
            else if(PSEL && PENABLE && !PWRITE)
            begin
                PREADY = 1;
                reg_addr =  PADDR;
            end
            
            else if(PSEL && !PENABLE && PWRITE)
                PREADY = 0;
            
            else if(PSEL && PENABLE && PWRITE)
            begin
                PREADY = 1;
                mem[PADDR] = PWDATA;
            end
            else PREADY = 0;
        end
    end
endmodule
