`timescale 1ns/1ps

module matvec_p1_tb;

    //==================================================
    // DUT SIGNALS
    //==================================================
    reg clk;
    reg rst_n;
    reg start;

    reg        A_we;
    reg  [5:0] A_waddr;
    reg signed [15:0] A_wdata;

    reg        x_we;
    reg  [2:0] x_waddr;
    reg signed [15:0] x_wdata;

    wire [319:0] y_out;
    wire done;


    //==================================================
    // TEST DATA
    //==================================================
    reg signed [15:0] A_test [0:63];
    reg signed [15:0] x_test [0:7];

    reg signed [39:0] expected [0:7];

    integer total_err;
    integer pass_cnt;
    integer fail_cnt;

    integer i;
    integer t;
    integer seed;

    integer case_err;
    integer case_cycles;

    integer random_err;
    integer random_pass;


    //==================================================
    // DUT
    //==================================================
    matvec_p1 dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .start   (start),

        .A_we    (A_we),
        .A_waddr (A_waddr),
        .A_wdata (A_wdata),

        .x_we    (x_we),
        .x_waddr (x_waddr),
        .x_wdata (x_wdata),

        .y_out   (y_out),
        .done    (done)
    );


    //==================================================
    // CLOCK: T = 10 ns
    //==================================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    //==================================================
    // CLEAR TEST DATA
    //==================================================
    task clear_test_data;
        integer k;
        begin

            for (k = 0; k < 64; k = k + 1)
                A_test[k] = 16'sd0;

            for (k = 0; k < 8; k = k + 1)
                x_test[k] = 16'sd0;

        end
    endtask


    //==================================================
    // GOLDEN MODEL
    //
    // y[r] = SUM A[r][c] * x[c]
    //==================================================
    task calc_golden;

        integer rr;
        integer cc;

        reg signed [31:0] product_ref;
        reg signed [63:0] acc_ref;

        begin

            for (rr = 0; rr < 8; rr = rr + 1) begin

                acc_ref = 64'sd0;

                for (cc = 0; cc < 8; cc = cc + 1) begin

                    product_ref =
                        $signed(A_test[rr*8 + cc])
                        * $signed(x_test[cc]);

                    acc_ref = acc_ref + product_ref;

                end

                expected[rr] = acc_ref[39:0];

            end

        end

    endtask


    //==================================================
    // LOAD A AND x
    //==================================================
    task load_data;

        integer k;

        begin

            // Load A
            for (k = 0; k < 64; k = k + 1) begin

                @(negedge clk);

                A_we    = 1'b1;
                A_waddr = k;
                A_wdata = A_test[k];

            end

            @(negedge clk);
            A_we = 1'b0;


            // Load x
            for (k = 0; k < 8; k = k + 1) begin

                @(negedge clk);

                x_we    = 1'b1;
                x_waddr = k;
                x_wdata = x_test[k];

            end

            @(negedge clk);
            x_we = 1'b0;

        end

    endtask


    //==================================================
    // RUN ONE DATASET
    //
    // Không tự in PASS/FAIL.
    // Trả về:
    //    err_out   = số lỗi
    //    cycle_out = latency
    //==================================================
    task run_dataset;

        output integer err_out;
        output integer cycle_out;

        integer rr;

        reg signed [39:0] got;

        begin

            err_out   = 0;
            cycle_out = 0;

            //--------------------------------------------------
            // Golden model
            //--------------------------------------------------
            calc_golden;


            //--------------------------------------------------
            // Load A, x
            //--------------------------------------------------
            load_data;


            //--------------------------------------------------
            // Start pulse
            //--------------------------------------------------
            @(negedge clk);
            start = 1'b1;

            @(posedge clk);
            #1;

            @(negedge clk);
            start = 1'b0;


            //--------------------------------------------------
            // Wait done
            //--------------------------------------------------
            while ((done !== 1'b1) &&
                   (cycle_out < 80)) begin

                @(posedge clk);
                #1;

                cycle_out = cycle_out + 1;

            end


            //--------------------------------------------------
            // Timeout
            //--------------------------------------------------
            if (done !== 1'b1) begin

                err_out = err_out + 1;

            end

            else begin

                //--------------------------------------------------
                // Check latency
                //--------------------------------------------------
                if (cycle_out !== 65)
                    err_out = err_out + 1;


                //--------------------------------------------------
                // Check all 8 outputs
                //--------------------------------------------------
                for (rr = 0; rr < 8; rr = rr + 1) begin

                    got = y_out[rr*40 +: 40];

                    if (got !== expected[rr])
                        err_out = err_out + 1;

                end


                //--------------------------------------------------
                // done phải chỉ kéo dài 1 cycle
                //--------------------------------------------------
                @(posedge clk);
                #1;

                if (done !== 1'b0)
                    err_out = err_out + 1;

            end

        end

    endtask


    //==================================================
    // MAIN TEST
    //==================================================
    initial begin

        rst_n = 1'b0;
        start = 1'b0;

        A_we    = 1'b0;
        A_waddr = 6'd0;
        A_wdata = 16'sd0;

        x_we    = 1'b0;
        x_waddr = 3'd0;
        x_wdata = 16'sd0;

        total_err = 0;
        pass_cnt  = 0;
        fail_cnt  = 0;

        seed = 32'h12345678;


        //==================================================
        // RESET
        //==================================================
        repeat (3)
            @(posedge clk);

        @(negedge clk);
        rst_n = 1'b1;


        //==================================================
        // TC01 - ZERO MATRIX
        //==================================================
        clear_test_data;

        for (i = 0; i < 8; i = i + 1)
            x_test[i] = i + 1;


        $display("");
        $display("========================================");
        $display("TC01 - ZERO MATRIX");
        $display("Stimulus : A = 0");
        $display("           x = {1,2,3,4,5,6,7,8}");
        $display("Expected : y = {0,0,0,0,0,0,0,0}");
        $display("========================================");

        run_dataset(case_err, case_cycles);

        if (case_err == 0) begin

            $display(
                "TC01: PASS - latency = %0d cycles",
                case_cycles
            );

            pass_cnt = pass_cnt + 1;

        end
        else begin

            $display(
                "TC01: FAIL - %0d errors",
                case_err
            );

            fail_cnt = fail_cnt + 1;

        end

        total_err = total_err + case_err;


        //==================================================
        // TC02 - IDENTITY MATRIX
        //==================================================
        clear_test_data;

        for (i = 0; i < 8; i = i + 1) begin

            A_test[i*8 + i] = 16'sd1;
            x_test[i]       = i + 1;

        end


        $display("");
        $display("========================================");
        $display("TC02 - IDENTITY MATRIX");
        $display("Stimulus : A = I8");
        $display("           x = {1,2,3,4,5,6,7,8}");
        $display("Expected : y = x");
        $display("========================================");

        run_dataset(case_err, case_cycles);

        if (case_err == 0) begin

            $display(
                "TC02: PASS - latency = %0d cycles",
                case_cycles
            );

            pass_cnt = pass_cnt + 1;

        end
        else begin

            $display(
                "TC02: FAIL - %0d errors",
                case_err
            );

            fail_cnt = fail_cnt + 1;

        end

        total_err = total_err + case_err;


        //==================================================
        // TC03 - ROW BOUNDARY / PREFETCH
        //==================================================
        clear_test_data;

        A_test[7]  =  16'sd3;     // A[0][7]
        A_test[8]  =  16'sd5;     // A[1][0]
        A_test[63] = -16'sd2;     // A[7][7]

        x_test[0] = 16'sd2;
        x_test[7] = 16'sd7;


        $display("");
        $display("========================================");
        $display("TC03 - ROW BOUNDARY / PREFETCH");
        $display("Stimulus : A07=3, A10=5, A77=-2");
        $display("           x0=2, x7=7");
        $display("Expected : y0=21, y1=10, y7=-14");
        $display("========================================");

        run_dataset(case_err, case_cycles);

        if (case_err == 0) begin

            $display(
                "TC03: PASS - latency = %0d cycles",
                case_cycles
            );

            pass_cnt = pass_cnt + 1;

        end
        else begin

            $display(
                "TC03: FAIL - %0d errors",
                case_err
            );

            fail_cnt = fail_cnt + 1;

        end

        total_err = total_err + case_err;


        //==================================================
        // TC04 - RANDOM
        //
        // 10 random datasets
        // Nhưng chỉ display kết quả chung một lần
        //==================================================
        $display("");
        $display("========================================");
        $display("TC04 - RANDOM TEST");
        $display("Stimulus : 10 random signed 16-bit A/x");
        $display("Expected : DUT = golden model");
        $display("========================================");


        random_err  = 0;
        random_pass = 0;


        for (t = 1; t <= 10; t = t + 1) begin

            clear_test_data;


            //--------------------------------------------------
            // Random A
            //--------------------------------------------------
            for (i = 0; i < 64; i = i + 1)
                A_test[i] = $random(seed);


            //--------------------------------------------------
            // Random x
            //--------------------------------------------------
            for (i = 0; i < 8; i = i + 1)
                x_test[i] = $random(seed);


            //--------------------------------------------------
            // Chạy nhưng không display từng random set
            //--------------------------------------------------
            run_dataset(case_err, case_cycles);

            if (case_err == 0)
                random_pass = random_pass + 1;

            random_err = random_err + case_err;

        end


        //--------------------------------------------------
        // Chỉ display kết quả chung của TC04
        //--------------------------------------------------
        if (random_err == 0) begin

            $display(
                "TC04: PASS - %0d/10 random sets passed",
                random_pass
            );

            pass_cnt = pass_cnt + 1;

        end
        else begin

            $display(
                "TC04: FAIL - %0d/10 sets passed, %0d errors",
                random_pass,
                random_err
            );

            fail_cnt = fail_cnt + 1;

        end

        total_err = total_err + random_err;


        //==================================================
        // FINAL REPORT
        //==================================================
        $display("");
        $display("========================================");
        $display("        FINAL TEST REPORT");
        $display("========================================");

        $display("Total testcases = 4");
        $display("PASS            = %0d", pass_cnt);
        $display("FAIL            = %0d", fail_cnt);
        $display("Total errors    = %0d", total_err);

        if (total_err == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: TEST FAILED");

        $display("========================================");

        #20;
        $finish;

    end

endmodule