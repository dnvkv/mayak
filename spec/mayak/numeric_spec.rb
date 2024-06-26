# typed: false
# frozen_string_literal: true

require "spec_helper"

describe Mayak::Numeric do
  describe "#parse_float" do
    subject { Mayak::Numeric.parse_float(value) }

    context "with valid string input" do
      let(:value) { "123.45" }

      it "parses string to float" do
        result = subject.value_or(nil)

        expect(result).to eq(123.45)
        expect(result).to be_a(Float)
      end
    end

    context "with valid BigDecimal input" do
      let(:value) { BigDecimal("123.45") }

      it "parses BigDecimal to float" do
        result = subject.value_or(nil)

        expect(result).to eq(123.45)
        expect(result).to be_a(Float)
      end
    end

    context "with valid Float input" do
      let(:value) { 123.45 }

      it "keeps float as is" do
        result = subject.value_or(nil)

        expect(result).to eq(123.45)
        expect(result).to be_a(Float)
      end
    end

    context "with nil input" do
      let(:value) { nil }

      it "returns None for nil input" do
        expect(subject.none?).to be true
      end
    end

    context "with invalid input" do
      let(:value) { "invalid" }

      it "returns None for invalid input" do
        expect(subject.none?).to be true
      end
    end
  end

  describe "#parse_decimal" do
    subject { Mayak::Numeric.parse_decimal(value) }

    context "with valid string input" do
      let(:value) { "123.45" }

      it "parses string to BigDecimal" do
        result = subject.value_or(nil)

        expect(subject.value_or(nil)).to eq(BigDecimal("123.45"))
        expect(result).to be_a(BigDecimal)
      end
    end

    context "with valid integer input" do
      let(:value) { 123 }

      it "parses integer to BigDecimal" do
        result = subject.value_or(nil)

        expect(result).to eq(BigDecimal("123"))
        expect(result).to be_a(BigDecimal)
      end
    end

    context "with valid BigDecimal input" do
      let(:value) { BigDecimal("123.45") }

      it "keeps BigDecimal as is" do
        result = subject.value_or(nil)

        expect(result).to eq(BigDecimal("123.45"))
        expect(result).to be_a(BigDecimal)
      end
    end

    context "with valid Float input" do
      let(:value) { 123.45 }

      it "parses Float to BigDecimal" do
        result = subject.value_or(nil)

        expect(result).to eq(BigDecimal("123.45"))
        expect(result).to be_a(BigDecimal)
      end
    end

    context "with nil input" do
      let(:value) { nil }

      it "returns None for nil input" do
        expect(subject.none?).to be true
      end
    end

    context "with invalid input" do
      let(:value) { "invalid" }

      it "returns None for invalid input" do
        expect(subject.none?).to be true
      end
    end
  end

  describe "#parse_integer" do
    subject { Mayak::Numeric.parse_integer(value) }

    context "with valid string input" do
      let(:value) { "123" }

      it "parses string to integer" do
        result = subject.value_or(nil)

        expect(result).to eq(123)
        expect(result).to be_a(Integer)
      end
    end

    context "with valid integer input" do
      let(:value) { 123 }

      it "keeps integer as is" do
        result = subject.value_or(nil)

        expect(result).to eq(123)
        expect(result).to be_a(Integer)
      end
    end

    context "with nil input" do
      let(:value) { nil }

      it "returns None for nil input" do
        expect(subject.none?).to be true
      end
    end

    context "with invalid input" do
      let(:value) { "invalid" }

      it "returns None for invalid input" do
        expect(subject.none?).to be true
      end
    end
  end

  describe "#percent_of" do
    subject { Mayak::Numeric.percent_of(value: value, total: total) }

    it "returns 0 if total is 0" do
      expect(Mayak::Numeric.percent_of(value: BigDecimal(69), total: BigDecimal(0))).to be_zero
    end

    it "returns 0 if value is 0" do
      expect(Mayak::Numeric.percent_of(value: BigDecimal(0), total: BigDecimal(100))).to be_zero
    end

    it "returns correct percentage" do
      expect(Mayak::Numeric.percent_of(value: BigDecimal(69), total: BigDecimal(100))).to eq(BigDecimal(69))
    end
  end
end
