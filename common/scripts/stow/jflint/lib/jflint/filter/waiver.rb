module JFLint
  module Filter
    class Waiver
      attr_accessor :entry
      attr_accessor :lines
      attr_accessor :source
      attr_accessor :matched

      attr_accessor :rule, :location, :severity, :message, :rationale

      # Valid waiver severities
      SEVERITIES = %w(
        ERROR
        WARNING
        NOTE
      )

      INVALID_LOCATION_CHARACTERS = %w(* ? [ ] { })

      def initialize(filename, linenumber)
        @source = SourceLocation.new(filename, linenumber)
        @parsed = false
        @matched = false
        @entry = nil
        @lines = []

        @logger = Logger.get
      end

      def parse
        begin
          @entry = YAML.load(lines.join, @source.filename).first
        rescue Psych::SyntaxError => e
          report_syntax_error(e)
        else
          @parsed = true
          @rule = entry['rule']
          @location = SourceLocation.from_value(entry['location'])
          @severity = entry['severity']
          @message = entry['message']
          @rationale = entry['rationale']
        end

        self
      end

      def report_syntax_error(e)
        line_index = e.line - 1
        line = lines[line_index]
        linenumber = @source.linenumber + line_index
        hint = syntax_error_hint(line, line_index)

        message = "Waiver syntax error while parsing waiver at " + "#{@source.filename}:#{linenumber}:#{e.column}"
        message += "\nHint: " + hint unless hint.empty?
        message += "\nError from parser: #{e.problem}"
        message += "\nLine: '" + line.rstrip + "'"
        message += "\n       " + " " * (e.column - 1) + "^"
        @logger.error(message)
      end

      def syntax_error_hint(line, line_index)
        if line_index == 0
          if line.match(/^-\s*$/)
          else !line.match(/^- \w+:/)
            return "Check spacing at beginning of the line. First line must being with '- ' (dash + single space)."
          end
        else
          if !line.match(/^\s{2}\w+:/)
            return "Check spacing at beginning of the line.  Line must begin with '  ' (two spaces)."
          end
        end

        ''
      end

      def validate
        return false unless @parsed

        valid = true

        if rule.nil? || rule.empty?
          @logger.error_with_waiver(self, 'Waiver missing required field \'rule\'')
          valid = false
        end

        if location.filename.nil? || location.filename.empty?
          @logger.error_with_waiver(self, 'Waiver missing required field \'location\'')
          valid = false
        end

        if location.linenumber && location.filename.match(/[#{INVALID_LOCATION_CHARACTERS.map { |char| "\\#{char}" }.join}]/)
          @logger.error_with_waiver(self, "The 'location' field may not contain characters #{INVALID_LOCATION_CHARACTERS.map { |char| "'#{char}'" }.join(', ')} when line number is present")
          valid = false
        end

        if message.nil? || (message.is_a?(String) && message.empty?)
          @logger.error_with_waiver(self, 'Waiver missing required field \'message\'')
          valid = false
        end

        if severity && !SEVERITIES.any? { |valid_severity| valid_severity == severity }
          @logger.error_with_waiver(self, "Waiver contains invalid severity '#{severity}'.  Must be one of #{SEVERITIES.join('|')}")
          valid = false
        end

        if rationale.nil? || rationale.empty?
          @logger.error_with_waiver(self, 'Waiver missing required field \'rationale\'')
          valid = false
        end

        valid
      end

      def match(violation)
        match = true

        match = false if severity && severity != violation.severity
        match = false if rule != violation.rule
        if location.linenumber
          match = false if location.to_s != violation.location.to_s
        else
          match = false if !File.fnmatch(location.filename, violation.location.filename, File::FNM_EXTGLOB | File::FNM_PATHNAME)
        end
        if message.is_a?(Regexp)
          match = false if !message.match(violation.message)
        else
          match = false if message != violation.message
        end

        match
      end

      def to_s
        source.to_s
      end
    end
  end
end
