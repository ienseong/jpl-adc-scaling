module JFLint
  module Filter
    class Waivers
      def self.load(paths)
        paths.flat_map do |path|
          Logger.get.info("Loading waivers from #{path}")
          parse_waivers(path)
        end
      end

      # Parses the sequence of nodes a node at a time
      #
      # This way we can obtain the line number of each node.
      #
      # @yields [Waiver] A waiver for each waiver parsed
      def self.parse_waivers(path)
        linenumber = 0
        waivers = []
        waiver = nil

        File.open(path, 'r').each do |line|
          linenumber += 1

          if line.match(/^\s*$/)
            # ignore blank lines
          elsif line == '---'
            # ignore section marker
          elsif line.match(/^\s*#/)
            #ignore comments
          elsif line.match(/^- /)
            waivers << waiver.parse if waiver

            waiver = Waiver.new(path, linenumber)
            waiver.lines << line
          else
            waiver.lines << line
          end
        end

        waivers << waiver.parse if waiver

        waivers
      end

    end
  end
end
