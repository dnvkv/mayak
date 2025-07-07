# typed: strong
# frozen_string_literal: true

module Mayak
  module Codec
    extend T::Sig
    extend T::Generic
    extend T::Helpers

    abstract!

    Entity  = type_member
    Protocol = type_member

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

    sig { returns(::Mayak::Encoder[Entity, Protocol]) }
    def to_encoder
      ::Mayak::Encoder::Implementation[Entity, Protocol].new do |entity|
        encode(entity)
      end
    end

    sig { returns(::Mayak::Decoder[Protocol, Entity]) }
    def to_decoder
      ::Mayak::Decoder::Implementation[Protocol, Entity].new do |protocol|
        decode(protocol)
      end
    end

    class FromPair < T::Struct
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      Entity  = type_member
      Protocol = type_member

      include ::Mayak::Codec

      const :encoder, ::Mayak::Encoder[Entity, Protocol]
      const :decoder, ::Mayak::Decoder[Protocol, Entity]


      sig { override.params(entity: Entity).returns(Protocol) }
      def encode(entity)
        encoder.encode(entity)
      end

      sig {
        override
          .params(response: Protocol)
          .returns(Mayak::Monads::Try[Entity])
      }
      def decode(response)
        decoder.decode(response)
      end
    end
  end
end