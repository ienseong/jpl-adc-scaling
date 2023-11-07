require 'test_helper'

describe JF::Logger do
  before do
    @obj = JF::Logger.new(color: :always)
  end

  describe 'name' do
    it 'has a default' do
      @obj.name.must_equal('UNINITIALIZED')
    end

    it 'can be changed' do
      @obj.name = 'myname'
      proc { @obj.info('info') }
        .must_output("\e[1mmyname: info\e[0m\n", '')
    end
  end

  describe 'level threshold' do
    it 'has a default' do
      @obj.level.must_equal(0)
    end

    it 'defaults to info' do
      proc { @obj.verbose('silent') }
        .must_output('', '')

      proc { @obj.info('info') }
        .must_output("\e[1mUNINITIALIZED: info\e[0m\n", '')
    end

    it 'can be decreased' do
      @obj.level -= 1

      proc { @obj.debug('info') }
        .must_output('', '')
      proc { @obj.warning('warning') }
        .must_output("\e[1;33mWARNING 1: UNINITIALIZED: warning\e[0m\n", '')
    end

    it 'can be increased' do
      @obj.level += 1

      proc { @obj.debug('debug') }
        .must_output('', '')
      proc { @obj.verbose('verbose') }
        .must_output("VERBOSE 1: UNINITIALIZED: verbose\e[0m\n", '')
    end
  end

  describe 'count' do
    before do
      @obj.level = JF::Logger::TRACE
    end

    it 'increments' do
      proc { @obj.warning('warning') }
        .must_output("\e[1;33mWARNING 1: UNINITIALIZED: warning\e[0m\n", '')
      proc { @obj.warning('warning') }
        .must_output("\e[1;33mWARNING 2: UNINITIALIZED: warning\e[0m\n", '')
    end

    it 'is per-level' do
      proc { @obj.trace('trace') }
        .must_output("TRACE 1: UNINITIALIZED: trace\e[0m\n", '')
      proc { @obj.trace('trace') }
        .must_output("TRACE 2: UNINITIALIZED: trace\e[0m\n", '')
      proc { @obj.debug('debug') }
        .must_output("DEBUG 1: UNINITIALIZED: debug\e[0m\n", '')
      proc { @obj.debug('debug') }
        .must_output("DEBUG 2: UNINITIALIZED: debug\e[0m\n", '')
    end
  end

  describe 'levels' do
    before do
      @obj.level = JF::Logger::TRACE
    end

    it 'supports trace' do
      proc { @obj.trace('trace') }
        .must_output("TRACE 1: UNINITIALIZED: trace\e[0m\n", '')
    end

    it 'supports debug' do
      proc { @obj.debug('debug') }
        .must_output("DEBUG 1: UNINITIALIZED: debug\e[0m\n", '')
    end

    it 'supports verbose' do
      proc { @obj.verbose('verbose') }
        .must_output("VERBOSE 1: UNINITIALIZED: verbose\e[0m\n", '')
    end

    it 'supports info' do
      proc { @obj.info('info') }
        .must_output("\e[1mUNINITIALIZED: info\e[0m\n", '')
    end

    it 'supports warning' do
      proc { @obj.warning('warning') }
        .must_output("\e[1;33mWARNING 1: UNINITIALIZED: warning\e[0m\n", '')
    end

    it 'supports error' do
      proc { @obj.error('error') }
        .must_output('', "\e[1;31mERROR 1: UNINITIALIZED: error\e[0m\n")
    end

    it 'supports fatal' do
      proc { @obj.fatal('fatal') }
        .must_output('', "\e[1;31mFATAL 1: UNINITIALIZED: fatal\e[0m\n")
    end
  end

  describe 'message' do
    it 'prefixes all lines' do
      multiline_message = [
        'line 1',
        'line 2'
      ].join("\n")

      proc { @obj.warning(multiline_message) }
        .must_output("\e[1;33mWARNING 1: UNINITIALIZED: line 1\nWARNING 1: UNINITIALIZED: line 2\e[0m\n", '')
    end

    it 'accepts nil' do
      proc { @obj.info(nil) }
        .must_output("\e[1mUNINITIALIZED: \e[0m\n", '')
    end

    it 'accepts objects' do
      obj = { key: :value }
      proc { @obj.info(obj) }
        .must_output("\e[1mUNINITIALIZED: #{obj.to_s}\e[0m\n", '')
    end
  end

  describe 'get' do
    it 'provides a static instance' do
      proc { JF::Logger.get.info('info') }
        .must_output("UNINITIALIZED: info\n", '')
    end
  end
end
