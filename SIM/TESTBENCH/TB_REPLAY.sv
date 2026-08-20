`timescale 1ns/1ps

module TB_REPLAY #(
    parameter integer CROSSBAR_DIMENSION = 8,
    parameter integer MAX_BL = 32,
    parameter integer STOCHASTIC_VALUE_WIDTH = 16,
    parameter integer OUTPUT_BUFFER_DEPTH = 10,
    parameter integer DIGITAL_CLOCK_NS = 10,
    parameter [STOCHASTIC_VALUE_WIDTH-1:0] LFSR_SEED = 16'hACE1
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
        .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION), .MAX_BL(MAX_BL),
        .BL_WIDTH(BL_WIDTH), .STOCHASTIC_VALUE_WIDTH(STOCHASTIC_VALUE_WIDTH),
        .OUTPUT_BUFFER_DEPTH(OUTPUT_BUFFER_DEPTH), .LFSR_SEED(LFSR_SEED)
    ) dut (
        .CLK(CLK), .RST(RST), .INPUT_VALID(INPUT_VALID), .INPUT_BL(INPUT_BL),
        .X_INPUT_VALUES(X_INPUT_VALUES), .D_INPUT_VALUES(D_INPUT_VALUES),
        .OUTPUT_READY(OUTPUT_READY), .X_PULSES_OUT(X_PULSES_OUT),
        .D_PULSES_OUT(D_PULSES_OUT), .VALID_OUT(VALID_OUT),
        .READY_IN(READY_IN), .BUFFER_FULL(BUFFER_FULL),
        .BUFFER_OCCUPANCY(BUFFER_OCCUPANCY),
        .GROUP_MASK_BYPASS(GROUP_MASK_BYPASS), .FRAME_DONE(FRAME_DONE)
    );

    always #(DIGITAL_CLOCK_NS / 2.0) CLK = ~CLK;

    integer t_pulse_ns;
    reg device_busy = 1'b0;
    realtime last_device_completion_time;
    assign OUTPUT_READY = !device_busy;

    integer output_pulse_positions;
    always @(posedge CLK) begin
        if (RST && VALID_OUT && OUTPUT_READY) begin
            device_busy = 1'b1;
            output_pulse_positions = output_pulse_positions + 1;
            fork
                begin
                    #(t_pulse_ns);
                    last_device_completion_time = $realtime;
                    device_busy = 1'b0;
                end
            join_none
        end
    end

    integer trace_fd;
    integer result_fd;
    reg [2047:0] trace_path;
    reg [2047:0] result_path;
    reg [255:0] architecture_name;
    integer trace_updates;
    integer trace_dimension;
    integer trace_width;
    integer trace_max_bl;
    integer update_id;
    integer update_bl;
    reg [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] trace_x;
    reg [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] trace_d;
    integer scan_status;

    integer accepted_candidates;
    integer deleted_positions;
    integer input_stall_cycles;
    integer buffer_full_cycles;
    integer max_buffer_occupancy;
    integer update_errors;
    integer total_errors;
    integer processed_updates;
    integer group_mask_bypass_count;
    reg update_active;
    realtime start_time;

    integer reference_matrix [0:CROSSBAR_DIMENSION-1][0:CROSSBAR_DIMENSION-1];
    integer output_matrix [0:CROSSBAR_DIMENSION-1][0:CROSSBAR_DIMENSION-1];
    integer row;
    integer col;
    integer clear_row;
    integer clear_col;
    integer compare_row;
    integer compare_col;
    reg blocked_last_cycle;
    reg [CROSSBAR_DIMENSION-1:0] blocked_x;
    reg [CROSSBAR_DIMENSION-1:0] blocked_d;

    // Architecture-independent protocol and coincidence-preservation checks.
    always @(posedge CLK) begin
        if (!RST) begin
            blocked_last_cycle = 1'b0;
        end else begin
            if (VALID_OUT && ((^X_PULSES_OUT === 1'bx) ||
                              (^D_PULSES_OUT === 1'bx))) begin
                update_errors = update_errors + 1;
                $display("ERROR: X/Z detected on valid output at %0t", $time);
            end

            if (blocked_last_cycle && VALID_OUT && !OUTPUT_READY &&
                ((X_PULSES_OUT !== blocked_x) || (D_PULSES_OUT !== blocked_d))) begin
                update_errors = update_errors + 1;
                $display("ERROR: output changed while blocked at %0t", $time);
            end
            blocked_last_cycle = VALID_OUT && !OUTPUT_READY;
            blocked_x = X_PULSES_OUT;
            blocked_d = D_PULSES_OUT;

            if (update_active) begin
                if (INPUT_VALID && READY_IN) begin
                    if (accepted_candidates == 0)
                        start_time = $realtime;
                    accepted_candidates = accepted_candidates + 1;
                end else if (INPUT_VALID && (accepted_candidates < update_bl)) begin
                    input_stall_cycles = input_stall_cycles + 1;
                end

                if (BUFFER_FULL)
                    buffer_full_cycles = buffer_full_cycles + 1;
                if (BUFFER_OCCUPANCY > max_buffer_occupancy)
                    max_buffer_occupancy = BUFFER_OCCUPANCY;

                if (dut.architecture_top.preprocess_valid &&
                    dut.architecture_top.preprocess_ready) begin
                    if (!dut.architecture_top.keep_preprocessed_pair)
                        deleted_positions = deleted_positions + 1;
                    for (row = 0; row < CROSSBAR_DIMENSION; row = row + 1)
                        for (col = 0; col < CROSSBAR_DIMENSION; col = col + 1)
                            if (dut.architecture_top.x_pulses_preprocessed[row] &&
                                dut.architecture_top.d_pulses_preprocessed[col])
                                reference_matrix[row][col] = reference_matrix[row][col] + 1;
                end

                if (VALID_OUT && OUTPUT_READY) begin
                    for (row = 0; row < CROSSBAR_DIMENSION; row = row + 1)
                        for (col = 0; col < CROSSBAR_DIMENSION; col = col + 1)
                            if (X_PULSES_OUT[row] && D_PULSES_OUT[col])
                                output_matrix[row][col] = output_matrix[row][col] + 1;
                end
            end
        end
    end

    task clear_update_metrics;
        begin
            accepted_candidates = 0;
            output_pulse_positions = 0;
            deleted_positions = 0;
            input_stall_cycles = 0;
            buffer_full_cycles = 0;
            max_buffer_occupancy = 0;
            update_errors = 0;
            start_time = -1.0;
            last_device_completion_time = -1.0;
            for (clear_row = 0; clear_row < CROSSBAR_DIMENSION; clear_row = clear_row + 1)
                for (clear_col = 0; clear_col < CROSSBAR_DIMENSION; clear_col = clear_col + 1) begin
                    reference_matrix[clear_row][clear_col] = 0;
                    output_matrix[clear_row][clear_col] = 0;
                end
        end
    endtask

    task run_update;
        realtime digital_completion_time;
        realtime end_time;
        realtime digital_duration;
        realtime device_duration;
        realtime latency;
        integer max_watchdog_cycles;
        integer frame_seen;
        integer device_seen;
        begin
            clear_update_metrics();
            update_active = 1'b1;
            @(negedge CLK);
            INPUT_BL = update_bl[BL_WIDTH-1:0];
            X_INPUT_VALUES = trace_x;
            D_INPUT_VALUES = trace_d;
            INPUT_VALID = 1'b1;

            max_watchdog_cycles = MAX_BL * ((t_pulse_ns / DIGITAL_CLOCK_NS) + 20) * 20;
            frame_seen = 0;
            fork : WAIT_FOR_FRAME
                begin
                    @(posedge FRAME_DONE);
                    digital_completion_time = $realtime;
                    frame_seen = 1;
                end
                begin
                    #(max_watchdog_cycles * DIGITAL_CLOCK_NS);
                end
            join_any
            disable WAIT_FOR_FRAME;
            if (!frame_seen) begin
                update_errors = update_errors + 1;
                $display("ERROR: timeout waiting for FRAME_DONE on update %0d", update_id);
                digital_completion_time = $realtime;
            end

            device_seen = !device_busy;
            if (device_busy) begin
                fork : WAIT_FOR_DEVICE
                    begin
                        wait (!device_busy);
                        device_seen = 1;
                    end
                    begin
                        #(max_watchdog_cycles * DIGITAL_CLOCK_NS);
                    end
                join_any
                disable WAIT_FOR_DEVICE;
                if (!device_seen) begin
                    update_errors = update_errors + 1;
                    $display("ERROR: timeout waiting for physical completion on update %0d", update_id);
                end
            end

            end_time = digital_completion_time;
            if (last_device_completion_time > end_time)
                end_time = last_device_completion_time;

            if (accepted_candidates != update_bl) begin
                update_errors = update_errors + 1;
                $display("ERROR: update %0d accepted %0d candidates, expected %0d",
                         update_id, accepted_candidates, update_bl);
            end

            for (compare_row = 0; compare_row < CROSSBAR_DIMENSION; compare_row = compare_row + 1)
                for (compare_col = 0; compare_col < CROSSBAR_DIMENSION; compare_col = compare_col + 1)
                    if (reference_matrix[compare_row][compare_col] != output_matrix[compare_row][compare_col]) begin
                        update_errors = update_errors + 1;
                        $display("ERROR: coincidence mismatch update=%0d row=%0d col=%0d ref=%0d out=%0d",
                                 update_id, compare_row, compare_col,
                                 reference_matrix[compare_row][compare_col], output_matrix[compare_row][compare_col]);
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
        end
    endtask

    initial begin
        total_errors = 0;
        processed_updates = 0;
        group_mask_bypass_count = 0;
        update_active = 1'b0;
        blocked_last_cycle = 1'b0;

        if (!$value$plusargs("TRACE_FILE=%s", trace_path)) begin
            $display("ERROR: +TRACE_FILE is required");
            $finish(2);
        end
        if (!$value$plusargs("RESULT_FILE=%s", result_path)) begin
            $display("ERROR: +RESULT_FILE is required");
            $finish(2);
        end
        if (!$value$plusargs("T_PULSE_NS=%d", t_pulse_ns) || (t_pulse_ns <= 0)) begin
            $display("ERROR: +T_PULSE_NS must be a positive integer");
            $finish(2);
        end
        if (!$value$plusargs("ARCHITECTURE=%s", architecture_name))
            architecture_name = "unknown";

        trace_fd = $fopen(trace_path, "r");
        result_fd = $fopen(result_path, "w");
        if ((trace_fd == 0) || (result_fd == 0)) begin
            $display("ERROR: could not open trace or result file");
            $finish(2);
        end

        scan_status = $fscanf(trace_fd, "%d %d %d %d\n",
                              trace_updates, trace_dimension,
                              trace_width, trace_max_bl);
        if ((scan_status != 4) || (trace_dimension != CROSSBAR_DIMENSION) ||
            (trace_width != STOCHASTIC_VALUE_WIDTH) || (trace_max_bl != MAX_BL)) begin
            $display("ERROR: converted trace header does not match compiled RTL");
            $finish(2);
        end

        $fwrite(result_fd,
            "update_id,input_bl,output_pulse_positions,deleted_positions,latency_ns,digital_frame_completion_ns,last_device_completion_ns,input_stall_cycles,buffer_full_cycles,max_buffer_occupancy,group_mask_bypass,errors\n");

        repeat (4) @(posedge CLK);
        RST = 1'b1;
        repeat (2) @(posedge CLK);

        while (!$feof(trace_fd)) begin
            scan_status = $fscanf(trace_fd, "%d %d %h %h\n",
                                  update_id, update_bl, trace_x, trace_d);
            if (scan_status == 4) begin
                if ((update_bl <= 0) || (update_bl > MAX_BL)) begin
                    $display("ERROR: invalid BL %0d for update %0d", update_bl, update_id);
                    total_errors = total_errors + 1;
                end else begin
                    run_update();
                end
            end else if (!$feof(trace_fd)) begin
                $display("ERROR: malformed converted trace record");
                total_errors = total_errors + 1;
                $finish(2);
            end
        end

        $fclose(trace_fd);
        $fclose(result_fd);
        if ((processed_updates != trace_updates) || (total_errors != 0)) begin
            $display("RESULT: FAIL architecture=%0s updates=%0d/%0d errors=%0d bypass=%0d",
                     architecture_name, processed_updates, trace_updates,
                     total_errors, group_mask_bypass_count);
            $finish(1);
        end
        $display("RESULT: PASS architecture=%0s updates=%0d errors=0 bypass=%0d",
                 architecture_name, processed_updates, group_mask_bypass_count);
        $finish(0);
    end
endmodule
