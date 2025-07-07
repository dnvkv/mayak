# typed: false
# frozen_string_literal: true

require "spec_helper"

describe Mayak::Decoder do
  include Mayak::Monads::Try::Mixin

  let(:implementation) do
    ::Mayak::Decoder::Implementation[String, { name: String, age: Integer }].new do |json|
      Try { JSON.parse(json) }.flat_map do |json|
        if !json["name"].is_a?(String) || !json["age"].is_a?(Integer)
          ::Mayak::Monads::Try::Failure.new(
            StandardError.new("Invalid JSON")
          )
        else
          ::Mayak::Monads::Try::Success.new({ name: json["name"], age: json["age"] })
        end
      end
    end
  end

  describe ::Mayak::Decoder::Implementation do
    it "decodes a value" do
      expect(implementation.decode('{"name":"John","age":30}').success).to eq({ name: "John", age: 30 })
    end

    it "returns a failure if the value can't be decoded" do
      expect(implementation.decode('{"name":"John"}')).to be_instance_of(::Mayak::Monads::Try::Failure)
    end
  end

  describe "#map" do
    it "returns new implementation that transform the decoder value" do
      mapped = implementation.map do |value|
        { name: value[:name], age: value[:age] + 1 }
      end

      expect(mapped.decode('{"name":"John","age":30}').success).to eq({ name: "John", age: 31 })
    end
  end
end
