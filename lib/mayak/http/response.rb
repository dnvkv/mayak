# frozen_string_literal: true
# typed: strict

module Mayak
  module Http
    class Response < T::Struct
      extend T::Sig

      SuccessfulStatuses  = T.let(Set.new(200..299).freeze, T::Set[Integer])
      StatusesWithoutBody = T.let(Set.new([204, 304]).freeze, T::Set[Integer])

      const :status,  Integer
      const :headers, T::Hash[String, String], default: {}
      const :body,    String, default: ""

      sig { returns(T::Boolean) }
      def success?
        SuccessfulStatuses.include?(status)
      end

      sig { returns(T::Boolean) }
      def failure?
        !success?
      end
    end
  end
end
