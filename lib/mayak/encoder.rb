# typed: strong
# frozen_string_literal: true

module Mayak
  module Encoder
    extend T::Sig
    extend T::Generic
    extend T::Helpers

    abstract!

    ResponseEntity = type_member
    ResponseType   = type_member

    sig { abstract.params(entity: ResponseEntity).returns(ResponseType) }
    def encode(entity)
    end

    sig {
      type_parameters(:NewResponse)
        .params(blk: T.proc.params(arg0: ResponseType).returns(T.type_parameter(:NewResponse)))
        .returns(::Mayak::Encoder[ResponseEntity, T.type_parameter(:NewResponse)])
    }
    def map_request(&blk)
      ::Mayak::Encoder::FromFunction[ResponseEntity, T.type_parameter(:NewResponse)].new do |entity|
        blk.call(encode(entity))
      end
    end

    class FromFunction
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      include ::Mayak::Encoder

      ResponseEntity = type_member
      ResponseType   = type_member

      sig { params(function: T.proc.params(response: ResponseEntity).returns(ResponseType)).void }
      def initialize(&function)
        @function = T.let(function, T.proc.params(response: ResponseEntity).returns(ResponseType))
      end

      sig { override.params(entity: ResponseEntity).returns(ResponseType) }
      def encode(entity)
        @function.call(entity)
      end
    end
  end
end
