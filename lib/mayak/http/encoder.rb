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

      In = type_member
      Out   = type_member {{ fixed: Mayak::Http::Response }}

      class IdentityEncoder
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        include ::Mayak::Http::Encoder

        In  = type_member {{ fixed: ::Mayak::Http::Response }}
        Out = type_member {{ fixed: Mayak::Http::Response }}

        sig { override.params(entity: In).returns(Out) }
        def encode(entity)
          entity
        end
      end

      class FromHashSerializableJson < T::Struct
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        include ::Mayak::Http::Encoder

        const :default_status,  Integer
        const :default_headers, T::Hash[String, String]

        In = type_member {{ fixed: ::Mayak::HashSerializable }}
        Out   = type_member {{ fixed: Mayak::Http::Response }}

        sig { override.params(entity: In).returns(Out) }
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
