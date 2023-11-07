module JF
  class Logger
    attr_accessor :name
    attr_accessor :level

    attr_accessor :show_counts
    attr_accessor :counts
    attr_accessor :formatter
    attr_accessor :color

    TRACE = 3
    DEBUG = 2
    VERBOSE = 1
    INFO = 0
    WARNING = -1
    ERROR = -2
    FATAL = -3

    LEVEL_NAMES = {
      TRACE =>   'TRACE',
      DEBUG =>   'DEBUG',
      VERBOSE => 'VERBOSE',
      INFO =>    'INFO',
      WARNING => 'WARNING',
      ERROR =>   'ERROR',
      FATAL =>   'FATAL',
    }

    COLORS = {
      INFO => "\e[1m",
      WARNING => "\e[1;33m",
      ERROR => "\e[1;31m",
      FATAL => "\e[1;31m",
      :none => "\e[0m",
    }

    DEFAULT_FORMATTER = -> color, level, level_name, show_counts, count, name, message {
      show_label = level != INFO

      label =
        if show_counts
          "%s:" % [level_name]
        else
          "%s %d:" % [level_name, count]
        end

      prefix =
        if show_label
          "%s %s:" % [label, name]
        else
          "%s:" % [name]
        end

      lines = message.empty? ? [''] : message.split("\n")

      message = lines
        .map { |line| [prefix, line].join(' ') }
        .join("\n")

      if color
        [COLORS[level], message, COLORS[:none]].join
      else
        message
      end
    }

    def initialize(
      name: 'UNINITIALIZED',
      level: INFO,
      show_counts: false,
      formatter: DEFAULT_FORMATTER,
      color: :auto
    )
      @name = name
      @level = level
      @show_counts = show_counts
      @formatter = formatter
      @counts = Hash.new(0)
      @color = color
    end

    def trace(message)
      report(TRACE, message)
    end

    def debug(message)
      report(DEBUG, message)
    end

    def verbose(message)
      report(VERBOSE, message)
    end

    def info(message)
      report(INFO, message)
    end

    def warning(message)
      report(WARNING, message)
    end

    def error(message)
      report(ERROR, message)
    end

    def fatal(message)
      report(FATAL, message)
    end

    def report(level, message)
      counts[level] += 1

      return if @level < level

      output =
        case level
        when ERROR, FATAL
          $stderr
        else
          $stdout
        end

      text = message.nil? ? '' : message.to_s
      color_enabled =
        case color
        when :auto
          output.tty?
        when :always
          true
        else
          false
        end
      output.puts formatter.call(color_enabled, level, LEVEL_NAMES[level], show_counts, counts[level], name, text)
    end

    def self.get(**args)
      @@logger ||= Logger.new(**args)
    end
  end
end
