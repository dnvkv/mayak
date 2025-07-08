# typed: true


module Mayak
  class JsonCodec::FromHashSerializable
    extend T::Sig
    extend T::Generic

    include ::Mayak::Codec

    Entity = type_member {{ upper: ::Mayak::HashSerializable }}
    Protocol = type_member {{ fixed: String }}

    sig { override.params(entity: Entity).returns(Protocol) }
    def encode(entity); end

    sig { override.params(response: Protocol).returns(::Mayak::Monads::Try[Entity]) }
    def decode(response); end
  end
end