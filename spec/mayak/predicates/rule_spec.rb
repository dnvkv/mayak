# typed: false
# frozen_string_literal: true

require "spec_helper"

describe Mayak::Predicates::Rule do
  describe "#both" do
    let(:a) { Mayak::Predicates::Rule[Integer].new { |a| a > 10 } }
    let(:b) { Mayak::Predicates::Rule[Integer].new { |a| a < 100 } }

    it "performs logical and" do
      expect(a.both(b).call(0)).to eq(false)
      expect(a.both(b).call(20)).to eq(true)
      expect(a.both(b).call(100)).to eq(false)
    end
  end

  describe "#&" do
    let(:a) { Mayak::Predicates::Rule[Integer].new { |a| a > 10 } }
    let(:b) { Mayak::Predicates::Rule[Integer].new { |a| a < 100 } }

    it "performs logical and" do
      expect((a & b).call(0)).to eq(false)
      expect((a & b).call(20)).to eq(true)
      expect((a & b).call(100)).to eq(false)
    end
  end

  describe "#any" do
    let(:a) { Mayak::Predicates::Rule[Integer].new { |a| a == 2 } }
    let(:b) { Mayak::Predicates::Rule[Integer].new { |a| a == 3 } }

    it "performs logical or" do
      expect(a.any(b).call(3)).to eq(true)
      expect(a.any(b).call(2)).to eq(true)
      expect(a.any(b).call(0)).to eq(false)
    end
  end

  describe "#|" do
    let(:a) { Mayak::Predicates::Rule[Integer].new { |a| a == 2 } }
    let(:b) { Mayak::Predicates::Rule[Integer].new { |a| a == 3 } }

    it "performs logical or" do
      expect((a | b).call(3)).to eq(true)
      expect((a | b).call(2)).to eq(true)
      expect((a | b).call(0)).to eq(false)
    end
  end

  describe "#negate" do
    let(:a) { Mayak::Predicates::Rule[Integer].new { |a| a == 1 } }

    it "performs logical negation" do
      expect(a.negate.call(0)).to eq(true)
      expect(a.negate.call(1)).to eq(false)
    end
  end

  describe "#!" do
    let(:a) { Mayak::Predicates::Rule[Integer].new { |a| a == 1 } }

    it "performs logical negation" do
      expect(!a.call(0)).to eq(true)
      expect(!a.call(1)).to eq(false)
    end
  end

  describe "#from" do
    let(:string_rule) { Mayak::Predicates::Rule[String].new { |a| a == "100" } }
    let(:int_to_string) { Mayak::Function[Integer, String].new(&:to_s) }

    it "performs transforms rule with a function" do
      expect(string_rule.from(int_to_string).call(100)).to eq(true)
      expect(string_rule.from(int_to_string).call(200)).to eq(false)
    end
  end

  describe "#presence" do
    let(:rule) { Mayak::Predicates::Rule[Integer].new { |a| a > 0 } }

    it "transforms consuming type to nilable" do
      expect(rule.presence.call(nil)).to eq(false)
      expect(rule.presence.call(0)).to eq(false)
      expect(rule.presence.call(1)).to eq(true)
    end
  end
end
