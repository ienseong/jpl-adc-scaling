# Logs jobs to various log files.
#
# Log files:
#
# * passes.log - Jobs completed with zero exit status.  Overwritten on each run
#   of Jobrnr.
# * fails.log - Jobs completed with non-zero exit status.  Overwritten on each
#   run of Jobrnr.
# * passes_cumulative.log - Jobs completed with zero exit status.  Entries are
#   appended on each run of Jobrnr.
# * fails_cumulative.log - Jobs completed with non-zero exit status.  Entries
#   are appended on each run of Jobrnr.
class Jobrnr::Plugin::JobLogs
  # Encapsulates a log file
  class JobLog
    # @param filename [String] filename of log relative to output directory
    # @param success [Boolean] indicates if successful or unsuccessful jobs
    # should be logged
    # @param mode [String] See IO.new
    def initialize(filename, success, mode)
      @success = success
      @file = File.open(filename, mode)
    end

    # Conditionally log a job to the log file
    #
    # @param instance [JobInstance] the job instance to be logged to the log
    # file
    def report(instance)
      if instance.success? == @success
        @file.write "%s '%s' %ds\n" % [Time.now.strftime("%FT%T%:z"), instance.to_s, instance.duration]
        @file.flush
      end
    end
  end

  # Initializes the logs.
  #
  # The logs are initialized here because we want to open the log files as soon
  # as possible.  If done in post_instance, a long running first job may result
  # in a discrepancy between the overwritten logs (e.g. passes.log) from a
  # previous run and the current run.  For example, passes.log may report many
  # passed jobs from a previous run but we don't have any completed jobs in the
  # current run yet.
  #
  # Part of Jobrnr plug-in API.  See `jobrnr --help-plugin`.
  def pre_instance(message)
    @logs ||= init_logs(message.options.output_directory)
  end

  # Reports a completed job to the all logs for logging.
  #
  # Part of Jobrnr plug-in API.  See `jobrnr --help-plugin`.
  def post_instance(message)
    @logs.each { |log| log.report(message.instance) }
  end

  # Initializes the logs.
  #
  # @param output_directory [String] see `output_directory` in `jobrnr
  # --help-plugin`
  def init_logs(output_directory)
    [
      JobLog.new(File.join(output_directory, 'passes.log'), true, 'w'),
      JobLog.new(File.join(output_directory, 'fails.log'), false, 'w'),
      JobLog.new(File.join(output_directory, 'passes_cumulative.log'), true, 'a'),
      JobLog.new(File.join(output_directory, 'fails_cumulative.log'), false, 'a')
    ]
  end
end
