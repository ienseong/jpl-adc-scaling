module Sequence
  class Pattern < Sequence
    def initialize(*sub_sequences)
      super()

      @sub_sequences = seqify(sub_sequences)
      @index = 0
    end

    def eval
      @last = current_sub_sequence.eval
      @done = current_sub_sequence.done && current_sub_sequence == @sub_sequences.last
      next_sub_sequence if current_sub_sequence.done

      @last
    end

    def next_sub_sequence
      @index = (@index + 1) % @sub_sequences.size 
    end

    def current_sub_sequence
      @sub_sequences[@index]
    end
  end
end
