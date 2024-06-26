# typed: false
# frozen_string_literal: true

require "spec_helper"

describe Mayak::Function do
  describe "#compose" do
    let(:f) { Mayak::Function[Integer, String].new(&:to_s) }
    let(:g) { Mayak::Function[String, T::Array[String]].new { |str| str.each_char.to_a } }

    it "executes g with a result of f" do
      expect(g.compose(f).call(100)).to eq(["1", "0", "0"])
      expect((g << f).call(100)).to eq(["1", "0", "0"])
    end
  end

  describe "#and_then" do
    let(:f) { Mayak::Function[Integer, String].new(&:to_s) }
    let(:g) { Mayak::Function[String, T::Array[String]].new { |str| str.each_char.to_a } }

    it "executes g with a result of f" do
      expect(f.and_then(g).call(100)).to eq(["1", "0", "0"])
      expect((f >> g).call(100)).to eq(["1", "0", "0"])
    end
  end
end
