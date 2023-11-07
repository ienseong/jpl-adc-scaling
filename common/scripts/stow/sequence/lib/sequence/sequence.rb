module Sequence
  class Sequence
    attr_reader :done, :last

    def initialize
      reset
    end

    def eval
    end

    def reset
      @done = false
      @last = nil
    end

    def seqify(collection)
      if collection.is_a?(Hash)
        collection.each_with_object({}) { |(k, v), h| h[k.is_a?(Sequence) ? k : Value.new(k)] = v }
      elsif collection.is_a?(Array)
        collection.map { |v| v.is_a?(Sequence) ? v : Value.new(v) }
      end
    end
  end
end
