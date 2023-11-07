# Adds a live status/summary dashboard file to Jobrnr.
#
# Reports:
#
# * Sandbox state
# * Statistics
# * Failed jobs and their errors
# * Passed jobs
# * Running jobs
class Jobrnr::Plugin::SummaryFile
  require 'cgi'

  FILENAME = 'summary'

  # Tracks error message details for failed jobs
  class FailedJob
    attr_reader :errors
    attr_reader :instance

    # Defines which lines to extract from the log and include in the summary.
    #
    # Patterns come in two forms: 1) a single line match AND 2) a multi-line
    # match.
    #
    # 1. A single line match is a single regexp.  If a line matches this
    #    regexp, it is included in the summary.
    #
    # 2. A multi-line match is an array of two regexps.  The first regexp
    #    matches the first line, the second regexp matches the last line.  All
    #    lines between and including the first and last lines are included in
    #    the summary.
    ERROR_PATTERNS = [
      # Multi-line Questa compile errors
      [
        /^\*\* Error: .* while parsing file included at/,
        /^\*\* at/
      ],
      /^\*\* Error/,    # Questa compile errors
      /^# \*\* Fatal:/, # Questa runtime fatal
      /^# \*\* Error:/, # Single-line Questa runtime error
      # Multi-line Questa runtime error
      #
      # Example:
      #
      # ** Error (suppressible): (vsim-3053) Illegal output or inout port connection for port 'pci_ad'.
      #    Time: 0 ps  Iteration: 0  Instance: /tb/pci_system_bfm File: /proj/ecm_avs/users/rdonnell/sbox/eio/2/eio/verif/testbench/tb.sv Line: 306
      [
        /^# \*\* (Error|Failure)/,
        /^#    Time:/,
      ],
      /ERROR[:+|]\d+:/, # UVM error
      /FATAL[:+|]:/,    # UVM fatal
      /^ERROR: /,       # Generic script errors
    ]

    def initialize(instance)
      @instance = instance
      @errors = extract_errors(instance.log)
    end

    # Returns lines containing error messages.
    #
    # See ERROR_PATTERNS.
    #
    # @param filename [String] filename of log to parse for errors.
    # @return [Array<String>] error message lines
    def extract_errors(filename)
      multi_line_capture = false
      end_capture_pattern = nil

      File.open(filename, 'r').each_with_object([]) do |line, lines|
        if multi_line_capture
          lines << line.strip

          multi_line_capture = false if line.match(end_capture_pattern)
        else
          matched_pattern =
            ERROR_PATTERNS
              .map { |error_pattern| Array(error_pattern) }
              .find { |error_pattern| line.match(error_pattern.first) }

          if matched_pattern
            if matched_pattern.size == 2
              multi_line_capture = true
              end_capture_pattern = matched_pattern.last
            end

            lines << line.strip
          end
        end
      end
    end

    def to_s
      [
        "Command: #{@instance.command}",
        "Log: #{@instance.log}",
        *@errors
      ].join("\n")
    end
  end

  def initialize
    @failed = []
    @passed = []
    @running = []
    @first_pre_instance = true
    @sbox_state = sbox_state
    @time_start = Time.now
    @time_finish = nil
  end

  # * Reports location of summary file
  # * Collects running jobs
  #
  # Part of Jobrnr plug-in API.  See `jobrnr --help-plugin`.
  def pre_instance(message)
    Jobrnr::Log.info "Summary: #{output_filename(message)}" if @first_pre_instance
    @first_pre_instance = false

    @running << message.instance
  end

  # * Collects failed and passed jobs
  # * Prunes running jobs
  #
  # Part of Jobrnr plug-in API.  See `jobrnr --help-plugin`.
  def post_instance(message)
    if message.instance.success?
      @passed.push(message.instance)
    else
      @failed.push(FailedJob.new(message.instance))
    end

    @running.reject! { |instance| instance == message.instance }
  end

  # * Writes status/summary file on each interval
  #
  # Part of Jobrnr plug-in API.  See `jobrnr --help-plugin`.
  def post_interval(message)
    write_summary(output_filename(message), message.stats, message.options)
  end

  # * Writes status/summary file on termination
  #
  # Part of Jobrnr plug-in API.  See `jobrnr --help-plugin`.
  def post_application(message)
    @time_finish = Time.now

    write_summary(output_filename(message), message.stats, message.options)
    write_junit(message.stats, message.options)

    Jobrnr::Log.info "Summary: #{output_filename(message)}"
    Jobrnr::Log.info job_times(message.options.max_jobs)
  end

  # Quotes plusarg values
  #
  # Transforms options in the form of "+key=value" to "+key='value'".
  def quote_plusarg_values(s)
    s.gsub(/(\+\w+)=(.*)/) { "#{$1}='#{$2}'" }
  end

  # Writes status/summary file
  #
  # @param filename [String] filename to write to
  # @param stats [#to_s] statistics object
  # @param options [Struct] jobrnr options struct
  def write_summary(filename, stats, options)
    @jobrnr_command ||= [
      File.basename($PROGRAM_NAME),
      *options.argv.map { |arg| quote_plusarg_values(arg) }
    ].join(' ')

    File.open(filename, 'w') do |file|
      file.write "Sandbox: #{ENV['SBOX']}\n"
      file.write "Host: #{%x{hostname}.chomp}\n"
      file.write @sbox_state
      file.write "Command: #{@jobrnr_command}\n"
      file.write "\n"

      file.write "STATISTICS\n"
      file.write "#{run_times}\n"
      file.write "#{stats.to_s}\n"
      file.write "#{job_times(options.max_jobs)}\n"
      file.write "\n"

      unless @running.empty?
        file.write "RUNNING\n"
        file.write @running.map(&:to_s).join("\n")
        file.write "\n\n"
      end

      unless @failed.empty?
        file.write "FAILED\n"
        file.write @failed.map(&:to_s).join("\n\n")
        file.write "\n"
      end
    end
  end

  # Writes JUnit XML
  #
  # @param stats [#to_s] statistics object
  # @param options [Struct] jobrnr options struct
  def write_junit(stats, options)
    filename = File.join(options.output_directory, 'results.xml')

    File.open(filename, 'w') do |file|
      file.write <<~EOF
        <?xml version="1.0" encoding="UTF-8"?>
        <testsuites>
        <testsuite package="jobrnr" errors="#{@failed.size}" hostname="#{%x{hostname}.chomp}" tests="#{stats.completed}" time="#{Time.now - @time_start}">
          <properties>
            <property name="hostname" value="#{%x{hostname}.chomp}"/>
            <property name="sandbox" value="#{ENV['SBOX']}"/>
            <property name="state" value="#{%x{sbox-state}.chomp}"/>
            <property name="command" value="#{@jobrnr_command}"/>
            <property name="runtimes" value="#{run_times}"/>
            <property name="stats" value="#{stats.to_s}"/>
            <property name="stats" value="#{job_times(options.max_jobs)}"/>
          </properties>
      EOF

      write_junit_testcases(file, @passed)
      write_junit_testcases(file, @failed)

      file.write <<~EOF
        </testsuite>
        </testsuites>
      EOF
    end
  end

  # Writes JUnit XML testcases
  #
  # @param file [File] file output to write to
  # @param jobs array of FailedJobs or JobInstances
  def write_junit_testcases(file, jobs)
    jobs.each do |job|
      instance = job.respond_to?(:instance) ? job.instance : job
      file.puts %{  <testcase classname="#{instance.command.split(/\s+/).first}" name="#{escape_xml(instance.command)}" time="#{instance.duration}">}
      if !instance.success?
        first_error =
          if job.errors.empty?
            'No errors found in log'
          else
            escape_xml(job.errors.first)
          end
        file.puts %{    <error message="#{first_error}">}
        file.puts job.errors.map { |line| "#{escape_xml(line)}" }.join("\n")
        file.puts %{    </error>}
      end
      file.puts %{  </testcase>}
    end
  end

  def escape_xml(s)
    CGI.escapeHTML(s)
  end

  # Returns filename of status/summary file
  #
  # @param message [#options]
  def output_filename(message)
    File.join(message.options.output_directory, FILENAME)
  end

  # Reports a representation of the sandbox state
  #
  # @return [String]
  def sbox_state
    "Git Revision: #{%x(sbox-state).chomp}\n"
  end

  # @param time [Time, nil] the Time to format
  # @return [String] formatted time
  def format_time(time)
    time ? time.strftime("%FT%T%:z") : "????-??-??T??:??:??±??:??"
  end

  # @return [String] start, finish, and duration
  def run_times
    "Start:#{format_time(@time_start)} Finish:#{format_time(@time_finish)} Duration:#{duration(Time.now - @time_start)}"
  end

  def job_times(max_jobs)
    durations = @passed.map(&:duration)
    cummulative = durations.reduce(&:+)
    average = durations.size > 0 ? cummulative / durations.size : nil
    stats = [cummulative, durations.max, durations.min, average].map { |stat| stat.nil? ? '??' : '%d' % stat }
    run_hours = (Time.now - @time_start) / 60 / 60
    jobs_per_hour_per_slot = @passed.size / run_hours / max_jobs

    "Cummulative:%ss Max:%ss Min:%ss Avg:%ss Jobs/Hour/Slot:%d" % [*stats, jobs_per_hour_per_slot]
  end

  # Converts a number of seconds to a more human readable representation
  #
  # @param seconds [Number]
  # @return [String]
  def duration(seconds)
    if seconds < 60
      "%d seconds" % seconds
    elsif seconds / 60 < 60
      "%0.1f minutes" % (seconds / 60)
    else
      "%0.2f hours" % (seconds / 3600)
    end
  end
end
