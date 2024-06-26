# frozen_string_literal: true
# typed: strict

module Mayak
  class WeakRef
    extend T::Sig
    extend T::Generic

    Value = type_member

    class EmptyReferenceError < StandardError
    end

    @@__map = T.let(::ObjectSpace::WeakMap.new, ::ObjectSpace::WeakMap)

    sig { params(value: Value).void }
    def initialize(value)
      @@__map[self] = value
    end

    sig { returns(Value) }
    def deref!
      if @@__map.key?(self)
        @@__map[self]
      else
        raise EmptyReferenceError.new("Reference is empty")
      end
    end

    sig { returns(Mayak::Monads::Maybe[Value]) }
    def deref
      Mayak::Monads::Maybe::Some[Value].new(deref!)
    rescue
      Mayak::Monads::Maybe::None[Value].new
    end
  end
end
