// Temporally front-loads pulses within each D lane while preserving X order.
module SORT #(
    parameter integer CROSSBAR_DIMENSION = 8, // Shared X and D lane count.
    parameter integer BIT_LENGTH = 32 // Pulse cycles in one complete train set.
) (
    input  wire                          CLK, // System clock.
    input  wire                          RST, // Active-low asynchronous reset.

    input  wire                          INPUT_VALID, // Current unsorted X/D pair is valid.
    input  wire                          INPUT_LAST, // Current pair is the final cycle of this set.
    output wire                          INPUT_READY, // Sorter can capture another source cycle.
    input  wire [CROSSBAR_DIMENSION-1:0] X_PULSES_IN, // X cycle retained in its original order.
    input  wire [CROSSBAR_DIMENSION-1:0] D_PULSES_IN, // D cycle accumulated independently per lane.

    output wire [CROSSBAR_DIMENSION-1:0] X_PULSES_OUT, // Original X cycle at the sorted time index.
    output wire [CROSSBAR_DIMENSION-1:0] D_PULSES_OUT, // Temporally sorted D layer.
    output wire                          OUTPUT_VALID, // Sorted X/D pair is available.
    output wire                          OUTPUT_LAST, // Current output is the final frame cycle.
    input  wire                          OUTPUT_READY // Downstream can accept the pair.
);

    localparam integer FRAME_INDEX_WIDTH =
        (BIT_LENGTH <= 1) ? 1 : $clog2(BIT_LENGTH);
    localparam integer D_COUNT_WIDTH =
        (BIT_LENGTH <= 1) ? 1 : $clog2(BIT_LENGTH + 1);
    localparam [FRAME_INDEX_WIDTH-1:0] LAST_FRAME_INDEX =
        BIT_LENGTH - 1;

    // X is buffered but never sorted; output index t always receives input X[t].
    // Each indexed X slot is written before that layer can become eligible.
    reg [CROSSBAR_DIMENSION-1:0] x_frame [0:BIT_LENGTH-1];
    reg [D_COUNT_WIDTH-1:0] d_pulse_count [0:CROSSBAR_DIMENSION-1];

    reg [FRAME_INDEX_WIDTH-1:0] input_index;
    reg [FRAME_INDEX_WIDTH-1:0] output_index;
    reg                         frame_captured;

    wire input_fire  = INPUT_VALID && INPUT_READY;
    wire output_fire = OUTPUT_VALID && OUTPUT_READY;

    wire [CROSSBAR_DIMENSION-1:0] current_d_layer;
    genvar lane;
    generate
        for (lane = 0; lane < CROSSBAR_DIMENSION;
             lane = lane + 1) begin : GEN_D_LAYER
            // A lane with count N is high in temporal layers 0 through N-1.
            assign current_d_layer[lane] =
                d_pulse_count[lane] > output_index;
        end
    endgenerate

    // Before frame end, only an all-one layer is final and safe to release.
    wire saturated_layer_ready = &current_d_layer;

    assign INPUT_READY = !frame_captured;
    assign OUTPUT_VALID = frame_captured || saturated_layer_ready;
    assign OUTPUT_LAST = OUTPUT_VALID &&
        (output_index == LAST_FRAME_INDEX);

    assign X_PULSES_OUT = OUTPUT_VALID ?
        x_frame[output_index] : {CROSSBAR_DIMENSION{1'b0}};
    assign D_PULSES_OUT = OUTPUT_VALID ?
        current_d_layer : {CROSSBAR_DIMENSION{1'b0}};

    integer capture_lane;
    integer reset_lane;

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            input_index   <= {FRAME_INDEX_WIDTH{1'b0}};
            output_index  <= {FRAME_INDEX_WIDTH{1'b0}};
            frame_captured <= 1'b0;

            for (reset_lane = 0;
                 reset_lane < CROSSBAR_DIMENSION;
                 reset_lane = reset_lane + 1) begin
                d_pulse_count[reset_lane] <= {D_COUNT_WIDTH{1'b0}};
            end
        end else begin
            if (input_fire) begin
                x_frame[input_index] <= X_PULSES_IN;

                for (capture_lane = 0;
                     capture_lane < CROSSBAR_DIMENSION;
                     capture_lane = capture_lane + 1) begin
                    d_pulse_count[capture_lane] <=
                        d_pulse_count[capture_lane] +
                        D_PULSES_IN[capture_lane];
                end

                if (INPUT_LAST) begin
                    input_index    <= {FRAME_INDEX_WIDTH{1'b0}};
                    frame_captured <= 1'b1;
                end else begin
                    input_index <= input_index + 1'b1;
                end
            end

            if (output_fire) begin
                if (OUTPUT_LAST) begin
                    // Final sorted layer accepted: release counters for the next set.
                    output_index   <= {FRAME_INDEX_WIDTH{1'b0}};
                    frame_captured <= 1'b0;

                    for (reset_lane = 0;
                         reset_lane < CROSSBAR_DIMENSION;
                         reset_lane = reset_lane + 1) begin
                        d_pulse_count[reset_lane] <=
                            {D_COUNT_WIDTH{1'b0}};
                    end
                end else begin
                    output_index <= output_index + 1'b1;
                end
            end
        end
    end

endmodule