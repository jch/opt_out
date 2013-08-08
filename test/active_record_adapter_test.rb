require 'unit/opt_out/adapter_tests'

class OptOut::ActiveRecordAdapterTest < Test::Unit::TestCase
  include AdapterTests
  test_adapter OptOut::Adapters::ActiveRecordAdapter, :table_name => 'opt_outs'
end
