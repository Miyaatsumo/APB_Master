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
module apb_top(
    input  logic PCLK,PRESETn,transfer,READ_WRITE,
    input  logic [8:0] apb_write_paddr,
    input  logic [7:0]apb_write_data,
    input  logic [8:0] apb_read_paddr,
    output logic PSLVERR,
    output logic [7:0] apb_read_data_out
);
    wire [7:0]PWDATA,PRDATA,PRDATA1,PRDATA2;
    wire [8:0]PADDR;
    wire PREADY,PREADY1,PREADY2,PENABLE,PSEL1,PSEL2,PWRITE;
    
    assign PREADY = PADDR[8] ? PREADY2 : PREADY1 ;
    assign PRDATA = READ_WRITE ? (PADDR[8] ? PRDATA2 : PRDATA1) : 8'dx ;

    apb_master mac(
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .READ_WRITE(READ_WRITE),
        .transfer(transfer),
        .PREADY(PREADY),
        .apb_write_paddr(apb_write_paddr),
        .apb_read_paddr(apb_read_paddr),
        .apb_write_data(apb_write_data),
        .PRDATA(PRDATA),
        .PADDR(PADDR),
        .PWRITE(PWRITE),
        .PSEL1(PSEL1),
        .PSEL2(PSEL2),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .apb_read_data_out(apb_read_data_out),
        .PSLVERR(PSLVERR)
    );

    ram_as_slave mac1(
        .PRESETn(PRESETn),
        .PSEL(PSEL1),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR [7:0]),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA1),
        .PREADY(PREADY1)
    );

    ram_as_slave mac2(
        .PRESETn(PRESETn),
        .PSEL(PSEL2),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR [7:0]),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA2),
        .PREADY(PREADY2)
    );


endmodule
