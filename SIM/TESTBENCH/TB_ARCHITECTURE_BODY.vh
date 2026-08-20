    parameter integer CROSSBAR_DIMENSION = 8; // X and D lanes in the square crossbar.
    parameter integer BIT_LENGTH = 8; // Pulse cycles in one complete train set; use <=8 to exercise active grouping.
    parameter integer STOCHASTIC_VALUE_WIDTH = 16; // Bits per normalized [0,1] value.
    parameter integer OUTPUT_BUFFER_DEPTH = 10; // DUT output FIFO entries.
    parameter integer SAMPLE_COUNT = 2048; // X/D pairs loaded from the stimulus file.
    parameter integer CLOCK_PERIOD = 3; // Clock period in nanoseconds.
    parameter integer MAX_SIMULATION_CYCLES = 250000; // Timeout guard.
    parameter integer ENABLE_OUTPUT_BACKPRESSURE = 0; // 1: periodically stall output consumption.
    parameter integer OUTPUT_STALL_PERIOD = 7; // Backpressure pattern length in clocks.
    parameter integer OUTPUT_STALL_CYCLES = 2; // Stalled clocks at the start of each pattern.
    parameter [8*256-1:0] STIMULUS_FILE =
        "../../../../TESTBENCH/data/x_d_training_pairs.hex"; // Normalized X/D inputs.

    localparam integer VALUE_VECTOR_WIDTH =
        CROSSBAR_DIMENSION * STOCHASTIC_VALUE_WIDTH;
    localparam integer PAIR_WIDTH = 2 * VALUE_VECTOR_WIDTH;
    localparam integer EXPECTED_SET_COUNT = SAMPLE_COUNT / BIT_LENGTH;
    localparam integer STARTUP_CYCLES = 2; // Reset-release and first-drive cycles excluded from throughput.
    localparam [8*64-1:0] ARCHITECTURE_NAME = `ARCHITECTURE_NAME;

`ifdef GROUP_MASK_ARCHITECTURE
    localparam integer IS_GROUP_MASK_ARCHITECTURE = 1;
