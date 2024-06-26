# frozen_string_literal: true
# typed: strict

require "json"

module Mayak
  module Json
    module Encoder
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      abstract!

      include ::Mayak::Encoder

      ResponseEntity = type_member
      ResponseType   = type_member {{ fixed: ::Mayak::Json::JsonType }}

      class FromFunction
        extend T::Sig
        extend T::Generic
        extend T::Helpers
  
        include ::Mayak::Encoder
  
        ResponseEntity = type_member
        ResponseType   = type_member {{ fixed: ::Mayak::Json::JsonType }}
  
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
end
