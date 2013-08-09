require 'adapter_tests'
require 'sqlite3'

class OptOut::ActiveRecordAdapterTest < Test::Unit::TestCase
  include AdapterTests
  test_adapter OptOut::Adapters::ActiveRecordAdapter, :table_name => 'opt_outs' do
    ActiveRecord::Base.establish_connection({
      :adapter => 'sqlite3',
      :database => './test.db'
    })
    conn = ActiveRecord::Base.connection

    unless conn.table_exists?(:opt_outs)
      conn.create_table(:opt_outs) do |t|
        t.string "list_id"
        t.string "user_id"
      end
    end
  end
end
