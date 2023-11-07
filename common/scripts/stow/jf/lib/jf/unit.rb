module JF
  class Unit
    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
    end

    def name
      if @path == ENV['SBOX']
        ENV['PROJECT']
      else
        File.basename(path)
      end
    end

    def identifier
      name.gsub('-', '_')
    end

    def rtl
      File.join(@path, 'rtl')
    end

    def verif
      File.join(@path, 'verif')
    end

    def verif_filelist
      File.join(verif, 'testbench/tb.f')
    end

    def rtl_filelist
      File.join(rtl, 'rtl.f')
    end

    def to_s
      @path
    end

    def to_str
      to_s
    end

    # a unit is defined by having at least one of these sub paths
    UNIT_SUB_PATHS = %w(rtl verif)

    def self.infer(path = Dir.pwd)
      levels = File.absolute_path(path).split(File::SEPARATOR)
      levels.count.times.map { |i| File.join(levels.take(i + 1)) }.reverse.each do |path|
        UNIT_SUB_PATHS.map { |sub_path| File.join(path, sub_path) }.each do |full_sub_path|
          return path if Dir.exists?(full_sub_path)
        end
      end

      nil
    end

    def self.from_option(opt_unit)
      raise JF::Error, "Could not infer unit.  Specify using --unit." if !opt_unit

      sbox_relative = File.join(ENV['SBOX'], opt_unit)

      if Pathname.new(opt_unit).absolute?
        # Absolute path (e.g. /path/sbox/unit/subunit)
        Unit.new(opt_unit)
      elsif File.exists?(sbox_relative)
        # Sandbox relative path (e.g. unit/subunit)
        Unit.new(sbox_relative)
      elsif opt_unit == ENV['PROJECT']
        # Use project to refer to $SBOX if $SBOX/project doesn't exist
        Unit.new(ENV['SBOX'])
      else
        raise JF::Error, "Unable to find unit '#{opt_unit}'"
      end
    end
  end
end
