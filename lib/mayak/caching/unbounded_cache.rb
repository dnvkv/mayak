# typed: strict
# frozen_string_literal: true

module Mayak
  module Caching
    class UnboundedCache
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      include Mayak::Cache

      Key   = type_member
      Value = type_member

      sig { returns(T::Hash[Key, Value]) }
      attr_reader :storage

      sig { params(storage: T::Hash[Key, Value]).void }
      def initialize(storage = {})
        @storage = T.let(storage, T::Hash[Key, Value])
      end

      sig { override.params(key: Key).returns(T.nilable(Value)) }
      def read(key)
        storage[key]
      end

      sig { override.params(key: Key, value: Value).void }
      def write(key, value)
        storage[key] = value
      end

      sig { override.params(key: Key, blk: T.proc.returns(Value)).returns(Value) }
      def fetch(key, &blk)
        return T.must(storage[key]) if storage.has_key?(key)

        value = blk.call
        storage[key] = value
        value
      end

      sig { override.void }
      def clear
        storage.clear
      end

      sig { override.params(key: Key).void }
      def delete(key)
        storage.delete(key)
      end
    end
  end
end
