require 'redis'
require 'uri'

module OptOut
  module Adapters
    # Adapter that persists data in a Redis set.
    #
    # Options
    #   :url   - redis connection url OR
    #   :host
    #   :port
    #   :password
    class RedisAdapter < AbstractAdapter
      def subscribe(list_id, user_id)
        redis.srem(key(list_id), user_id) and return
      end

      def unsubscribe(list_id, user_id)
        redis.sadd(key(list_id), user_id) and return
      end

      def unsubscribed?(list_id, user_id)
        redis.sismember(key(list_id), user_id)
      end

      def unsubscribers(list_id)
        redis.smembers(key(list_id))
      end

      def reset
        redis.flushdb
      end

      private

      def redis
        return @redis if @redis

        @redis = if @options[:url]
          uri = URI.parse(@options[:url])
          Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
        else
          Redis.new(:host => @options[:host], :port => @options[:port], :password => @options[:password])
        end
      end

      # Prefixes set with `opt_out:`
      def key(list_id)
        "opt_out:#{list_id}"
      end
    end
  end
end