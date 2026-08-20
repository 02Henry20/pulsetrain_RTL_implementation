// Buffers one runtime-length frame and front-loads each D lane in time.
module SORT #(
    parameter integer CROSSBAR_DIMENSION = 8,
    parameter integer MAX_BL = 32
) (
    input wire CLK,
    input wire RST,
    input wire INPUT_VALID,
    input wire INPUT_LAST,
    output wire INPUT_READY,
    input wire [CROSSBAR_DIMENSION-1:0] X_PULSES_IN,
    input wire [CROSSBAR_DIMENSION-1:0] D_PULSES_IN,
    output wire [CROSSBAR_DIMENSION-1:0] X_PULSES_OUT,
    output wire [CROSSBAR_DIMENSION-1:0] D_PULSES_OUT,
    output wire OUTPUT_VALID,
    output wire OUTPUT_LAST,
    input wire OUTPUT_READY
);
    localparam integer INDEX_WIDTH = (MAX_BL <= 1) ? 1 : $clog2(MAX_BL);
    localparam integer LENGTH_WIDTH = (MAX_BL <= 1) ? 1 : $clog2(MAX_BL + 1);

    reg [CROSSBAR_DIMENSION-1:0] x_frame [0:MAX_BL-1];
    reg [LENGTH_WIDTH-1:0] d_pulse_count [0:CROSSBAR_DIMENSION-1];
    reg [INDEX_WIDTH-1:0] input_index;
    reg [INDEX_WIDTH-1:0] output_index;
    reg [LENGTH_WIDTH-1:0] frame_length;
    reg frame_captured;

    wire input_fire = INPUT_VALID && INPUT_READY;
    wire output_fire = OUTPUT_VALID && OUTPUT_READY;
    assign INPUT_READY = !frame_captured;
    assign OUTPUT_VALID = frame_captured;
    assign OUTPUT_LAST = frame_captured &&
        (output_index == (frame_length - 1'b1));
    assign X_PULSES_OUT = frame_captured ?
        x_frame[output_index] : {CROSSBAR_DIMENSION{1'b0}};

    genvar lane;
    generate
        for (lane = 0; lane < CROSSBAR_DIMENSION; lane = lane + 1) begin : GEN_D_LAYER
            assign D_PULSES_OUT[lane] = frame_captured &&
                (d_pulse_count[lane] > output_index);
        end
    endgenerate

    integer i;
    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            input_index <= 0;
            output_index <= 0;
            frame_length <= 0;
            frame_captured <= 1'b0;
            for (i = 0; i < CROSSBAR_DIMENSION; i = i + 1)
                d_pulse_count[i] <= 0;
        end else begin
            if (input_fire) begin
                x_frame[input_index] <= X_PULSES_IN;
                for (i = 0; i < CROSSBAR_DIMENSION; i = i + 1)
                    d_pulse_count[i] <= d_pulse_count[i] + D_PULSES_IN[i];

                if (INPUT_LAST) begin
                    frame_length <=
                        {{(LENGTH_WIDTH-INDEX_WIDTH){1'b0}}, input_index} + 1'b1;
                    input_index <= 0;
                    frame_captured <= 1'b1;
                end else begin
                    input_index <= input_index + 1'b1;
                end
            end

            if (output_fire) begin
                if (OUTPUT_LAST) begin
                    output_index <= 0;
                    frame_captured <= 1'b0;
                    for (i = 0; i < CROSSBAR_DIMENSION; i = i + 1)
                        d_pulse_count[i] <= 0;
                end else begin
                    output_index <= output_index + 1'b1;
                end
            end
        end
    end
endmodule
