// Ready/valid FIFO for generated X/D pulse-vector pairs.
module OUTPUT_BUFFER #(
    parameter integer CROSSBAR_DIMENSION = 8,
    parameter integer OUTPUT_BUFFER_DEPTH = 10
) (
    input wire CLK,
    input wire RST,
    input wire [CROSSBAR_DIMENSION-1:0] X_PULSES_IN,
    input wire [CROSSBAR_DIMENSION-1:0] D_PULSES_IN,
    input wire VALID_IN,
    output wire [CROSSBAR_DIMENSION-1:0] X_PULSES_OUT,
    output wire [CROSSBAR_DIMENSION-1:0] D_PULSES_OUT,
    output wire VALID_OUT,
    output wire READY_IN,
    output wire FULL,
    output wire [((OUTPUT_BUFFER_DEPTH <= 1) ? 1 : $clog2(OUTPUT_BUFFER_DEPTH + 1))-1:0] OCCUPANCY,
    input wire OUTPUT_READY
);
    localparam integer PAIR_WIDTH = 2 * CROSSBAR_DIMENSION;
    localparam integer PTR_WIDTH =
        (OUTPUT_BUFFER_DEPTH <= 1) ? 1 : $clog2(OUTPUT_BUFFER_DEPTH);
    localparam integer COUNT_WIDTH =
        (OUTPUT_BUFFER_DEPTH <= 1) ? 1 : $clog2(OUTPUT_BUFFER_DEPTH + 1);
    localparam [PTR_WIDTH-1:0] LAST_ADDRESS = OUTPUT_BUFFER_DEPTH - 1;
    localparam [COUNT_WIDTH-1:0] CAPACITY = OUTPUT_BUFFER_DEPTH;

    reg [PAIR_WIDTH-1:0] fifo [0:OUTPUT_BUFFER_DEPTH-1];
    reg [PTR_WIDTH-1:0] write_ptr;
    reg [PTR_WIDTH-1:0] read_ptr;
    reg [COUNT_WIDTH-1:0] count;

    wire empty = (count == 0);
    wire pop = OUTPUT_READY && !empty;
    wire push = VALID_IN && READY_IN;
    wire [PAIR_WIDTH-1:0] head = fifo[read_ptr];

    assign READY_IN = (count != CAPACITY) || pop;
    assign FULL = (count == CAPACITY);
    assign OCCUPANCY = count;
    assign VALID_OUT = !empty;
    assign X_PULSES_OUT = empty ? 0 : head[PAIR_WIDTH-1:CROSSBAR_DIMENSION];
    assign D_PULSES_OUT = empty ? 0 : head[CROSSBAR_DIMENSION-1:0];

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            write_ptr <= 0;
            read_ptr <= 0;
            count <= 0;
        end else begin
            if (push) begin
                fifo[write_ptr] <= {X_PULSES_IN, D_PULSES_IN};
                write_ptr <= (write_ptr == LAST_ADDRESS) ? 0 : write_ptr + 1'b1;
            end
            if (pop)
                read_ptr <= (read_ptr == LAST_ADDRESS) ? 0 : read_ptr + 1'b1;

            case ({push, pop})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end
endmodule
