# typed: strong
# frozen_string_literal: true

module Mayak
  module Http
    module Encoder
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      interface!

      RequestEntity = type_member

      sig { abstract.params(entity: RequestEntity).returns(Mayak::Http::Request) }
      def encode(entity)
      end

      class IdentityEncoder
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        include ::Mayak::Http::Encoder

        RequestEntity = type_member { { fixed: ::Mayak::Http::Request } }

        sig { override.params(entity: RequestEntity).returns(Mayak::Http::Request) }
        def encode(entity)
          entity
        end
      end

      class FromFunction
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        include ::Mayak::Http::Encoder

        RequestEntity = type_member

        sig { params(function: Mayak::Function[RequestEntity, Mayak::Http::Request]).void }
        def initialize(function)
          @function = T.let(function, Mayak::Function[RequestEntity, Mayak::Http::Request])
        end

        sig { override.params(entity: RequestEntity).returns(Mayak::Http::Request) }
        def encode(entity)
          @function.call(entity)
        end
      end
    end
  end
end
