module GROUP_MASK #(
    parameter integer NUM_VALUES    = 8,
    parameter integer MAX_PULSES    = 32
) (
    input  wire                  CLK,
    input  wire                  RST,

    input  wire [NUM_VALUES-1:0] PULSES_IN,
    input  wire                  DONE,

    output reg  [NUM_VALUES-1:0] PULSES_OUT,
    output reg                   VALID_OUT,
    output reg                   DONE_OUT
);

    localparam STATE_CAPTURE = 1'b0;
    localparam STATE_DRAIN   = 1'b1;
    localparam COUNTER_WIDTH = $clog2(MAX_PULSES + 1);
    reg state;

    /*
     * Absolute number of received pulses for each stream.
     * These counters are never decremented.
     */
    reg [COUNTER_WIDTH-1:0] pulse_count [0:NUM_VALUES-1];

    /*
     * Number of sorted output columns already emitted.
     */
    reg [COUNTER_WIDTH-1:0] output_level;

    /*
     * Largest pulse count among all streams.
     * This determines the total sorted output length.
     */
    reg [COUNTER_WIDTH-1:0] max_count;

    wire [NUM_VALUES-1:0] next_level_available;
    wire [NUM_VALUES-1:0] sorted_output_mask;
    wire [NUM_VALUES-1:0] counter_reaches_new_max;

    wire all_next_level_available;
    wire increase_max_count;

    genvar g;
    generate
        for (g = 0; g < NUM_VALUES; g = g + 1) begin : STATUS_LOGIC

            /*
             * Check the counter after accepting the current input.
             *
             * If it is greater than output_level, this stream can
             * participate in the next sorted output column.
             */
            assign next_level_available[g] =
                ({1'b0, pulse_count[g]} + PULSES_IN[g])
                > {1'b0, output_level};

            /*
             * During draining, bit g is one while its total pulse
             * count is greater than the current output level.
             */
            assign sorted_output_mask[g] =
                pulse_count[g] > output_level;

            /*
             * The maximum can increase by at most one each clock.
             *
             * It increases when a counter that is currently equal
             * to max_count receives another pulse.
             */
            assign counter_reaches_new_max[g] =
                PULSES_IN[g] &&
                (pulse_count[g] == max_count);

        end
    endgenerate

    /*
     * The next output column can be emitted as all ones when every
     * stream has accumulated a pulse above the current output level.
     */
    assign all_next_level_available =
        &next_level_available;

    assign increase_max_count =
        |counter_reaches_new_max;

    integer i;

    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            state        <= STATE_CAPTURE;
            output_level <= {COUNTER_WIDTH{1'b0}};
            max_count    <= {COUNTER_WIDTH{1'b0}};

            PULSES_OUT <= {NUM_VALUES{1'b0}};
            VALID_OUT  <= 1'b0;
            DONE_OUT   <= 1'b0;

            for (i = 0; i < NUM_VALUES; i = i + 1) begin
                pulse_count[i] <= {COUNTER_WIDTH{1'b0}};
            end

        end else begin
            /*
             * Default output values.
             */
            PULSES_OUT <= {NUM_VALUES{1'b0}};
            VALID_OUT  <= 1'b0;
            DONE_OUT   <= 1'b0;

            case (state)

                // =====================================================
                // Receive and count input pulses
                // =====================================================
                STATE_CAPTURE: begin

                    /*
                     * Add the current input pulse to every corresponding
                     * counter.
                     */
                    for (i = 0; i < NUM_VALUES; i = i + 1) begin
                        pulse_count[i] <=
                            pulse_count[i] + PULSES_IN[i];
                    end

                    /*
                     * Update the maximum pulse count.
                     *
                     * Because each counter increases by at most one,
                     * the maximum can also increase by at most one.
                     */
                    if (increase_max_count) begin
                        max_count <= max_count + 1'b1;
                    end

                    /*
                     * Emit an all-one column as soon as every stream
                     * contains a pulse for the next output level.
                     *
                     * No counters need to be decremented.
                     */
                    if (all_next_level_available) begin
                        PULSES_OUT <= {NUM_VALUES{1'b1}};
                        VALID_OUT  <= 1'b1;

                        output_level <= output_level + 1'b1;
                    end

                    /*
                     * DONE is treated as being asserted together with
                     * the final valid PULSES_IN value.
                     *
                     * If DONE is asserted one cycle later instead,
                     * simply drive PULSES_IN to zero during that cycle.
                     */
                    if (DONE) begin
                        state <= STATE_DRAIN;
                    end
                end

                // =====================================================
                // Emit the remaining sorted pulse columns
                // =====================================================
                STATE_DRAIN: begin

                    if (output_level < max_count) begin

                        /*
                         * Generate the next sorted column by comparing
                         * every fixed counter against output_level.
                         */
                        PULSES_OUT <= sorted_output_mask;
                        VALID_OUT  <= 1'b1;

                        /*
                         * If this is the final level, the current output
                         * is the final valid sorted column.
                         */
                        if (output_level == max_count - 1'b1) begin
                            DONE_OUT <= 1'b1;
                            state    <= STATE_CAPTURE;

                            output_level <= {COUNTER_WIDTH{1'b0}};
                            max_count    <= {COUNTER_WIDTH{1'b0}};

                            for (i = 0; i < NUM_VALUES; i = i + 1) begin
                                pulse_count[i] <=
                                    {COUNTER_WIDTH{1'b0}};
                            end

                        end else begin
                            output_level <= output_level + 1'b1;
                        end

                    end else begin
                        /*
                         * All output columns may already have been
                         * emitted during capture.
                         */
                        DONE_OUT <= 1'b1;
                        state    <= STATE_CAPTURE;

                        output_level <= {COUNTER_WIDTH{1'b0}};
                        max_count    <= {COUNTER_WIDTH{1'b0}};

                        for (i = 0; i < NUM_VALUES; i = i + 1) begin
                            pulse_count[i] <=
                                {COUNTER_WIDTH{1'b0}};
                        end
                    end
                end

                default: begin
                    state <= STATE_CAPTURE;
                end

            endcase
        end
    end

endmodule