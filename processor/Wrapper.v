`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface. 
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 *  
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/  

module Wrapper (CLK100MHZ, SW, button, hall_effect, motor_output, LED, moving_LED, LED_dest, display, AN, AUD_PWM, AUD_SD);
	input CLK100MHZ;
	input [3:0] button, hall_effect;
	input [6:0] SW;
	output motor_output;
	output [15:0] LED;
	output moving_LED;
	output [3:0] LED_dest;
	output [6:0] display;
	output [7:0]AN;
    output AUD_PWM, AUD_SD;
    
    wire reset;
    assign reset = 1'b0;
    
    
    // output [6:0] display

    wire clock;
    assign clock = CLK100MHZ;
    
    reg [3:0] button_pressed = 0, reg_led_dest = 0;
    reg [15:0] led_temp = 0;
    reg [31:0] reg_memDataOut = 0, reg_next = 0, reg_currentfloor = 1;
    reg [11:0] reg_queued;
    reg [19:0] reg_duty;
    reg [7:0] reg_anode = 0;
    reg [6:0] reg_display = 0;
    assign display = ~reg_display;
    assign AN[7:0] = reg_anode;

    reg [2:0] cnt_display = 0;
    always @(posedge clock_slow) begin
        cnt_display <= cnt_display + 1;
        case (cnt_display)
            3'b000 : begin
                reg_anode <= 8'b11111110;
                case (reg_currentfloor)
                    32'd1 : reg_display <= 7'b0000110;
                    32'd2 : reg_display <= 7'b1011011;
                    32'd3 : reg_display <= 7'b1001111;
                    32'd4 : reg_display <= 7'b1100110;
                    default : reg_display <= 7'b0;
                endcase
                end
            3'b001 : begin
                reg_anode <= 8'b01111111;
                case (reg_queued[2:0])
                    3'd0 : reg_display <= 7'b0111111;
                    3'd1 : reg_display <= 7'b0000110;
                    3'd2 : reg_display <= 7'b1011011;
                    3'd3 : reg_display <= 7'b1001111;
                    3'd4 : reg_display <= 7'b1100110;
                    default : reg_display <= 7'b0;
                endcase
            end
            3'b010 : begin
                reg_anode <= 8'b10111111;
                case (reg_queued[5:3])
                    3'd0 : reg_display <= 7'b0111111;
                    3'd1 : reg_display <= 7'b0000110;
                    3'd2 : reg_display <= 7'b1011011;
                    3'd3 : reg_display <= 7'b1001111;
                    3'd4 : reg_display <= 7'b1100110;
                    default : reg_display <= 7'b0;
                endcase
            end
            3'b011 : begin
                reg_anode <= 8'b11011111;
                case (reg_queued[8:6])
                    3'd0 : reg_display <= 7'b0111111;
                    3'd1 : reg_display <= 7'b0000110;
                    3'd2 : reg_display <= 7'b1011011;
                    3'd3 : reg_display <= 7'b1001111;
                    3'd4 : reg_display <= 7'b1100110;
                    default : reg_display <= 7'b0;
                endcase
            end
           3'b100 : begin
                reg_anode <= 8'b11101111;
                case (reg_queued[11:9])
                    3'd0 : reg_display <= 7'b0111111;
                    3'd1 : reg_display <= 7'b0000110;
                    3'd2 : reg_display <= 7'b1011011;
                    3'd3 : reg_display <= 7'b1001111;
                    3'd4 : reg_display <= 7'b1100110;
                    default : reg_display <= 7'b0;
                endcase
            end
            default : reg_display <= 7'b0;
        endcase
    end
    
    PWMSerializer pwm(clock, 1'b0, reg_duty, motor_output); 
    // ===========================================
    //                     SW
    // ===========================================
    always @ (posedge clock) begin
        if(|button_trigger) begin
            button_pressed = button_trigger; 
        end
        if(memAddr == 32'd4005) begin
            button_pressed <= 0; 
        end
        else if(memAddr == 32'd4023) begin
            reg_duty <= memDataIn[19:0];
        end 
        else if(memAddr == 32'd4030) begin
            reg_queued[2:0] <= memDataIn[2:0];
            reg_led_dest = memDataIn[2:0]; 
            if(memDataIn[2:0] == 3'd3) begin
                reg_led_dest <= 4'b0100; 
            end else if(memDataIn[2:0] == 3'd4 ) begin
                reg_led_dest <= 4'b1000;
            end else begin
                reg_led_dest <= memDataIn[2:0];
            end
        end
        else if(memAddr == 32'd4031) begin
            reg_queued[5:3] <= memDataIn[2:0]; 
        end
        else if(memAddr == 32'd4032) begin
            reg_queued[8:6] <= memDataIn[2:0];
        end 
        else if(memAddr == 32'd4033) begin
            reg_queued[11:9] <= memDataIn[2:0];
        end
        else if(memAddr == 32'd4043) begin
            led_temp[0] <= 1;
        end
            
    end
    
//    assign LED[2:0] = reg_currentfloor[2:0];
    assign LED[15:0] = led_temp[15:0];
    
    assign LED_dest = reg_led_dest;
       
    wire [31:0] proc_memDataOut;
    assign proc_memDataOut = reg_memDataOut;
    // ===========================================
    //                     LW
    // ===========================================
    always @ (posedge clock) begin
        if(memAddr ==  32'd4000) begin
            reg_memDataOut <= button_pressed[0] ? 32'd1 : 0;
        end else if(memAddr == 32'd4001) begin
            reg_memDataOut <=  button_pressed[1] ? 32'd2 : 0;
        end else if(memAddr == 32'd4002) begin
            reg_memDataOut <=  button_pressed[2] ? 32'd3 : 0;
        end else if(memAddr == 32'd4003) begin
            reg_memDataOut <=  button_pressed[3] ? 32'd4 : 0;
        end else if(memAddr == 32'd4004) begin
            reg_memDataOut <= reg_currentfloor;
        end else begin
            reg_memDataOut <= memDataOut;
        end
    end
   
    wire [11:0] ram_memAddr;
    assign ram_memAddr = memAddr >= 32'd4000 ? 12'b0 : memAddr;
     
    wire [3:0] button_trigger;
    debounce button_pulse1(button_trigger[0], clock, |(~button[0]));
    debounce button_pulse2(button_trigger[1], clock, |(~button[1]));
    debounce button_pulse3(button_trigger[2], clock, |(~button[2]));
    debounce button_pulse4(button_trigger[3], clock, |(~button[3]));

    wire [3:0] magnet_trigger;
    debounce magnet1(magnet_trigger[0], clock, ~hall_effect[0]);
    debounce magnet2(magnet_trigger[1], clock, ~hall_effect[1]);
    debounce magnet3(magnet_trigger[2], clock, ~hall_effect[2]);
    debounce magnet4(magnet_trigger[3], clock, ~hall_effect[3]);


    always @(posedge clock) begin  
        if(magnet_trigger[0]) begin
            reg_currentfloor <= 32'd1;
        end else if (magnet_trigger[1]) begin
            reg_currentfloor <= 32'd2;
        end else if (magnet_trigger[2]) begin
            reg_currentfloor <= 32'd3; 
        end else if (magnet_trigger[3]) begin
            reg_currentfloor <= 32'd4;
        end 
    end 
    
    
    

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
            memAddr, memDataIn, memDataOut;
    
	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "working";
	
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(proc_memDataOut)); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));

	// Register File
	regfile RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB));

	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(mwe), 
		.addr(ram_memAddr[11:0]), 
		.dataIn(memDataIn),
		.dataOut(memDataOut)
		);
		
          
    reg clock_slow = 0;
    reg [31:0] counter;
    always @(posedge clock) begin
        if(counter < 200)
            counter <= counter + 1;
        else begin
            counter <= 0;
            clock_slow <= ~clock_slow;
        end

    end

endmodule
