require 'active_record'

module OptOut
  module Adapters
    # Adapter that stores persists data through ActiveRecord.
    # It requires the following table:
    #
    #    :list_id string
    #    :user_id string
    #    composite index on (list_id, user_id)
    #
    # Options
    #   :table_name - name of storage table. Defaults to 'opt_outs'
    class ActiveRecordAdapter < AbstractAdapter

      def subscribe(list_id, user_id)
        return if [list_id, user_id].any? {|s| s.nil? || s == ''}
        store.where(:list_id => list_id, :user_id => user_id).delete_all
        nil
      end

      # TODO: would prefer opt_outs table to not have a primary key `id`, but
      # that's not working right now
      def unsubscribe(list_id, user_id)
        store.create(:list_id => list_id, :user_id => user_id)
      rescue ActiveRecord::RecordNotUnique
        # already unsubscribed
      ensure
        return nil
      end

      def unsubscribed?(list_id, user_id)
        store.exists?(:list_id => list_id, :user_id => user_id)
      end

      def unsubscribers(list_id)
        store.where(:list_id => list_id).map(&:user_id).to_a
      end

      def reset
        store.delete_all
      end

      private

      def store
        return @store if @store

        table_name = @options[:table_name]
        @store = Class.new(ActiveRecord::Base) do
          self.table_name = table_name
        end
      end
    end
  end
end