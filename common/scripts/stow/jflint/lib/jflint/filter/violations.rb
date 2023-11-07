module JFLint
  module Filter
    class Violations
      def self.load(file)
        YAML.load(file.read)
          .map { |entry| Violation.new(entry) }
      end
    end
  end
end
