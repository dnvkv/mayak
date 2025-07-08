# typed: strict
# frozen_string_literal: true

module Mayak
  module JsonCodec
    extend T::Sig
    extend T::Generic
    extend T::Helpers

    include ::Mayak::Codec

    abstract!

    Entity   = type_member
    Protocol = type_member {{ fixed: String }}

    sig { abstract.params(entity: Entity).returns(Protocol) }
    def encode(entity)
    end

    sig {
      abstract
        .params(response: Protocol)
        .returns(Mayak::Monads::Try[Entity])
    }
    def decode(response)
    end
  end
end