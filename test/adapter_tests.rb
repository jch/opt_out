require 'opt_out'
require 'test/unit'
require 'dotenv'

Dotenv.load

# All adapters must pass these tests. To setup a new adapter test:
#
# class MyAdapterTest < Test::Unit::TestCase
#   include AdapterTests
#   test_adapter(MyAdapter, {:some => 'options'}) do
#     # optional test setup block
#   end
# end
module AdapterTests
  def self.included(base)
    base.extend Macros
  end

  module Macros
    attr_accessor :original_config, :test_config

    def test_adapter(adapter, options = {}, &blk)
      self.original_config = OptOut.config.dup
      self.test_config = {
        :adapter => adapter,
        :options => options,
        :setup   => blk
      }
    end
  end

  def setup
    if custom_setup = self.class.test_config[:setup]
      custom_setup.call
    end
    OptOut.configure do |c|
      c.adapter = self.class.test_config[:adapter]
      c.options = self.class.test_config[:options]
    end
    OptOut.reset
  end

  def teardown
    OptOut.config.adapter = self.class.original_config[:adapter]
    OptOut.config.options = self.class.original_config[:options]
    OptOut.reset
  end

  def test_auto_subscribed
    assert OptOut.subscribed?('newsletters', '5')
  end

  def test_resubscribe
    OptOut.unsubscribe('newsletters', '5')
    OptOut.subscribe('newsletters', '5')
    assert OptOut.subscribed?('newsletters', '5')
    assert !OptOut.unsubscribed?('newsletters', '5')
  end

  def test_unsubscribe
    OptOut.unsubscribe('newsletters', '5')
    assert !OptOut.subscribed?('newsletters', '5')
    assert OptOut.unsubscribed?('newsletters', '5')
  end

  def test_multi_unsubscribe
    OptOut.unsubscribe('newsletters', '5')
    OptOut.unsubscribe('newsletters', '5')
    assert !OptOut.subscribed?('newsletters', '5')
    assert OptOut.unsubscribed?('newsletters', '5')
  end

  def test_unsubscribers
    OptOut.unsubscribe('newsletters', '5')
    OptOut.unsubscribe('newsletters', '6')
    assert_equal ['5', '6'], OptOut.unsubscribers('newsletters').sort
  end
end
