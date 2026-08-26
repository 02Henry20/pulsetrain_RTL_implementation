`timescale 1ns/1ps

module TB_REPLAY #(
    parameter integer CROSSBAR_DIMENSION = 8,
    parameter integer MAX_BL = 32,
    parameter integer STOCHASTIC_VALUE_WIDTH = 16,
    parameter integer OUTPUT_BUFFER_DEPTH = 10,
    parameter integer DIGITAL_CLOCK_NS = 10,
    parameter [STOCHASTIC_VALUE_WIDTH-1:0] LFSR_SEED = 16'hACE1,
    parameter integer USE_SHARED_LFSR = 0
);
    localparam integer BL_WIDTH = (MAX_BL <= 1) ? 1 : $clog2(MAX_BL + 1);
    localparam integer OCC_WIDTH =
        (OUTPUT_BUFFER_DEPTH <= 1) ? 1 : $clog2(OUTPUT_BUFFER_DEPTH + 1);

    reg CLK = 1'b0;
    reg RST = 1'b0;
    reg INPUT_VALID = 1'b0;
    reg [BL_WIDTH-1:0] INPUT_BL = 0;
    reg [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] X_INPUT_VALUES = 0;
    reg [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] D_INPUT_VALUES = 0;
    reg [CROSSBAR_DIMENSION-1:0] X_RAW_PULSES_IN = 0;
    reg [CROSSBAR_DIMENSION-1:0] D_RAW_PULSES_IN = 0;

    wire OUTPUT_READY;
    wire [CROSSBAR_DIMENSION-1:0] X_PULSES_OUT;
    wire [CROSSBAR_DIMENSION-1:0] D_PULSES_OUT;
    wire VALID_OUT;
    wire READY_IN;
    wire BUFFER_FULL;
    wire [OCC_WIDTH-1:0] BUFFER_OCCUPANCY;
    wire GROUP_MASK_BYPASS;
    wire FRAME_DONE;

    TOP #(
        .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION),
        .MAX_BL(MAX_BL),
        .BL_WIDTH(BL_WIDTH),
        .STOCHASTIC_VALUE_WIDTH(STOCHASTIC_VALUE_WIDTH),
        .OUTPUT_BUFFER_DEPTH(OUTPUT_BUFFER_DEPTH),
        .RAW_REPLAY_MODE(1),
        .LFSR_SEED(LFSR_SEED)
    ) dut (
        .CLK(CLK), .RST(RST),
        .INPUT_VALID(INPUT_VALID), .INPUT_BL(INPUT_BL),
        .X_INPUT_VALUES(X_INPUT_VALUES), .D_INPUT_VALUES(D_INPUT_VALUES),
        .X_RAW_PULSES_IN(X_RAW_PULSES_IN),
        .D_RAW_PULSES_IN(D_RAW_PULSES_IN),
        .OUTPUT_READY(OUTPUT_READY),
        .X_PULSES_OUT(X_PULSES_OUT), .D_PULSES_OUT(D_PULSES_OUT),
        .VALID_OUT(VALID_OUT), .READY_IN(READY_IN),
        .BUFFER_FULL(BUFFER_FULL), .BUFFER_OCCUPANCY(BUFFER_OCCUPANCY),
        .GROUP_MASK_BYPASS(GROUP_MASK_BYPASS), .FRAME_DONE(FRAME_DONE)
    );

    always #(DIGITAL_CLOCK_NS / 2.0) CLK = ~CLK;

    integer saif_enable;
    integer saif_active;
    string saif_path;
    integer saif_clk_cycles;
    integer saif_source_fires;
    integer lfsr_advances;
    integer lfsr_seq_errors;
    integer shared_delay_errors;
    integer rng_fd;
    string rng_stats_path;
    wire src_fire;
    wire [STOCHASTIC_VALUE_WIDTH-1:0] probe_lfsr;
    wire [STOCHASTIC_VALUE_WIDTH-1:0] probe_delay1;
    wire [STOCHASTIC_VALUE_WIDTH-1:0] probe_delay2;
    assign src_fire = dut.architecture_top.source_fire;
    generate
        if (USE_SHARED_LFSR != 0) begin : GEN_RNG_PROBE_SHARED
            assign probe_lfsr = dut.architecture_top.GEN_SHARED_LFSR.shared_lfsr.VALUE;
            assign probe_delay1 = dut.architecture_top.GEN_SHARED_LFSR.d_delay_1;
            assign probe_delay2 = dut.architecture_top.GEN_SHARED_LFSR.d_delay_2;
        end else begin : GEN_RNG_PROBE_INDEPENDENT
            assign probe_lfsr =
                dut.architecture_top.GEN_PER_INPUT_LFSRS.GEN_LANE_LFSRS[0].x_lfsr.VALUE;
            assign probe_delay1 = {STOCHASTIC_VALUE_WIDTH{1'b0}};
            assign probe_delay2 = {STOCHASTIC_VALUE_WIDTH{1'b0}};
        end
    endgenerate

    task saif_begin;
        begin
            if (saif_enable && !saif_active) begin
                $set_toggle_region(dut);
                @(posedge CLK);
                $toggle_start;
                saif_active = 1;
            end
        end
    endtask

    task saif_end;
        begin
            if (saif_active) begin
                $toggle_stop;
                // VCS $toggle_report requires a string literal filename.
                $toggle_report("tb.saif", 1.0e-9, "TB_REPLAY.dut");
                $display("SAIF: wrote tb.saif at time %0t", $time);
                saif_active = 0;
            end
        end
    endtask

    reg [STOCHASTIC_VALUE_WIDTH-1:0] lfsr_q_prev;
    reg [STOCHASTIC_VALUE_WIDTH-1:0] delay1_expect;
    reg [STOCHASTIC_VALUE_WIDTH-1:0] delay2_expect;
    reg src_fire_d;
    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            src_fire_d <= 1'b0;
            lfsr_q_prev <= probe_lfsr;
            delay1_expect <= probe_delay1;
            delay2_expect <= probe_delay2;
        end else begin
            if (saif_active) begin
                saif_clk_cycles <= saif_clk_cycles + 1;
                if (src_fire)
                    saif_source_fires <= saif_source_fires + 1;
            end
            if (src_fire_d) begin
                lfsr_advances <= lfsr_advances + 1;
                if (probe_lfsr === lfsr_q_prev)
                    lfsr_seq_errors <= lfsr_seq_errors + 1;
                if ((USE_SHARED_LFSR != 0) &&
                    ((probe_delay1 !== delay1_expect) ||
                     (probe_delay2 !== delay2_expect)))
                    shared_delay_errors <= shared_delay_errors + 1;
            end
            if (src_fire) begin
                delay1_expect <= probe_lfsr;
                delay2_expect <= probe_delay1;
            end
            src_fire_d <= src_fire;
            lfsr_q_prev <= probe_lfsr;
        end
    end

    integer t_pulse_ns;
    reg device_busy;
    realtime device_completion_target;
    realtime last_device_completion_time;
    integer output_pulse_positions;
    assign OUTPUT_READY = !device_busy;

    // Device readiness changes on the half-cycle before an eligible acceptance
    // edge. This makes exact 10-ns boundaries deterministic and records the
    // exact physical completion time separately from clock-edge availability.
    always @(posedge CLK or negedge CLK or negedge RST) begin
        if (!RST) begin
            device_busy <= 1'b0;
            device_completion_target <= -1.0;
            last_device_completion_time <= -1.0;
        end else if (CLK) begin
            if (VALID_OUT && OUTPUT_READY) begin
                device_busy <= 1'b1;
                device_completion_target <= $realtime + t_pulse_ns;
                last_device_completion_time <= $realtime + t_pulse_ns;
                output_pulse_positions <= output_pulse_positions + 1;
            end
        end else if (
            device_busy &&
            (($realtime + (DIGITAL_CLOCK_NS / 2.0)) >= device_completion_target)
        ) begin
            device_busy <= 1'b0;
        end
    end

    integer trace_fd;
    integer result_fd;
    reg [2047:0] trace_path;
    reg [2047:0] result_path;
    reg [255:0] architecture_name;
    integer trace_updates;
    integer trace_positions;
    integer trace_dimension;
    integer trace_max_bl;
    integer update_id;
    integer update_bl;
    integer update_x_size;
    integer update_d_size;
    integer update_tile_index;
    integer scan_status;
    integer loaded_positions;
    integer update_ordinal;
    integer load_position;
    integer row_update_id;
    integer row_bl;
    integer row_pulse_index;
    integer row_x_size;
    integer row_d_size;
    integer row_tile_index;
    reg [CROSSBAR_DIMENSION-1:0] row_x;
    reg [CROSSBAR_DIMENSION-1:0] row_d;
    reg [CROSSBAR_DIMENSION-1:0] trace_x_frame [0:MAX_BL-1];
    reg [CROSSBAR_DIMENSION-1:0] trace_d_frame [0:MAX_BL-1];

    integer expect_sort;
    integer expect_zero_delete;
    integer expect_baseline;
    integer accepted_candidates;
    integer preprocessed_positions;
    integer baseline_output_index;
    integer deleted_positions;
    integer raw_empty_positions;
    integer input_stall_cycles;
    integer buffer_full_cycles;
    integer max_buffer_occupancy;
    integer update_errors;
    integer total_errors;
    integer processed_updates;
    integer group_mask_bypass_count;
    reg update_active;
    reg frame_seen;
    realtime start_time;
    realtime digital_completion_time;

    integer reference_matrix [0:CROSSBAR_DIMENSION-1][0:CROSSBAR_DIMENSION-1];
    integer output_matrix [0:CROSSBAR_DIMENSION-1][0:CROSSBAR_DIMENSION-1];
    integer sorted_d_count [0:CROSSBAR_DIMENSION-1];
    integer row;
    integer col;
    integer clear_row;
    integer clear_col;
    integer compare_row;
    integer compare_col;
    integer count_position;
    reg [CROSSBAR_DIMENSION-1:0] expected_d_vector;
    reg stalled_last_cycle;
    reg [CROSSBAR_DIMENSION-1:0] stalled_x;
    reg [CROSSBAR_DIMENSION-1:0] stalled_d;
    reg [BL_WIDTH-1:0] stalled_bl;
    reg blocked_last_cycle;
    reg [CROSSBAR_DIMENSION-1:0] blocked_x;
    reg [CROSSBAR_DIMENSION-1:0] blocked_d;

    always @(posedge FRAME_DONE) begin
        if (update_active) begin
            frame_seen = 1'b1;
            digital_completion_time = $realtime;
        end
    end

    // Protocol, transform, zero-delete, and coincidence-preservation checks.
    always @(posedge CLK) begin
        if (!RST) begin
            stalled_last_cycle = 1'b0;
            blocked_last_cycle = 1'b0;
        end else begin
            if (stalled_last_cycle &&
                ((!INPUT_VALID) ||
                 (X_RAW_PULSES_IN !== stalled_x) ||
                 (D_RAW_PULSES_IN !== stalled_d) ||
                 (INPUT_BL !== stalled_bl))) begin
                update_errors = update_errors + 1;
                $display("ERROR: raw input changed while stalled at %0t", $time);
            end
            stalled_last_cycle = INPUT_VALID && !READY_IN;
            if (INPUT_VALID && !READY_IN) begin
                stalled_x = X_RAW_PULSES_IN;
                stalled_d = D_RAW_PULSES_IN;
                stalled_bl = INPUT_BL;
            end

            if (VALID_OUT && ((^X_PULSES_OUT === 1'bx) ||
                              (^D_PULSES_OUT === 1'bx))) begin
                update_errors = update_errors + 1;
                $display("ERROR: X/Z detected on valid output at %0t", $time);
            end
            if (blocked_last_cycle &&
                ((!VALID_OUT) ||
                 (X_PULSES_OUT !== blocked_x) ||
                 (D_PULSES_OUT !== blocked_d))) begin
                update_errors = update_errors + 1;
                $display("ERROR: output changed while blocked at %0t", $time);
            end
            blocked_last_cycle = VALID_OUT && !OUTPUT_READY;
            if (VALID_OUT && !OUTPUT_READY) begin
                blocked_x = X_PULSES_OUT;
                blocked_d = D_PULSES_OUT;
            end

            if (update_active) begin
                if (INPUT_BL !== update_bl[BL_WIDTH-1:0]) begin
                    update_errors = update_errors + 1;
                    $display("ERROR: INPUT_BL changed within update %0d", update_id);
                end
                if (BUFFER_FULL)
                    buffer_full_cycles = buffer_full_cycles + 1;
                if (BUFFER_OCCUPANCY > max_buffer_occupancy)
                    max_buffer_occupancy = BUFFER_OCCUPANCY;

                if (dut.architecture_top.preprocess_valid &&
                    dut.architecture_top.preprocess_ready) begin
                    if (preprocessed_positions >= update_bl) begin
                        update_errors = update_errors + 1;
                        $display("ERROR: too many preprocessed positions on update %0d", update_id);
                    end else begin
                        expected_d_vector = trace_d_frame[preprocessed_positions];
                        if (expect_sort != 0) begin
                            expected_d_vector = 0;
                            for (col = 0; col < CROSSBAR_DIMENSION; col = col + 1)
                                if (sorted_d_count[col] > preprocessed_positions)
                                    expected_d_vector[col] = 1'b1;
                        end
                        if (dut.architecture_top.x_pulses_preprocessed !==
                            trace_x_frame[preprocessed_positions]) begin
                            update_errors = update_errors + 1;
                            $display("ERROR: X transform mismatch update=%0d position=%0d",
                                     update_id, preprocessed_positions);
                        end
                        if (dut.architecture_top.d_pulses_preprocessed !==
                            expected_d_vector) begin
                            update_errors = update_errors + 1;
                            $display("ERROR: D transform mismatch update=%0d position=%0d",
                                     update_id, preprocessed_positions);
                        end
                    end

                    if (!dut.architecture_top.keep_preprocessed_pair) begin
                        deleted_positions = deleted_positions + 1;
                        if ((|dut.architecture_top.x_pulses_preprocessed) &&
                            (|dut.architecture_top.d_pulses_preprocessed)) begin
                            update_errors = update_errors + 1;
                            $display("ERROR: non-empty pair deleted on update %0d", update_id);
                        end
                    end

                    for (row = 0; row < CROSSBAR_DIMENSION; row = row + 1)
                        for (col = 0; col < CROSSBAR_DIMENSION; col = col + 1)
                            if (dut.architecture_top.x_pulses_preprocessed[row] &&
                                dut.architecture_top.d_pulses_preprocessed[col])
                                reference_matrix[row][col] =
                                    reference_matrix[row][col] + 1;
                    preprocessed_positions = preprocessed_positions + 1;
                end

                if (VALID_OUT && OUTPUT_READY) begin
                    if (expect_baseline != 0) begin
                        if (baseline_output_index >= update_bl) begin
                            update_errors = update_errors + 1;
                            $display("ERROR: baseline emitted too many positions");
                        end else if (
                            (X_PULSES_OUT !== trace_x_frame[baseline_output_index]) ||
                            (D_PULSES_OUT !== trace_d_frame[baseline_output_index])
                        ) begin
                            update_errors = update_errors + 1;
                            $display("ERROR: baseline replay mismatch update=%0d position=%0d",
                                     update_id, baseline_output_index);
                        end
                        baseline_output_index = baseline_output_index + 1;
                    end
                    for (row = 0; row < CROSSBAR_DIMENSION; row = row + 1)
                        for (col = 0; col < CROSSBAR_DIMENSION; col = col + 1)
                            if (X_PULSES_OUT[row] && D_PULSES_OUT[col])
                                output_matrix[row][col] =
                                    output_matrix[row][col] + 1;
                end
            end
        end
    end

    task clear_update_metrics;
        begin
            accepted_candidates = 0;
            preprocessed_positions = 0;
            baseline_output_index = 0;
            output_pulse_positions = 0;
            deleted_positions = 0;
            raw_empty_positions = 0;
            input_stall_cycles = 0;
            buffer_full_cycles = 0;
            max_buffer_occupancy = 0;
            update_errors = 0;
            frame_seen = 1'b0;
            start_time = -1.0;
            digital_completion_time = -1.0;
            last_device_completion_time = -1.0;
            stalled_last_cycle = 1'b0;
            blocked_last_cycle = 1'b0;
            for (clear_row = 0; clear_row < CROSSBAR_DIMENSION; clear_row = clear_row + 1) begin
                sorted_d_count[clear_row] = 0;
                for (clear_col = 0; clear_col < CROSSBAR_DIMENSION; clear_col = clear_col + 1) begin
                    reference_matrix[clear_row][clear_col] = 0;
                    output_matrix[clear_row][clear_col] = 0;
                end
            end
            for (count_position = 0; count_position < update_bl;
                 count_position = count_position + 1) begin
                if ((trace_x_frame[count_position] == 0) ||
                    (trace_d_frame[count_position] == 0))
                    raw_empty_positions = raw_empty_positions + 1;
                for (clear_col = 0; clear_col < CROSSBAR_DIMENSION;
                     clear_col = clear_col + 1)
                    sorted_d_count[clear_col] = sorted_d_count[clear_col] +
                        trace_d_frame[count_position][clear_col];
            end
        end
    endtask

    task run_update;
        realtime end_time;
        realtime digital_duration;
        realtime device_duration;
        realtime latency;
        integer max_watchdog_cycles;
        integer watchdog_cycles;
        integer drive_position;
        begin
            clear_update_metrics();
            drive_position = 0;

            @(negedge CLK);
            INPUT_BL = update_bl[BL_WIDTH-1:0];
            X_RAW_PULSES_IN = trace_x_frame[0];
            D_RAW_PULSES_IN = trace_d_frame[0];
            INPUT_VALID = 1'b1;
            update_active = 1'b1;

            while (drive_position < update_bl) begin
                @(posedge CLK);
                if (INPUT_VALID && READY_IN) begin
                    if (accepted_candidates == 0)
                        start_time = $realtime;
                    accepted_candidates = accepted_candidates + 1;
                    drive_position = drive_position + 1;
                    @(negedge CLK);
                    if (drive_position < update_bl) begin
                        X_RAW_PULSES_IN = trace_x_frame[drive_position];
                        D_RAW_PULSES_IN = trace_d_frame[drive_position];
                    end else begin
                        INPUT_VALID = 1'b0;
                    end
                end else begin
                    input_stall_cycles = input_stall_cycles + 1;
                    @(negedge CLK);
                end
            end

            max_watchdog_cycles =
                MAX_BL * (((t_pulse_ns + DIGITAL_CLOCK_NS - 1) /
                           DIGITAL_CLOCK_NS) + 20) * 20;
            watchdog_cycles = 0;
            while (!frame_seen && (watchdog_cycles < max_watchdog_cycles)) begin
                @(posedge CLK);
                watchdog_cycles = watchdog_cycles + 1;
            end
            if (!frame_seen) begin
                update_errors = update_errors + 1;
                digital_completion_time = $realtime;
                $display("ERROR: timeout waiting for FRAME_DONE on update %0d", update_id);
            end

            if (last_device_completion_time > $realtime)
                #(last_device_completion_time - $realtime);

            end_time = digital_completion_time;
            if (last_device_completion_time > end_time)
                end_time = last_device_completion_time;

            if (accepted_candidates != update_bl) begin
                update_errors = update_errors + 1;
                $display("ERROR: update %0d accepted %0d candidates, expected %0d",
                         update_id, accepted_candidates, update_bl);
            end
            if (preprocessed_positions != update_bl) begin
                update_errors = update_errors + 1;
                $display("ERROR: update %0d preprocessed %0d positions, expected %0d",
                         update_id, preprocessed_positions, update_bl);
            end
            if ((expect_baseline != 0) &&
                (baseline_output_index != update_bl)) begin
                update_errors = update_errors + 1;
                $display("ERROR: baseline update %0d emitted %0d positions, expected %0d",
                         update_id, baseline_output_index, update_bl);
            end
            if ((expect_zero_delete != 0) && (expect_sort == 0) &&
                (deleted_positions != raw_empty_positions)) begin
                update_errors = update_errors + 1;
                $display("ERROR: zero-delete update %0d removed %0d, expected %0d empty positions",
                         update_id, deleted_positions, raw_empty_positions);
            end

            for (compare_row = 0; compare_row < CROSSBAR_DIMENSION;
                 compare_row = compare_row + 1)
                for (compare_col = 0; compare_col < CROSSBAR_DIMENSION;
                     compare_col = compare_col + 1)
                    if (reference_matrix[compare_row][compare_col] !=
                        output_matrix[compare_row][compare_col]) begin
                        update_errors = update_errors + 1;
                        $display("ERROR: coincidence mismatch update=%0d row=%0d col=%0d ref=%0d out=%0d",
                                 update_id, compare_row, compare_col,
                                 reference_matrix[compare_row][compare_col],
                                 output_matrix[compare_row][compare_col]);
                    end

            digital_duration = digital_completion_time - start_time;
            device_duration = (last_device_completion_time < 0.0) ?
                0.0 : last_device_completion_time - start_time;
            latency = end_time - start_time;
            $fwrite(result_fd,
                "%0d,%0d,%0d,%0d,%0.3f,%0.3f,%0.3f,%0d,%0d,%0d,%0d,%0d\n",
                update_id, update_bl, output_pulse_positions, deleted_positions,
                latency, digital_duration, device_duration,
                input_stall_cycles, buffer_full_cycles, max_buffer_occupancy,
                GROUP_MASK_BYPASS, update_errors);

            if (GROUP_MASK_BYPASS)
                group_mask_bypass_count = group_mask_bypass_count + 1;
            total_errors = total_errors + update_errors;
            processed_updates = processed_updates + 1;
            update_active = 1'b0;
            @(negedge CLK);
            INPUT_VALID = 1'b0;
            X_RAW_PULSES_IN = 0;
            D_RAW_PULSES_IN = 0;
        end
    endtask

    task validate_and_store_row;
        input integer expected_position;
        integer lane;
        begin
            if (scan_status != 8) begin
                $display("ERROR: malformed converted trace row for update ordinal %0d",
                         update_ordinal);
                $finish(2);
            end
            if ((row_update_id != update_id) || (row_bl != update_bl) ||
                (row_pulse_index != expected_position) ||
                (row_x_size != update_x_size) ||
                (row_d_size != update_d_size) ||
                (row_tile_index != update_tile_index)) begin
                $display("ERROR: inconsistent trace row update=%0d pulse=%0d",
                         row_update_id, row_pulse_index);
                $finish(2);
            end
            if ((row_x_size <= 0) || (row_x_size > CROSSBAR_DIMENSION) ||
                (row_d_size <= 0) || (row_d_size > CROSSBAR_DIMENSION)) begin
                $display("ERROR: invalid X/D size in converted trace");
                $finish(2);
            end
            for (lane = row_x_size; lane < CROSSBAR_DIMENSION; lane = lane + 1)
                if (row_x[lane]) begin
                    $display("ERROR: active X lane beyond x_size");
                    $finish(2);
                end
            for (lane = row_d_size; lane < CROSSBAR_DIMENSION; lane = lane + 1)
                if (row_d[lane]) begin
                    $display("ERROR: active D lane beyond d_size");
                    $finish(2);
                end
            trace_x_frame[expected_position] = row_x;
            trace_d_frame[expected_position] = row_d;
            loaded_positions = loaded_positions + 1;
        end
    endtask

    initial begin
        total_errors = 0;
        processed_updates = 0;
        group_mask_bypass_count = 0;
        update_active = 1'b0;
        loaded_positions = 0;
        device_busy = 1'b0;
        expect_sort = 0;
        expect_zero_delete = 0;
        expect_baseline = 0;
        saif_enable = 0;
        saif_active = 0;
        saif_path = "";
        saif_clk_cycles = 0;
        saif_source_fires = 0;
        lfsr_advances = 0;
        lfsr_seq_errors = 0;
        shared_delay_errors = 0;
        src_fire_d = 0;
        rng_fd = 0;
        rng_stats_path = "";
        saif_enable = $value$plusargs("SAIF_FILE=%s", saif_path);
        if (!$value$plusargs("RNG_STATS_FILE=%s", rng_stats_path))
            rng_stats_path = "rng_stats.csv";

        if (!$value$plusargs("TRACE_FILE=%s", trace_path)) begin
            $display("ERROR: +TRACE_FILE is required");
            $finish(2);
        end
        if (!$value$plusargs("RESULT_FILE=%s", result_path)) begin
            $display("ERROR: +RESULT_FILE is required");
            $finish(2);
        end
        if (!$value$plusargs("T_PULSE_NS=%d", t_pulse_ns) ||
            (t_pulse_ns <= 0)) begin
            $display("ERROR: +T_PULSE_NS must be a positive integer");
            $finish(2);
        end
        if (!$value$plusargs("ARCHITECTURE=%s", architecture_name))
            architecture_name = "unknown";
        scan_status = $value$plusargs("EXPECT_SORT=%d", expect_sort);
        scan_status = $value$plusargs("EXPECT_ZERO_DELETE=%d", expect_zero_delete);
        scan_status = $value$plusargs("EXPECT_BASELINE=%d", expect_baseline);

        trace_fd = $fopen(trace_path, "r");
        result_fd = $fopen(result_path, "w");
        if ((trace_fd == 0) || (result_fd == 0)) begin
            $display("ERROR: could not open trace or result file");
            $finish(2);
        end

        scan_status = $fscanf(trace_fd, "%d %d %d %d\n",
                              trace_updates, trace_positions,
                              trace_dimension, trace_max_bl);
        if ((scan_status != 4) || (trace_updates <= 0) ||
            (trace_positions <= 0) ||
            (trace_dimension != CROSSBAR_DIMENSION) ||
            (trace_max_bl != MAX_BL)) begin
            $display("ERROR: converted trace header does not match compiled RTL");
            $finish(2);
        end

        $fwrite(result_fd,
            "update_id,input_bl,output_pulse_positions,deleted_positions,latency_ns,digital_completion_ns,physical_completion_ns,input_stall_cycles,buffer_full_cycles,max_buffer_occupancy,group_mask_bypass,errors\n");

        repeat (4) @(posedge CLK);
        RST = 1'b1;
        repeat (2) @(posedge CLK);
        saif_begin;

        for (update_ordinal = 0; update_ordinal < trace_updates;
             update_ordinal = update_ordinal + 1) begin
            scan_status = $fscanf(trace_fd, "%d %d %d %d %d %d %h %h\n",
                                  row_update_id, row_bl, row_pulse_index,
                                  row_x_size, row_d_size, row_tile_index,
                                  row_x, row_d);
            if (scan_status != 8) begin
                $display("ERROR: missing first row for update ordinal %0d", update_ordinal);
                saif_end;
                $finish(2);
            end
            update_id = row_update_id;
            update_bl = row_bl;
            update_x_size = row_x_size;
            update_d_size = row_d_size;
            update_tile_index = row_tile_index;
            if ((update_bl <= 0) || (update_bl > MAX_BL) ||
                (row_pulse_index != 0)) begin
                $display("ERROR: invalid BL or first pulse index for update %0d", update_id);
                $finish(2);
            end
            validate_and_store_row(0);

            for (load_position = 1; load_position < update_bl;
                 load_position = load_position + 1) begin
                scan_status = $fscanf(trace_fd, "%d %d %d %d %d %d %h %h\n",
                                      row_update_id, row_bl, row_pulse_index,
                                      row_x_size, row_d_size, row_tile_index,
                                      row_x, row_d);
                validate_and_store_row(load_position);
            end
            run_update();
        end

        if (loaded_positions != trace_positions) begin
            $display("ERROR: loaded %0d positions, trace header declares %0d",
                     loaded_positions, trace_positions);
            total_errors = total_errors + 1;
        end
        scan_status = $fscanf(trace_fd, "%d", row_update_id);
        if (scan_status != -1) begin
            $display("ERROR: extra or malformed data after declared trace updates");
            total_errors = total_errors + 1;
        end

        $fclose(trace_fd);
        $fclose(result_fd);
        if ((processed_updates != trace_updates) || (total_errors != 0)) begin
            $display("RESULT: FAIL architecture=%0s updates=%0d/%0d errors=%0d bypass=%0d",
                     architecture_name, processed_updates, trace_updates,
                     total_errors, group_mask_bypass_count);
            saif_end;
            $finish(1);
        end
        @(posedge CLK);
        #1;
        if ((lfsr_advances != saif_source_fires) ||
            (lfsr_seq_errors != 0) || (shared_delay_errors != 0)) begin
            $display("ERROR: RNG sequence checker failed fires=%0d advances=%0d seq_err=%0d delay_err=%0d",
                     saif_source_fires, lfsr_advances, lfsr_seq_errors, shared_delay_errors);
            total_errors = total_errors + 1;
        end
        rng_fd = $fopen(rng_stats_path, "w");
        if (rng_fd != 0) begin
            $fwrite(rng_fd,
                "saif_clk_cycles,source_fire_count,source_fire_duty,lfsr_advances,rng_gated_cycles,rng_active_cycles,lfsr_seq_errors,shared_delay_errors\n");
            $fwrite(rng_fd, "%0d,%0d,%0.9f,%0d,%0d,%0d,%0d,%0d\n",
                    saif_clk_cycles, saif_source_fires,
                    (saif_clk_cycles == 0) ? 0.0 : (1.0 * saif_source_fires) / saif_clk_cycles,
                    lfsr_advances,
                    (saif_clk_cycles > saif_source_fires) ? (saif_clk_cycles - saif_source_fires) : 0,
                    saif_source_fires, lfsr_seq_errors, shared_delay_errors);
            $fclose(rng_fd);
        end
        $display("RNG_STATS clk=%0d fires=%0d duty=%0.6f advances=%0d seq_err=%0d delay_err=%0d",
                 saif_clk_cycles, saif_source_fires,
                 (saif_clk_cycles == 0) ? 0.0 : (1.0 * saif_source_fires) / saif_clk_cycles,
                 lfsr_advances, lfsr_seq_errors, shared_delay_errors);
        if ((processed_updates != trace_updates) || (total_errors != 0)) begin
            $display("RESULT: FAIL architecture=%0s updates=%0d/%0d errors=%0d bypass=%0d",
                     architecture_name, processed_updates, trace_updates,
                     total_errors, group_mask_bypass_count);
            saif_end;
            $finish(1);
        end
        $display("RESULT: PASS architecture=%0s updates=%0d errors=0 bypass=%0d",
                 architecture_name, processed_updates, group_mask_bypass_count);
        saif_end;
        $finish(0);
    end
endmodule
