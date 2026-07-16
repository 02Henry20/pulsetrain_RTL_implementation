module PULSE_GENERATOR_LSFR #(
    parameter NUM_VALUES  = 8,
    parameter VALUE_WIDTH = 16
) (
    input  wire [VALUE_WIDTH-1:0]            LFSR_VALUE,
    input  wire [NUM_VALUES*VALUE_WIDTH-1:0] INPUT_VALUES,

    output reg  [NUM_VALUES-1:0]             PULSES
);

    integer i;

    always @(*) begin
        PULSES = {NUM_VALUES{1'b0}};

        for (i = 0; i < NUM_VALUES; i = i + 1) begin
            PULSES[i] =
                LFSR_VALUE <
                INPUT_VALUES[i*VALUE_WIDTH +: VALUE_WIDTH];
        end
    end

endmodule