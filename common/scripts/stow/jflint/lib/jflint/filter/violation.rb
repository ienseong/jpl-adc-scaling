module JFLint
  module Filter
    class Violation
      attr_accessor :entry
      attr_accessor :rule, :location, :severity, :message

      def initialize(entry)
        @entry = entry
        @rule = entry['rule']
        @location = SourceLocation.from_value(entry['location'])
        @severity = entry['severity']
        @message = entry['message']
      end

      def to_s
        @entry.to_yaml
      end
    end
  end
end
