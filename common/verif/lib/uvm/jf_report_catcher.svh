// Author:  Rob Donnelly <robert.donnelly@jpl.nasa.gov>
// Created: 2019-06-25

// Class: jf_report_catcher
//
// Catches deprecated UVM warnings.
//
// Questa comes with a version of UVM that includes deprecated code (I.e. not
// compiled with the UVM_NO_DEPRECATED define).  This class works around this
// problem by catching the deprecated warnings.  These warnings are not valid
// in UVM 1.2.
class jf_report_catcher extends uvm_report_catcher;
    function new(string name = "jf_report_catcher");
        super.new(name);
    endfunction

    virtual function action_e catch();
        case (get_id())
            "UVM/RSRC/NOREGEX": begin
                // This warning is due to uvm_reg_block classes having a '.'
                // character in their full name.  Having a '.' character in the
                // full name is by UVM design.  This warning is only seen when
                // a uvm_reg_block is nested within another uvm_reg_block.
                //
                // Example warning:
                //
                // # WARNING:1: 0ns 0s [UVM/RSRC/NOREGEX:1] a resource with meta
                // characters in the field name has been created "regs.system"
                //
                // Source: https://github.com/accellera/uvm/blob/UVM_1_2_RELEASE/distrib/src/base/uvm_resource.svh#L1416
                return CAUGHT;
            end
            "RegModel": begin
                case (1)
                    starts_with(get_message(), "Trying to predict value of register"): begin
                        // This warning is thrown when calling uvm_reg::predict()
                        // while a register is in the process of being accessed.
                        //
                        // We want to promote this to an error because
                        // uvm_reg::do_predict() will early return and not actually
                        // perform the prediction.
                        //
                        // Source: https://github.com/accellera/uvm/blob/UVM_1_2_RELEASE/distrib/src/reg/uvm_reg.svh#L1972-L1973
                        set_severity(UVM_ERROR);
                        set_message({
                            get_message(), "\n",
                            "Prediction not performed.\n",
                            "Resolve by doing one or more of the following:\n",
                            "* Modify the stimulus and/or checking to avoid a collision on access and prediction\n",
                            "* Call uvm_reg::Xset_busyX(0) before uvm_reg::predict()\n",
                            "* Use uvm_reg_field::predict() instead"
                        });
                        return THROW;
                    end
                    starts_with(get_message(), "Trying to predict value of field"): begin
                        // This warning is thrown when calling
                        // uvm_reg_field::predict() while a register is in the
                        // process of being accessed but, unlike
                        // uvm_reg::predict(), the prediction still occurs.
                        //
                        // We ignore this warning because we often need to call
                        // predict on a write to implement custom behavior.
                        return CAUGHT;
                    end
                endcase
            end
        endcase

        return THROW;
    endfunction

    function bit starts_with(string s, string substr);
        return s.substr(0, substr.len() - 1) == substr;
    endfunction
endclass
