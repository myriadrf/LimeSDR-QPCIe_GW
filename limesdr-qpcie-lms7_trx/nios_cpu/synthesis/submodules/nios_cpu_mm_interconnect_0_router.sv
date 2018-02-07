// (C) 2001-2016 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/16.1/ip/merlin/altera_merlin_router/altera_merlin_router.sv.terp#1 $
// $Revision: #1 $
// $Date: 2016/08/07 $
// $Author: swbranch $

// -------------------------------------------------------
// Merlin Router
//
// Asserts the appropriate one-hot encoded channel based on 
// either (a) the address or (b) the dest id. The DECODER_TYPE
// parameter controls this behaviour. 0 means address decoder,
// 1 means dest id decoder.
//
// In the case of (a), it also sets the destination id.
// -------------------------------------------------------

`timescale 1 ns / 1 ns

module nios_cpu_mm_interconnect_0_router_default_decode
  #(
     parameter DEFAULT_CHANNEL = 11,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 14 
   )
  (output [83 - 79 : 0] default_destination_id,
   output [24-1 : 0] default_wr_channel,
   output [24-1 : 0] default_rd_channel,
   output [24-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[83 - 79 : 0];

  generate
    if (DEFAULT_CHANNEL == -1) begin : no_default_channel_assignment
      assign default_src_channel = '0;
    end
    else begin : default_channel_assignment
      assign default_src_channel = 24'b1 << DEFAULT_CHANNEL;
    end
  endgenerate

  generate
    if (DEFAULT_RD_CHANNEL == -1) begin : no_default_rw_channel_assignment
      assign default_wr_channel = '0;
      assign default_rd_channel = '0;
    end
    else begin : default_rw_channel_assignment
      assign default_wr_channel = 24'b1 << DEFAULT_WR_CHANNEL;
      assign default_rd_channel = 24'b1 << DEFAULT_RD_CHANNEL;
    end
  endgenerate

endmodule


module nios_cpu_mm_interconnect_0_router
(
    // -------------------
    // Clock & Reset
    // -------------------
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                       sink_valid,
    input  [97-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output                          src_valid,
    output reg [97-1    : 0] src_data,
    output reg [24-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    // -------------------------------------------------------
    // Local parameters and variables
    // -------------------------------------------------------
    localparam PKT_ADDR_H = 52;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 83;
    localparam PKT_DEST_ID_L = 79;
    localparam PKT_PROTECTION_H = 87;
    localparam PKT_PROTECTION_L = 85;
    localparam ST_DATA_W = 97;
    localparam ST_CHANNEL_W = 24;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 55;
    localparam PKT_TRANS_READ  = 56;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    // -------------------------------------------------------
    // Figure out the number of bits to mask off for each slave span
    // during address decoding
    // -------------------------------------------------------
    localparam PAD0 = log2ceil(64'h10000 - 64'h8000); 
    localparam PAD1 = log2ceil(64'h11000 - 64'h10800); 
    localparam PAD2 = log2ceil(64'h11100 - 64'h11000); 
    localparam PAD3 = log2ceil(64'h11200 - 64'h11100); 
    localparam PAD4 = log2ceil(64'h11300 - 64'h11200); 
    localparam PAD5 = log2ceil(64'h11400 - 64'h11300); 
    localparam PAD6 = log2ceil(64'h11500 - 64'h11400); 
    localparam PAD7 = log2ceil(64'h11600 - 64'h11500); 
    localparam PAD8 = log2ceil(64'h11620 - 64'h11600); 
    localparam PAD9 = log2ceil(64'h11640 - 64'h11620); 
    localparam PAD10 = log2ceil(64'h11660 - 64'h11640); 
    localparam PAD11 = log2ceil(64'h11680 - 64'h11660); 
    localparam PAD12 = log2ceil(64'h11690 - 64'h11680); 
    localparam PAD13 = log2ceil(64'h116a0 - 64'h11690); 
    localparam PAD14 = log2ceil(64'h116b0 - 64'h116a0); 
    localparam PAD15 = log2ceil(64'h116c0 - 64'h116b0); 
    localparam PAD16 = log2ceil(64'h116d0 - 64'h116c0); 
    localparam PAD17 = log2ceil(64'h116e0 - 64'h116d0); 
    localparam PAD18 = log2ceil(64'h116f0 - 64'h116e0); 
    localparam PAD19 = log2ceil(64'h11700 - 64'h116f0); 
    localparam PAD20 = log2ceil(64'h11710 - 64'h11700); 
    localparam PAD21 = log2ceil(64'h11720 - 64'h11710); 
    localparam PAD22 = log2ceil(64'h11728 - 64'h11720); 
    localparam PAD23 = log2ceil(64'h11730 - 64'h11728); 
    // -------------------------------------------------------
    // Work out which address bits are significant based on the
    // address range of the slaves. If the required width is too
    // large or too small, we use the address field width instead.
    // -------------------------------------------------------
    localparam ADDR_RANGE = 64'h11730;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam RG = RANGE_ADDR_WIDTH-1;
    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;

      reg [PKT_ADDR_W-1 : 0] address;
      always @* begin
        address = {PKT_ADDR_W{1'b0}};
        address [REAL_ADDRESS_RANGE:0] = sink_data[OPTIMIZED_ADDR_H : PKT_ADDR_L];
      end   

    // -------------------------------------------------------
    // Pass almost everything through, untouched
    // -------------------------------------------------------
    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [24-1 : 0] default_src_channel;




    // -------------------------------------------------------
    // Write and read transaction signals
    // -------------------------------------------------------
    wire read_transaction;
    assign read_transaction  = sink_data[PKT_TRANS_READ];


    nios_cpu_mm_interconnect_0_router_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

        // --------------------------------------------------
        // Address Decoder
        // Sets the channel and destination ID based on the address
        // --------------------------------------------------

    // ( 0x8000 .. 0x10000 )
    if ( {address[RG:PAD0],{PAD0{1'b0}}} == 17'h8000   ) begin
            src_channel = 24'b000000000000100000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 14;
    end

    // ( 0x10800 .. 0x11000 )
    if ( {address[RG:PAD1],{PAD1{1'b0}}} == 17'h10800   ) begin
            src_channel = 24'b000000000000000000010000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 13;
    end

    // ( 0x11000 .. 0x11100 )
    if ( {address[RG:PAD2],{PAD2{1'b0}}} == 17'h11000   ) begin
            src_channel = 24'b000000000000010000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 16;
    end

    // ( 0x11100 .. 0x11200 )
    if ( {address[RG:PAD3],{PAD3{1'b0}}} == 17'h11100   ) begin
            src_channel = 24'b000000000000001000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 17;
    end

    // ( 0x11200 .. 0x11300 )
    if ( {address[RG:PAD4],{PAD4{1'b0}}} == 17'h11200   ) begin
            src_channel = 24'b000000000000000100000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 18;
    end

    // ( 0x11300 .. 0x11400 )
    if ( {address[RG:PAD5],{PAD5{1'b0}}} == 17'h11300   ) begin
            src_channel = 24'b000000000000000010000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 19;
    end

    // ( 0x11400 .. 0x11500 )
    if ( {address[RG:PAD6],{PAD6{1'b0}}} == 17'h11400   ) begin
            src_channel = 24'b000000000000000001000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 20;
    end

    // ( 0x11500 .. 0x11600 )
    if ( {address[RG:PAD7],{PAD7{1'b0}}} == 17'h11500   ) begin
            src_channel = 24'b000000000000000000100000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 15;
    end

    // ( 0x11600 .. 0x11620 )
    if ( {address[RG:PAD8],{PAD8{1'b0}}} == 17'h11600   ) begin
            src_channel = 24'b100000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 7;
    end

    // ( 0x11620 .. 0x11640 )
    if ( {address[RG:PAD9],{PAD9{1'b0}}} == 17'h11620   ) begin
            src_channel = 24'b010000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 3;
    end

    // ( 0x11640 .. 0x11660 )
    if ( {address[RG:PAD10],{PAD10{1'b0}}} == 17'h11640   ) begin
            src_channel = 24'b001000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 8;
    end

    // ( 0x11660 .. 0x11680 )
    if ( {address[RG:PAD11],{PAD11{1'b0}}} == 17'h11660   ) begin
            src_channel = 24'b000000000000000000000100;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 11;
    end

    // ( 0x11680 .. 0x11690 )
    if ( {address[RG:PAD12],{PAD12{1'b0}}} == 17'h11680  && read_transaction  ) begin
            src_channel = 24'b000100000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 5;
    end

    // ( 0x11690 .. 0x116a0 )
    if ( {address[RG:PAD13],{PAD13{1'b0}}} == 17'h11690   ) begin
            src_channel = 24'b000010000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 2;
    end

    // ( 0x116a0 .. 0x116b0 )
    if ( {address[RG:PAD14],{PAD14{1'b0}}} == 17'h116a0   ) begin
            src_channel = 24'b000001000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 21;
    end

    // ( 0x116b0 .. 0x116c0 )
    if ( {address[RG:PAD15],{PAD15{1'b0}}} == 17'h116b0  && read_transaction  ) begin
            src_channel = 24'b000000100000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 22;
    end

    // ( 0x116c0 .. 0x116d0 )
    if ( {address[RG:PAD16],{PAD16{1'b0}}} == 17'h116c0   ) begin
            src_channel = 24'b000000010000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 6;
    end

    // ( 0x116d0 .. 0x116e0 )
    if ( {address[RG:PAD17],{PAD17{1'b0}}} == 17'h116d0   ) begin
            src_channel = 24'b000000001000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 4;
    end

    // ( 0x116e0 .. 0x116f0 )
    if ( {address[RG:PAD18],{PAD18{1'b0}}} == 17'h116e0  && read_transaction  ) begin
            src_channel = 24'b000000000100000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 1;
    end

    // ( 0x116f0 .. 0x11700 )
    if ( {address[RG:PAD19],{PAD19{1'b0}}} == 17'h116f0  && read_transaction  ) begin
            src_channel = 24'b000000000010000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 9;
    end

    // ( 0x11700 .. 0x11710 )
    if ( {address[RG:PAD20],{PAD20{1'b0}}} == 17'h11700   ) begin
            src_channel = 24'b000000000001000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 10;
    end

    // ( 0x11710 .. 0x11720 )
    if ( {address[RG:PAD21],{PAD21{1'b0}}} == 17'h11710   ) begin
            src_channel = 24'b000000000000000000000010;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
    end

    // ( 0x11720 .. 0x11728 )
    if ( {address[RG:PAD22],{PAD22{1'b0}}} == 17'h11720  && read_transaction  ) begin
            src_channel = 24'b000000000000000000001000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 23;
    end

    // ( 0x11728 .. 0x11730 )
    if ( {address[RG:PAD23],{PAD23{1'b0}}} == 17'h11728   ) begin
            src_channel = 24'b000000000000000000000001;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 12;
    end

end


    // --------------------------------------------------
    // Ceil(log2()) function
    // --------------------------------------------------
    function integer log2ceil;
        input reg[65:0] val;
        reg [65:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule


