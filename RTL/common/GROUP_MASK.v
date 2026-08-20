// Groups equal D vectors for runtime frames up to GROUP_LIMIT and emits unary X layers.
// Longer runtime frames bypass grouping without changing their ready/valid behavior.
module GROUP_MASK #(
    parameter integer CROSSBAR_DIMENSION = 8,
    parameter integer MAX_BL = 32,
    parameter integer BL_WIDTH = (MAX_BL <= 1) ? 1 : $clog2(MAX_BL + 1),
    parameter integer GROUP_LIMIT = 8
) (
    input wire CLK,
    input wire RST,
    input wire [BL_WIDTH-1:0] FRAME_BL,
    input wire INPUT_VALID,
    input wire INPUT_KEEP,
    input wire INPUT_LAST,
    output wire INPUT_READY,
    input wire [CROSSBAR_DIMENSION-1:0] X_PULSES_IN,
    input wire [CROSSBAR_DIMENSION-1:0] D_PULSES_IN,
    output wire [CROSSBAR_DIMENSION-1:0] X_PULSES_OUT,
    output wire [CROSSBAR_DIMENSION-1:0] D_PULSES_OUT,
    output wire OUTPUT_VALID,
    input wire OUTPUT_READY,
    output wire FRAME_DONE
);
    localparam integer COUNT_WIDTH = (GROUP_LIMIT <= 1) ? 1 : $clog2(GROUP_LIMIT + 1);
    localparam integer INDEX_WIDTH = (GROUP_LIMIT <= 1) ? 1 : $clog2(GROUP_LIMIT);

    wire bypass = FRAME_BL > GROUP_LIMIT;
    wire bypass_done = bypass && INPUT_VALID && INPUT_LAST &&
        (!INPUT_KEEP || OUTPUT_READY);

    reg [CROSSBAR_DIMENSION-1:0] d_patterns [0:GROUP_LIMIT-1];
    reg [CROSSBAR_DIMENSION*COUNT_WIDTH-1:0] x_counts [0:GROUP_LIMIT-1];
    reg [COUNT_WIDTH-1:0] group_count;
    reg frame_closed;
    reg frame_done_reg;
    reg [COUNT_WIDTH-1:0] emit_group;
    reg [COUNT_WIDTH-1:0] emitted_layer;

    reg match_found;
    reg [INDEX_WIDTH-1:0] match_index;
    integer g;
    always @(*) begin
        match_found = 1'b0;
        match_index = 0;
        for (g = 0; g < GROUP_LIMIT; g = g + 1) begin
            if (!match_found && (g < group_count) &&
                (d_patterns[g] == D_PULSES_IN)) begin
                match_found = 1'b1;
                match_index = g[INDEX_WIDTH-1:0];
            end
        end
    end

    reg [CROSSBAR_DIMENSION-1:0] grouped_x;
    reg grouped_layer_available;
    reg grouped_more_layers;
    integer lane;
    always @(*) begin
        grouped_x = 0;
        grouped_layer_available = 1'b0;
        grouped_more_layers = 1'b0;
        for (lane = 0; lane < CROSSBAR_DIMENSION; lane = lane + 1) begin
            if ((emit_group < group_count) &&
                (x_counts[emit_group][lane*COUNT_WIDTH +: COUNT_WIDTH] > emitted_layer)) begin
                grouped_x[lane] = 1'b1;
                grouped_layer_available = 1'b1;
            end
            if ((emit_group < group_count) &&
                (x_counts[emit_group][lane*COUNT_WIDTH +: COUNT_WIDTH] > emitted_layer + 1'b1))
                grouped_more_layers = 1'b1;
        end
    end

    assign INPUT_READY = bypass ?
        (!INPUT_VALID || !INPUT_KEEP || OUTPUT_READY) : !frame_closed;
    assign OUTPUT_VALID = bypass ?
        (INPUT_VALID && INPUT_KEEP) :
        (frame_closed && (emit_group < group_count) && grouped_layer_available);
    assign X_PULSES_OUT = bypass ? X_PULSES_IN : grouped_x;
    assign D_PULSES_OUT = bypass ? D_PULSES_IN :
        ((emit_group < group_count) ? d_patterns[emit_group] : 0);
    assign FRAME_DONE = bypass ? bypass_done : frame_done_reg;

    wire input_fire = INPUT_VALID && INPUT_READY;
    wire output_fire = OUTPUT_VALID && OUTPUT_READY;
    integer clear_group;
    integer capture_lane;

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            group_count <= 0;
            frame_closed <= 1'b0;
            frame_done_reg <= 1'b0;
            emit_group <= 0;
            emitted_layer <= 0;
            for (clear_group = 0; clear_group < GROUP_LIMIT; clear_group = clear_group + 1)
                x_counts[clear_group] <= 0;
        end else begin
            frame_done_reg <= 1'b0;

            if (!bypass && input_fire && !frame_closed) begin
                if (INPUT_KEEP) begin
                    if (match_found) begin
                        for (capture_lane = 0; capture_lane < CROSSBAR_DIMENSION; capture_lane = capture_lane + 1)
                            x_counts[match_index][capture_lane*COUNT_WIDTH +: COUNT_WIDTH] <=
                                x_counts[match_index][capture_lane*COUNT_WIDTH +: COUNT_WIDTH] + X_PULSES_IN[capture_lane];
                    end else begin
                        d_patterns[group_count[INDEX_WIDTH-1:0]] <= D_PULSES_IN;
                        for (capture_lane = 0; capture_lane < CROSSBAR_DIMENSION; capture_lane = capture_lane + 1)
                            x_counts[group_count[INDEX_WIDTH-1:0]][capture_lane*COUNT_WIDTH +: COUNT_WIDTH] <= X_PULSES_IN[capture_lane];
                        group_count <= group_count + 1'b1;
                    end
                end
                if (INPUT_LAST)
                    frame_closed <= 1'b1;
            end

            if (!bypass && frame_closed) begin
                if (emit_group >= group_count) begin
                    group_count <= 0;
                    frame_closed <= 1'b0;
                    frame_done_reg <= 1'b1;
                    emit_group <= 0;
                    emitted_layer <= 0;
                end else if (!grouped_layer_available) begin
                    emit_group <= emit_group + 1'b1;
                    emitted_layer <= 0;
                end else if (output_fire) begin
                    if (grouped_more_layers)
                        emitted_layer <= emitted_layer + 1'b1;
                    else begin
                        emit_group <= emit_group + 1'b1;
                        emitted_layer <= 0;
                    end
                end
            end
        end
    end
endmodule
