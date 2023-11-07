module JFLint
  module Filter
    class SourceLocation
      include Comparable

      attr_accessor :filename
      attr_accessor :linenumber

      def initialize(filename, linenumber)
        @filename = filename
        @linenumber = linenumber
      end

      # Create SourceLocation from value where value may be one of:
      #
      # * `<verbatim_file_path>:<line_number>`
      # * `<globbed_file_path>`
      def self.from_value(value)
        if md = value.match(/(.*):(\d+)/)
          SourceLocation.new(md.captures.first, md.captures.last.to_i)
        else
          SourceLocation.new(value, nil)
        end
      end

      def <=>(other)
        filename <=> other.filename
      end

      def to_s
        if linenumber
          [filename, ':', linenumber].join
        else
          filename
        end
      end
    end
  end
end
