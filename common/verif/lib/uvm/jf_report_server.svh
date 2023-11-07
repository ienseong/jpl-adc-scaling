// Class: jf_report_server
//
// Overrides the default UVM report server for simplified messaging.
//
// * Adds a count to INFO, WARNING, and ERROR messages
// * Makes INFO and WARNING single line messages
// * Excludes extraneous information from INFO and WARNING (e.g. filename,
//   context)
// * Shortens severity (e.g. from 'UVM_INFO' to 'INFO')
// * Prefixes each line of multi-line messages with severity for easy
//   grepping.
class jf_report_server extends uvm_default_report_server;
    virtual class short_severity_t;
        typedef enum {
            INFO,
            WARNING,
            ERROR,
            FATAL
        } e;
    endclass

    static const bit REPORT_CONTEXT[short_severity_t::e] = '{
        short_severity_t::INFO: 0,
        short_severity_t::WARNING: 0,
        short_severity_t::ERROR: 1,
        short_severity_t::FATAL: 1
    };

    local jf_time system_time;

    function new();
        jf_report_catcher catcher = new();

        super.new();

        set_name("jf_report_server");

        system_time = jf_time_new();

        uvm_report_cb::add(null, catcher);
    endfunction

    function string get_type_name();
        return "jf_report_server";
    endfunction

    local function string id_string(uvm_report_message report_message);
        return $sformatf("[%s:%0d]", report_message.get_id(),
            get_id_count(report_message.get_id()) + 1);
    endfunction

    local function string severity_string(uvm_report_message report_message);
        short_severity_t::e short_severity
            = short_severity_t::e'(report_message.get_severity());

        return short_severity.name();
    endfunction

    local function string severity_count_string(uvm_report_message report_message);
        if (report_message.get_severity() == short_severity_t::FATAL) begin
            // Count isn't applicable for FATAL
            return "";
        end else begin
            return $sformatf("%0d", get_severity_count(report_message.get_severity()) + 1);
        end
    endfunction

    // Function: compose_report_message
    //
    // Overrides uvm_default_report_server::compose_report_message.
    function string compose_report_message(
        uvm_report_message report_message,
        string report_object_name = ""
    );
        short_severity_t::e short_severity
            = short_severity_t::e'(report_message.get_severity());
        string time_str = $sformatf("%0t %s", $realtime, format_seconds(jf_time_elapsed(system_time)));
        string severity = severity_string(report_message);
        string severity_count = severity_count_string(report_message);
        bit has_context = report_message.get_context().len() > 0;
        bit has_report_object = report_message.get_report_object() != null;
        bit has_filename = report_message.get_filename().len() > 0;

        string message = {
            time_str, " ",
            id_string(report_message), " ",
            trim_newlines(report_message.get_message())
        };

        if (has_context && REPORT_CONTEXT[short_severity]) begin
            message = {
                message, "\n",
                "Context: ", report_message.get_context()
            };
        end

        if (has_report_object && REPORT_CONTEXT[short_severity]) begin
            if (report_message.get_report_object().get_full_name().len()) begin
                message = {
                    message, "\n",
                    "Reported by: ",
                    report_message.get_report_object().get_full_name()
                };
            end
        end

        if (has_filename && REPORT_CONTEXT[short_severity]) begin
            string line_str;
            line_str.itoa(report_message.get_line());

            message = {
                message, "\n",
                report_message.get_filename(), ",", line_str
            };
        end

        message = prefix_lines(severity, severity_count, message);

        return message;
    endfunction

    function string format_seconds(u64 seconds);
        struct {u32 hours; u32 minutes; u32 seconds;} duration = '{
            hours: seconds / 3600,
            minutes: (seconds / 60) % 60,
            seconds: seconds % 60
        };

        if (duration.hours) begin
            return $sformatf("%0dh%0dm%0ds", duration.hours, duration.minutes,
                duration.seconds);
        end else if (duration.minutes) begin
            return $sformatf("%0dm%0ds", duration.minutes, duration.seconds);
        end else begin
            return $sformatf("%0ds", duration.seconds);
        end
    endfunction

    // Function: trim_newlines
    //
    // Removes trailing newline character
    function string trim_newlines(string message);
        if (message[message.len - 1] == "\n") begin
            return message.substr(0, message.len - 2);
        end else begin
            return message;
        end
    endfunction

    // Function: prefix_lines
    //
    // Adds a prefix to all lines of input string.
    function string prefix_lines(string severity, string count, string message);
        string lines[$];
        string line;

        // Split lines
        for (int l = 0, r = 0; r < message.len; r++) begin
            if (message[r] == "\n" || r == message.len - 1) begin
                line = message.substr(l, r);
                lines.push_back(line);
                l = r + 1;
            end
        end

        // Prefix lines
        foreach (lines[i]) begin
            if (i == 0) begin
                lines[i] = {severity, ":", count, ": ", lines[i]};
            end else if (i == lines.size() - 1) begin
                lines[i] = {severity, "|", count, ": ", lines[i]};
            end else begin
                lines[i] = {severity, "+", count, ": ", lines[i]};
            end
        end

        // Join lines
        message = "";
        foreach (lines[i]) begin
            message = {message, lines[i]};
        end

        return message;
    endfunction
endclass
