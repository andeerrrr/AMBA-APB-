module apb_s(
    input              pclk,
    input              presetn,
    input       [31:0] paddr,
    input              psel,
    input              penable,
    input       [7:0]  pwdata,
    input              pwrite,
    
    output      [7:0]  prdata,
    output reg         pready,
    output             pslverr
);

    localparam [1:0] IDLE  = 2'b00, 
                     WRITE = 2'b01, 
                     READ  = 2'b10;

    reg [7:0] mem [0:15];
    reg [1:0] state, nstate;

    wire addr_err;

    assign addr_err = (paddr > 32'd15);
    assign pslverr  = (psel && penable) ? addr_err : 1'b0;

    // Continuous read data: outputs valid data when in READ access phase
    assign prdata = (state == READ && psel && penable && !addr_err) ? mem[paddr[3:0]] : 8'h00;

    // Combinational next-state & pready
    always @(*) begin
        nstate = state;
        pready = 1'b0;

        case (state)
            IDLE: begin
                if (psel && !penable) begin
                    if (pwrite) nstate = WRITE;
                    else        nstate = READ;
                end
            end

            WRITE: begin
                if (psel && penable) begin
                    pready = 1'b1;
                    nstate = IDLE;
                end
            end

            READ: begin
                if (psel && penable) begin
                    pready = 1'b1;
                    nstate = IDLE;
                end
            end

            default: nstate = IDLE;
        endcase
    end

    // Sequential write and reset
    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            state <= IDLE;
            for (int i = 0; i < 16; i++) mem[i] <= 8'h00;
        end else begin
            state <= nstate;
            if (state == WRITE && psel && penable && !addr_err) begin
                mem[paddr[3:0]] <= pwdata;
            end
        end
    end

endmodule
