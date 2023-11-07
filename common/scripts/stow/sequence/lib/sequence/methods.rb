module Sequence
  def seqPtn(*args)
    Sequence::Pattern.new(*args)
  end

  def seqWt(*args)
    Sequence::Weighted.new(*args)
  end
end

