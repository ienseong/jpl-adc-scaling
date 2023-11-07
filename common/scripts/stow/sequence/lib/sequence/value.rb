module Sequence
  class Value < Sequence
    def initialize(value)
      super()

      @value = value
    end

    def eval
      @last = @value
      @done = true

      last
    end
  end
end
