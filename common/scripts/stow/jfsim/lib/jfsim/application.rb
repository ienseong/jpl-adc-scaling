module JFSim
  require 'fileutils'

  class Application
    attr_reader :argv
    attr_reader :logger

    def initialize(argv)
      @argv = argv
      @logger = JF::Logger.get(
        name: NAME
      )
    end

    def run
      begin
        run_without_exception_handling
      rescue JF::Error => e
        @logger.error e.message
        exit 1
      rescue Errno::ENOENT => e
        @logger.error e.message
        exit 1
      rescue OptionParser::ParseError => e
        @logger.error e.message
        exit 1
      end
    end

    def run_without_exception_handling
      raise JFSim::EnvironmentError, '$SBOX not valid.  Must be in sandbox.' if !File.exists?(ENV['SBOX'])

      options, plusargs = Options.new.parse(argv.clone)

      status = 0

      if options.lsf
        @logger.info options.lsf_command
        exec options.lsf_command
      elsif options.host != "localhost"
        @logger.info options.ssh_command
        exec options.ssh_command
      elsif options.rerun
        @logger.info options.rerun_command
        exec options.rerun_command
      else
        rake = Rake.new(options, plusargs)
        @logger.info rake.to_s
        if !options.dryrun
          FileUtils.mkdir_p(options.resdir)
          Dir.chdir(options.resdir)
          Command.new(argv).write(File.join(options.resdir, JFSim::COMMAND_FILE))
          system(rake.to_s)
          status = $?.exitstatus
        end

        if options.run
          @logger.info "Results in #{options.resdir}"

          wavefile = File.join(options.resdir, JFSim::WAVE_FILE)
          if options.dump && File.exist?(wavefile)
            @logger.info "View waves with: vsim -view #{wavefile}"
          end

          designfile = File.join(options.resdir, 'design.bin')
          wavefile = File.join(options.resdir, 'qwave.db')
          if options.visualizer && File.exist?(designfile) && File.exist?(wavefile)
            @logger.info "View waves with: vis -designfile #{designfile} -wavefile #{wavefile}"
          end

          coverage_path = File.join(options.resdir, JFSim::COVERAGE_PATH)
          if options.coverage && File.exist?(coverage_path)
            @logger.info "Coverage: #{coverage_path}"
          end

          logfile = File.join(options.resdir, JFSim::LOG_FILE)
          @logger.info "Sim log at #{logfile}"
        end

        report_exit_status(status)

        exit status
      end
    end

    def report_exit_status(status)
      def colorize(color_enabled, color, message)
        if color_enabled
          "\e[#{color}m#{message}\e[0m"
        else
          message
        end
      end

      green = '1;32'
      red = '1;31'
      white = '1;37'

      output, color, status_message =
        if status > 0
          [$stderr, red, 'Failed']
        else
          [$stdout, green, 'Succeeded']
        end
      color_enabled = output.tty?

      message = '%s: %s' % [NAME, colorize(color_enabled, color, status_message)]
      output.puts colorize(color_enabled, white, message)
    end
  end
end
