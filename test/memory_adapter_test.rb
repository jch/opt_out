require 'unit/opt_out/adapter_tests'

class OptOut::MemoryAdapterTest < Test::Unit::TestCase
  include AdapterTests
  test_adapter OptOut::Adapters::MemoryAdapter, :store => {}
end
