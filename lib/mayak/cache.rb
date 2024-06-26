# typed: strict
# frozen_string_literal: true

module Mayak
  module Cache
    extend T::Sig
    extend T::Generic
    extend T::Helpers

    interface!

    Key   = type_member
    Value = type_member

    sig { abstract.params(key: Key).returns(T.nilable(Value)) }
    def read(key)
    end

    sig { abstract.params(key: Key, value: Value).void }
    def write(key, value)
    end

    sig { abstract.params(key: Key, blk: T.proc.returns(Value)).returns(Value) }
    def fetch(key, &blk)
    end

    sig { abstract.void }
    def clear
    end

    sig { abstract.params(key: Key).void }
    def delete(key)
    end
  end
end
