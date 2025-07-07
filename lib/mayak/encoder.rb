# typed: strong
# frozen_string_literal: true

module Mayak
  module Encoder
    extend T::Sig
    extend T::Generic
    extend T::Helpers

    abstract!

    In  = type_member(:in)
    Out = type_member(:out)

    sig { abstract.params(input: In).returns(Out) }
    def encode(input)
    end

    sig {
      type_parameters(:In2)
        .params(blk: T.proc.params(arg0: Out).returns(T.type_parameter(:In2)))
        .returns(::Mayak::Encoder[In, T.type_parameter(:In2)])
    }
    def map(&blk)
      ::Mayak::Encoder::Implementation[In, T.type_parameter(:In2)].new do |entity|
        blk.call(encode(entity))
      end
    end

    class Implementation
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      include ::Mayak::Encoder

      In = type_member
      Out   = type_member

      sig { params(function: T.proc.params(in: In).returns(Out)).void }
      def initialize(&function)
        @function = T.let(function, T.proc.params(in: In).returns(Out))
      end

      sig { override.params(entity: In).returns(Out) }
      def encode(entity)
        @function.call(entity)
      end
    end
  end
end
