//module AudioController(
//    input        clk, 		// System Clock Input 100 Mhz
//    input		 audioEn,   // Audio Enable
//	output       audioOut	// PWM signal to the audio jack
//	);	

//	localparam MHz = 1000000;
//	localparam SYSTEM_FREQ = 100*MHz; // System clock frequency

//	// Initialize the frequency array. FREQs[0] = 261
//	reg[10:0] FREQs[0:15];
//	initial begin
//		$readmemh("FREQs.mem", FREQs);
//	end
	
//	////////////////////
//	// Your Code Here //
//	////////////////////

//	wire [6:0] duty_cycle;
//	PWMSerializer serrr (clk, 1'b0, duty_cycle, audioOut);
	
//	// TODO
//	assign duty_cycle = clk_400Hz ? 7'd25 : 7'd75;
	
////	reg [3:0] idx = 0;
////	reg song_playing = 1;
////	always @(posedge clk_idx) begin
////        idx <= idx + 1;
////	end

//	reg [31:0] cnt_duty = 0;
//	reg clk_duty = 0;
//	always @(posedge clk) begin
//		if(cnt_duty < (50000000 / FREQs[0]) - 1) begin
//			cnt_duty <= cnt_duty + 1;
//		end else begin
//			cnt_duty <= 0;
//			clk_duty <= ~clk_duty;
//		end
//	end

////	reg [31:0] cnt_idx = 0;
////	reg clk_idx = 0;
////	always @(posedge clk) begin
////		if(cnt_idx < SYSTEM_FREQ) begin
////			cnt_idx <= cnt_idx + 1;
////		end else begin
////			cnt_idx <= 0;
////			clk_idx <= ~clk_idx;
////		end
////	end

//endmodule

module AudioController(
    input        clk, 		// System Clock Input 100 Mhz
    output       audioOut);	// Audio Enable

	localparam MHz = 1000000;
	localparam SYSTEM_FREQ = 100*MHz; // System clock frequency

	// Initialize the frequency array. FREQs[0] = 261
	reg[10:0] FREQs[0:15];
	initial begin
		$readmemh("FREQs.mem", FREQs);
	end
	
	////////////////////
	// Your Code Here //
	////////////////////
	
	 reg[17:0] counter, counter2, clk_mic;
    reg smth = 0;
    always @(posedge clk) begin
      if(counter < 50000000/FREQs[0] - 1)
           counter <= counter + 1;
       else begin
            counter <= 0;
            smth <= ~smth;
        end
       
    end
      
    //PWMserializer miccc(clk, reset, duty_cycle, audioOut);
    PWMSerializer scale(clk, reset, ((smth ? 70 : 30))/2 , audioOut);
    //PWMSerializer scale(clk, reset, ((smth ? 0 : 0) + duty_cycle), audioOut);
//    wire[6:0] duty_cycle;
//    PWMDeserializer sdkf(clk, reset, micData, duty_cycle);

	

endmodule