# typed: strong
# frozen_string_literal: true

module Mayak
  module Http
    module Decoder
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      interface!

      ResponseEntity = type_member

      sig {
        abstract
          .params(response: Mayak::Http::Response)
          .returns(Mayak::Monads::Try[ResponseEntity])
      }
      def decode(response)
      end

      class IdentityDecoder
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        include ::Mayak::Http::Decoder


        ResponseEntity = type_member { { fixed: ::Mayak::Http::Response } }

        sig {
          override
            .params(response: Mayak::Http::Response)
            .returns(Mayak::Monads::Try[ResponseEntity])
        }
        def decode(response)
          Mayak::Monads::Try::Success[ResponseEntity].new(response)
        end
      end
    end
  end
end
