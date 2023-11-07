# Sequence

A library to define a series of numbers that may vary over time.

## Example

    '''ruby
    irb(main):001:0> require 'sequence'
    irb(main):003:0> seq = Sequence::Pattern.new(5, 6, 7)
    irb(main):004:0> 6.times.map { seq.eval }
    => [5, 6, 7, 5, 6, 7]
    '''

## Test

    rake test


