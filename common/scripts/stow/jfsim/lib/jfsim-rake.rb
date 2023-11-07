# Rake output customization
#
# Rake has two sources of output:
# * Rake::FileUtilsExt::rake_output_message
# * FileUtils::fu_output_message
#
# We can customize Rake output by monkey patching these methods.  This code
# monkey patches these methods to first pass the message to our
# transform_message method then passing the result to the original output
# method.

COLOR_INFO = "\e[1m"
COLOR_NONE = "\e[0m"

def transform_message(*args)
  message = ['jfsim:', *args].join(' ')
  if $stderr.tty?
    [COLOR_INFO, message, COLOR_NONE].join
  else
    message
  end
end

module Rake
  module FileUtilsExt
    alias :real_rake_output_message :rake_output_message
    def rake_output_message(*args, &block)
      real_rake_output_message(transform_message(*args), &block)
    end
  end
end

module FileUtils
  alias :real_fu_output_message :fu_output_message
  def fu_output_message(msg)
    real_fu_output_message transform_message(msg)
  end
end
