// Area-efficient run grouper for temporally sorted D streams.
// Runtime frames above GROUP_LIMIT bypass grouping unchanged.
module GROUP_MASK_AFTER_SORTED #(
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
    localparam STATE_COLLECT = 1'b0;
    localparam STATE_FLUSH = 1'b1;

    wire bypass = FRAME_BL > GROUP_LIMIT;
    reg state;
    reg group_active;
    reg frame_closed;
    reg frame_done_reg;
    reg [CROSSBAR_DIMENSION-1:0] current_d_pattern;
    reg [CROSSBAR_DIMENSION*COUNT_WIDTH-1:0] x_counts;
    reg [COUNT_WIDTH-1:0] emitted_layer;

    wire pattern_change = !bypass && (state == STATE_COLLECT) &&
        INPUT_VALID && INPUT_KEEP && group_active &&
        (D_PULSES_IN != current_d_pattern);

    reg [CROSSBAR_DIMENSION-1:0] layer_x;
    reg layer_available;
    reg more_layers;
    integer lane;
    always @(*) begin
        layer_x = 0;
        layer_available = 1'b0;
        more_layers = 1'b0;
        for (lane = 0; lane < CROSSBAR_DIMENSION; lane = lane + 1) begin
            if (x_counts[lane*COUNT_WIDTH +: COUNT_WIDTH] > emitted_layer) begin
                layer_x[lane] = 1'b1;
                layer_available = 1'b1;
            end
            if (x_counts[lane*COUNT_WIDTH +: COUNT_WIDTH] > emitted_layer + 1'b1)
                more_layers = 1'b1;
        end
    end

    assign INPUT_READY = bypass ?
        (!INPUT_VALID || !INPUT_KEEP || OUTPUT_READY) :
        ((state == STATE_COLLECT) && !pattern_change);
    assign OUTPUT_VALID = bypass ?
        (INPUT_VALID && INPUT_KEEP) :
        ((state == STATE_FLUSH) && group_active && layer_available);
    assign X_PULSES_OUT = bypass ? X_PULSES_IN : layer_x;
    assign D_PULSES_OUT = bypass ? D_PULSES_IN : current_d_pattern;
    assign FRAME_DONE = bypass ?
        (INPUT_VALID && INPUT_LAST && (!INPUT_KEEP || OUTPUT_READY)) :
        frame_done_reg;

    wire input_fire = INPUT_VALID && INPUT_READY;
    wire output_fire = OUTPUT_VALID && OUTPUT_READY;
    integer capture_lane;

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            state <= STATE_COLLECT;
            group_active <= 1'b0;
            frame_closed <= 1'b0;
            frame_done_reg <= 1'b0;
            current_d_pattern <= 0;
            x_counts <= 0;
            emitted_layer <= 0;
        end else begin
            frame_done_reg <= 1'b0;

            if (!bypass && pattern_change)
                state <= STATE_FLUSH;

            if (!bypass && input_fire && (state == STATE_COLLECT)) begin
                if (INPUT_KEEP) begin
                    if (!group_active) begin
                        group_active <= 1'b1;
                        current_d_pattern <= D_PULSES_IN;
                        emitted_layer <= 0;
                        for (capture_lane = 0; capture_lane < CROSSBAR_DIMENSION; capture_lane = capture_lane + 1)
                            x_counts[capture_lane*COUNT_WIDTH +: COUNT_WIDTH] <= X_PULSES_IN[capture_lane];
                    end else begin
                        for (capture_lane = 0; capture_lane < CROSSBAR_DIMENSION; capture_lane = capture_lane + 1)
                            x_counts[capture_lane*COUNT_WIDTH +: COUNT_WIDTH] <=
                                x_counts[capture_lane*COUNT_WIDTH +: COUNT_WIDTH] + X_PULSES_IN[capture_lane];
                    end
                end

                if (INPUT_LAST) begin
                    if (INPUT_KEEP || group_active) begin
                        frame_closed <= 1'b1;
                        state <= STATE_FLUSH;
                    end else begin
                        frame_done_reg <= 1'b1;
                    end
                end
            end

            if (!bypass && (state == STATE_FLUSH)) begin
                if (!group_active || !layer_available) begin
                    group_active <= 1'b0;
                    x_counts <= 0;
                    emitted_layer <= 0;
                    state <= STATE_COLLECT;
                    if (frame_closed) begin
                        frame_closed <= 1'b0;
                        frame_done_reg <= 1'b1;
                    end
                end else if (output_fire) begin
                    if (more_layers)
                        emitted_layer <= emitted_layer + 1'b1;
                    else begin
                        group_active <= 1'b0;
                        x_counts <= 0;
                        emitted_layer <= 0;
                        state <= STATE_COLLECT;
                        if (frame_closed) begin
                            frame_closed <= 1'b0;
                            frame_done_reg <= 1'b1;
                        end
                    end
                end
            end
        end
    end
endmodule
