# Track user unsubscriptions by list.
#
# OptOut.unsubscribe('newsletters', '5')  # unsubscribe user id '5' from 'newsletters'
# OptOut.subscribed?('newsletters', '5')
# => false
#
# OptOut.subscribe('newsletters', '5')  # re-subscribe a user to 'newsletters'
# OptOut.subscribed?('newsletters', '5')
# => true
#
# OptOut.unsubscribed?('newsletters', '5')  # another way to query
# => false
#
# OptOut.subscribed('newsletters', '8')  # users are subscribed by default unless explicitly unsubscribed
# => true
#
# ['1', '2', '3'].each {|user_id| OptOut.unsubscribe('newsletters', user_id)}
# OptOut.unsubscribers  # returns a list of unsubscribed user ids
# => ['1', '2', '3']
require 'forwardable'
require 'opt_out/adapters'

module OptOut
  # Options:
  #   :adapter - subclass of OptOut::Adapters::AbstractAdapter
  #   :options - instantiation options to pass to `adapter`
  class Configuration < Struct.new(:adapter, :options)
  end

  class << self
    extend Forwardable
    delegate [:subscribe, :subscribed?, :unsubscribe, :unsubscribed?, :unsubscribers, :reset] => :adapter

    # Private: returns a memoized instance of adapter to use
    def adapter
      @adapter ||= config.adapter.new(config.options)
    end

    # Public: Configure OptOut. Returns Configuration.
    #
    # Example:
    #
    #    OptOut.configure do |c|
    #      c.adapter = OptOut::Adapters::RedisAdapter
    #      c.options = {:host => 'localhost', :port => '6379', :password => ''}
    #    end
    def configure(&blk)
      blk.call(config)
      @adapter = nil  # invalidate adapter on reconfiguration
      config
    end

    # Public: Returns Configuration
    def config
      @config ||= Configuration.new
    end
  end
end