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
    #   :key_format - format string for redis key. list_id is interpolated into this option.
    #                 Default is "opt_out:%s"
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

      def key_format
        @key_format || @options[:key_format] || "opt_out:%s"
      end
      attr_writer :key_format

      # Private: returns redis client for this adapter
      def redis
        return @redis if @redis

        @redis = if @options[:url]
          uri = URI.parse(@options[:url])
          Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
        else
          Redis.new(:host => @options[:host], :port => @options[:port], :password => @options[:password])
        end
      end

      private

      # Returns key to use for redis set add from `:key_format` option
      def key(list_id)
        key_format % list_id
      end
    end
  end
end