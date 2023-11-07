module JFLint
  module Filter
    class Application
      require 'yaml'

      attr_accessor :logger

      NAME = "jflint-filter"

      def initialize(argv)
        @argv = argv
        @logger = Logger.get(
          name: NAME
        )
      end

      def run()
        begin
          main(@argv)
        rescue JF::Error => e
           logger.error(e.message)
           exit 1
        end
      end

      def validate_waivers(waivers)
        waivers.select { |waiver| waiver.validate }
      end

      def filter(violations, waivers)
        violations.reject do |violation|
          matched_waivers = waivers.find_all { |waiver| waiver.match(violation) }
          logger.report_multi_match(violation, matched_waivers) if matched_waivers.size > 1

          mark_waivers(matched_waivers)

          !matched_waivers.empty?
        end
      end

      def mark_waivers(waivers)
        waivers.each { |waiver| waiver.matched = true }
      end

      def count_severity(violations, severity)
        violations
          .select { |violation| violation.severity == severity }
          .size
      end

      def write_report(path, violations)
        File.open(path, 'w') do |file|
          file.puts violations
            .map { |violation| violation.entry }
            .to_yaml
            .gsub(/^- /, "\n- ")
        end
      end

      def main(argv)
        options = Options.new(argv)
        logger.level = options.verbosity

        input =
          if options.input == '-'
            STDIN
          else
            File.open(options.input, 'r')
          end

        violations = Violations.load(input)
        waivers = Waivers.load(options.waivers)
        valid_waivers = validate_waivers(waivers)
        remaining_violations = filter(violations, valid_waivers)
        unmatched_waivers = valid_waivers.find_all { |waiver| !waiver.matched }

        unmatched_waivers.each do |waiver|
          logger.error_with_waiver(waiver, 'Waiver does not match any violations')
        end

        stats = Statistics.new
        stats.violations = violations.size
        stats.violations_syntax = count_severity(violations, 'SYNTAX')
        stats.violations_synthesis = count_severity(violations, 'SYNTHESIS')
        stats.violations_error = count_severity(violations, 'ERROR')
        stats.violations_warning = count_severity(violations, 'WARNING')
        stats.violations_note = count_severity(violations, 'NOTE')
        stats.remaining = remaining_violations.size
        stats.remaining_synthesis = count_severity(remaining_violations, 'SYNTHESIS')
        stats.remaining_error = count_severity(remaining_violations, 'ERROR')
        stats.remaining_warning = count_severity(remaining_violations, 'WARNING')
        stats.remaining_note = count_severity(remaining_violations, 'NOTE')
        stats.waivers = waivers.size
        stats.valid_waivers = valid_waivers.size
        stats.unmatched = unmatched_waivers.size

        write_report(options.output, remaining_violations)
        logger.info stats.to_s

        message = "Violations present (#{options.output})"
        if stats.remaining_synthesis > 0 || stats.remaining_error > 0
          logger.error(message)
        elsif stats.remaining > 0
          logger.warning(message)
        end

        exit 1 if logger.counts[Logger::ERROR] > 0
      end
    end
  end
end
