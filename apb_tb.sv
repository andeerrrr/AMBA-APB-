`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2026 02:06:52 PM
// Design Name: 
// Module Name: apb_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

// ========================================================
// 0. Interface
// ========================================================
interface apb_if(input logic pclk);
    logic        presetn;
    logic [31:0] paddr;
    logic        psel;
    logic        penable;
    logic [7:0]  pwdata;
    logic        pwrite;
    logic [7:0]  prdata;
    logic        pready;
    logic        pslverr;
endinterface

// ========================================================
// 1. Transaction Item
// ========================================================
class transaction;
  rand bit [31:0] paddr;
  rand bit [7:0]  pwdata;
  randc bit       pwrite;
       bit [7:0]  prdata;
       bit        pready;
       bit        pslverr;

  constraint addr_c {
    paddr inside {[0:15]};
  }

  constraint data_c {
    pwdata inside {[0:255]};
  }

  function void display(input string tag);
    $display("[%0s] : paddr:0x%0h pwdata:0x%0h pwrite:%0b prdata:0x%0h pslverr:%0b @ %0t",
             tag, paddr, pwdata, pwrite, prdata, pslverr, $time);
  endfunction
endclass

// ========================================================
// 2. Generator
// ========================================================
class generator;
  transaction tr;
  mailbox #(transaction) mbx;
  int count = 0;

  event nextdrv; // Driver completes handshake
  event done;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run();
    repeat (count) begin
      tr = new();
      assert(tr.randomize()) else $error("Randomization failed");
      mbx.put(tr);
      tr.display("GEN");
      @(nextdrv);
    end
    ->done;
  endtask
endclass

// ========================================================
// 3. Driver (Strict 2-Cycle APB Protocol)
// ========================================================
class driver;
  virtual apb_if vif;
  mailbox #(transaction) mbx;
  transaction datac;
  event nextdrv;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task reset();
    vif.presetn <= 1'b0;
    vif.psel    <= 1'b0;
    vif.penable <= 1'b0;
    vif.pwdata  <= '0;
    vif.paddr   <= '0;
    vif.pwrite  <= 1'b0;
    repeat (5) @(posedge vif.pclk);
    vif.presetn <= 1'b1;
    $display("[DRV] : RESET DONE @ %0t", $time);
    $display("----------------------------------------------------------------------------");
  endtask

  task run();
    forever begin
      mbx.get(datac);
      
      // Cycle 1: SETUP Phase (PSEL=1, PENABLE=0)
      @(posedge vif.pclk);
      vif.psel    <= 1'b1;
      vif.penable <= 1'b0;
      vif.paddr   <= datac.paddr;
      vif.pwrite  <= datac.pwrite;
      vif.pwdata  <= (datac.pwrite) ? datac.pwdata : 8'h00;

      // Cycle 2: ACCESS Phase (PSEL=1, PENABLE=1)
      @(posedge vif.pclk);
      vif.penable <= 1'b1;

      // Wait until slave is ready (PREADY == 1)
      @(posedge vif.pclk);
      while (!vif.pready) @(posedge vif.pclk);

      // De-assert controls immediately at completion
      vif.psel    <= 1'b0;
      vif.penable <= 1'b0;
      vif.pwrite  <= 1'b0;
      
      datac.display("DRV");
      ->nextdrv;
    end
  endtask
endclass

// ========================================================
// 4. Monitor (Sample at negedge of ACCESS)
// ========================================================
class monitor;
  virtual apb_if vif;
  mailbox #(transaction) mbx;
  transaction tr;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run();
    forever begin
      @(negedge vif.pclk);
      if (vif.psel && vif.penable && vif.pready) begin
        tr = new();
        tr.paddr   = vif.paddr;
        tr.pwdata  = vif.pwdata;
        tr.pwrite  = vif.pwrite;
        tr.prdata  = vif.prdata;
        tr.pslverr = vif.pslverr;
        
        tr.display("MON");
        mbx.put(tr);
      end
    end
  endtask
endclass

// ========================================================
// 5. Scoreboard
// ========================================================
class scoreboard;
  mailbox #(transaction) mbx;
  transaction tr;

  bit [7:0] pwdata[16] = '{default:0};
  bit [7:0] rdata;
  int err = 0;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run();
    forever begin
      mbx.get(tr);
      tr.display("SCO");

      if (tr.pwrite && !tr.pslverr) begin
        pwdata[tr.paddr] = tr.pwdata;
        $display("[SCO] : DATA STORED -> ADDR: 0x%0h | DATA: 0x%0h", tr.paddr, tr.pwdata);
      end 
      else if (!tr.pwrite && !tr.pslverr) begin
        rdata = pwdata[tr.paddr];
        if (tr.prdata === rdata)
          $display("[SCO PASS] : Read Data Matched (0x%0h)", tr.prdata);
        else begin
          err++;
          $error("[SCO FAIL] : Mismatch at Addr 0x%0h! Expected: 0x%0h, Got: 0x%0h", 
                 tr.paddr, rdata, tr.prdata);
        end
      end 
      else if (tr.pslverr) begin
        $display("[SCO] : SLAVE ERROR DETECTED AS EXPECTED");
      end
      
      $display("----------------------------------------------------------------------------");
    end
  endtask
endclass

// ========================================================
// 6. Environment (Restored Wrapper)
// ========================================================
class environment;
  generator  gen;
  driver     drv;
  monitor    mon;
  scoreboard sco;

  event nextgd;

  mailbox #(transaction) gdmbx;
  mailbox #(transaction) msmbx;

  virtual apb_if vif;

  function new(virtual apb_if vif);
    this.vif = vif;

    gdmbx = new();
    msmbx = new();

    gen = new(gdmbx);
    drv = new(gdmbx);
    mon = new(msmbx);
    sco = new(msmbx);

    drv.vif = this.vif;
    mon.vif = this.vif;

    // Connect generator to driver notification
    gen.nextdrv = nextgd;
    drv.nextdrv = nextgd;
  endfunction

  task pre_test();
    drv.reset();
  endtask

  task test();
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_any
  endtask

  task post_test();
    wait (gen.done.triggered);
    #100;
    $display("=================================================");
    $display("---- Total Number of Mismatches : %0d ----", sco.err);
    $display("=================================================");
    $finish();
  endtask

  task run();
    pre_test();
    test();
    post_test();
  endtask
endclass

// ========================================================
// 7. Testbench Top
// ========================================================
module apb_tb();
  logic pclk = 0;
  always #10 pclk = ~pclk; // 50 MHz clock

  apb_if vif (pclk);

  // Connect RTL DUT
  apb_s dut (
    .pclk    (vif.pclk),
    .presetn (vif.presetn),
    .paddr   (vif.paddr),
    .psel    (vif.psel),
    .penable (vif.penable),
    .pwdata  (vif.pwdata),
    .pwrite  (vif.pwrite),
    .prdata  (vif.prdata),
    .pready  (vif.pready),
    .pslverr (vif.pslverr)
  );

  environment env;

  initial begin
    env = new(vif);
    env.gen.count = 20;
    env.run();
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
