require 'set'

module OptOut
  module Adapters
    # Adapter that stores persists data in memory in a hash.
    #
    # Options
    #   :store - optional Hash instance to store unsubscriptions
    class MemoryAdapter < AbstractAdapter
      # Subscribe `user_id` to `list_id`. Returns nothing.
      def subscribe(list_id, user_id)
        store[list_id].delete(user_id) and return
      end

      def unsubscribe(list_id, user_id)
        store[list_id] ||= Set.new
        store[list_id] << user_id
        nil
      end

      def unsubscribed?(list_id, user_id)
        store[list_id].include?(user_id)
      end

      def unsubscribers(list_id)
        store[list_id].to_a
      end

      def reset
        store.clear
      end

      private

      def store
        @store ||= @options[:store] || Hash.new
      end
    end
  end
end