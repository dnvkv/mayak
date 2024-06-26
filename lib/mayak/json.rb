# frozen_string_literal: true
# typed: strict

require "json"

module Mayak
  module Json
    extend T::Sig

    JsonType = T.type_alias {
      T.any(
        T::Array[T.untyped],
        T::Hash[T.untyped, T.untyped],
        String,
        Integer,
        Float
      )
    }

    class ParsingError < StandardError
    end

    sig { params(string: String).returns(Mayak::Monads::Try[JsonType]) }
    def self.parse(string)
      Mayak::Monads::Try::Success.new(JSON.parse(string))
    rescue JSON::ParserError => e
      Mayak::Monads::Try::Failure.new(ParsingError.new(e.message))
    end

    sig { params(string: String).returns(JsonType) }
    def self.parse_unsafe!(string)
      JSON.parse(string)
    end
  end
end
