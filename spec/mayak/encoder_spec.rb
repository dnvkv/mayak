# typed: false
# frozen_string_literal: true

require "spec_helper"

describe Mayak::Encoder do
  describe ::Mayak::Encoder::Implementation do
    let(:implementation) do
      ::Mayak::Encoder::Implementation[{ name: String, age: Integer }, String].new { |value| JSON.dump(value) }
    end

    it "encodes a value" do
      expect(implementation.encode({ name: "John", age: 30 })).to eq('{"name":"John","age":30}')
    end
  end

  describe "#map" do
    let(:implementation) do
      ::Mayak::Encoder::Implementation[{ name: String, age: Integer }, [String, Integer]].new do |value|
        [value[:name], value[:age]]
      end
    end


    it "returns new implementation that transform the encoded value" do
      mapped =implementation.map do |value|
        JSON.dump({ first: value[0], second: value[1] })
      end
      expect(mapped.encode({ name: "John", age: 30 })).to eq('{"first":"John","second":30}')
    end
  end
end
