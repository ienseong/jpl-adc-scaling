module JFSim
  require 'optparse'
  require 'ostruct'
  require 'pathname'

  class Options
    # Arguments are passed to LSF bsub as follows:
    #
    #     echo command non_quoted_argument '"quoted_argument"' | bsub ...
    #
    # The single + double quotes are required so that a only one layer of
    # quotes is seen at command execution.
    #
    # The first layer of quotes (single quotes) is stripped by the shell when
    # passed to echo.  LSF bsub preserves the second layer of quotes (double
    # quotes) when the command is passed on standard input.  If the command
    # were passed on the command line, the second layer of quotes would also
    # get stripped.
    class LSF
      def self.args(orig_args)
        orig_args
          .reject { |arg| arg == '--lsf' }
          .map { |arg| quote_arg?(arg) ? quote_arg(arg) : arg }
          .push('--no-lsf')
      end

      def self.quote_arg?(arg)
        arg.match(/[; ]/)
      end

      def self.quote_arg(arg)
        %Q('"#{arg}"')
      end
    end

    CLEAN_TARGET_ALIASES = {
      obj: :clean_obj,
      res: :clean_results,
      all: :clean_all,
    }

    def parse(args)
      options = option_defaults(args)

      op = OptionParser.new do |op|
        op.separator("NAME")
        op.separator("    jfsim - J5 Sim")
        op.separator("")

        op.separator("SYNOPSIS")
        op.separator("    jfsim [<option(s)>] [<plusarg(s)>]")
        op.separator("")

        op.separator("GENERAL OPTIONS")
        op.on("-n", "--dry-run", "Dry run.  Don't actually run anything") do
          options.dryrun = true
        end
        op.on("-u", "--unit <unit>", "Path to unit. Can be path relative to $SBOX.  Default: inferred using pwd.  Example: 'hk', \"$SBOX/vp\".") do |arg|
          options.unit = arg
        end
        op.on("--resdir <resdir>", "Results directory.  Default: '#{options.resdir}'") do |arg|
          options.resdir = arg
        end
        op.on("--[no-]lsf", "(EXPERIMENTAL) Enable or disable LSF submission.  Default: #{options.lsf ? "enabled" : "disabled"}") do |arg|
          options.lsf = arg
        end
        op.on("--host <host>", "(EXPERIMENTAL) Which host to run on.  Default: #{options.host}") do |arg|
          options.host = arg
        end
        op.on("--rerun <resdir>", "(EXPERIMENTAL) Rerun a previous simulation.") do |arg|
          options.rerun = arg
        end
        op.separator("")

        op.separator("RAKE TASKS")
        op.on("--clean [<type>]", CLEAN_TARGET_ALIASES, "Clean one of: obj, results, all.  Default: 'obj'") do |arg|
          options.clean = arg.nil? ? :clean_obj : arg
        end
        op.on("--compile", "Compile simulation") { options.compile = true }
        op.on("--run", "Run simulation") { options.run = true }
        op.separator("")
        op.separator("    Both --compile and --run are inferred if no rake tasks are specified.")
        op.separator("")

        op.separator("COMPILE OPTIONS")
        op.on("--gate", "Compile for gate sim.  Defines GATE.") do
          options.gate = true
        end
        op.on("--netlist <path>", "Specify a netlist path.  Defines NETLIST=<path>.") do |arg|
          options.netlist = arg
        end
        op.on("--compopts <compopts>", "Additional compile options to pass to the SystemVerilog compiler (vlog)") do |arg|
          options.compopts = arg
        end
        op.on("--vhdlopts <vhdlopts>", "Additional compile options to pass to the VHDL compiler (vcom)") do |arg|
          options.vhdlopts = arg
        end
        op.on("--objdir <objdir>", "Object diretory.  Default: '#{options.objdir}'") do |arg|
            options.objdir = arg
        end
        op.on("--optopts <optopts>", "Additional optimization options to pass to the optimizer (vopt)") do |arg|
          options.optopts = arg
        end
        op.separator("")

        op.separator("RUNTIME OPTIONS")
        op.on("-t", "--test <test>", "UVM test to run.  Passed as +UVM_TESTNAME=<test>") do |arg|
          options.test = arg
        end
        op.on("-i", "--interactive", "Run in interactive mode") do |arg|
          options.interactive = true
        end
        op.on("-g", "--gui", "Run with the GUI") do |arg|
          options.gui = true
        end
        op.on("--dump", "Enable waveform dumping.") do
          options.dump = true
        end
        op.on("--visualizer", "Enable visualizer waveform dumping.") do
          options.visualizer = true
        end
        op.on("--seed <seed>", "Set all seeds for randomization.  Valid values: <decimal-value>, <hexadecimal>, 'random'.  Default: '0'") do |arg|
          if arg == 'random'
            options.seed = Random.rand(0xffff_ffff)
          else
            begin
              options.seed = Integer(arg)
            rescue ArgumentError => e
              raise JFSim::UsageError, "Unable to parse seed '#{arg}'"
            end
          end
        end
        op.on("--maxerrs <maxerrs>", "Quit on maxerrs.  Default: '1'") do |arg|
          options.maxerrs = arg
        end
        op.on("--runopts <runopts>", "Additional run options to pass to the simulator (vsim)") do |arg|
          options.runopts = arg
        end
        op.separator("")

        op.separator("COMPILE & RUNTIME OPTIONS")
        op.on("--coverage", "Enable coverage collection") do
          options.coverage = true
        end
        op.on("--top-module <module>", "The top module of the testbench.  Default: '#{options.top_module}'") do |arg|
          options.top_module = arg
        end
        op.separator("")

        op.separator("MISCELLANEOUS OPTIONS")
        op.on('-h', 'Show short help (this message)') do
          puts op
          exit
        end
        op.on('--help', 'Show long help') do
          man_path = File.expand_path(File.join(File.dirname(__FILE__), '../../man/man1/jfsim.1'))
          exec "man #{man_path}"
        end
      end
      op.parse!(args)

      # accept plusargs, rejects others
      check_args(args)
      plusargs = args

      transform_options(options, plusargs)
      check_options(options)

      [options, plusargs]
    end

    def option_defaults(args)
      options = OpenStruct.new
      options.args = args.clone
      options.run = false
      options.compile = false
      options.dryrun = false
      options.unit = JF::Unit::infer
      options.resdir = DEFAULT_RESDIR
      options.interactive = false
      options.gui = false
      options.rerun = nil
      options.seed = 0
      options.dump = false
      options.visualizer = false
      options.coverage = false
      options.lsf = false
      options.lsf_command = ["echo jfsim", *LSF.args(args), "| bsub -I -m 'dline06 dline07 dline08'"].join(" ")
      options.host = "localhost"
      options.top_module = 'tb'
      options.vhdlopts = ''

      options
    end

    def check_options(options)
      raise JFSim::EnvironmentError, "$SBOX environment variable undefined. Must be in a sandbox. Try 'sba setsbox <path>'" if !ENV.key?('SBOX')
      raise JFSim::EnvironmentError, "$PROJECT environment variable undefined. Must be in a sandbox. Try 'sba setsbox <path>'" if !ENV.key?('PROJECT')

      if !File.exists?(options.unit.verif_filelist)
        raise JF::Error, "Unit '#{options.unit}' is not configured to run simulation.\n" +
          "Missing '#{options.unit.verif_filelist}'"
      end
    end

    def transform_options(options, plusargs)
      options.ssh_command = build_ssh_command(options.host, options.args)

      options.unit = JF::Unit::from_option(options.unit)

      if options.rerun
        rerun_resdir = transform_resdir(options.unit.path, options.rerun)
        options.rerun_command = Rerun.new(rerun_resdir, options, plusargs).to_s
      end

      if !options.clean && !options.run && !options.compile
        options.run = true
        options.compile = true
      end

      options.resdir = transform_resdir(options.unit.path, options.resdir)
    end

    def transform_resdir(unit, opt_resdir)
      if Pathname.new(opt_resdir).absolute?
        # absolute
        opt_resdir
      elsif opt_resdir.match('/')
        # relative to pwd
        File.absolute_path(opt_resdir)
      else
        # relative to results
        File.join(unit, "verif", "results", opt_resdir)
      end
    end

    def check_args(args)
      rejects = args.reject { |opt| opt.start_with?("+") }
      abort("Unrecognized option(s): #{rejects.join(" ")}") if !rejects.empty?
    end

    def build_ssh_command(host, args)
      ssh_options = []
      # Suppress the banner
      ssh_options << "q"
      # Allocate a pseudo-terminal for colors if were connected to a terminal
      ssh_options << "t" if $stdout.tty?

      ssh_command = []
      ssh_command << "ssh"
      ssh_command << "-#{ssh_options.join}"
      ssh_command << host
      # Run jfsim via sboxenv to load the project environment
      ssh_command << "sboxenv"
      ssh_command << ENV["SBOX"]
      ssh_command << "jfsim"
      ssh_command << ssh_quote_args(args)
      # Override the host option so we don't recurse
      ssh_command << "--host localhost"

      ssh_command.join(" ")
    end

    # Allows special characters (e.g. ';') to be passed in args
    #
    # Example command:
    #
    #   echo 'one;two;'
    #
    # Example ssh command:
    #
    #   ssh remote echo "'""one;two;""'"
    #
    # If args were not quoted, the ssh command would be:
    #
    #   ssh remote echo one;two;
    #
    # 'one' would be echoed on the remote and 'two' would be executed on localhost (instead of echoed on the remote):
    #
    #   one
    #   bash: two: command not found
    #
    # If args were only single quoted, the ssh command would be:
    #
    #   ssh remote echo 'one;two;'
    #
    # 'one' would be echoed on the remote and 'two' would be executed on the remote (instead of echoed):
    #
    #   one
    #   bash: two: command not found
    def ssh_quote_args(args)
      args.map { |arg| ssh_quote_arg(arg) }
    end

    def ssh_quote_arg(arg)
      [%q{"'""}, arg, %q{""'"}].join
    end
  end
end
