module JFSim
  class Rake
    attr_reader :options
    attr_reader :plusargs

    def initialize(options, plusargs)
      @options = options
      @plusargs = Plusargs.new(plusargs)
    end

    def targets
      targets = []
      targets.push(options.clean) if options.clean
      targets.push("compile") if options.compile
      targets.push("sim") if options.run

      targets
    end

    def split_plus_defines(plus_defines)
      Array(plus_defines)
      .map { |plus_define| plus_define.gsub(/^\+define(\+|=)/, "").split('+') }
      .flatten
    end

    def get_runopts(plusargs)
      opts = Array(plusargs)

      opts.push("+UVM_MAX_QUIT_COUNT=" << options.maxerrs) if options.maxerrs
      opts.push(options.runopts) if options.runopts
      opts.push("-sv_seed " << options.seed.to_s) if options.seed
      opts.push("+seed=0x" << options.seed.to_s(16)) if options.seed
      opts.push(get_testname(opts))

      opts
    end

    def get_testname(runopts)
      knobs = get_knobs(runopts)

      if knobs.nil?
        '-testname "%s"' % options.test
      else
        '-testname "%s_%s"' % [options.test, knobs]
      end
    end

    # Returns argument to the +knobs plusarg if present.
    # Returns empty string otherwise.
    #
    # String is transformed to prevent invalid characters in
    # the Questa -testname argument.
    #
    # From Questa: -testname argument may not have any of
    # ':,/\' characters.
    def get_knobs(runopts)
      runopts
        .select { |opt| opt.match(/^\+knobs="/) }
        .map { |opt| opt.match(/^\+knobs="(.*)"$/).captures.first }
        .first
        &.tr(';:,/\\', '__.\-\-')
    end

    def get_compopts(plus_defines)
      defines = plus_defines + get_common_defines

      opts = []
      opts.push(defines.map { |define| "-define #{define}" }) if defines.any?
      opts.push(options.compopts) if options.compopts

      opts
    end

    def get_optopts()
      opts = []

      opts.push(options.optopts) if options.optopts

      opts
    end

    def get_common_defines
      defines = []
      defines.push("GATE") if options.gate
      defines.push("UNIT_#{options.unit.identifier.upcase}")
    end

    def get_c_defines(plus_defines)
      defines = plus_defines + get_common_defines
      defines.push("NETLIST=#{options.netlist}") if options.netlist

      defines.map { |define| "-D#{define}" }
    end

    def to_s
      if !@command
        plus_defines = split_plus_defines(plusargs.compiletime_plusargs)
        runopts = get_runopts(plusargs.runtime_plusargs)
        compopts = get_compopts(plus_defines)
        optopts = get_optopts
        c_defines = get_c_defines(plus_defines)

        args = []
        args.push("rake -f $J5_COMMON/scripts/Rakefile")
        args.push("UNIT='" << options.unit.path << "'")
        args.push("C_DEFINES='" << c_defines.join(" ") << "'") if c_defines.any?
        args.push("RUNOPT='" << runopts.join(" ") << "'") if runopts.any?
        args.push("COMPOPT='" << compopts.join(" ") << "'") if compopts.any?
        args.push("VHDLOPT='" << options.vhdlopts << "'") if !options.vhdlopts.empty?
        args.push("OPTOPT='" << optopts.join(" ") << "'") if optopts.any?
        args.push("DUMP=#{options.dump}")
        args.push("VISUALIZER=#{options.visualizer}")
        args.push("INTERACTIVE=#{options.interactive}")
        args.push("GUI=#{options.gui}")
        args.push("TEST='" << options.test << "'") if options.test
        args.push("OBJDIR='" << options.objdir << "'") if options.objdir
        args.push("COVERAGE=#{options.coverage}")
        args.push("TOP_MODULE=#{options.top_module}") if options.top_module
        args.push(*targets)

        @command = args.join(" ")
      end

      @command
    end
  end
end
