require_relative '../lib/sequence'

require 'minitest/autorun'

describe Sequence::Pattern do
  attr_accessor :value, :sequence

  describe "single value" do
    before do
      @value = rand(10)
    end

    describe "when initialized" do
      before do
        @sequence = Sequence::Pattern.new(@value)
      end

      it "must not be done" do
        @sequence.done.must_equal(false)
      end

      it "must not have a valid last value" do
        @sequence.last.must_be_nil
      end
    end

    describe "when evaluated with single value" do
      before do
        @sequence = Sequence::Pattern.new(@value)
      end

      it "must return defined value" do
        @sequence.eval.must_equal(@value)
      end
    end

    describe "after evaluation with single value" do
      before do
        @sequence = Sequence::Pattern.new(@value)
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
        @sequence = Sequence::Pattern.new(@value)
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

  describe "multiple values" do
    before do
      @values = [5, 6]
    end

    describe "when evaluated once" do
      before do
        @sequence = Sequence::Pattern.new(*@values)
        @sequence.eval
      end

      it "must not be done" do
        @sequence.done.must_equal(false)
      end

      it "last evaluated value must match first value" do
        @sequence.last.must_equal(@values.first)
      end
    end

    describe "when evaluated to end" do
      before do
        @sequence = Sequence::Pattern.new(*@values)
      end

      it "must return values in order" do
        @sequence.eval.must_equal(@values.first)
        @sequence.eval.must_equal(@values.last)
      end
    end

    describe "after evaluated to end" do
      before do
        @sequence = Sequence::Pattern.new(*@values)
        @values.size.times { @sequence.eval }
      end

      it "must return done" do
        @sequence.done.must_equal(true)
      end

      it "last evaluated value must match last value" do
        @sequence.last.must_equal(@values.last)
      end
    end

    describe "when evaluated past end" do
      before do
        @sequence = Sequence::Pattern.new(*@values)
      end

      it "must repeat" do
        expected_values = @values.cycle(3).to_a
        actual_values = expected_values.map { @sequence.eval }
        actual_values.must_equal(expected_values)
      end
    end
  end

  describe "nested patterns" do
    before do
      @values = [5, 6]

      @sequence = Sequence::Pattern.new(
        Sequence::Pattern.new(*@values),
        *@values
      )

      @cycles = 2
      @size = @values.size * @cycles
    end

    describe "evaluated" do
      it "must not be done when top level sequence is not done" do
        @sequence.reset
        @values.size.times { @sequence.eval }
        @sequence.done.must_equal(false)
      end

      it "must be done when top level sequence is done" do
        @sequence.reset
        @size.times { @sequence.eval }
        @sequence.done.must_equal(true)
      end

      it "must return the correct sequence" do
        expected_values = @values.cycle(2 * @cycles).to_a
        actual_values = expected_values.map { @sequence.eval }
        actual_values.must_equal(expected_values)
      end
    end
  end
end
