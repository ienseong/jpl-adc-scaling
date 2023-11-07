require_relative '../lib/sequence'

require 'minitest/autorun'

describe Sequence::Value do
  attr_accessor :value, :sequence

  before do
    @value = rand(10)
  end

  describe "when initialized" do
    before do
      @sequence = Sequence::Value.new(@value)
    end

    it "must not be done" do
      @sequence.done.must_equal(false)
    end

    it "must not have a valid last value" do
      @sequence.last.must_be_nil
    end
  end

  describe "when evaluated" do
    before do
      @sequence = Sequence::Value.new(@value)
    end

    it "must return defined value" do
      @sequence.eval.must_equal(@value)
    end
  end

  describe "after evaluation" do
    before do
      @sequence = Sequence::Value.new(@value)
      @sequence.eval
    end

    it "must be done" do
      @sequence.done.must_equal(true)
    end

    it "must have a valid last value" do
      @sequence.last.must_equal(@value)
    end
  end

  describe "after reset" do
    before do
      @sequence = Sequence::Value.new(@value)
      @sequence.eval
      @sequence.reset
    end

    it "must not be done" do
      @sequence.done.must_equal(false)
    end

    it "must not have a valid last value" do
      @sequence.last.must_be_nil
    end
  end
end
