# typed: strong
# frozen_string_literal: true

module Mayak
  module Http
    module Encoder
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      abstract!

      include ::Mayak::Encoder

      ResponseEntity = type_member
      ResponseType   = type_member {{ fixed: Mayak::Http::Response }}

      class IdentityEncoder
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        include ::Mayak::Http::Encoder

        ResponseEntity = type_member {{ fixed: ::Mayak::Http::Response }}
        ResponseType   = type_member {{ fixed: Mayak::Http::Response }}

        sig { override.params(entity: ResponseEntity).returns(ResponseType) }
        def encode(entity)
          entity
        end
      end

      class FromFunction
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        include ::Mayak::Http::Encoder

        ResponseEntity = type_member
        ResponseType   = type_member {{ fixed: Mayak::Http::Response }}

        sig { params(function: T.proc.params(response: ResponseEntity).returns(ResponseType)).void }
        def initialize(&function)
          @function = T.let(function, T.proc.params(response: ResponseEntity).returns(ResponseType))
        end

        sig { override.params(entity: ResponseEntity).returns(ResponseType) }
        def encode(entity)
          @function.call(entity)
        end
      end

      class FromHashSerializableJson < T::Struct
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        include ::Mayak::Http::Encoder

        const :default_status,  Integer
        const :default_headers, T::Hash[String, String]

        ResponseEntity = type_member {{ fixed: ::Mayak::HashSerializable }}
        ResponseType   = type_member {{ fixed: Mayak::Http::Response }}

        sig { override.params(entity: ResponseEntity).returns(ResponseType) }
        def encode(entity)
          Mayak::Http::Response.new(
            status:  default_status,
            headers: default_headers,
            body:    Mayak::Json.dump(entity.serialize)
          )
        end
      end
    end
  end
end
