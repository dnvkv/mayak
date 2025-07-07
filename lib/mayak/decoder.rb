# typed: strong
# frozen_string_literal: true

module Mayak
  module Decoder
    extend T::Sig
    extend T::Generic
    extend T::Helpers

    abstract!

    In  = type_member(:in)
    Out = type_member(:out)

    sig {
      abstract
        .params(response: In)
        .returns(Mayak::Monads::Try[Out])
    }
    def decode(response)
    end

    sig {
      type_parameters(:In2)
        .params(blk: T.proc.params(arg0: Out).returns(T.type_parameter(:In2)))
        .returns(::Mayak::Decoder[In, T.type_parameter(:In2)])
    }
    def map(&blk)
      ::Mayak::Decoder::Implementation[In, T.type_parameter(:In2)].new do |entity|
        decode(entity).map { |result| blk.call(result) }
      end
    end

    class Implementation
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      include ::Mayak::Decoder

      In = type_member
      Out   = type_member

      sig { params(function: T.proc.params(response: In).returns(::Mayak::Monads::Try[Out])).void }
      def initialize(&function)
        @function = T.let(function, T.proc.params(response: In).returns(::Mayak::Monads::Try[Out]))
      end

      sig {
        override
          .params(response: In)
          .returns(Mayak::Monads::Try[Out])
      }
      def decode(response)
        @function.call(response)
      end
    end
  end
end
