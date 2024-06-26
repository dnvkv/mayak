# typed: strong
# frozen_string_literal: true

require_relative 'encoder'
require_relative 'decoder'

module Mayak
  module Http
    module Codec
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      abstract!

      include ::Mayak::Http::Encoder
      include ::Mayak::Http::Decoder

      ResponseEntity = type_member
      ResponseType   = type_member {{ fixed: ::Mayak::Http::Response }}
      RequestType    = type_member {{ fixed: ::Mayak::Http::Request }}
      RequestEntity  = type_member
    end
  end
end
