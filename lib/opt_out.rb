require 'active_support/core_ext/hash/keys'

# Manage user email subscriptions and opt-outs.
module OptOut
  def config
    @config ||= Configuration.new
  end

  def configure(&blk)
    blk.call(config) if blk
    config
  end
  module_function :config, :configure

  class Configuration < Struct.new(:persistence)
    def persistence
      self[:persistence][:adapter].new(self[:persistence][:options] || {})
    end
  end

  # Required methods for including this class:
  #   #id
  #   #serializable_hash
  module Persistence
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def find(id)
        if attributes = adapter.find(id)
          new(attributes)
        end
      end

      def adapter
        @adapter ||= OptOut.config.persistence
      end
    end

    # String identifier for this instance
    def id
      raise NotImplementedError.new
    end

    # Persist this instance. Returns boolean indicating success.
    def save
      self.class.adapter.save(id, serializable_hash)
    end

    # Destroy this instance. Returns boolean indicating success.
    def destroy
      self.class.adapter.destroy(id)
    end

    # Return a Hash of attributes to save
    def serializable_hash
      raise NotImplementedError.new
    end
  end

  module Persistence
    # A persistence adapter is responsible for persisting instances and
    # retrieving them by id.
    class AbstractAdapter
      # Find an instance by id
      def find(id)
        raise NotImplementedError.new
      end

      def save(id, attributes)
        raise NotImplementedError.new
      end

      def destroy(id)
        raise NotImplementedError.new
      end
    end

    require 'set'
    class MemoryAdapter < AbstractAdapter
      def initialize(options = {})
        @store = options[:store] || Hash.new
      end

      def find(id)
        @store[id.to_s]
      end

      def destroy(id)
        @store.delete(id.to_s)
      end

      def save(id, attributes)
        @store[id.to_s] = attributes
      end

      def to_s
        "#<OptOut::Persistence::MemoryAdapter:0x007ff10ab04c50 @store=#{@store.inspect}>"
      end
      alias_method :inspect, :to_s
    end
  end

  class Unsubscription
    include OptOut::Persistence

    def initialize(attributes)
      @attributes = attributes.symbolize_keys
    end

    def id
      "#{list_id}|#{user_id}"
    end

    def user_id
      @attributes[:user_id]
    end

    def list_id
      @attributes[:list_id]
    end

    def serializable_hash
      {:user_id => user_id, :list_id => list_id}
    end
  end

  class List
    include OptOut::Persistence

    # Public: lookup a list by name
    #
    # Returns a List instance
    def self.[](name)
      new(:name => name)
    end

    attr_accessor :name

    def initialize(attributes)
      attributes.symbolize_keys!
      @name = attributes[:name]
    end

    # Identifier to use for persistence
    def id
      name
    end

    def serializable_hash
      {:name => name}
    end

    # Public: Subscribe a user to this list. Persists this list. Returns
    # nothing.
    def subscribe(user_id)
      if unsubscription = find_unsubscription(user_id)
        unsubscription.destroy
      end
      save
      nil
    end

    def unsubscribe(user_id)
      unless unsubscription = find_unsubscription(user_id)
        Unsubscription.new(:user_id => user_id, :list_id => id).save
      end
      save
      nil
    end

    def subscribed?(user_id)
      !find_unsubscription(user_id)
    end

    private

    def find_unsubscription(user_id)
      Unsubscription.find("#{self.id}|#{user_id}")
    end
  end
end