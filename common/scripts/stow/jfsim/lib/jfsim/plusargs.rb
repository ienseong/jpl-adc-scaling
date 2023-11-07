module JFSim
  class Plusargs
    def initialize(plusargs)
      @plusargs = plusargs

      @compiletime_plusargs, @runtime_plusargs = categorize_plusargs(plusargs)
    end

    def compiletime_plusargs
      @compiletime_plusargs
    end

    def runtime_plusargs
      quote_plusarg_values(@runtime_plusargs)
    end

    def categorize_plusargs(plusargs)
      grouped_plusargs = plusargs.group_by { |plusarg| plusarg.match(/^\+define/) ? :compile : :run }

      compiletime_plusargs, runtime_plusargs = grouped_plusargs[:compile], grouped_plusargs[:run]
    end

    # Quotes plusarg values
    #
    # So that the argument `+knobs='myknob = 10;'` becomes `+knobs="myknob =
    # 10;"` instead of `+knobs=myknob = 10;`.  Otherwise such an argument to
    # jfsim would become multiple arguments to the simulator.
    #
    # @param plusargs [Array<String>] array of runtime plusargs
    def quote_plusarg_values(plusargs)
      Array(plusargs).map { |plusarg| plusarg.gsub(/^\+(\w+)([+=])(.*)/, %q(+\1\2"\3")) }
    end

    def to_s
      [*compiletime_plusargs, *runtime_plusargs].join(' ')
    end
  end
end
