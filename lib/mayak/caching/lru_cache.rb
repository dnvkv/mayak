# typed: strict
# frozen_string_literal: true

module Mayak
  module Caching
    class LRUCache
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      include Mayak::Cache

      Key   = type_member
      Value = type_member

      sig { returns(Integer) }
      attr_reader :max_size

      sig { params(max_size: Integer).void }
      def initialize(max_size:)
        @storage  = T.let({}, T::Hash[Key, Value])
        if max_size <= 0
          raise ArgumentError.new("max_size should be a positive integer")
        end
        @max_size = T.let(max_size, Integer)
      end

      sig { override.params(key: Key).returns(T.nilable(Value)) }
      def read(key)
        @storage[key]
      end

      sig { override.params(key: Key, value: Value).void }
      def write(key, value)
        if @storage.size == max_size && !@storage.key?(key)
          evict!
        elsif @storage.key?(key)
          @storage.delete(key)
        end
        @storage[key] = value
      end

      sig { override.params(key: Key, blk: T.proc.returns(Value)).returns(Value) }
      def fetch(key, &blk)
        return T.must(@storage[key]) if @storage.has_key?(key)

        value = blk.call
        write(key, value)
        value
      end

      sig { override.void }
      def clear
        @storage.clear
      end

      sig { override.params(key: Key).void }
      def delete(key)
        @storage.delete(key)
      end
      
      private

      sig { void }
      def evict!
        first_key = @storage.first&.first
        case first_key
        when NilClass
          return
        else
          @storage.delete(first_key)
        end
      end
    end
  end
end
