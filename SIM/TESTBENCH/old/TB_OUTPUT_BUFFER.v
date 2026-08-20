`timescale 1ns/100ps

module TB_PULSE_GENERATOR;

    parameter NUM_VALUES  = 8;
    parameter VALUE_WIDTH = 16;
    parameter RANDOM_TESTS = 1000;

    reg  [NUM_VALUES*VALUE_WIDTH-1:0] LFSR_VALUES;
    reg  [NUM_VALUES*VALUE_WIDTH-1:0] INPUT_VALUES;

    wire [NUM_VALUES-1:0] PULSES;
    reg  [NUM_VALUES-1:0] EXPECTED;

    reg [15:0] lfsr_state;
    reg [15:0] input_state;

    integer i;
    integer test_index;
    integer total_tests;
    integer passed_tests;
    integer failed_tests;


    PULSE_GENERATOR #(
        .NUM_VALUES (NUM_VALUES),
        .VALUE_WIDTH(VALUE_WIDTH)
    ) dut (
        .LFSR_VALUES (LFSR_VALUES),
        .INPUT_VALUES(INPUT_VALUES),
        .PULSES      (PULSES)
    );


    /*
     * 16-bit LFSR:
     * Polynomial: x^16 + x^14 + x^13 + x^11 + 1
     *
     * The seed must not be zero.
     */
    function [15:0] lfsr_next;
        input [15:0] current_state;

        begin
            lfsr_next = {
                current_state[14:0],
                current_state[15] ^
                current_state[13] ^
                current_state[12] ^
                current_state[10]
            };
        end
    endfunction


    /*
     * Check the current LFSR_VALUES and INPUT_VALUES.
     *
     * verbose = 1:
     * Print every vector element.
     *
     * verbose = 0:
     * Print details only if the test fails.
     */
    task check_test;
        input integer test_id;
        input integer verbose;

        integer element;

        begin
            /*
             * Allow combinational logic to settle.
             */
            #1;

            for (
                element = 0;
                element < NUM_VALUES;
                element = element + 1
            ) begin
                EXPECTED[element] =
                    LFSR_VALUES[
                        element*VALUE_WIDTH +: VALUE_WIDTH
                    ]
                    <
                    INPUT_VALUES[
                        element*VALUE_WIDTH +: VALUE_WIDTH
                    ];
            end

            total_tests = total_tests + 1;

            if (PULSES === EXPECTED) begin
                passed_tests = passed_tests + 1;

                if (verbose)
                    $display(
                        "TEST %0d: PASS, pulses = %b",
                        test_id,
                        PULSES
                    );
            end
            else begin
                failed_tests = failed_tests + 1;

                $display(
                    "TEST %0d: FAIL, expected = %b, actual = %b",
                    test_id,
                    EXPECTED,
                    PULSES
                );
            end

            if (verbose || (PULSES !== EXPECTED)) begin
                $display(
                    "Element | LFSR value       | Input value      | Pulse"
                );
                $display(
                    "------------------------------------------------------"
                );

                for (
                    element = 0;
                    element < NUM_VALUES;
                    element = element + 1
                ) begin
                    $display(
                        "%0d       | %016b | %016b | %b",
                        element,
                        LFSR_VALUES[
                            element*VALUE_WIDTH +: VALUE_WIDTH
                        ],
                        INPUT_VALUES[
                            element*VALUE_WIDTH +: VALUE_WIDTH
                        ],
                        PULSES[element]
                    );
                end

                $display("");
            end
        end
    endtask


    /*
     * Generate NUM_VALUES consecutive LFSR values.
     */
    task generate_lfsr_values;
        integer element;

        begin
            for (
                element = 0;
                element < NUM_VALUES;
                element = element + 1
            ) begin
                lfsr_state = lfsr_next(lfsr_state);

                LFSR_VALUES[
                    element*VALUE_WIDTH +: VALUE_WIDTH
                ] = lfsr_state;
            end
        end
    endtask


    /*
     * Generate pseudo-random input thresholds from a second
     * independently seeded LFSR sequence.
     */
    task generate_input_values;
        integer element;

        begin
            for (
                element = 0;
                element < NUM_VALUES;
                element = element + 1
            ) begin
                input_state = lfsr_next(input_state);

                INPUT_VALUES[
                    element*VALUE_WIDTH +: VALUE_WIDTH
                ] = input_state;
            end
        end
    endtask


    initial begin
        $dumpfile("TB_PULSE_GENERATOR.vcd");
        $dumpvars(0, TB_PULSE_GENERATOR);

        $timeformat(-9, 1, " ns", 10);

        LFSR_VALUES = 0;
        INPUT_VALUES = 0;
        EXPECTED = 0;

        total_tests = 0;
        passed_tests = 0;
        failed_tests = 0;

        /*
         * Nonzero LFSR seeds.
         */
        lfsr_state = 16'hACE1;
        input_state = 16'h1D3F;


        $display("");
        $display("========================================");
        $display("Directed edge-case tests");
        $display("========================================");


        /*
         * Test 1:
         * 0 < 0 is false for every element.
         */
        LFSR_VALUES = {NUM_VALUES{16'h0000}};
        INPUT_VALUES = {NUM_VALUES{16'h0000}};
        check_test(1, 1);


        /*
         * Test 2:
         * 0 < maximum is true for every element.
         */
        LFSR_VALUES = {NUM_VALUES{16'h0000}};
        INPUT_VALUES = {NUM_VALUES{16'hFFFF}};
        check_test(2, 1);


        /*
         * Test 3:
         * maximum < maximum is false.
         */
        LFSR_VALUES = {NUM_VALUES{16'hFFFF}};
        INPUT_VALUES = {NUM_VALUES{16'hFFFF}};
        check_test(3, 1);


        /*
         * Test 4:
         * Equal values must always produce zero because
         * the module uses strict less-than.
         */
        generate_lfsr_values;
        INPUT_VALUES = LFSR_VALUES;
        check_test(4, 1);


        /*
         * Test 5:
         * Input threshold zero must always produce zero.
         */
        generate_lfsr_values;
        INPUT_VALUES = {NUM_VALUES{16'h0000}};
        check_test(5, 1);


        /*
         * Test 6:
         * Mixed comparisons.
         */
        LFSR_VALUES = {
            16'd65535,
            16'd0,
            16'd900,
            16'd600,
            16'd7,
            16'd100,
            16'd50,
            16'd10
        };

        INPUT_VALUES = {
            16'd65535,
            16'd1,
            16'd800,
            16'd700,
            16'd8,
            16'd100,
            16'd40,
            16'd20
        };

        check_test(6, 1);


        $display("");
        $display("========================================");
        $display("%0d LFSR-based regression tests", RANDOM_TESTS);
        $display("========================================");


        /*
         * Generate many deterministic pseudo-random tests.
         */
        for (
            test_index = 0;
            test_index < RANDOM_TESTS;
            test_index = test_index + 1
        ) begin
            generate_lfsr_values;
            generate_input_values;

            check_test(100 + test_index, 0);
        end


        $display("");
        $display("========================================");
        $display("Test summary");
        $display("========================================");
        $display("Total tests:  %0d", total_tests);
        $display("Passed tests: %0d", passed_tests);
        $display("Failed tests: %0d", failed_tests);

        if (failed_tests == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: TEST FAILURE");

        $display("========================================");
        $display("");

        #1;
        $finish;
    end

endmodule
