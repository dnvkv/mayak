# typed: false
# frozen_string_literal: true

require "spec_helper"

describe Mayak::JsonCodec::FromHashSerializable do
  include Mayak::Monads::Try::Mixin

  class TestStruct < T::Struct
    include ::Mayak::HashSerializable

    const :a, Integer
    const :b, String

    def ==(other)
      a == other.a && b == other.b
    end
  end

  let(:codec) do
    ::Mayak::JsonCodec::FromHashSerializable[TestStruct].new
  end

  describe "#encode" do
    it "encodes a value" do
      expect(codec.encode(TestStruct.new(a: 1, b: "2"))).to eq('{"a":1,"b":"2"}')
    end
  end

  describe "#decode" do
    it "decodes a value" do
      expect(codec.decode('{"a":1,"b":"2"}').success).to eq(TestStruct.new(a: 1, b: "2"))
    end

    it "returns a failure if the value can't be decoded" do
      expect(codec.decode('{"a":"foo","b":2}')).to be_instance_of(::Mayak::Monads::Try::Failure)
    end
  end

  describe "#to_encoder" do
    it "returns an encoder" do
      expect(codec.to_encoder.encode(TestStruct.new(a: 1, b: "2"))).to eq('{"a":1,"b":"2"}')
    end
  end

  describe "#to_decoder" do
    it "returns a decoder" do
      expect(codec.to_decoder.decode('{"a":1,"b":"2"}').success).to eq(TestStruct.new(a: 1, b: "2"))
    end
  end
end