# Adds functionality to `jfsim` jobs.
#
# * Adds `--resdir` option if not already present.
# * Prints path to log for failed jobs for quick debug.
# * Performs coverage merging when `--coverage` option is present.
# * Logs results to database if enabled.
class Jobrnr::Plugin::JFSimJob
  require_relative 'jfsim_job/database'
  require_relative 'jfsim_job/coverage'
  require_relative 'jfsim_job/load_balance'

  attr_reader :database
  attr_reader :coverage
  attr_reader :load_balance

  def initialize
    @database = JFSimJob::Database.new
    @coverage = JFSimJob::Coverage.new
    @load_balance = JFSimJob::LoadBalance.new
  end

  ############################################################################
  # @!group API methods
  ############################################################################

  # See `jobrnr --help-plugin`
  def pre_instance(message)
    return unless jfsim_job?(message.instance)

    instance = message.instance
    resdir = resdir_from_log(instance.log)

    # add --resdir option
    instance.command << " --resdir #{resdir}" if needs_resdir?(instance.command)

    load_balance.pre_instance(message)
  end

  # See `jobrnr --help-plugin`
  def post_instance(message)
    return unless jfsim_job?(message.instance)

    instance = message.instance
    options = message.options

    # merge coverage if present
    if instance.success? && coverage_command?(instance.command)
      coverage.merge(
          instance: instance,
          unit: unit_from_command(instance.command),
          resdir: resdir_from_command(instance.command),
          output_directory: options.output_directory)
    end

    # print path to log on failure
    unless instance.success?
      log = File.join(options.output_directory, resdir_from_log(instance.log))
      puts "Log: #{log}"
    end

    if run_command?(instance.command)
      unit, test, seed = %w(unit test seed).map { |option| command_option_value(instance.command, option) }
      database.log(instance, unit, test, seed)
    end

    load_balance.post_instance(message)
  end

  ############################################################################
  # @!group Identification methods
  ############################################################################

  # Determines if job is an jfsim job.
  #
  # @param job [#command] the job definition or instance to inspect
  # @return [Boolean]
  def jfsim_job?(job)
    # A job command may contain one or more shell commands, match jobrnr at the
    # beginning of a shell command.
    job.command.match(/(^|;|&&)\s*\bjfsim\b/)
  end

  # Determines if an option is present in a command.
  #
  # NOTE: Only works with long options (e.g. `--option`).
  #
  # @param command [String] the command to inspect
  # @param option [String] the long option to look for
  # @return [Boolean]
  def option_present?(command, option)
    !command.match(/\s--#{option}\b/).nil?
  end

  def run_command?(command)
    explicit = option_present?(command, 'run')
    implicit = !option_present?(command, 'clean') && !option_present?(command, 'compile')

    explicit || implicit
  end

  # Determines if this is a command we chould collect coverage for.
  #
  # @param command [String] the command to inspect
  # @return [Boolean]
  def coverage_command?(command)
    option_present?(command, 'coverage') && run_command?(command)
  end

  # Determines if the command needs `--resdir` added to it.
  #
  # @param command [String] the command to inspect
  # @return [Boolean]
  def needs_resdir?(command)
    !option_present?(command, 'resdir')
  end

  ############################################################################
  # @!group Inspection methods
  ############################################################################

  # Derives the results directory based on the log filename.
  #
  # @param log_filename [String] log filename w/o path (e.g. filename.log)
  # @return [String] the results directory relative to `<unit>/verif/results`
  def resdir_from_log(log_filename)
    File.basename(log_filename, '.log')
  end

  # @param command [String] the jfsim command
  # @return [String] absolute path of the results directory
  def resdir_from_command(command)
    resdir = command_option_value(command, 'resdir')

    if resdir[0] == '/'
      # absolute path
      resdir
    else
      # relative to <unit>/verif/results
      unit = unit_from_command(command)
      File.join(unit, 'verif/results', resdir)
    end
  end

  # @param command [String] the jfsim command
  # @return [String] absolute path of the unit directory
  def unit_from_command(command)
    unit = command_option_value(command, 'unit')

    if unit[0] == '/'
      unit
    else
      # relative to $SBOX
      File.join(ENV['SBOX'], unit)
    end
  end

  # Gets an option value.
  #
  # NOTE: Only works with long options (e.g. `--option`).
  #
  # @param command [String] the jfsim command
  # @param option [String] the option to get the value for
  # @raise [Jobrnr::Error] if option cannot be parsed
  def command_option_value(command, option)
    if md = command.match(/\s--#{option}(?:\s+|=)(\S+)/)
      md.captures.first
    else
      fail Jobrnr::Error, "Cannot parse --#{option} in '#{command}'"
    end
  end
end
