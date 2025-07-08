# typed: ignore
# frozen_string_literal: true

require_relative "../monads/try"
require "sorbet-coerce"

module Mayak
  module JsonCodec
    class FromHashSerializable
      include ::Mayak::Monads::Try::Mixin

      include ::Mayak::Codec

      def initialize(type)
        @type = type
      end

      def self.[](type)
        ::Mayak::JsonCodec::FromHashSerializable.new(type)
      end

      def new
        self
      end

      def encode(entity)
        JSON.dump(entity.serialize)
      end

      def decode(response)
        Try do
          parsed = JSON.parse(response)
          ::TypeCoerce::Converter.new(@type).from(parsed)
        end
      end
    end
  end
end