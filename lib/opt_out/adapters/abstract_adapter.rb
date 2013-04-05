module OptOut
  module Adapters
    # An adapter is responsible for tracking (un/re)subscriptions, and
    # unsubscribers.
    class AbstractAdapter
      def initialize(options = nil)
        @options = options || {}
      end

      # Public: `user_id` is subscribed? to `list_id` iff it's unsubscribed.
      #
      # Returns boolean.
      def subscribed?(list_id, user_id)
        !unsubscribed?(list_id, user_id)
      end

      # Public: Resubscribe `user_id` to `list_id`. Note that adapters should
      # only keep track of unsubscriptions. Even if subscribe has never been
      # called before, a user is unsubscribed only if `#unsubscribe` is
      # called.
      #
      # Returns nothing.
      def subscribe(list_id, user_id)
        raise NotImplementedError.new
      end

      # Public: unsubscribe `user_id` from `list_id`
      #
      # Returns nothing.
      def unsubscribe(list_id, user_id)
        raise NotImplementedError.new
      end

      # Public: is `user_id` unsubscribed from `list_id`?
      #
      # Returns boolean.
      def unsubscribed?(list_id, user_id)
        raise NotImplementedError.new
      end

      # Public: returns an array of unsubscribers for `list_id`
      def unsubscribers(list_id)
        raise NotImplementedError.new
      end

      # Private: reset internal data store for testing
      def reset
        raise NotImplementedError.new
      end
    end
  end
end