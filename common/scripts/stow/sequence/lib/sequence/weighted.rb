module Sequence
  class Weighted < Sequence
    def initialize(weighted_sequences)
      super()

      @weighted_sequences = seqify(weighted_sequences)
      @weight_sum = weighted_sequences.values.reduce(:+)
    end

    def eval
      target = rand(@weight_sum)
      @weighted_sequences.each do |sequence, weight|
        return sequence.eval if target < weight
        target -= weight
      end
    end
  end
end
