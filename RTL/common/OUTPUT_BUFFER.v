module OUTPUT_BUFFER #(
    parameter NUM_VALUES = 8,
    parameter FIFO_DEPTH = 10
) (
    input  wire                  CLK,
    input  wire                  RST,

    input  wire [NUM_VALUES-1:0] X_PULSES_IN,
    input  wire [NUM_VALUES-1:0] D_PULSES_IN,
    input  wire                  VALID_IN,

    output wire [NUM_VALUES-1:0] X_PULSES_OUT,
    output wire [NUM_VALUES-1:0] D_PULSES_OUT,
    output wire                  VALID_OUT,

    input  wire                  PULSE_DONE
);

    localparam PTR_WIDTH   = (FIFO_DEPTH <= 1) ? 1 : $clog2(FIFO_DEPTH);
    localparam COUNT_WIDTH = $clog2(FIFO_DEPTH + 1);
    localparam [PTR_WIDTH-1:0] LAST_PTR = FIFO_DEPTH - 1;
    
    reg [2*NUM_VALUES-1:0] fifo [0:FIFO_DEPTH-1];
    reg [2*NUM_VALUES-1:0] pulses_reg;

    reg [PTR_WIDTH-1:0]   write_ptr;
    reg [PTR_WIDTH-1:0]   read_ptr;
    reg [COUNT_WIDTH-1:0] count;
    reg                   valid_reg;

    wire write_fifo = VALID_IN;
    wire read_fifo  = !valid_reg && (count != 0);

    assign VALID_OUT = valid_reg;

    assign X_PULSES_OUT =
        valid_reg ? pulses_reg[2*NUM_VALUES-1:NUM_VALUES] : {NUM_VALUES{1'b0}};

    assign D_PULSES_OUT =
        valid_reg ? pulses_reg[NUM_VALUES-1:0] : {NUM_VALUES{1'b0}};

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            write_ptr  <= 0;
            read_ptr   <= 0;
            count      <= 0;
            pulses_reg <= 0;
            valid_reg  <= 0;
        end
        else begin
            if (PULSE_DONE && valid_reg)
                valid_reg <= 0;

            else if (read_fifo) begin
                pulses_reg <= fifo[read_ptr];
                valid_reg  <= 1'b1;

                if (read_ptr == LAST_PTR)
                    read_ptr <= {PTR_WIDTH{1'b0}};
                else
                    read_ptr <= read_ptr + 1'b1;
            end

            if (write_fifo) begin
                fifo[write_ptr] <= {X_PULSES_IN, D_PULSES_IN};

                if (write_ptr == LAST_PTR)
                    write_ptr <= {PTR_WIDTH{1'b0}};
                else
                    write_ptr <= write_ptr + 1'b1;
            end

            case ({write_fifo, read_fifo})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
            endcase
        end
    end

endmodule