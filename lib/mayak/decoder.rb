# typed: strong
# frozen_string_literal: true

module Mayak
  module Decoder
    extend T::Sig
    extend T::Generic
    extend T::Helpers

    abstract!

    RequestType   = type_member
    RequestEntity = type_member

    sig {
      abstract
        .params(response: RequestType)
        .returns(Mayak::Monads::Try[RequestEntity])
    }
    def decode(response)
    end
  end
end
