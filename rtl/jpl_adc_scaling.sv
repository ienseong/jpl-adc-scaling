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
// ENGINEER: Jinseong Lee (jinseong.lee@jpl.nasa.gov),
//           Ryan Stern (ryan.a.stern@jpl.nasa.gov)
// CREATED: 2023-09-21
//
// FILENAME: jpl_adc_scaling.sv
//
// DESCRIPTION: Processes an ADC output: running a calibration sequence to
// determine an offset, subtracting out the offset from subsequent values, and
// scaling the result according to the following equations:
//
//   o_result = ((i_adc_raw - offset) * i_scale_val) / (2^D)
//
// The offset can be computed during calibration or supplied externally:
//
//   offset = (i_offset_mode) ? i_ext_offset : cal_offset
//
// The calibration offset is calculated during calibration as follows:
//
//   cal_offset = (Sum of AVG samples of i_adc_raw)>>LOG2AVG
//
// PORTS:
// Outputs:
// - o_result[B+S-D:0] : Processed ADC result.  Two's complement. Signed
// - o_result_valid : Asserts for one clock when a new result is valid. 
// - o_cal_offset[B-1:0] : Calibration offset computed for each channel.  
//   Unsigned.  Valid when o_cal_done asserts.
// - o_cal_done : Asserts for one clock when calibration is complete.
// - o_fault_adc_raw : Asserts when the result falls outside the range 
//                    -i_threshold ~ +i_threshold. 0 = no fault , 1 = fault alarm
// 
// Inputs:
// - i_adc_raw[B-1:0] : Raw ADC value for each channel.  Unsigned.
// - i_adc_raw_valid : Assert for one clock when i_adc_raw is valid
// - i_start_cal : Assert for one clock to start calibration
// - i_scale_val[S-1:0] : Controls channel scaling.  Unsigned integer.  Each 
//   channel is effectively scaled i_scale_val / (2^D).
// - i_ext_offset[B-1:0] : Externally-provided offset for each channel.  
//   Unsigned.  Only used when i_offset_mode = 1.
// - i_offset_mode : Offset mode: 0 = use calibration offset, 1 = use external 
//   offset
// - i_threshold [B+S-D-1:0] :  Threshold of the output result, unsigned
// - i_clk : Module clock
// - i_rst_n : Active-low module reset              
//
// Parameters:
// - B : Bit width of raw ADC input.
// - S : Bit width of scaling factor (i_scale_val).
// - D : Number of bits to right-shift the scaled result.
// - LOG2AVG : Log2 of the number of samples to average during calibration.
//
// SUPPORTING DOCUMENTATION: 
// - https://github.jpl.nasa.gov/jpl-fpga-ip-incubator/jpl-adc-scaling
//
// DEPENDENCIES: None
//
// REVISION HISTORY:
// - 2023-10-05    J.Lee     Initial version
// - 2023-10-10    J.Lee     Resolved issue with negative operation
// - 2023-10-13    R.Stern   Updated header.  Removed N.  Changed width of o_result.
// - 2023-10-23    J. Lee    Updated fault msg by comprison with threshold, and
//                           calculate scaling conversion when input data is valid
// - 2023-10-27    J. Lee    Removed case statement to calculate s_sum_mem_adc_raw, 
//                           and updated multiplication/division per each clock 
// - 2023-10-28    J. Lee    Reset s_sum_mem_adc_raw on i_start_cal anytime, and refined the code


