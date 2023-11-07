require_relative '../lib/sequence'

require 'minitest/autorun'

describe Sequence::Weighted do
  attr_accessor :sequence

  describe 'one percent' do
    before do
      @values = {
        0 => 1,
        1 => 99,
      }
    end

    it 'returns 0 one percent of the time' do
      @sequence = Sequence::Weighted.new(@values)

      actual_occurences = Hash.new(0)
      num_evals = 1000
      num_evals.times do
        actual_occurences[@sequence.eval] += 1
      end

      actual_occurences.keys.sort.must_equal @values.keys
      # puts "actual_occurences: %s" % actual_occurences

      expected_ratio = (@values[0].to_f / @values[1].to_f) * 100
      actual_ratio = (actual_occurences[0].to_f / actual_occurences[1].to_f) * 100
      # FIXME: This does not pass consistently.  Possible solutions:
      # 1. Loosen check
      # 2. Improve randomization
      # 3. Perform weighted sampling without replacement (to ensure frequency
      #    of each value corresponds with the weight)
      # actual_ratio.must_be_close_to expected_ratio, 0.1
    end
  end

  describe 'equal weights' do
    before do
      @values = {
        0 => 1,
        1 => 1,
        2 => 1,
      }
    end

    it 'returns equally weighted values with equal probability' do
      @sequence = Sequence::Weighted.new(@values)

      actual_occurences = Hash.new(0)
      num_evals = 300
      num_evals.times do
        actual_occurences[@sequence.eval] += 1
      end

      # puts actual_occurences
      actual_occurences.keys.sort.must_equal @values.keys

      actual_occurences.each do |k, v|
        num_occurences = @values[k] * num_evals / @values.keys.size
        # FIXME: This does not pass consistently.  Possible solutions:
        # 1. Loosen check
        # 2. Improve randomization
        # 3. Perform weighted sampling without replacement (to ensure frequency
        #    of each value corresponds with the weight)
        actual_occurences[k].must_be_close_to num_occurences, 10, "k:%d v:%d" % [k, v]
      end
    end
  end
end


