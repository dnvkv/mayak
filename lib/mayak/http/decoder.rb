# typed: strong
# frozen_string_literal: true

require_relative "../monads/try"

module Mayak
  module Http
    module Decoder
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      abstract!

      include ::Mayak::Decoder

      In  = type_member(:in) {{ fixed: ::Mayak::Http::Request }}
      Out = type_member(:out)

      sig {
        type_parameters(:A)
          .params(blk: T.proc.params(arg: String).returns(Mayak::Monads::Try[T.type_parameter(:A)]))
          .returns(::Mayak::Http::Decoder[T.type_parameter(:A)])
      }
      def self.decode_body(&blk)
        FunctionFromBodyDecoder.new(decoder: blk)
      end

      class IdentityDecoder
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        include ::Mayak::Http::Decoder

        In   = type_member(:in) {{ fixed: ::Mayak::Http::Request }}
        Out = type_member(:out) {{ fixed: ::Mayak::Http::Request }}

        sig {
          override
            .params(response: In)
            .returns(Mayak::Monads::Try[Out])
        }
        def decode(response)
          Mayak::Monads::Try::Success.new(response)
        end
      end

      class FunctionFromBodyDecoder < T::Struct
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        include ::Mayak::Http::Decoder

        In  = type_member {{ fixed: ::Mayak::Http::Request }}
        Out = type_member

        const :decoder, T.proc.params(arg: String).returns(Mayak::Monads::Try[Out])

        sig {
          override
            .params(response: In)
            .returns(Mayak::Monads::Try[Out])
        }
        def decode(response)
          decoder.call(response.body || "")
        end
      end
    end
  end
end