module jpl_adc_scaling #(
    parameter            B        = 12       ,  
    parameter            S        = 12       ,  
    parameter            D        = 0        ,  
    parameter            LOG2AVG  = 3        
 
  )(  
    input  logic         i_clk               ,
    input  logic         i_rst_n             ,

    input  logic [B-1:0] i_adc_raw           ,  
    input  logic         i_adc_raw_valid     ,  
    input  logic         i_start_cal         ,  
    input  logic [S-1:0] i_scale_val         ,  
    input  logic [B-1:0] i_ext_offset        ,  
    input  logic         i_offset_mode       ,  
    input  logic [B+S-D-1:0] i_threshold       ,  

    output logic signed [B+S-D:0] o_result   ,  
    output logic         o_result_valid      ,  
    output logic [B-1:0] o_cal_offset        ,  
    output logic         o_cal_done          ,
    output logic         o_fault_adc_raw      
  );
   
    logic [LOG2AVG*2:0] s_cnt_valid_i_adc_raw  ; //incoming valid data counter, set enough   
    
    // summation of samples for average calculation
    logic [LOG2AVG+B-1:0] s_sum_mem_adc_raw; //with Ryan
    
    logic [B-1:0] cal_offset ;//calibrated offset
    logic  [B-1:0] s_offset;
    
    logic s_cal_mode;

    //scaling variables
    logic signed [(B-1)+1:0] s_result_sub; //subtraction
    logic signed [B + S:0] s_result_mul_scale ;//multiplicaiton
    logic signed [B+S-D:0] s_result_scale_div;//division, shift
    
    // output result valid and latency
    logic s_result_valid;
    logic s_result_valid_d1;                   
    logic s_result_valid_d2;                     
    
    
    // States for FSM
    typedef enum  logic [1:0] { IDLE   = 0  , 
                                ADC_SCALE   , 
                                CALIBRATION 
                            } adc_fsm_state;
    adc_fsm_state cur_adc_state, next_adc_state; 
    
    always_ff @ (posedge i_clk or negedge i_rst_n) begin    
        if(!i_rst_n)    cur_adc_state <= IDLE;
        else            cur_adc_state <= next_adc_state;
        
    end

    // Finite State Machine
    always_comb begin
        case(cur_adc_state)
            IDLE:
                    next_adc_state = ADC_SCALE;
                
            ADC_SCALE:  
             
                if(i_start_cal == 1'b1 ) begin  next_adc_state = CALIBRATION;
                end
                else begin                      next_adc_state = ADC_SCALE;
                end
            
            CALIBRATION: 
                if ((i_adc_raw_valid == 1'b1) && s_cnt_valid_i_adc_raw == (1<<LOG2AVG)-1 ) begin //here  
                                                next_adc_state = ADC_SCALE;
                end
                else begin                      next_adc_state = CALIBRATION;
                end

            default:                                        
                                                next_adc_state = IDLE;
        endcase
    end 

    //calculate cal_offset
    always_ff @ (posedge i_clk or negedge i_rst_n) begin 
        if(!i_rst_n) begin 
                // s_sum_mem_adc_raw   <= {(LOG2AVG+B){1'b0}};
                s_sum_mem_adc_raw   <= 'b0;
        end
        else begin
            if(i_adc_raw_valid == 1'b1 && cur_adc_state == CALIBRATION) 
                s_sum_mem_adc_raw     <= s_sum_mem_adc_raw + {{LOG2AVG{1'b0}},i_adc_raw};//
            else
                s_sum_mem_adc_raw   <= s_sum_mem_adc_raw;

            if(i_start_cal == 1'b1 ) 
                s_sum_mem_adc_raw   <= 'b0;
        end
    end

    //calibrated offset
    always_comb begin
        case(cur_adc_state)
            IDLE: begin
                    cal_offset = 'b0;
                end
           
            ADC_SCALE:  
                if(o_cal_done ==1'b1) begin
                    cal_offset = B'(s_sum_mem_adc_raw >> LOG2AVG); //error
                end
                else
                    cal_offset = 'b0; //error
            
            default:
                    cal_offset = 'b0;
        endcase
    end 


    //calculate output offset
    assign s_offset = (i_offset_mode ==1'b1) ? i_ext_offset : cal_offset;
    assign o_cal_offset = cal_offset;   
   
    always_ff @ (posedge i_clk or negedge i_rst_n) begin 
        if(!i_rst_n) begin
            s_result_sub       <= {B{1'b0}}; 
            s_result_mul_scale <= {(B+1+S){1'b0}}; 
            s_result_scale_div <= {(B+1+S-D){1'b0}}; 
        end
        else begin
            case(next_adc_state) 
                ADC_SCALE: begin
                    if(i_adc_raw_valid == 1'b1 && cur_adc_state == ADC_SCALE) begin
                        s_result_sub <={1'b0,i_adc_raw} - {1'b0,s_offset}; //test
                    end 
                    else  begin 
                        s_result_sub <= s_result_sub; //test
                    end
                end 
                        
                default: begin
                        s_result_sub          <= s_result_sub; 
                   
                end
            endcase
            
            if(s_result_sub[B] == 1'b1) begin //negative 
                s_result_mul_scale <= (B+1+S)'({1'b1,~(({~s_result_sub+1})*i_scale_val)+1});
            end 
            else begin //positive
                s_result_mul_scale <= (B+1+S)'({1'b0, s_result_sub*i_scale_val});
            end
            
            s_result_scale_div <= (B+1+S-D)'(s_result_mul_scale >> D);  
        end
    end

    //output adc_scaling result after conversion
    assign o_result = s_result_scale_div;       
    
    //output valid during ADC_SCALE when incoming signal is valid
    assign s_result_valid = (!i_rst_n)? 0:
                            ((cur_adc_state == ADC_SCALE) && (i_adc_raw_valid == 1'b1)) ? 1'b1 :
                             1'b0; // compare with threshold

    // delay
    always_ff @ (posedge i_clk or negedge i_rst_n) begin 
        if(!i_rst_n) begin 
            s_result_valid_d1 <= s_result_valid_d1;                   
            s_result_valid_d2 <= s_result_valid_d2;  
            o_result_valid    <= o_result_valid;                   
                
        end
        else begin
            s_result_valid_d1 <= s_result_valid;     
            s_result_valid_d2 <= s_result_valid_d1;  
            o_result_valid    <= s_result_valid_d2;     
        end
    end

    // valid raw data counter
    always_ff @ (posedge i_clk or negedge i_rst_n) begin 
        if(!i_rst_n) begin   
                                    s_cnt_valid_i_adc_raw <= 'b0;
        end 
        else begin
                case(next_adc_state) 
                    IDLE: begin
                                    s_cnt_valid_i_adc_raw <= 'b0;
                            end    

                    ADC_SCALE: begin
                            if ((s_cal_mode == 1'b1 && (s_cnt_valid_i_adc_raw == (1<<LOG2AVG)-1) && 
                                (cur_adc_state== CALIBRATION))
                                || (cur_adc_state==IDLE) ) begin
                                    s_cnt_valid_i_adc_raw <= 'b0;
                            end
                            else begin
                                if( i_adc_raw_valid == 1'b1 ) begin
                                    s_cnt_valid_i_adc_raw <= s_cnt_valid_i_adc_raw+ 1;
                                end
                                else begin
                                    s_cnt_valid_i_adc_raw <= s_cnt_valid_i_adc_raw;
                                end
                            end
                        end

                    CALIBRATION: begin
                            if(i_start_cal == 1'b1 ) begin      
                                    s_cnt_valid_i_adc_raw <= 'd0;       
                            end                                     
                            else begin
                                if( i_adc_raw_valid == 1'b1 ) begin
                                    s_cnt_valid_i_adc_raw <= s_cnt_valid_i_adc_raw+ 1;
                                end 
                                else begin
                                    s_cnt_valid_i_adc_raw <= s_cnt_valid_i_adc_raw; 
                                end
                            end
                        end

                    default:     begin
                                    s_cnt_valid_i_adc_raw  <= 'b0;
                        end
                endcase
        end
    end

    //assert when calibration is done
    always_ff @ (posedge i_clk or negedge i_rst_n) begin 
        if(!i_rst_n) begin 
                                s_cal_mode <= 1'b0;  
                                o_cal_done <= 1'b0;
        end 
        else begin 
                                    
            // case(cur_adc_state) 
            case(next_adc_state) 
                
                ADC_SCALE:  begin   
                                s_cal_mode <= 1'b0;
                                o_cal_done <=  (s_cal_mode == 1'b1 && 
                                               (s_cnt_valid_i_adc_raw == (1<<LOG2AVG)-1)) 
                                                ? 1'b1: o_cal_done; //pulse
                            end     

                CALIBRATION: begin  
                                s_cal_mode <= 1'b1; 
                                o_cal_done <= 1'b0; 
                            end

                default:    begin 
                                s_cal_mode <= 1'b0;
                                o_cal_done <= 1'b0;
                            end
            endcase
        end
    end
   
   // fault alarm by comparaing the output result with threshold
    always_comb begin
        if (o_result_valid ==1) begin
            if((o_result[B+S-D] == 1'b0)  &&  //positive when MSB is 0
               (o_result[B+S-D-1:0] > (B+S-D)'({i_threshold}))) begin // larger than threshold
                    o_fault_adc_raw = 1'b1;
            end
            else begin
                if ((o_result[B+S-D] == 1'b1) && //negative when MSB is 1
                    ((B+S-D)'({~o_result+1}) > (B+S-D)'({i_threshold}))) begin//flip negative result and check its magnitude is larger than threshold
                    o_fault_adc_raw = 1'b1;
                end
                else
                    o_fault_adc_raw = 1'b0;
            end
        end
        else
                    o_fault_adc_raw = 1'b0;

    end
endmodule
