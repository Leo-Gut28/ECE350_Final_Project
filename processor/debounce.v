module debounce(trigger, clock, in);
    input in, clock;
    output trigger;
    
    wire q0, q1, q2;
    dffe_ref ff0(q0, in, clock, 1'b1, 1'b0);
    dffe_ref ff1(q1, q0, clock, 1'b1, 1'b0);
    dffe_ref ff2(q2, q1, clock, 1'b1, 1'b0);

    assign trigger = q1 && !q2;
endmodule
