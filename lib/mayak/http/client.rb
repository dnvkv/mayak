# frozen_string_literal: true
# typed: strict

module Mayak
  module Http
    module Client
      extend T::Sig
      extend T::Generic

      interface!

      sig { abstract.params(request: Http::Request).returns(Mayak::Monads::Try[Mayak::Http::Response]) }
      def send_request(request)
      end
    end
  end
end
