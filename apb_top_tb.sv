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

module apb_top_tb;
    logic PCLK,PRESETn,transfer,READ_WRITE;
    logic [8:0]apb_write_paddr;
    logic [7:0]apb_write_data;
    logic [8:0]apb_read_paddr;
    logic [7:0]apb_read_data_out;
    logic PSLVERR;
    logic [7:0]data,expected;
    
    logic [7:0]mem[0:15];
    
    apb_top DUT(PCLK,PRESETn,transfer,READ_WRITE,apb_write_paddr,apb_write_data,apb_read_paddr,PSLVERR,apb_read_data_out);
    
    integer i,j;
    initial
    begin
        PCLK <= 0;
        forever #5 PCLK = ~PCLK;
    end
    
    initial $readmemh("check.mem",mem);
    
    initial
    begin
        PRESETn<=0; transfer<=0; READ_WRITE =0;
        @(posedge PCLK)      PRESETn = 1;                                     //no write address available but request for write operation
        @(posedge PCLK)      transfer = 1;
        repeat(2) @(posedge PCLK);
        @(negedge PCLK)      Write_slave1;        // write operation
        repeat(3) @(posedge PCLK);    Write_slave2;
        @(posedge PCLK);    apb_write_paddr = 9'd526;  apb_write_data = 9'd9;
        repeat(2) @(posedge PCLK);    apb_write_paddr = 9'd22; apb_write_data = 9'd35;
        repeat(2) @(posedge PCLK);
        @(posedge PCLK)     READ_WRITE =1; PRESETn<=0; transfer<=0; 
        @(posedge PCLK)     PRESETn = 1;
        repeat(3) @(posedge PCLK)     transfer = 1;                             // no read address available but request for read operation
        repeat(2) @(posedge PCLK)     Read_slave1;                             //read operation
        repeat(3) @(posedge PCLK);   Read_slave2;
        repeat(3) @(posedge PCLK);   apb_read_paddr = 9'd45;                 //data not inserted in write operation but requested for read operation
        repeat(4) @(posedge PCLK);
        $finish;
    end
    
    task Write_slave1;
        begin
            transfer =1;
            for (i = 0; i < 8; i=i+1) 
            begin
                repeat(2)@(negedge PCLK)
                begin
                    data = i;
                    apb_write_data = 2*i;
                    apb_write_paddr =  {1'b0,data};
                end
            end
        end
    endtask
    
    task Write_slave2;
        begin
            for (i = 0; i < 8; i=i+1) 
            begin
                repeat(2)@(negedge PCLK)
                begin
                    data = i;
                    apb_write_paddr = {1'b1,data};
                    apb_write_data = i;
                end
            end
        end
    endtask
    
    task Read_slave1;
        begin
            for (j = 0;  j< 8; j= j+1)
            begin
                repeat(2)@(negedge PCLK)
                begin
                    data = j;
                    apb_read_paddr = {1'b0,data};
                end
            end
        end
    endtask
    
    task Read_slave2;
        begin
            for (j = 0;  j< 8; j= j+1)
            begin
                repeat(2)@(negedge PCLK)
                begin
                    data = j;
                    apb_read_paddr = {1'b1,data};
                end
            end
        end
    endtask
endmodule
