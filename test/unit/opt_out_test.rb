require 'opt_out'

module AdapterTests
  def self.included(base)
    base.extend Macros
  end

  module Macros
    attr_accessor :original_config, :test_config

    def test_adapter(adapter, options = {})
      self.original_config = OptOut.config.dup
      self.test_config = {
        :adapter => adapter,
        :options => options
      }
    end
  end

  def setup
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

class OptOut::MemoryAdapterTest < Test::Unit::TestCase
  include AdapterTests
  test_adapter OptOut::Adapters::MemoryAdapter, :store => {}
end

class OptOut::RedisAdapterTest < Test::Unit::TestCase
  include AdapterTests
  test_adapter OptOut::Adapters::RedisAdapter, :url => ENV['BOXEN_REDIS_URL']

  def test_default_key_format
    OptOut.unsubscribe('releases', '9')
    assert_equal ['9'], OptOut.adapter.redis.smembers("opt_out:releases")
  end

  def test_custom_key_format
    OptOut.adapter.key_format = "notifications:%s:subscribe"
    OptOut.unsubscribe('releases', '9')
    assert_equal ['9'], OptOut.adapter.redis.smembers("notifications:releases:subscribe")
  end
end

class OptOut::ActiveRecordAdapterTest < Test::Unit::TestCase
  include AdapterTests
  test_adapter OptOut::Adapters::ActiveRecordAdapter, :table_name => 'opt_outs'
end