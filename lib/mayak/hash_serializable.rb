# typed: strict
# frozen_string_literal: true

module Mayak
  module HashSerializable
    extend T::Sig
    extend T::Helpers

    interface!

    sig { abstract.returns(T::Hash[String, T.untyped])}
    def serialize
    end
  end
end
