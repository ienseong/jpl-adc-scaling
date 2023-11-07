module JFSim
  class Rerun
    def initialize(resdir, options, plusargs)
      @command = build_command(resdir, options, plusargs)
    end

    def build_command(resdir, options, plusargs)
      command_file = File.join(resdir, JFSim::COMMAND_FILE)
      original_command = File.read(command_file).strip
      base_command = original_command
        .gsub(/--run\b/, '')
        .gsub(/--resdir \w+/, '')

      new_resdir =
        if options.resdir == DEFAULT_RESDIR
          "#{File.basename(resdir)}_rerun"
        else
          options.resdir
        end

      command = base_command
      command += ' --run' if options.run
      command += " --resdir #{new_resdir}"
      command += ' ' + Plusargs.new(plusargs).to_s
    end

    def to_s
      @command
    end
  end
end
