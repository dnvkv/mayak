# typed: strong
# frozen_string_literal: true

module Mayak
  module Http
    module Codec
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      interface!

      include Mayak::Http::Encoder
      include Mayak::Http::Decoder

      RequestEntity  = type_member
      ResponseEntity = type_member
    end
  end
end
