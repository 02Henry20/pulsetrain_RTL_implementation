`timescale 1ns/100ps

module TB_TOP_ZERO_DELETE;

    parameter NUM_VALUES   = 4;
    parameter VALUE_WIDTH  = 8;
    parameter FIFO_DEPTH   = 10;
    parameter CLOCK_PERIOD = 10;

    reg CLK;
    reg RSTn;
    reg PULSE_DONE;

    reg [VALUE_WIDTH-1:0] X_LFSR_VALUE;
    reg [VALUE_WIDTH-1:0] D_LFSR_VALUE;

    reg [NUM_VALUES*VALUE_WIDTH-1:0] X_INPUT_VALUES;
    reg [NUM_VALUES*VALUE_WIDTH-1:0] D_INPUT_VALUES;

    wire [NUM_VALUES-1:0] X_PULSES_OUT;
    wire [NUM_VALUES-1:0] D_PULSES_OUT;
    wire                  VALID_OUT;

    TOP_PREV #(
        .NUM_VALUES (NUM_VALUES),
        .VALUE_WIDTH(VALUE_WIDTH),
        .FIFO_DEPTH (FIFO_DEPTH)
    ) dut (
        .CLK           (CLK),
        .RSTn          (RSTn),

        .X_LFSR_VALUE  (X_LFSR_VALUE),
        .X_INPUT_VALUES(X_INPUT_VALUES),

        .D_LFSR_VALUE  (D_LFSR_VALUE),
        .D_INPUT_VALUES(D_INPUT_VALUES),

        .PULSE_DONE    (PULSE_DONE),

        .X_PULSES_OUT  (X_PULSES_OUT),
        .D_PULSES_OUT  (D_PULSES_OUT),
        .VALID_OUT     (VALID_OUT)
    );

    always #(CLOCK_PERIOD / 2) CLK = ~CLK;

    task send_values;
        input [VALUE_WIDTH-1:0]            x_lfsr;
        input [NUM_VALUES*VALUE_WIDTH-1:0] x_input;
        input [VALUE_WIDTH-1:0]            d_lfsr;
        input [NUM_VALUES*VALUE_WIDTH-1:0] d_input;

        begin
            @(negedge CLK);

            X_LFSR_VALUE   = x_lfsr;
            X_INPUT_VALUES = x_input;
            D_LFSR_VALUE   = d_lfsr;
            D_INPUT_VALUES = d_input;

            // Values are written into the buffers at this rising edge.
            @(posedge CLK);

            // Clear the inputs before the following rising edge so that
            // keep_item does not write the same vectors repeatedly.
            @(negedge CLK);

            X_LFSR_VALUE   = 0;
            X_INPUT_VALUES = 0;
            D_LFSR_VALUE   = 0;
            D_INPUT_VALUES = 0;
        end
    endtask

    task finish_pulse;
        begin
            @(negedge CLK);
            PULSE_DONE = 1'b1;

            @(posedge CLK);
            #1;

            if (
                VALID_OUT !== 1'b0 ||
                X_PULSES_OUT !== {NUM_VALUES{1'b0}} ||
                D_PULSES_OUT !== {NUM_VALUES{1'b0}}
            )
                $display(
                    "OUTPUT CLEAR: FAIL, X=%b D=%b VALID=%b",
                    X_PULSES_OUT,
                    D_PULSES_OUT,
                    VALID_OUT
                );
            else
                $display("OUTPUT CLEAR: PASS");

            @(negedge CLK);
            PULSE_DONE = 1'b0;
        end
    endtask

    task check_output;
        input [NUM_VALUES-1:0] expected_x;
        input [NUM_VALUES-1:0] expected_d;

        begin
            if (
                VALID_OUT &&
                X_PULSES_OUT === expected_x &&
                D_PULSES_OUT === expected_d
            )
                $display(
                    "OUTPUT X=%b D=%b: PASS",
                    expected_x,
                    expected_d
                );
            else
                $display(
                    "OUTPUT: FAIL, expected X=%b D=%b, got X=%b D=%b VALID=%b",
                    expected_x,
                    expected_d,
                    X_PULSES_OUT,
                    D_PULSES_OUT,
                    VALID_OUT
                );
        end
    endtask

    initial begin
        $dumpfile("TB_TOP_ZERO_DELETE.vcd");
        $dumpvars(0, TB_TOP_ZERO_DELETE);

        CLK            = 0;
        RSTn           = 0;
        PULSE_DONE     = 0;
        X_LFSR_VALUE   = 0;
        D_LFSR_VALUE   = 0;
        X_INPUT_VALUES = 0;
        D_INPUT_VALUES = 0;

        repeat (3) @(posedge CLK);

        @(negedge CLK);
        RSTn = 1'b1;

        // X = 0101, D = 0011
        send_values(
            8'd10,
            {8'd5, 8'd20, 8'd5, 8'd20},
            8'd10,
            {8'd5, 8'd5, 8'd20, 8'd20}
        );

        // X = 1010, D = 1100
        send_values(
            8'd10,
            {8'd20, 8'd5, 8'd20, 8'd5},
            8'd10,
            {8'd20, 8'd20, 8'd5, 8'd5}
        );

        // Deleted because X = 0000
        send_values(
            8'd10,
            {8'd0, 8'd0, 8'd0, 8'd0},
            8'd10,
            {8'd20, 8'd20, 8'd20, 8'd20}
        );

        wait (VALID_OUT);
        #1;
        check_output(4'b0101, 4'b0011);

        finish_pulse();

        // Next queued entry is loaded on the next rising edge.
        @(posedge CLK);
        #1;
        check_output(4'b1010, 4'b1100);

        finish_pulse();

        // No third entry should exist.
        @(posedge CLK);
        #1;

        if (
            !VALID_OUT &&
            X_PULSES_OUT === 4'b0000 &&
            D_PULSES_OUT === 4'b0000
        )
            $display("DELETE TEST: PASS");
        else
            $display(
                "DELETE TEST: FAIL, X=%b D=%b VALID=%b",
                X_PULSES_OUT,
                D_PULSES_OUT,
                VALID_OUT
            );

        $finish;
    end

    initial begin
        #(100 * CLOCK_PERIOD);
        $display("TEST FAILURE: timeout");
        $finish;
    end

endmodule