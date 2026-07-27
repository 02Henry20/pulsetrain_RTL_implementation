// Stores accepted X/D stochastic pulse-vector pairs.
module OUTPUT_BUFFER #(
    parameter CROSSBAR_DIMENSION = 8, // Width of each X and D pulse vector.
    parameter OUTPUT_BUFFER_DEPTH = 10 // Maximum queued pulse-vector pairs.
) (
    input  wire                  CLK, // System clock.
    input  wire                  RST, // Active-low asynchronous reset.

    input  wire [CROSSBAR_DIMENSION-1:0] X_PULSES_IN, // X vector to enqueue.
    input  wire [CROSSBAR_DIMENSION-1:0] D_PULSES_IN, // D vector paired with X.
    input  wire                  VALID_IN, // Input pair should enter the FIFO.

    output wire [CROSSBAR_DIMENSION-1:0] X_PULSES_OUT, // X vector at the FIFO head.
    output wire [CROSSBAR_DIMENSION-1:0] D_PULSES_OUT, // D vector at the FIFO head.
    output wire                  VALID_OUT, // FIFO head contains a valid pair.
    output wire                  READY_IN, // FIFO can accept an input this clock.
    output wire                  FULL, // FIFO currently has no free entry.

    input  wire                  PULSE_DONE // Consumer removes the current FIFO head.
);

    localparam PULSE_PAIR_WIDTH  = 2 * CROSSBAR_DIMENSION;
    localparam BUFFER_PTR_WIDTH   = (OUTPUT_BUFFER_DEPTH <= 1) ? 1 : $clog2(OUTPUT_BUFFER_DEPTH);
    localparam BUFFER_COUNT_WIDTH = (OUTPUT_BUFFER_DEPTH <= 1) ? 1 : $clog2(OUTPUT_BUFFER_DEPTH + 1);
    localparam [BUFFER_PTR_WIDTH-1:0] LAST_BUFFER_ADDRESS = OUTPUT_BUFFER_DEPTH - 1;
    localparam [BUFFER_COUNT_WIDTH-1:0] BUFFER_CAPACITY = OUTPUT_BUFFER_DEPTH;

    reg [PULSE_PAIR_WIDTH-1:0] fifo [0:OUTPUT_BUFFER_DEPTH-1];
    // count invalidates drained entries, so stale memory can never become valid output.

    reg [BUFFER_PTR_WIDTH-1:0]   write_ptr;
    reg [BUFFER_PTR_WIDTH-1:0]   read_ptr;
    reg [BUFFER_COUNT_WIDTH-1:0] count;

    wire empty = (count == {BUFFER_COUNT_WIDTH{1'b0}});

    // A simultaneous pop permits a push even when the FIFO starts full.
    wire pop   = PULSE_DONE && !empty; // Remove only an existing output pair.
    wire push  = VALID_IN && READY_IN; // Enqueue only an accepted input pair.
    // Asynchronous head access removes an extra output-register cycle.
    wire [PULSE_PAIR_WIDTH-1:0] head = fifo[read_ptr];

    assign READY_IN = (count != BUFFER_CAPACITY) || pop;
    assign FULL     = (count == BUFFER_CAPACITY);

    assign VALID_OUT = !empty;

    assign X_PULSES_OUT = !empty ?
        head[PULSE_PAIR_WIDTH-1:CROSSBAR_DIMENSION] : {CROSSBAR_DIMENSION{1'b0}};

    assign D_PULSES_OUT = !empty ?
        head[CROSSBAR_DIMENSION-1:0] : {CROSSBAR_DIMENSION{1'b0}};

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            write_ptr  <= 0;
            read_ptr   <= 0;
            count      <= 0;
        end
        else begin
            if (push) begin
                fifo[write_ptr] <= {X_PULSES_IN, D_PULSES_IN};

                if (write_ptr == LAST_BUFFER_ADDRESS)
                    write_ptr <= {BUFFER_PTR_WIDTH{1'b0}};
                else
                    write_ptr <= write_ptr + 1'b1;
            end

            if (pop) begin
                if (read_ptr == LAST_BUFFER_ADDRESS)
                    read_ptr <= {BUFFER_PTR_WIDTH{1'b0}};
                else
                    read_ptr <= read_ptr + 1'b1;
            end

            case ({push, pop})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

endmodule
