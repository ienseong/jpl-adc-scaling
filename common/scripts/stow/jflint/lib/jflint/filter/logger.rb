module JFLint
  module Filter
    class Logger < JF::Logger
      def initialize(*args)
        super(*args)
      end

      def error_with_waiver(waiver, message)
        error("#{message} (#{waiver.to_s})")
      end

      def report_multi_match(violation, waivers)
        violation_text = violation
          .to_s
          .split("\n")
          .map { |line| "  " + line }
          .join("\n")

        warning <<~EOF
          Multiple waivers match violation
          Violation:
          #{violation_text}
          Waivers: #{waivers.map(&:to_s)}
        EOF
      end

      def self.get(*args)
        @@logger ||= Logger.new(*args)
      end
    end
  end
end
