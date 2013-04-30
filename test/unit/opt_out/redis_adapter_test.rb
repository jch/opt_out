require 'unit/opt_out/adapter_tests'

class OptOut::RedisAdapterTest < Test::Unit::TestCase
  include AdapterTests
  test_adapter OptOut::Adapters::RedisAdapter, :redis => GitHub.redis

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
