`timescale 1ns/100ps

module TB_TOP_ZERO_DELETE_FULL;

    parameter NUM_VALUES   = 4;
    parameter VALUE_WIDTH  = 8;
    parameter FIFO_DEPTH   = 10;
    parameter CLOCK_PERIOD = 10;

    parameter RANDOM_TESTS = 200;
    parameter MAX_EXPECTED = 4096;

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

    reg [NUM_VALUES-1:0] expected_x [0:MAX_EXPECTED-1];
    reg [NUM_VALUES-1:0] expected_d [0:MAX_EXPECTED-1];

    integer expected_write;
    integer expected_read;

    integer checks;
    integer errors;
    integer accepted_items;
    integer deleted_items;

    integer i;
    integer j;
    integer before_write;

    reg [VALUE_WIDTH-1:0] tmp_x_lfsr;
    reg [VALUE_WIDTH-1:0] tmp_d_lfsr;

    reg [NUM_VALUES*VALUE_WIDTH-1:0] tmp_x_input;
    reg [NUM_VALUES*VALUE_WIDTH-1:0] tmp_d_input;

    reg [NUM_VALUES-1:0] tmp_x_pattern;
    reg [NUM_VALUES-1:0] tmp_d_pattern;

    localparam [VALUE_WIDTH-1:0] MAX_VALUE = {VALUE_WIDTH{1'b1}};

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

    /*
     * Generate the expected pulse vector using the same rule as the DUT:
     *
     * pulse[i] = LFSR_VALUE < INPUT_VALUE[i]
     */
    function [NUM_VALUES-1:0] generate_expected_pulses;
        input [VALUE_WIDTH-1:0] lfsr;
        input [NUM_VALUES*VALUE_WIDTH-1:0] input_values;

        integer index;

        begin
            for (index = 0; index < NUM_VALUES; index = index + 1)
                generate_expected_pulses[index] =
                    lfsr <
                    input_values[index*VALUE_WIDTH +: VALUE_WIDTH];
        end
    endfunction

    /*
     * Convert a desired pulse pattern into suitable input values.
     *
     * The LFSR value used with this function should be greater than zero.
     *
     * Desired 1 -> input is maximum value
     * Desired 0 -> input is zero
     */
    function [NUM_VALUES*VALUE_WIDTH-1:0] values_for_pattern;
        input [NUM_VALUES-1:0] pattern;

        integer index;

        begin
            for (index = 0; index < NUM_VALUES; index = index + 1)
                values_for_pattern[index*VALUE_WIDTH +: VALUE_WIDTH] =
                    pattern[index] ? MAX_VALUE : {VALUE_WIDTH{1'b0}};
        end
    endfunction

    task clear_inputs;
        begin
            X_LFSR_VALUE   = 0;
            D_LFSR_VALUE   = 0;
            X_INPUT_VALUES = 0;
            D_INPUT_VALUES = 0;
        end
    endtask

    /*
     * Model whether the supplied input pair should enter the FIFO.
     */
    task record_expected_item;
        input [VALUE_WIDTH-1:0]            x_lfsr;
        input [NUM_VALUES*VALUE_WIDTH-1:0] x_input;
        input [VALUE_WIDTH-1:0]            d_lfsr;
        input [NUM_VALUES*VALUE_WIDTH-1:0] d_input;

        reg [NUM_VALUES-1:0] generated_x;
        reg [NUM_VALUES-1:0] generated_d;

        begin
            generated_x = generate_expected_pulses(x_lfsr, x_input);
            generated_d = generate_expected_pulses(d_lfsr, d_input);

            if ((|generated_x) && (|generated_d)) begin
                if (expected_write >= MAX_EXPECTED) begin
                    $display(
                        "ERROR: Testbench scoreboard overflow at time %0t",
                        $time
                    );
                    errors = errors + 1;
                end
                else begin
                    expected_x[expected_write] = generated_x;
                    expected_d[expected_write] = generated_d;

                    expected_write = expected_write + 1;
                    accepted_items = accepted_items + 1;
                end
            end
            else begin
                deleted_items = deleted_items + 1;
            end
        end
    endtask

    /*
     * Present one new X/D pair for one rising clock edge.
     *
     * This task does not clear the inputs afterward, allowing consecutive
     * calls to produce back-to-back writes on consecutive rising edges.
     */
    task send_cycle;
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

            @(posedge CLK);

            record_expected_item(
                x_lfsr,
                x_input,
                d_lfsr,
                d_input
            );
        end
    endtask

    /*
     * Send one pair and then clear the inputs before the next rising edge.
     */
    task send_one;
        input [VALUE_WIDTH-1:0]            x_lfsr;
        input [NUM_VALUES*VALUE_WIDTH-1:0] x_input;
        input [VALUE_WIDTH-1:0]            d_lfsr;
        input [NUM_VALUES*VALUE_WIDTH-1:0] d_input;

        begin
            send_cycle(
                x_lfsr,
                x_input,
                d_lfsr,
                d_input
            );

            @(negedge CLK);
            clear_inputs();
        end
    endtask

    /*
     * Wait for the next expected output and compare both X and D.
     */
    task wait_and_check_output;
        integer waited_cycles;

        begin : WAIT_CHECK_BLOCK
            checks = checks + 1;

            if (expected_read >= expected_write) begin
                $display(
                    "ERROR: Output expected, but scoreboard is empty at time %0t",
                    $time
                );

                errors = errors + 1;
                disable WAIT_CHECK_BLOCK;
            end

            waited_cycles = 0;

            while (
                VALID_OUT !== 1'b1 &&
                waited_cycles < 20
            ) begin
                @(posedge CLK);
                #1;

                waited_cycles = waited_cycles + 1;
            end

            if (VALID_OUT !== 1'b1) begin
                $display(
                    "ERROR: Timeout waiting for output at time %0t",
                    $time
                );

                errors = errors + 1;
                disable WAIT_CHECK_BLOCK;
            end

            if (
                X_PULSES_OUT !== expected_x[expected_read] ||
                D_PULSES_OUT !== expected_d[expected_read]
            ) begin
                $display(
                    "ERROR: Output mismatch at item %0d, time %0t",
                    expected_read,
                    $time
                );

                $display(
                    "       Expected X=%b D=%b",
                    expected_x[expected_read],
                    expected_d[expected_read]
                );

                $display(
                    "       Received X=%b D=%b VALID=%b",
                    X_PULSES_OUT,
                    D_PULSES_OUT,
                    VALID_OUT
                );

                errors = errors + 1;
            end
        end
    endtask

    /*
     * Verify that the current output remains unchanged while PULSE_DONE
     * remains low.
     */
    task check_output_stability;
        input integer cycles;

        reg [NUM_VALUES-1:0] held_x;
        reg [NUM_VALUES-1:0] held_d;

        integer cycle;

        begin
            held_x = X_PULSES_OUT;
            held_d = D_PULSES_OUT;

            for (cycle = 0; cycle < cycles; cycle = cycle + 1) begin
                @(posedge CLK);
                #1;

                checks = checks + 1;

                if (
                    VALID_OUT !== 1'b1 ||
                    X_PULSES_OUT !== held_x ||
                    D_PULSES_OUT !== held_d
                ) begin
                    $display(
                        "ERROR: Output changed without PULSE_DONE at time %0t",
                        $time
                    );

                    $display(
                        "       Expected X=%b D=%b",
                        held_x,
                        held_d
                    );

                    $display(
                        "       Received X=%b D=%b VALID=%b",
                        X_PULSES_OUT,
                        D_PULSES_OUT,
                        VALID_OUT
                    );

                    errors = errors + 1;
                end
            end
        end
    endtask

    /*
     * Complete the current output pulse pair.
     */
    task finish_current_output;
        begin
            checks = checks + 1;

            if (VALID_OUT !== 1'b1) begin
                $display(
                    "ERROR: finish_current_output called while VALID_OUT=0"
                );

                errors = errors + 1;
            end

            @(negedge CLK);
            PULSE_DONE = 1'b1;

            @(posedge CLK);
            #1;

            if (
                VALID_OUT !== 1'b0 ||
                X_PULSES_OUT !== {NUM_VALUES{1'b0}} ||
                D_PULSES_OUT !== {NUM_VALUES{1'b0}}
            ) begin
                $display(
                    "ERROR: Output not cleared after PULSE_DONE at time %0t",
                    $time
                );

                $display(
                    "       X=%b D=%b VALID=%b",
                    X_PULSES_OUT,
                    D_PULSES_OUT,
                    VALID_OUT
                );

                errors = errors + 1;
            end

            if (expected_read < expected_write)
                expected_read = expected_read + 1;
            else begin
                $display(
                    "ERROR: Consumed output while scoreboard was empty"
                );

                errors = errors + 1;
            end

            @(negedge CLK);
            PULSE_DONE = 1'b0;
        end
    endtask

    task consume_next_output;
        begin
            wait_and_check_output();
            finish_current_output();
        end
    endtask

    /*
     * Confirm that the output remains empty for two complete clock cycles.
     */
    task expect_empty;
        integer cycle;

        begin
            for (cycle = 0; cycle < 2; cycle = cycle + 1) begin
                @(posedge CLK);
                #1;

                checks = checks + 1;

                if (
                    VALID_OUT !== 1'b0 ||
                    X_PULSES_OUT !== {NUM_VALUES{1'b0}} ||
                    D_PULSES_OUT !== {NUM_VALUES{1'b0}}
                ) begin
                    $display(
                        "ERROR: Expected empty output at time %0t",
                        $time
                    );

                    $display(
                        "       X=%b D=%b VALID=%b",
                        X_PULSES_OUT,
                        D_PULSES_OUT,
                        VALID_OUT
                    );

                    errors = errors + 1;
                end
            end
        end
    endtask

    /*
     * Assert PULSE_DONE while no output is valid.
     */
    task test_done_while_empty;
        begin
            @(negedge CLK);
            PULSE_DONE = 1'b1;

            @(posedge CLK);
            #1;

            checks = checks + 1;

            if (
                VALID_OUT !== 1'b0 ||
                X_PULSES_OUT !== {NUM_VALUES{1'b0}} ||
                D_PULSES_OUT !== {NUM_VALUES{1'b0}}
            ) begin
                $display(
                    "ERROR: PULSE_DONE changed an empty output at time %0t",
                    $time
                );

                errors = errors + 1;
            end

            @(negedge CLK);
            PULSE_DONE = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("TB_TOP_ZERO_DELETE_FULL.vcd");
        $dumpvars(0, TB_TOP_ZERO_DELETE_FULL);

        CLK            = 0;
        RSTn           = 1;
        PULSE_DONE     = 0;

        X_LFSR_VALUE   = 0;
        D_LFSR_VALUE   = 0;
        X_INPUT_VALUES = 0;
        D_INPUT_VALUES = 0;

        expected_write = 0;
        expected_read  = 0;

        checks          = 0;
        errors          = 0;
        accepted_items  = 0;
        deleted_items   = 0;

        /*
         * =============================================================
         * TEST 1: RESET AND EMPTY STATE
         * =============================================================
         */

        $display("");
        $display("========================================");
        $display("TEST 1: RESET AND EMPTY STATE");
        $display("========================================");

        #1;
        RSTn = 1'b0;

        #1;
        checks = checks + 1;

        if (
            VALID_OUT !== 1'b0 ||
            X_PULSES_OUT !== {NUM_VALUES{1'b0}} ||
            D_PULSES_OUT !== {NUM_VALUES{1'b0}}
        ) begin
            $display("ERROR: Reset did not clear the outputs");
            errors = errors + 1;
        end

        repeat (3) @(posedge CLK);

        @(negedge CLK);
        RSTn = 1'b1;

        expect_empty();
        test_done_while_empty();

        /*
         * =============================================================
         * TEST 2: DIRECTED PULSE GENERATION AND ZERO DELETION
         * =============================================================
         */

        $display("");
        $display("========================================");
        $display("TEST 2: DIRECTED PULSE GENERATION");
        $display("========================================");

        // Expected X=0101, D=0011
        send_one(
            8'd10,
            {8'd5, 8'd20, 8'd5, 8'd20},
            8'd10,
            {8'd5, 8'd5, 8'd20, 8'd20}
        );

        // Expected X=1111, D=1111
        send_one(
            8'd0,
            {8'd255, 8'd255, 8'd255, 8'd255},
            8'd0,
            {8'd255, 8'd255, 8'd255, 8'd255}
        );

        // Delete: X=0000
        send_one(
            8'd10,
            {8'd0, 8'd0, 8'd0, 8'd0},
            8'd10,
            {8'd20, 8'd20, 8'd20, 8'd20}
        );

        // Delete: D=0000
        send_one(
            8'd10,
            {8'd20, 8'd20, 8'd20, 8'd20},
            8'd10,
            {8'd0, 8'd0, 8'd0, 8'd0}
        );

        // Delete: equality must produce zero because comparison is strict <
        send_one(
            8'd10,
            {8'd10, 8'd10, 8'd10, 8'd10},
            8'd10,
            {8'd10, 8'd10, 8'd10, 8'd10}
        );

        wait_and_check_output();
        check_output_stability(3);
        finish_current_output();

        consume_next_output();
        expect_empty();

        /*
         * =============================================================
         * TEST 3: FIFO ORDER AND POINTER WRAPAROUND
         * =============================================================
         */

        $display("");
        $display("========================================");
        $display("TEST 3: FIFO ORDER AND WRAPAROUND");
        $display("========================================");

        /*
         * Send FIFO_DEPTH entries on consecutive rising edges.
         * This also makes the non-power-of-two pointer wrap from 9 to 0.
         */
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            tmp_x_pattern =
                (i % ((1 << NUM_VALUES) - 1)) + 1;

            tmp_d_pattern =
                ((i * 3) % ((1 << NUM_VALUES) - 1)) + 1;

            send_cycle(
                1,
                values_for_pattern(tmp_x_pattern),
                1,
                values_for_pattern(tmp_d_pattern)
            );
        end

        @(negedge CLK);
        clear_inputs();

        while (expected_read < expected_write)
            consume_next_output();

        expect_empty();

        /*
         * Send another batch after both pointers wrapped around.
         */
        for (i = 0; i < 6; i = i + 1) begin
            tmp_x_pattern =
                ((i + 5) % ((1 << NUM_VALUES) - 1)) + 1;

            tmp_d_pattern =
                ((i + 9) % ((1 << NUM_VALUES) - 1)) + 1;

            send_cycle(
                1,
                values_for_pattern(tmp_x_pattern),
                1,
                values_for_pattern(tmp_d_pattern)
            );
        end

        @(negedge CLK);
        clear_inputs();

        while (expected_read < expected_write)
            consume_next_output();

        expect_empty();

        /*
         * =============================================================
         * TEST 4: WRITE WHILE COMPLETING CURRENT PULSE
         * =============================================================
         */

        $display("");
        $display("========================================");
        $display("TEST 4: SIMULTANEOUS WRITE AND DONE");
        $display("========================================");

        send_one(
            8'd10,
            {8'd5, 8'd20, 8'd5, 8'd20},
            8'd10,
            {8'd5, 8'd5, 8'd20, 8'd20}
        );

        send_one(
            8'd10,
            {8'd20, 8'd5, 8'd20, 8'd5},
            8'd10,
            {8'd20, 8'd20, 8'd5, 8'd5}
        );

        wait_and_check_output();

        /*
         * Complete the current output and write another input pair on
         * the same rising edge.
         */
        @(negedge CLK);

        tmp_x_lfsr = 8'd10;
        tmp_d_lfsr = 8'd10;

        tmp_x_input = {8'd20, 8'd20, 8'd5, 8'd5};
        tmp_d_input = {8'd5, 8'd20, 8'd20, 8'd5};

        X_LFSR_VALUE   = tmp_x_lfsr;
        X_INPUT_VALUES = tmp_x_input;
        D_LFSR_VALUE   = tmp_d_lfsr;
        D_INPUT_VALUES = tmp_d_input;

        PULSE_DONE = 1'b1;

        @(posedge CLK);

        record_expected_item(
            tmp_x_lfsr,
            tmp_x_input,
            tmp_d_lfsr,
            tmp_d_input
        );

        #1;
        checks = checks + 1;

        if (
            VALID_OUT !== 1'b0 ||
            X_PULSES_OUT !== {NUM_VALUES{1'b0}} ||
            D_PULSES_OUT !== {NUM_VALUES{1'b0}}
        ) begin
            $display(
                "ERROR: Output not cleared during simultaneous write/done"
            );

            errors = errors + 1;
        end

        expected_read = expected_read + 1;

        @(negedge CLK);
        PULSE_DONE = 1'b0;
        clear_inputs();

        while (expected_read < expected_write)
            consume_next_output();

        expect_empty();

        /*
         * =============================================================
         * TEST 5: ASYNCHRONOUS RESET WITH DATA IN THE FIFO
         * =============================================================
         */

        $display("");
        $display("========================================");
        $display("TEST 5: ASYNCHRONOUS RESET");
        $display("========================================");

        send_one(
            8'd1,
            values_for_pattern(4'b0001),
            8'd1,
            values_for_pattern(4'b0010)
        );

        send_one(
            8'd1,
            values_for_pattern(4'b0100),
            8'd1,
            values_for_pattern(4'b1000)
        );

        send_one(
            8'd1,
            values_for_pattern(4'b1111),
            8'd1,
            values_for_pattern(4'b0110)
        );

        wait_and_check_output();

        /*
         * Assert reset between clock edges.
         */
        #2;
        RSTn = 1'b0;

        #1;
        checks = checks + 1;

        if (
            VALID_OUT !== 1'b0 ||
            X_PULSES_OUT !== {NUM_VALUES{1'b0}} ||
            D_PULSES_OUT !== {NUM_VALUES{1'b0}}
        ) begin
            $display(
                "ERROR: Asynchronous reset did not clear output immediately"
            );

            errors = errors + 1;
        end

        /*
         * Reset also invalidates everything previously stored.
         */
        expected_write = 0;
        expected_read  = 0;

        repeat (2) @(posedge CLK);

        @(negedge CLK);
        RSTn = 1'b1;

        expect_empty();

        /*
         * =============================================================
         * TEST 6: EXHAUSTIVE X LFSR BOUNDARY SWEEP
         * =============================================================
         */

        $display("");
        $display("========================================");
        $display("TEST 6: EXHAUSTIVE X LFSR SWEEP");
        $display("========================================");

        /*
         * Test every possible 8-bit X LFSR value.
         *
         * For each LFSR:
         *   feature 0 = equal
         *   feature 1 = one greater, unless already maximum
         *   feature 2 = one smaller, unless already zero
         *   feature 3 = maximum
         *
         * D is always active.
         */
        for (i = 0; i <= MAX_VALUE; i = i + 1) begin
            tmp_x_lfsr = i;
            tmp_x_input = 0;

            for (j = 0; j < NUM_VALUES; j = j + 1) begin
                case (j % 4)
                    0:
                        tmp_x_input[
                            j*VALUE_WIDTH +: VALUE_WIDTH
                        ] = i;

                    1:
                        tmp_x_input[
                            j*VALUE_WIDTH +: VALUE_WIDTH
                        ] = (i < MAX_VALUE) ? i + 1 : i;

                    2:
                        tmp_x_input[
                            j*VALUE_WIDTH +: VALUE_WIDTH
                        ] = (i > 0) ? i - 1 : i;

                    default:
                        tmp_x_input[
                            j*VALUE_WIDTH +: VALUE_WIDTH
                        ] = MAX_VALUE;
                endcase
            end

            tmp_d_lfsr = 0;
            tmp_d_input = {(NUM_VALUES*VALUE_WIDTH){1'b1}};

            before_write = expected_write;

            send_one(
                tmp_x_lfsr,
                tmp_x_input,
                tmp_d_lfsr,
                tmp_d_input
            );

            if (expected_write > before_write)
                consume_next_output();
            else
                expect_empty();
        end

        /*
         * =============================================================
         * TEST 7: EXHAUSTIVE D LFSR BOUNDARY SWEEP
         * =============================================================
         */

        $display("");
        $display("========================================");
        $display("TEST 7: EXHAUSTIVE D LFSR SWEEP");
        $display("========================================");

        /*
         * Repeat the same exhaustive boundary test for D.
         * X is always active.
         */
        for (i = 0; i <= MAX_VALUE; i = i + 1) begin
            tmp_d_lfsr = i;
            tmp_d_input = 0;

            for (j = 0; j < NUM_VALUES; j = j + 1) begin
                case (j % 4)
                    0:
                        tmp_d_input[
                            j*VALUE_WIDTH +: VALUE_WIDTH
                        ] = i;

                    1:
                        tmp_d_input[
                            j*VALUE_WIDTH +: VALUE_WIDTH
                        ] = (i < MAX_VALUE) ? i + 1 : i;

                    2:
                        tmp_d_input[
                            j*VALUE_WIDTH +: VALUE_WIDTH
                        ] = (i > 0) ? i - 1 : i;

                    default:
                        tmp_d_input[
                            j*VALUE_WIDTH +: VALUE_WIDTH
                        ] = MAX_VALUE;
                endcase
            end

            tmp_x_lfsr = 0;
            tmp_x_input = {(NUM_VALUES*VALUE_WIDTH){1'b1}};

            before_write = expected_write;

            send_one(
                tmp_x_lfsr,
                tmp_x_input,
                tmp_d_lfsr,
                tmp_d_input
            );

            if (expected_write > before_write)
                consume_next_output();
            else
                expect_empty();
        end

        /*
         * =============================================================
         * TEST 8: RANDOMIZED INPUTS
         * =============================================================
         */

        $display("");
        $display("========================================");
        $display("TEST 8: RANDOMIZED INPUTS");
        $display("========================================");

        for (i = 0; i < RANDOM_TESTS; i = i + 1) begin
            tmp_x_lfsr = $random;
            tmp_d_lfsr = $random;

            for (j = 0; j < NUM_VALUES; j = j + 1) begin
                tmp_x_input[
                    j*VALUE_WIDTH +: VALUE_WIDTH
                ] = $random;

                tmp_d_input[
                    j*VALUE_WIDTH +: VALUE_WIDTH
                ] = $random;
            end

            before_write = expected_write;

            send_one(
                tmp_x_lfsr,
                tmp_x_input,
                tmp_d_lfsr,
                tmp_d_input
            );

            if (expected_write > before_write)
                consume_next_output();
            else
                expect_empty();
        end

        /*
         * =============================================================
         * FINAL CONSISTENCY CHECK
         * =============================================================
         */

        expect_empty();

        checks = checks + 1;

        if (expected_read != expected_write) begin
            $display(
                "ERROR: Scoreboard contains %0d unconsumed entries",
                expected_write - expected_read
            );

            errors = errors + 1;
        end

        $display("");
        $display("========================================");
        $display("TEST SUMMARY");
        $display("========================================");
        $display("Checks performed : %0d", checks);
        $display("Accepted items   : %0d", accepted_items);
        $display("Deleted items    : %0d", deleted_items);
        $display("Errors            : %0d", errors);

        if (errors == 0) begin
            $display("");
            $display("RESULT: ALL TESTS PASSED");
        end
        else begin
            $display("");
            $display("RESULT: TEST FAILED");
        end

        $display("========================================");

        $finish;
    end

    /*
     * Global timeout protection.
     */
    initial begin
        #(50000 * CLOCK_PERIOD);

        $display("");
        $display("========================================");
        $display("RESULT: TEST FAILED - TIMEOUT");
        $display("Simulation time: %0t", $time);
        $display("========================================");

        $finish;
    end

endmodule