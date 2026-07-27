    parameter integer CROSSBAR_DIMENSION = 8; // X and D lanes in the square crossbar.
    parameter integer BIT_LENGTH = 32; // Pulse cycles in one complete train set.
    parameter integer STOCHASTIC_VALUE_WIDTH = 16; // Bits per normalized [0,1] value.
    parameter integer OUTPUT_BUFFER_DEPTH = 10; // DUT output FIFO entries.
    parameter integer SAMPLE_COUNT = 2048; // X/D pairs loaded from the stimulus file.
    parameter integer CLOCK_PERIOD = 10; // Clock period in nanoseconds.
    parameter integer MAX_SIMULATION_CYCLES = 250000; // Timeout guard.
    parameter [8*256-1:0] STIMULUS_FILE =
        "../../../../TESTBENCH/data/x_d_training_pairs.hex"; // Normalized X/D inputs.
    parameter [8*256-1:0] RANDOM_FILE =
        "../../../../TESTBENCH/data/random_values.hex"; // Deterministic per-sample lane random values.

    localparam integer VALUE_VECTOR_WIDTH =
        CROSSBAR_DIMENSION * STOCHASTIC_VALUE_WIDTH;
    localparam integer PAIR_WIDTH = 2 * VALUE_VECTOR_WIDTH;
    localparam integer EXPECTED_SET_COUNT = SAMPLE_COUNT / BIT_LENGTH;
    localparam [8*64-1:0] ARCHITECTURE_NAME = `ARCHITECTURE_NAME;

    reg CLK;
    reg RST;
    reg INPUT_VALID;
    reg [VALUE_VECTOR_WIDTH-1:0] X_INPUT_VALUES;
    reg [VALUE_VECTOR_WIDTH-1:0] D_INPUT_VALUES;
    reg [VALUE_VECTOR_WIDTH-1:0] X_RANDOM_VALUES;
    reg [VALUE_VECTOR_WIDTH-1:0] D_RANDOM_VALUES;

    wire [CROSSBAR_DIMENSION-1:0] X_PULSES_OUT;
    wire [CROSSBAR_DIMENSION-1:0] D_PULSES_OUT;
    wire                          VALID_OUT;
    wire                          READY_IN;
    wire                          BUFFER_FULL;
    wire                          FRAME_DONE;
    wire                          PULSE_DONE = RST; // Consume every available output.

    reg [PAIR_WIDTH-1:0] stimulus_memory [0:SAMPLE_COUNT-1];
    reg [PAIR_WIDTH-1:0] random_memory [0:SAMPLE_COUNT-1];
    reg [8*256-1:0] stimulus_path;
    reg [8*256-1:0] random_path;
    reg [8*256-1:0] expected_path;

    integer drive_index;
    integer verify_index;
    integer stimulus_fd;
    integer random_fd;
    integer expected_fd;
    integer expected_scan_result;
    integer expected_event_type;
    integer expected_frame_index;
    integer expected_events_checked;
    integer golden_errors;
    integer metrics_fd;

    reg [CROSSBAR_DIMENSION-1:0] expected_x_pulses;
    reg [CROSSBAR_DIMENSION-1:0] expected_d_pulses;

    integer cycle_count;
    integer accepted_samples;
    integer completed_sets;
    integer output_pairs;
    integer x_output_pulses;
    integer d_output_pulses;
    integer output_toggles;
    integer input_stall_cycles;
    integer buffer_full_cycles;
    integer first_accept_cycle;
    integer last_set_done_cycle;
    integer errors;

    reg [CROSSBAR_DIMENSION-1:0] previous_x_output;
    reg [CROSSBAR_DIMENSION-1:0] previous_d_output;
    reg stimulus_loaded;
    reg stimulus_complete;
    reg test_finished;
    reg set_pending_completion;

    TOP #(
        .CROSSBAR_DIMENSION    (CROSSBAR_DIMENSION),
        .BIT_LENGTH            (BIT_LENGTH),
        .STOCHASTIC_VALUE_WIDTH(STOCHASTIC_VALUE_WIDTH),
        .OUTPUT_BUFFER_DEPTH   (OUTPUT_BUFFER_DEPTH)
    ) dut (
        .CLK            (CLK),
        .RST            (RST),
        .INPUT_VALID    (INPUT_VALID),
        .X_INPUT_VALUES (X_INPUT_VALUES),
        .D_INPUT_VALUES (D_INPUT_VALUES),
        .X_RANDOM_VALUES(X_RANDOM_VALUES),
        .D_RANDOM_VALUES(D_RANDOM_VALUES),
        .PULSE_DONE     (PULSE_DONE),
        .X_PULSES_OUT   (X_PULSES_OUT),
        .D_PULSES_OUT   (D_PULSES_OUT),
        .VALID_OUT      (VALID_OUT),
        .READY_IN       (READY_IN),
        .BUFFER_FULL    (BUFFER_FULL),
        .FRAME_DONE     (FRAME_DONE)
    );

    localparam integer EXPECTED_OUTPUT_EVENT = 0;
    localparam integer EXPECTED_FRAME_EVENT = 1;

    function integer count_ones;
        input [CROSSBAR_DIMENSION-1:0] value;
        integer bit_index;
        begin
            count_ones = 0;
            for (bit_index = 0;
                 bit_index < CROSSBAR_DIMENSION;
                 bit_index = bit_index + 1) begin
                if (value[bit_index])
                    count_ones = count_ones + 1;
            end
        end
    endfunction

    // Consume one independent golden event for each output or frame boundary.
    task check_expected_event;
        input integer actual_event_type;
        input [CROSSBAR_DIMENSION-1:0] actual_x_pulses;
        input [CROSSBAR_DIMENSION-1:0] actual_d_pulses;
        begin
            expected_scan_result = $fscanf(
                expected_fd,
                "%d %d %h %h\n",
                expected_event_type,
                expected_frame_index,
                expected_x_pulses,
                expected_d_pulses
            );

            if (expected_scan_result != 4) begin
                $display("ERROR [%0s]: expected event file ended early at event %0d",
                         ARCHITECTURE_NAME, expected_events_checked);
                golden_errors = golden_errors + 1;
            end else begin
                expected_events_checked = expected_events_checked + 1;

                if (expected_event_type != actual_event_type) begin
                    $display("ERROR [%0s]: event %0d type expected %0d, received %0d",
                             ARCHITECTURE_NAME,
                             expected_events_checked - 1,
                             expected_event_type,
                             actual_event_type);
                    golden_errors = golden_errors + 1;
                end

                if (expected_frame_index != completed_sets) begin
                    $display("ERROR [%0s]: event %0d frame expected %0d, received %0d",
                             ARCHITECTURE_NAME,
                             expected_events_checked - 1,
                             expected_frame_index,
                             completed_sets);
                    golden_errors = golden_errors + 1;
                end

                if ((actual_event_type == EXPECTED_OUTPUT_EVENT) &&
                    ((expected_x_pulses !== actual_x_pulses) ||
                     (expected_d_pulses !== actual_d_pulses))) begin
                    $display("ERROR [%0s]: event %0d expected X=%h D=%h, received X=%h D=%h",
                             ARCHITECTURE_NAME,
                             expected_events_checked - 1,
                             expected_x_pulses,
                             expected_d_pulses,
                             actual_x_pulses,
                             actual_d_pulses);
                    golden_errors = golden_errors + 1;
                end
            end
        end
    endtask

    always #(CLOCK_PERIOD / 2) CLK = ~CLK;

    // Count accepted work and activity without placing logic inside the DUT.
    always @(posedge CLK) begin
        if (!RST) begin
            cycle_count          <= 0;
            accepted_samples     <= 0;
            completed_sets       <= 0;
            output_pairs         <= 0;
            x_output_pulses      <= 0;
            d_output_pulses      <= 0;
            output_toggles       <= 0;
            input_stall_cycles   <= 0;
            buffer_full_cycles   <= 0;
            first_accept_cycle   <= -1;
            last_set_done_cycle  <= -1;
            errors               <= 0;
            previous_x_output      <= {CROSSBAR_DIMENSION{1'b0}};
            previous_d_output      <= {CROSSBAR_DIMENSION{1'b0}};
            set_pending_completion <= 1'b0;
        end else begin
            cycle_count <= cycle_count + 1;

            if (INPUT_VALID && READY_IN) begin
                if (accepted_samples == 0)
                    first_accept_cycle <= cycle_count;
                accepted_samples <= accepted_samples + 1;
            end

            if (INPUT_VALID && !READY_IN)
                input_stall_cycles <= input_stall_cycles + 1;

            if (BUFFER_FULL)
                buffer_full_cycles <= buffer_full_cycles + 1;

            if (INPUT_VALID && READY_IN &&
                ((accepted_samples % BIT_LENGTH) == (BIT_LENGTH - 1)))
                set_pending_completion <= 1'b1;

            if (VALID_OUT && PULSE_DONE)
                check_expected_event(
                    EXPECTED_OUTPUT_EVENT,
                    X_PULSES_OUT,
                    D_PULSES_OUT
                );
            else if (FRAME_DONE)
                check_expected_event(
                    EXPECTED_FRAME_EVENT,
                    {CROSSBAR_DIMENSION{1'b0}},
                    {CROSSBAR_DIMENSION{1'b0}}
                );

            if (FRAME_DONE) begin
                completed_sets         <= completed_sets + 1;
                last_set_done_cycle    <= cycle_count;
                set_pending_completion <= 1'b0;
            end

            if (set_pending_completion && READY_IN && !FRAME_DONE) begin
                $display("ERROR [%0s]: READY_IN reopened before set completion at %0t",
                         ARCHITECTURE_NAME, $time);
                errors <= errors + 1;
            end

            if (FRAME_DONE && VALID_OUT) begin
                $display("ERROR [%0s]: stale output remains valid after FRAME_DONE at %0t",
                         ARCHITECTURE_NAME, $time);
                errors <= errors + 1;
            end

            if (VALID_OUT && PULSE_DONE) begin
                output_pairs    <= output_pairs + 1;
                x_output_pulses <= x_output_pulses +
                    count_ones(X_PULSES_OUT);
                d_output_pulses <= d_output_pulses +
                    count_ones(D_PULSES_OUT);
            end

            output_toggles <= output_toggles +
                count_ones(X_PULSES_OUT ^ previous_x_output) +
                count_ones(D_PULSES_OUT ^ previous_d_output);
            previous_x_output <= X_PULSES_OUT;
            previous_d_output <= D_PULSES_OUT;

            if ((READY_IN !== 1'b0) && (READY_IN !== 1'b1)) begin
                $display("ERROR [%0s]: READY_IN is unknown at %0t",
                         ARCHITECTURE_NAME, $time);
                errors <= errors + 1;
            end

            if ((VALID_OUT !== 1'b0) && (VALID_OUT !== 1'b1)) begin
                $display("ERROR [%0s]: VALID_OUT is unknown at %0t",
                         ARCHITECTURE_NAME, $time);
                errors <= errors + 1;
            end else if (VALID_OUT &&
                         (((^X_PULSES_OUT) === 1'bx) ||
                          ((^D_PULSES_OUT) === 1'bx))) begin
                $display("ERROR [%0s]: valid output contains X at %0t",
                         ARCHITECTURE_NAME, $time);
                errors <= errors + 1;
            end
        end
    end

    initial begin : CLOCK_AND_RESET
        CLK = 1'b0;
        RST = 1'b0;
        repeat (5) @(posedge CLK);
        @(negedge CLK);
        RST = 1'b1;
    end

    initial begin : LOAD_AND_DRIVE_STIMULUS
        INPUT_VALID       = 1'b0;
        X_INPUT_VALUES    = {VALUE_VECTOR_WIDTH{1'b0}};
        D_INPUT_VALUES    = {VALUE_VECTOR_WIDTH{1'b0}};
        X_RANDOM_VALUES   = {VALUE_VECTOR_WIDTH{1'b0}};
        D_RANDOM_VALUES   = {VALUE_VECTOR_WIDTH{1'b0}};
        stimulus_loaded   = 1'b0;
        stimulus_complete = 1'b0;
        expected_events_checked = 0;
        golden_errors     = 0;
        stimulus_path     = STIMULUS_FILE;
        random_path       = RANDOM_FILE;
        $sformat(
            expected_path,
            "../../../../TESTBENCH/data/expected/%0s.expected",
            ARCHITECTURE_NAME
        );

        if ($value$plusargs("STIMULUS_FILE=%s", stimulus_path))
            $display("Using stimulus override: %0s", stimulus_path);
        if ($value$plusargs("RANDOM_FILE=%s", random_path))
            $display("Using random override: %0s", random_path);
        if ($value$plusargs("EXPECTED_FILE=%s", expected_path))
            $display("Using expected-output override: %0s", expected_path);

        stimulus_fd = $fopen(stimulus_path, "r");
        random_fd = $fopen(random_path, "r");
        expected_fd = $fopen(expected_path, "r");

        if (stimulus_fd == 0) begin
            $display("ERROR [%0s]: cannot open stimulus file %0s",
                     ARCHITECTURE_NAME, stimulus_path);
            $finish;
        end
        if (random_fd == 0) begin
            $display("ERROR [%0s]: cannot open random file %0s",
                     ARCHITECTURE_NAME, random_path);
            $finish;
        end
        if (expected_fd == 0) begin
            $display("ERROR [%0s]: cannot open expected file %0s",
                     ARCHITECTURE_NAME, expected_path);
            $finish;
        end

        $fclose(stimulus_fd);
        $fclose(random_fd);
        $readmemh(stimulus_path, stimulus_memory);
        $readmemh(random_path, random_memory);

        for (verify_index = 0;
             verify_index < SAMPLE_COUNT;
             verify_index = verify_index + 1) begin
            if ((^stimulus_memory[verify_index]) === 1'bx) begin
                $display("ERROR [%0s]: stimulus entry %0d is invalid",
                         ARCHITECTURE_NAME, verify_index);
                $finish;
            end
            if ((^random_memory[verify_index]) === 1'bx) begin
                $display("ERROR [%0s]: random entry %0d is invalid",
                         ARCHITECTURE_NAME, verify_index);
                $finish;
            end
        end

        if ((SAMPLE_COUNT % BIT_LENGTH) != 0) begin
            $display("ERROR [%0s]: SAMPLE_COUNT must be divisible by BIT_LENGTH",
                     ARCHITECTURE_NAME);
            $finish;
        end

        stimulus_loaded = 1'b1;
        wait (RST === 1'b1);

        for (drive_index = 0;
             drive_index < SAMPLE_COUNT;
             drive_index = drive_index + 1) begin
            // Do not present a new set until the previous set is fully consumed.
            if ((drive_index != 0) &&
                ((drive_index % BIT_LENGTH) == 0)) begin
                @(negedge CLK);
                INPUT_VALID     = 1'b0;
                X_INPUT_VALUES  = {VALUE_VECTOR_WIDTH{1'b0}};
                D_INPUT_VALUES  = {VALUE_VECTOR_WIDTH{1'b0}};
                X_RANDOM_VALUES = {VALUE_VECTOR_WIDTH{1'b0}};
                D_RANDOM_VALUES = {VALUE_VECTOR_WIDTH{1'b0}};
                wait (completed_sets >= (drive_index / BIT_LENGTH));
            end

            @(negedge CLK);
            X_INPUT_VALUES = stimulus_memory[drive_index]
                [PAIR_WIDTH-1 -: VALUE_VECTOR_WIDTH];
            D_INPUT_VALUES = stimulus_memory[drive_index]
                [VALUE_VECTOR_WIDTH-1:0];
            X_RANDOM_VALUES = random_memory[drive_index]
                [PAIR_WIDTH-1 -: VALUE_VECTOR_WIDTH];
            D_RANDOM_VALUES = random_memory[drive_index]
                [VALUE_VECTOR_WIDTH-1:0];
            INPUT_VALID = 1'b1;

            // Hold this pair until the DUT accepts it on a rising edge.
            @(posedge CLK);
            while (READY_IN !== 1'b1)
                @(posedge CLK);
        end

        @(negedge CLK);
        INPUT_VALID       = 1'b0;
        X_INPUT_VALUES    = {VALUE_VECTOR_WIDTH{1'b0}};
        D_INPUT_VALUES    = {VALUE_VECTOR_WIDTH{1'b0}};
        X_RANDOM_VALUES   = {VALUE_VECTOR_WIDTH{1'b0}};
        D_RANDOM_VALUES   = {VALUE_VECTOR_WIDTH{1'b0}};
        stimulus_complete = 1'b1;
    end

    initial begin : COMPLETE_AND_REPORT
        test_finished = 1'b0;
        wait (stimulus_loaded && (RST === 1'b1));
        wait (stimulus_complete);
        wait (completed_sets >= EXPECTED_SET_COUNT);
        wait (VALID_OUT === 1'b0);
        repeat (2) @(posedge CLK);

        // One additional read must encounter EOF after the final FRAME event.
        expected_scan_result = $fscanf(
            expected_fd,
            "%d %d %h %h\n",
            expected_event_type,
            expected_frame_index,
            expected_x_pulses,
            expected_d_pulses
        );
        if (expected_scan_result != -1) begin
            $display("ERROR [%0s]: expected file contains extra or malformed events",
                     ARCHITECTURE_NAME);
            golden_errors = golden_errors + 1;
        end
        $fclose(expected_fd);

        if (accepted_samples != SAMPLE_COUNT) begin
            $display("ERROR [%0s]: accepted %0d of %0d samples",
                     ARCHITECTURE_NAME, accepted_samples, SAMPLE_COUNT);
            errors = errors + 1;
        end

        if (completed_sets != EXPECTED_SET_COUNT) begin
            $display("ERROR [%0s]: completed %0d of %0d sets",
                     ARCHITECTURE_NAME,
                     completed_sets,
                     EXPECTED_SET_COUNT);
            errors = errors + 1;
        end

        metrics_fd = $fopen("architecture_metrics.csv", "w");
        if (metrics_fd != 0) begin
            $fdisplay(metrics_fd,
                "architecture,samples,sets,cycles,end_to_end_latency_cycles,input_stall_cycles,buffer_full_cycles,output_pairs,x_output_pulses,d_output_pulses,output_toggles,expected_events,golden_errors,errors");
            $fdisplay(metrics_fd,
                "%0s,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
                ARCHITECTURE_NAME,
                accepted_samples,
                completed_sets,
                cycle_count,
                last_set_done_cycle - first_accept_cycle + 1,
                input_stall_cycles,
                buffer_full_cycles,
                output_pairs,
                x_output_pulses,
                d_output_pulses,
                output_toggles,
                expected_events_checked,
                golden_errors,
                errors + golden_errors);
            $fclose(metrics_fd);
        end else begin
            $display("ERROR [%0s]: cannot create architecture_metrics.csv",
                     ARCHITECTURE_NAME);
            errors = errors + 1;
        end

        $display("");
        $display("============================================================");
        $display("ARCHITECTURE EXPERIMENT: %0s", ARCHITECTURE_NAME);
        $display("Stimulus pairs              : %0d", accepted_samples);
        $display("Completed sets              : %0d", completed_sets);
        $display("Measured cycles             : %0d", cycle_count);
        $display("End-to-end set latency      : %0d",
                 last_set_done_cycle - first_accept_cycle + 1);
        $display("Input stall cycles          : %0d", input_stall_cycles);
        $display("Output pulse pairs          : %0d", output_pairs);
        $display("X output pulses             : %0d", x_output_pulses);
        $display("D output pulses             : %0d", d_output_pulses);
        $display("Output toggles              : %0d", output_toggles);
        $display("Golden events checked       : %0d", expected_events_checked);
        $display("Golden mismatches           : %0d", golden_errors);
        $display("Errors                      : %0d", errors + golden_errors);
        if ((errors + golden_errors) == 0)
            $display("RESULT: PASS");
        else
            $display("RESULT: FAIL");
        $display("============================================================");

        test_finished = 1'b1;
        $finish;
    end

    initial begin : TIMEOUT_GUARD
        wait (RST === 1'b1);
        repeat (MAX_SIMULATION_CYCLES) @(posedge CLK);
        if (!test_finished) begin
            $display("ERROR [%0s]: timeout after %0d cycles",
                     ARCHITECTURE_NAME, MAX_SIMULATION_CYCLES);
            $finish;
        end
    end
