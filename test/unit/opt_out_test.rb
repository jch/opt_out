# test_helper
require 'opt_out'

STORE = {}  # shared memory store for persistence. Cleared between tests
OptOut.configure do |c|
  c.persistence = {
    :adapter => OptOut::Persistence::MemoryAdapter,
    :options => {
      :store => STORE
    }
  }
end

module OptOut
  class OptOutTest < Test::Unit::TestCase
    def test_configuration_requires_persistence
      original = OptOut.config.persistence

      begin
        OptOut.config.persistence = nil
        Struct.new('Model') { include OptOut::Persistence }
      rescue => e
        assert false, "expected argument error, got #{e.class}: #{e.message}" unless e.is_a?(ArgumentError)
      ensure
        OptOut.config.persistence = original
      end
    end

    def test_adapter
      assert OptOut.config.adapter.is_a?(OptOut::Persistence::MemoryAdapter)
    end
  end

  module PersistenceTests
    Model = Struct.new(:id, :email) do
      include OptOut::Persistence

      def serializable_hash
        {:email => email}
      end
    end

    def setup
      OptOut.config.adapter.reset
      @instance = Model.new(:id => 'model_1', :email => 'jollyjerry@gmail.com')
      @instance.save
    end

    def test_save_and_find
      record = Model.find(@instance.id)
      assert_not_nil record
      assert_equal @instance.email, record.email
    end

    def test_destroy_and_find
      @instance.destroy
      assert_nil Model.find(@instance.id)
    end
  end

  class MemoryAdapterTest < Test::Unit::TestCase
    include PersistenceTests
  end

  class ListTest < Test::Unit::TestCase
    def setup
      OptOut.config.adapter.reset
      @list = List['security']
    end

    def test_lookup
      assert @list.is_a?(List)
      assert_equal 'security', @list.name
    end

    def test_subscribe
      @list.subscribe('user_1')
      assert @list.subscribed?('user_1')
    end

    def test_unsubscribe
      @list.unsubscribe('user_1')
      assert !@list.subscribed?('user_1')
    end

    def test_resubscribe
      @list.unsubscribe('user_1')
      @list.subscribe('user_1')
      assert @list.subscribed?('user_1')
    end
  end
end