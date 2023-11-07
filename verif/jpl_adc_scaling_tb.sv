////////////////////////////////////////////////////////////////////////////////
// COPYRIGHT 2023, BY THE CALIFORNIA INSTITUTE OF TECHNOLOGY. ALL RIGHTS 
// RESERVED. UNITED STATES GOVERNMENT SPONSORSHIP ACKNOWLEDGED. ANY COMMERCIAL 
// USE MUST BE NEGOTIATED WITH THE OFFICE OF TECHNOLOGY TRANSFER AT THE 
// CALIFORNIA INSTITUTE OF TECHNOLOGY.
// 
// THIS SOFTWARE MAY BE SUBJECT TO U.S. EXPORT CONTROL LAWS AND REGULATIONS. BY 
// ACCEPTING THIS DOCUMENT, THE USER AGREES TO COMPLY WITH ALL APPLICABLE U.S. 
// EXPORT LAWS AND REGULATIONS. USER HAS THE RESPONSIBILITY TO OBTAIN EXPORT 
// LICENSES, OR OTHER EXPORT AUTHORITY AS MAY BE REQUIRED, BEFORE EXPORTING SUCH 
// INFORMATION TO FOREIGN COUNTRIES OR PROVIDING ACCESS TO FOREIGN PERSONS.
// 
// DESIGN: IP
// PROJECT: JPL IP Library
// COMPANY: Jet Propulsion Laboratory
// ENGINEER: Jinseong Lee (jinseong.lee@jpl.nasa.gov)
// CREATED: 2023-09-21
//
// FILENAME: jpl_adc_scaling_tb.sv
//
// DESCRIPTION: Unit test for jpl_adc_scaling.
//
// SUPPORTING DOCUMENTATION: 
// - README.md
//
// DEPENDENCIES: None
//
// REVISION HISTORY:
// REVISION HISTORY:
// - 2023-10-05    J.Lee     Initial version
// - 2023-10-31    R.Stern   Updated to display PASS/FAIL results at the end.
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

