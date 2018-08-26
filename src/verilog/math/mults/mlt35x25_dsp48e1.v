//-----------------------------------------------------------------------------
//
// Title       : mlt35x25_dsp48e1
// Design      : FFTK
// Author      : Kapitanov
// Company     :
//
// Description : Multiplier 35x25 based on DSP48E1 block
//
//-----------------------------------------------------------------------------
//
//	Version 1.0: 14.02.2018
//
//  Description: Double complex multiplier by DSP48 unit
//
//  Math: MLT_P = MLT_A * MLT_B (w/ double multiplier)
//
//  DSP48 data signals:
//    A port - data width up to 25 (27)* bits
//    B port - data width up to 35 bits
//  * - 25 bits for DSP48E1, 27 bits for DSP48E2.
//
//  Total delay			: 4 clock cycles,
//  Total resources		: 2 DSP48 units
//
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//
//  GNU GENERAL PUBLIC LICENSE
//  Version 3, 29 June 2007
//
//  Copyright (c) 2018 Kapitanov Alexander
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//  THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
//  APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT 
//  HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY 
//  OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, 
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
//  PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM 
//  IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF 
//  ALL NECESSARY SERVICING, REPAIR OR CORRECTION. 
// 
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

module mlt35x25_dsp48e1
	(
		input   RST, CLK,
		input  [34:0] MLT_A,
		input  [24:0] MLT_B,
		output reg [59:0] MLT_P
	);

	wire [29 : 0] dspA_12;
	wire [17 : 0] dspB_M1;
	wire [17 : 0] dspB_M2;
	wire [47 : 0] dspP_M1;
	wire [47 : 0] dspP_M2;
	wire [47 : 0] dspP_12;

	always @(posedge CLK) begin  
		MLT_P[16 : 00] <= dspP_M2[16 : 00];
	end
	always @(*) begin
        MLT_P[59 : 17] <= dspP_M1[42 : 00];
    end

	assign dspA_12[24 : 00] = MLT_B[24 : 0];
	assign dspA_12[29 : 25] = {5{MLT_B[24]}};
	
	assign dspB_M2[16 : 00] = MLT_A[16 : 00];
	assign dspB_M2[17] = 1'b0;
	assign dspB_M1[17 : 00] = MLT_A[34 : 17];

    // Wrap DSP48E1 unit
	DSP48E1 #(
		.USE_MULT("MULTIPLY"),  
		.ACASCREG(1),           
		.ADREG(1),              
		.ALUMODEREG(1),         
		.AREG(2),               
		.BCASCREG(1),           
		.BREG(2),               
		.CARRYINREG(1),         
		.CARRYINSELREG(1),      
		.CREG(1),               
		.DREG(1),               
		.INMODEREG(1),          
		.MREG(1),               
		.OPMODEREG(1),          
		.PREG(1)                
	)
    xDSP_M1 (                 
       // Cascade: 30-bit (each) input: 
       .ACIN(30'b0),                     
       .BCIN(18'b0),                     
       .CARRYCASCIN(1'b0),       
       .MULTSIGNIN(1'b0),         
       .PCIN(dspP_12),
       .ALUMODE(4'b0),
       .CARRYINSEL(3'b0),
       .CLK(CLK),
       .INMODE(5'b0),
       .OPMODE(7'b1010101),
       // Data input / output data ports
       .A(dspA_12),
       .B(dspB_M1),
       .C(48'b0),
       .P(dspP_M1),
       .D(25'b0),
       .CARRYIN(1'b0),
       // Clock enables
       .CEA1(1'b1),     
       .CEA2(1'b1),     
       .CEAD(1'b1),     
       .CEALUMODE(1'b1),
       .CEB1(1'b1),     
       .CEB2(1'b1),     
       .CEC(1'b1),      
       .CECARRYIN(1'b1),
       .CECTRL(1'b1),   
       .CED(1'b1),      
       .CEINMODE(1'b1), 
       .CEM(1'b1),
       .CEP(1'b1),
       .RSTA(RST),
       .RSTALLCARRYIN(RST),   
       .RSTALUMODE(RST),
       .RSTB(RST),
       .RSTC(RST),
       .RSTCTRL(RST),
       .RSTD(RST),
       .RSTINMODE(RST),
       .RSTM(RST),
       .RSTP(RST)
    );

    // Wrap DSP48E1 unit
	DSP48E1 #(
		.USE_MULT("MULTIPLY"),  
		.ACASCREG(1),           
		.ADREG(1),              
		.ALUMODEREG(1),         
		.AREG(1),               
		.BCASCREG(1),           
		.BREG(1),               
		.CARRYINREG(1),         
		.CARRYINSELREG(1),      
		.CREG(1),               
		.DREG(1),               
		.INMODEREG(1),          
		.MREG(1),               
		.OPMODEREG(1),          
		.PREG(1)                
	)
    xDSP_M2 (                 
       // Cascade: 30-bit (each) input: 
       .ACIN(30'b0),                     
       .BCIN(18'b0),                     
       .CARRYCASCIN(1'b0),       
       .MULTSIGNIN(1'b0),         
       .PCIN(48'b0),
       .PCOUT(dspP_12), 
       .ALUMODE(4'b0),
       .CARRYINSEL(3'b0),
       .CLK(CLK),
       .INMODE(5'b0),
       .OPMODE(7'b0000101),
       // Data input / output data ports
       .A(dspA_12),
       .B(dspB_M2),
       .C(48'b0),
       .P(dspP_M2),

       .D(25'b0),
       .CARRYIN(1'b0),
       // Clock enables
       .CEA1(1'b1),     
       .CEA2(1'b1),     
       .CEAD(1'b1),     
       .CEALUMODE(1'b1),
       .CEB1(1'b1),     
       .CEB2(1'b1),     
       .CEC(1'b1),      
       .CECARRYIN(1'b1),
       .CECTRL(1'b1),   
       .CED(1'b1),      
       .CEINMODE(1'b1), 
       .CEM(1'b1),
       .CEP(1'b1),
       .RSTA(RST),
       .RSTALLCARRYIN(RST),   
       .RSTALUMODE(RST),
       .RSTB(RST),
       .RSTC(RST),
       .RSTCTRL(RST),
       .RSTD(RST),
       .RSTINMODE(RST),
       .RSTM(RST),
       .RSTP(RST)
    );

endmodule