`else
    localparam integer IS_GROUP_MASK_ARCHITECTURE = 0;
`endif

    // Active grouping may emit mathematically equivalent layers in a different
    // order because complete all-one layers are sent during input capture.
    // Frames above the limit bypass grouping and retain ordered stream checks.
    localparam integer GROUP_MASK_BIT_LENGTH_LIMIT = 8;
    localparam integer ACTIVE_GROUP_MASK =
        IS_GROUP_MASK_ARCHITECTURE &&
        (BIT_LENGTH <= GROUP_MASK_BIT_LENGTH_LIMIT);
    localparam integer GROUP_MASK_BYPASS =
        IS_GROUP_MASK_ARCHITECTURE &&
        (BIT_LENGTH > GROUP_MASK_BIT_LENGTH_LIMIT);
    localparam integer UPDATE_MATRIX_ENTRIES =
        CROSSBAR_DIMENSION * CROSSBAR_DIMENSION;

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
    reg                           PULSE_DONE;

    reg [PAIR_WIDTH-1:0] stimulus_memory [0:SAMPLE_COUNT-1];
    reg [8*256-1:0] stimulus_path;

    integer drive_index;
    integer verify_index;
    integer stimulus_fd;
    integer expected_events_checked;
    integer golden_errors;
    integer metrics_fd;

    integer actual_update_matrix [0:UPDATE_MATRIX_ENTRIES-1];
    integer reference_update_matrix [0:UPDATE_MATRIX_ENTRIES-1];
    // Exact stream accepted immediately before the output FIFO.
    // This reference remains valid when randomness is generated internally.
    reg [CROSSBAR_DIMENSION-1:0] stream_reference_x [0:BIT_LENGTH-1];
    reg [CROSSBAR_DIMENSION-1:0] stream_reference_d [0:BIT_LENGTH-1];
    integer stream_reference_count;
    integer stream_output_index;
    integer matrix_reset_index;
    integer matrix_compare_index;
    integer actual_frame_output_events;


    integer cycle_count;
    integer accepted_samples;
    integer completed_sets;
    integer output_pairs;
    integer x_output_pulses;
    integer d_output_pulses;
    integer output_toggles;
    integer input_stall_cycles;
    integer buffer_full_cycles;
    integer kept_pairs;
    integer deleted_pairs;
    integer first_accept_cycle;
    integer last_set_done_cycle;
    integer errors;

    reg [CROSSBAR_DIMENSION-1:0] previous_x_output;
    reg [CROSSBAR_DIMENSION-1:0] previous_d_output;
    reg stimulus_loaded;
    reg stimulus_complete;
    reg test_finished;
    reg set_pending_completion;
    reg stalled_output_pending;
    reg [CROSSBAR_DIMENSION-1:0] stalled_x_output;
    reg [CROSSBAR_DIMENSION-1:0] stalled_d_output;

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
`ifdef PER_INPUT_LFSR_ARCHITECTURE
    // Prove that a per-input TB elaborated the independent generator bank
    // and that every lane receives the deterministic nonzero seed intended
    // by ARCH_TOP. A shared-wrapper/filelist mix-up fails at elaboration
    // because the hierarchy below does not exist in the shared architecture.
    genvar lfsr_check_lane;
    generate
        for (lfsr_check_lane = 0;
             lfsr_check_lane < CROSSBAR_DIMENSION;
             lfsr_check_lane = lfsr_check_lane + 1) begin : GEN_CHECK_PER_INPUT_LFSR_SEEDS
            localparam [STOCHASTIC_VALUE_WIDTH-1:0] X_CHECK_SEED_RAW =
                16'hACE1 ^ ((2*lfsr_check_lane + 1) * 32'h9E37_79B9);
            localparam [STOCHASTIC_VALUE_WIDTH-1:0] D_CHECK_SEED_RAW =
                16'hACE1 ^ ((2*lfsr_check_lane + 2) * 32'h7F4A_7C15);
            localparam [STOCHASTIC_VALUE_WIDTH-1:0] X_CHECK_SEED =
                (X_CHECK_SEED_RAW == {STOCHASTIC_VALUE_WIDTH{1'b0}}) ?
                {{(STOCHASTIC_VALUE_WIDTH-1){1'b0}}, 1'b1} :
                X_CHECK_SEED_RAW;
            localparam [STOCHASTIC_VALUE_WIDTH-1:0] D_CHECK_SEED =
                (D_CHECK_SEED_RAW == {STOCHASTIC_VALUE_WIDTH{1'b0}}) ?
                {{(STOCHASTIC_VALUE_WIDTH-1){1'b0}}, 1'b1} :
                D_CHECK_SEED_RAW;

            initial begin : VERIFY_LFSR_RESET_SEEDS
                wait (RST === 1'b0);
                @(posedge CLK);
                #0.1;
                if (dut.architecture_top.
                    GEN_INDEPENDENT_LFSR_PULSE_GENERATION.
                    GEN_LANE_RANDOM_SOURCES[lfsr_check_lane].
                    x_lane_lfsr.VALUE !== X_CHECK_SEED) begin
                    $fatal(1,
                        "X lane %0d LFSR seed mismatch: expected %h, got %h",
                        lfsr_check_lane, X_CHECK_SEED,
                        dut.architecture_top.
                        GEN_INDEPENDENT_LFSR_PULSE_GENERATION.
                        GEN_LANE_RANDOM_SOURCES[lfsr_check_lane].
                        x_lane_lfsr.VALUE);
                end
                if (dut.architecture_top.
                    GEN_INDEPENDENT_LFSR_PULSE_GENERATION.
                    GEN_LANE_RANDOM_SOURCES[lfsr_check_lane].
                    d_lane_lfsr.VALUE !== D_CHECK_SEED) begin
                    $fatal(1,
                        "D lane %0d LFSR seed mismatch: expected %h, got %h",
                        lfsr_check_lane, D_CHECK_SEED,
                        dut.architecture_top.
                        GEN_INDEPENDENT_LFSR_PULSE_GENERATION.
                        GEN_LANE_RANDOM_SOURCES[lfsr_check_lane].
                        d_lane_lfsr.VALUE);
                end
            end
        end
    endgenerate
`endif



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


    task accumulate_actual_update;
        input [CROSSBAR_DIMENSION-1:0] x_pulses;
        input [CROSSBAR_DIMENSION-1:0] d_pulses;
        integer x_lane;
        integer d_lane;
        integer matrix_entry;
        begin
            actual_frame_output_events = actual_frame_output_events + 1;
            for (x_lane = 0;
                 x_lane < CROSSBAR_DIMENSION;
                 x_lane = x_lane + 1) begin
                for (d_lane = 0;
                     d_lane < CROSSBAR_DIMENSION;
                     d_lane = d_lane + 1) begin
                    matrix_entry = x_lane*CROSSBAR_DIMENSION + d_lane;
                    if (x_pulses[x_lane] && d_pulses[d_lane])
                        actual_update_matrix[matrix_entry] =
                            actual_update_matrix[matrix_entry] + 1;
                end
            end
        end
    endtask

    // Reference contribution entering the group-mask stage. This is taken
    // directly from the DUT after optional sorting and zero-delete selection,
    // so active group-mask tests do not depend on an old ordered golden file.
    task accumulate_reference_update;
        input [CROSSBAR_DIMENSION-1:0] x_pulses;
        input [CROSSBAR_DIMENSION-1:0] d_pulses;
        integer x_lane;
        integer d_lane;
        integer matrix_entry;
        begin
            for (x_lane = 0;
                 x_lane < CROSSBAR_DIMENSION;
                 x_lane = x_lane + 1) begin
                for (d_lane = 0;
                     d_lane < CROSSBAR_DIMENSION;
                     d_lane = d_lane + 1) begin
                    matrix_entry = x_lane*CROSSBAR_DIMENSION + d_lane;
                    if (x_pulses[x_lane] && d_pulses[d_lane])
                        reference_update_matrix[matrix_entry] =
                            reference_update_matrix[matrix_entry] + 1;
                end
            end
        end
    endtask

    // Record each kept pair accepted immediately before the output FIFO.
    task capture_stream_reference;
        input [CROSSBAR_DIMENSION-1:0] x_pulses;
        input [CROSSBAR_DIMENSION-1:0] d_pulses;
        begin
            if (stream_reference_count >= BIT_LENGTH) begin
                $display("ERROR [%0s]: stream reference overflow in frame %0d",
                         ARCHITECTURE_NAME, completed_sets);
                golden_errors = golden_errors + 1;
            end else begin
                stream_reference_x[stream_reference_count] = x_pulses;
                stream_reference_d[stream_reference_count] = d_pulses;
                stream_reference_count = stream_reference_count + 1;
            end
        end
    endtask

    // Compare each consumed output against the corresponding kept pair.
    task check_stream_output;
        input [CROSSBAR_DIMENSION-1:0] x_pulses;
        input [CROSSBAR_DIMENSION-1:0] d_pulses;
        begin
            expected_events_checked = expected_events_checked + 1;

            if (stream_output_index >= stream_reference_count) begin
                $display("ERROR [%0s]: unexpected output %0d in frame %0d",
                         ARCHITECTURE_NAME,
                         stream_output_index,
                         completed_sets);
                golden_errors = golden_errors + 1;
            end else begin
                if ((x_pulses !== stream_reference_x[stream_output_index]) ||
                    (d_pulses !== stream_reference_d[stream_output_index])) begin
                    $display("ERROR [%0s]: output %0d expected X=%h D=%h, received X=%h D=%h",
                             ARCHITECTURE_NAME,
                             stream_output_index,
                             stream_reference_x[stream_output_index],
                             stream_reference_d[stream_output_index],
                             x_pulses,
                             d_pulses);
                    golden_errors = golden_errors + 1;
                end
            end

            stream_output_index = stream_output_index + 1;
        end
    endtask

    task check_stream_frame;
        begin
            expected_events_checked = expected_events_checked + 1;

            if (stream_output_index != stream_reference_count) begin
                $display("ERROR [%0s]: frame %0d expected %0d outputs, received %0d",
                         ARCHITECTURE_NAME,
                         completed_sets,
                         stream_reference_count,
                         stream_output_index);
                golden_errors = golden_errors + 1;
            end

            stream_reference_count = 0;
            stream_output_index = 0;
        end
    endtask

    // Compare the accumulated output update against the exact update that
    // entered the active group-mask stage. Output ordering, group ordering and
    // unary-layer decomposition may differ without changing the crossbar update.
    task check_order_independent_frame;
        integer matrix_entry;
        begin
            expected_events_checked = expected_events_checked + 1;

            for (matrix_entry = 0;
                 matrix_entry < UPDATE_MATRIX_ENTRIES;
                 matrix_entry = matrix_entry + 1) begin
                if (actual_update_matrix[matrix_entry] !=
                    reference_update_matrix[matrix_entry]) begin
                    $display("ERROR [%0s]: frame %0d update[%0d,%0d] expected %0d, received %0d",
                             ARCHITECTURE_NAME,
                             completed_sets,
                             matrix_entry / CROSSBAR_DIMENSION,
                             matrix_entry % CROSSBAR_DIMENSION,
                             reference_update_matrix[matrix_entry],
                             actual_update_matrix[matrix_entry]);
                    golden_errors = golden_errors + 1;
                end

                actual_update_matrix[matrix_entry] = 0;
                reference_update_matrix[matrix_entry] = 0;
            end

            actual_frame_output_events = 0;
        end
    endtask

    always #(CLOCK_PERIOD / 2.0) CLK = ~CLK;

    // Performance runs remain always-ready by default. Enable the deterministic
    // pattern to exercise FIFO backpressure and GROUP_MASK's output holding path.
    always @(negedge CLK or negedge RST) begin
        if (!RST) begin
            PULSE_DONE <= 1'b0;
        end else if (!ENABLE_OUTPUT_BACKPRESSURE) begin
            PULSE_DONE <= 1'b1;
        end else begin
            PULSE_DONE <=
                ((cycle_count % OUTPUT_STALL_PERIOD) >= OUTPUT_STALL_CYCLES);
        end
    end

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
            kept_pairs           <= 0;
            deleted_pairs        <= 0;
            first_accept_cycle   <= -1;
            last_set_done_cycle  <= -1;
            errors               <= 0;
            previous_x_output      <= {CROSSBAR_DIMENSION{1'b0}};
            previous_d_output      <= {CROSSBAR_DIMENSION{1'b0}};
            set_pending_completion <= 1'b0;
            stalled_output_pending <= 1'b0;
            stalled_x_output       <= {CROSSBAR_DIMENSION{1'b0}};
            stalled_d_output       <= {CROSSBAR_DIMENSION{1'b0}};
            actual_frame_output_events = 0;
            stream_reference_count = 0;
            stream_output_index = 0;
            for (matrix_reset_index = 0;
                 matrix_reset_index < UPDATE_MATRIX_ENTRIES;
                 matrix_reset_index = matrix_reset_index + 1) begin
                actual_update_matrix[matrix_reset_index] = 0;
                reference_update_matrix[matrix_reset_index] = 0;
            end
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

            // Zero delete cannot avoid pulse sampling, but it removes these
            // pairs from downstream buffering and crossbar update work.
            if (dut.architecture_top.preprocess_valid &&
                dut.architecture_top.preprocess_ready) begin
                if (dut.architecture_top.keep_preprocessed_pair)
                    kept_pairs <= kept_pairs + 1;
                else
                    deleted_pairs <= deleted_pairs + 1;
            end

            if (INPUT_VALID && READY_IN &&
                ((accepted_samples % BIT_LENGTH) == (BIT_LENGTH - 1)))
                set_pending_completion <= 1'b1;

            // Capture the exact accepted stream after optional sorting and
            // zero deletion. For active grouping, compare update equivalence;
            // otherwise compare the ordered stream against the FIFO output.
            if (dut.architecture_top.preprocess_valid &&
                dut.architecture_top.preprocess_ready &&
                dut.architecture_top.keep_preprocessed_pair) begin
                if (ACTIVE_GROUP_MASK)
                    accumulate_reference_update(
                        dut.architecture_top.x_pulses_preprocessed,
                        dut.architecture_top.d_pulses_preprocessed
                    );
                else
                    capture_stream_reference(
                        dut.architecture_top.x_pulses_preprocessed,
                        dut.architecture_top.d_pulses_preprocessed
                    );
            end

            if (VALID_OUT && PULSE_DONE) begin
                if (ACTIVE_GROUP_MASK)
                    accumulate_actual_update(X_PULSES_OUT, D_PULSES_OUT);
                else
                    check_stream_output(X_PULSES_OUT, D_PULSES_OUT);
            end else if (FRAME_DONE) begin
                if (ACTIVE_GROUP_MASK)
                    check_order_independent_frame;
                else
                    check_stream_frame;
            end

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

            if (stalled_output_pending) begin
                if (!VALID_OUT ||
                    (X_PULSES_OUT !== stalled_x_output) ||
                    (D_PULSES_OUT !== stalled_d_output)) begin
                    $display("ERROR [%0s]: output changed while PULSE_DONE was low at %0t",
                             ARCHITECTURE_NAME, $time);
                    errors <= errors + 1;
                end
            end

            stalled_output_pending <= VALID_OUT && !PULSE_DONE;
            if (VALID_OUT && !PULSE_DONE) begin
                stalled_x_output <= X_PULSES_OUT;
                stalled_d_output <= D_PULSES_OUT;
            end

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
        PULSE_DONE = 1'b0;
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

        if ($value$plusargs("STIMULUS_FILE=%s", stimulus_path))
            $display("Using stimulus override: %0s", stimulus_path);

        stimulus_fd = $fopen(stimulus_path, "r");
        if (stimulus_fd == 0) begin
            $display("ERROR [%0s]: cannot open stimulus file %0s",
                     ARCHITECTURE_NAME, stimulus_path);
            $finish;
        end

        $fclose(stimulus_fd);
        $readmemh(stimulus_path, stimulus_memory);

        for (verify_index = 0;
             verify_index < SAMPLE_COUNT;
             verify_index = verify_index + 1) begin
            if ((^stimulus_memory[verify_index]) === 1'bx) begin
                $display("ERROR [%0s]: stimulus entry %0d is invalid",
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
            // Legacy random ports are ignored; randomness is internal.
            X_RANDOM_VALUES = {VALUE_VECTOR_WIDTH{1'b0}};
            D_RANDOM_VALUES = {VALUE_VECTOR_WIDTH{1'b0}};
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

        if (IS_GROUP_MASK_ARCHITECTURE &&
            (BIT_LENGTH <= GROUP_MASK_BIT_LENGTH_LIMIT) &&
            (input_stall_cycles != 0)) begin
            $display("ERROR [%0s]: active group mask stalled %0d input cycles; expected one input per clock",
                     ARCHITECTURE_NAME, input_stall_cycles);
            errors = errors + 1;
        end

        metrics_fd = $fopen("architecture_metrics.csv", "w");
        if (metrics_fd != 0) begin
            $fdisplay(metrics_fd,
                "architecture,samples,sets,cycles,startup_cycles,end_to_end_latency_cycles,input_stall_cycles,buffer_full_cycles,kept_pairs,deleted_pairs,output_pairs,x_output_pulses,d_output_pulses,output_toggles,expected_events,golden_errors,errors");
            $fdisplay(metrics_fd,
                "%0s,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
                ARCHITECTURE_NAME,
                accepted_samples,
                completed_sets,
                cycle_count,
                STARTUP_CYCLES,
                last_set_done_cycle - first_accept_cycle + 1,
                input_stall_cycles,
                buffer_full_cycles,
                kept_pairs,
                deleted_pairs,
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
        if (ACTIVE_GROUP_MASK)
            $display("Golden comparison mode       : pre-group/update equivalence");
        else
            $display("Golden comparison mode       : live pre-FIFO sequence");
        $display("Output backpressure enabled : %0d",
                 ENABLE_OUTPUT_BACKPRESSURE);
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
        $display("Golden/equivalence checks    : %0d", expected_events_checked);
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
