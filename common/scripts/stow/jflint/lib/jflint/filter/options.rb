module JFLint
  module Filter
    class Options
      require 'optparse'
      require 'forwardable'

      extend Forwardable
      def_delegators :@options, :input, :output, :waivers, :verbosity

      def initialize(argv)
        @options = Struct.new(:input, :output, :waivers, :verbosity).new
        @logger = Logger.get
        defaults
        parse(argv.clone)
      end

      def defaults
        @options.input = '-'
        @options.waivers = []
        @options.verbosity = 0
      end

      def parse(argv)
        OptionParser.new do |op|
          op.on('-i', '--input=<input-file>', 'Violation report file.  Specify \'-\' to read from standard input.  Default: \'-\'') do |value|
            raise JF::Error, "Input file does not exist (#{value})" unless File.exists?(value)
            @options.input = value
          end

          op.on('-o', '--output=<output-file>', 'Filtered violations file.') do |value|
            @options.output = value
          end

          op.on('-w', '--waivers=<waivers-file>', 'Waiver file(s).') do |value|
            if File.exists?(value)
              @options.waivers << value
            else
              @logger.warning("Waiver file does not exist (#{value})")
            end
          end

          op.on('-v', '--verbose', 'Increase verbosity.') do
            @options.verbosity += 1
          end

          op.on('-q', '--quiet', 'Decrease verbosity.') do
            @options.verbosity -= 1
          end
        end.parse!(argv)
      end
    end
  end
end

