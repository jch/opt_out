module OptOut
  module Adapters
    autoload :AbstractAdapter, 'opt_out/adapters/abstract_adapter'
    autoload :MemoryAdapter,   'opt_out/adapters/memory_adapter'
    autoload :RedisAdapter,    'opt_out/adapters/redis_adapter'
  end
end