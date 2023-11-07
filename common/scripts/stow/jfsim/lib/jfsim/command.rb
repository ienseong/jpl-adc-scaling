module JFSim
  class Command
    attr_reader :argv

    def initialize(argv)
      @argv = argv
    end

    # Quotes elements that contain spaces
    #
    # @param array [Array<String>]
    def quote(array)
      array.map do |element|
        if element.match(/\s|;/)
          "'#{element}'"
        else
          element
        end
      end
    end

    # Writes command line to file
    def write(path)
      File.open(path, 'w') do |fh|
        fh.puts [JFSim::NAME, *quote(argv)].join(' ')
      end
    end
  end
end