module jpl_adc_scaling_tb #(
    parameter            B    = 12    ,  
    parameter            N    = 2     ,  // channel
    parameter            S    = 12    ,  
    parameter            D    = 0     ,  
    parameter            LOG2AVG  = 12           
    
  ); 
  //parameters
    localparam          SYSCLK_PERIOD           = 10;// 100MHZ
    localparam          LOG2INT                 = 2; //input valid once per 2^LOG2INT
    localparam          s_adc_raw_valid_period  = 8;
    localparam          init_i_adc_raw          = 4; 
    


    logic            i_clk                 ;
    logic            i_rst_n               ;
  
    logic [B-1:0]    i_adc_raw             ;  
    logic            i_adc_raw_valid       ;  
    logic            i_start_cal           ;  
    logic [S-1:0]    i_scale_val           ;  
    logic [B-1:0]    i_ext_offset          ;  
    logic            i_offset_mode         ;  
    logic [B+S-D-1:0]i_threshold           ;
    
    logic signed [B+S-D:0] o_result        ;  
    logic            o_result_valid        ;  // 
    logic [B-1:0]    o_cal_offset          ;  
    logic            o_cal_done            ;   
    logic            o_fault_adc_raw       ;   

    logic [B+LOG2INT+1:0] s_cnt_clk        ;
    logic [B-1:0]    s_offset              ;
    logic            s_adc_raw_valid_cont  ;

    logic     [LOG2INT:0] cnt_i_offset_mode;
    
    integer num_passed1 = 0;
    integer num_errors1 = 0;
    integer num_passed2 = 0;
    integer num_errors2 = 0;
    
  
    localparam toggle_dly_i_rst_n = 'd2;
    localparam time_finish = 'd200000;
    
    integer fd;
    initial begin 
        $timeformat(-9, 0, " ns");
        $display("=========== START============");
        
        i_clk           = 1'b1;    
        i_rst_n         = 1'b0;
        
        i_start_cal     = 1'b0;
        i_scale_val     = 12'd1;
        i_offset_mode   = 1'd0; //1: external, 0: internal
        cnt_i_offset_mode = 'd0;

        s_adc_raw_valid_cont = 1'd1;// 1: continuous valid, 0: interval
        s_cnt_clk       = 'b0;
        
        i_ext_offset    =     init_i_adc_raw;
        i_adc_raw       =     init_i_adc_raw;
        i_threshold     = (B+S-D)'('d5);
        
        #(SYSCLK_PERIOD*2);  
            i_rst_n     = 1'b1;

        //open log file
        fd= $fopen("jpl_adc_scaling_log.txt", "w");

        #2000000
        $fclose(fd);
        $display ("");
        $display ("-----------------------------------------------------------------");     
        if ((num_errors1 + num_errors2) == 0) begin
          $display ("TEST PASSED");
        end
        else begin
          $display ("TEST FAILED");
        end
        $display ("PASSED: %0d, FAILED: %0d", (num_passed1 + num_passed2), (num_errors1 + num_errors2));
        $display ("");
        $display ("For more details see jpl_adc_scaling_log.txt");
        $display ("-----------------------------------------------------------------");
        $display ("");
        $stop;
    end

 
    always
        #(SYSCLK_PERIOD/2) i_clk <= !i_clk;
   
    // update raw_data 
    always @ (posedge i_clk) begin 
        if (s_cnt_clk == toggle_dly_i_rst_n) begin
            i_rst_n   <= 1'b1; // deactivate 
        end

        if (s_cnt_clk == 0) begin
            i_rst_n   <= 1'b0; // active low reset 
        end

        //=================  start calibration =================  
        if (s_cnt_clk == toggle_dly_i_rst_n + (1<<LOG2INT)*2)  // after two more raw
            i_start_cal      <= 1'b1;
        
        if (s_cnt_clk == toggle_dly_i_rst_n + (1<<LOG2INT)*2 + 1) 
            i_start_cal      <= 1'b0;

        if (s_cnt_clk == toggle_dly_i_rst_n + (1<<LOG2INT)*2) //increase when calibration start
            i_adc_raw   <= i_adc_raw + 1;

        //=================  increment clk_cnt and toggle adc_valid between continuous/interval =================  
        if(s_adc_raw_valid_cont == 1'b1) begin //continuous valid
            s_cnt_clk <= s_cnt_clk + 1;
            if (s_cnt_clk == {(B+1){1'b1}}) begin
                s_cnt_clk <='b0;
                s_adc_raw_valid_cont <= 1'b0;
            end
        end
        else begin
            if (s_cnt_clk == ({(B+LOG2INT+1){1'b1}})) begin
                s_cnt_clk <='b0;
                s_adc_raw_valid_cont <= 1'b1;
            end
            else
                s_cnt_clk <= s_cnt_clk + 1;
        end

        // =================  trigger the interval for adc_raw_valid =================  
        if(s_adc_raw_valid_cont==1'b1) 
                i_adc_raw_valid <= 1'b1;
        else begin
            if (s_cnt_clk % (1<<LOG2INT)==0) 
                i_adc_raw_valid <= 1'b1;
            else
                i_adc_raw_valid <= 1'b0;
        end
    end

    //=================  toggle offset mode =================  
    always @(i_start_cal, cnt_i_offset_mode) begin
        if(i_start_cal==1'b1) begin
        // if(i_start_cal%2==1'b0)
            cnt_i_offset_mode = cnt_i_offset_mode + 1;
            
            if(cnt_i_offset_mode % 2 == 1)
                i_offset_mode = ~i_offset_mode;
        end
    end

    assign s_offset = (i_offset_mode ==1'b1) ? i_ext_offset : o_cal_offset;
    string PassFail;

    //=================  self-check  =================  
    always_comb begin : self_check
        if (o_result_valid == 1'b1 && o_cal_done ==1'b1) begin
            if(i_offset_mode == 1'b0) begin//internal offset
                assert (i_adc_raw==o_cal_offset && o_result == 'd0)  begin
                    PassFail = "PASS";
                    $fwrite(fd, "PASS:  %0t,      mode = %b,   i_adc_raw: %d, s_offset: %p, o_result: %d\n", 
                                      $time,  i_offset_mode,       i_adc_raw,     s_offset,     o_result);
                    num_passed1 = num_passed1 + 1;
                end
                else begin
                    PassFail = "FAIL <<--------";
                    num_errors1 = num_errors1 + 1;
                end
            end
            else begin // external offset
                assert ((o_result==i_adc_raw - s_offset) && (s_offset == i_ext_offset)) begin
                    PassFail = "PASS";
                    $fwrite(fd, "PASS:  %0t,      mode = %b,   i_adc_raw: %d, s_offset: %p, o_result: %d\n", 
                                      $time,  i_offset_mode,       i_adc_raw,     s_offset,     o_result);
                    num_passed2 = num_passed2 + 1;
                end
                else begin
                    PassFail = "FAIL <<--------";
                    num_errors2 = num_errors2 + 1;
                end
            end
        end
    end

    //=================  log file =================  
    always_comb begin : Error_Log_file
        if(PassFail == "FAIL") begin
            $error ("FAIL:      %0t,     mode = %b,  i_adc_raw: %d, s_offset: %p, o_result: %d", 
                        $time,       i_offset_mode,  i_adc_raw,     s_offset,     o_result);
            $fwrite(fd, "FAIL:  %0t,     mode = %b,  i_adc_raw: %d, s_offset: %p, o_result: %d\n", 
                        $time,  i_offset_mode,       i_adc_raw,     s_offset,     o_result);
            $stop;
        end
    end

  //=================  Instantiate =================  
    jpl_adc_scaling
    #(
        .B  (B),
        .S  (S),  
        .D   (D),
        .LOG2AVG  (LOG2AVG)
    )  jpl_adc_scaling  
    (
        // Inputs
        .i_clk          (i_clk)             ,         
        .i_rst_n        (i_rst_n)           ,         

        .i_adc_raw      (i_adc_raw)         ,      
        .i_adc_raw_valid(i_adc_raw_valid)   ,
        .i_start_cal    (i_start_cal)       ,
        .i_scale_val    (i_scale_val)       ,
        .i_ext_offset   (i_ext_offset)      ,
        .i_offset_mode  (i_offset_mode)     ,
        .i_threshold    (i_threshold)       ,

        .o_result       (o_result)          ,
        .o_result_valid (o_result_valid)    ,
        .o_cal_offset   (o_cal_offset)      ,
        .o_cal_done     (o_cal_done)        ,
        .o_fault_adc_raw(o_fault_adc_raw)
    );
  
endmodule