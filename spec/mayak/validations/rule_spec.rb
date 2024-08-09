# typed: false
# frozen_string_literal: true

require "spec_helper"

describe Mayak::Validations::Rule do
  describe Mayak::Validations::Rule::FromFunction do
    let(:int_equal_to_10_rule) do
      ::Mayak::Validations::Rule::FromFunction[Integer, String].new do |checked|
        if checked == 10
          ::Mayak::ValidationResult::Valid.new
        else
          ::Mayak::ValidationResult::Invalid.new(errors: ["Value #{checked} should equal to 10"])
        end
      end
    end

    describe "#check" do
      it "returns ValidationResult::Valid if function returns Valid" do
        expect(int_equal_to_10_rule.check(10)).to be_a(Mayak::ValidationResult::Valid)
      end

      it "returns ValidationResult::Invalid if function returns Invalid" do
        expect(int_equal_to_10_rule.check(0)).to be_a(Mayak::ValidationResult::Invalid)
      end
    end

    describe "#transform" do
      it "returns an updated rule" do
        expect(
          int_equal_to_10_rule.transform(
            ::Mayak::Function[Integer, Integer].new { |value| value - 10 }
          ).check(20)
        ).to be_a(Mayak::ValidationResult::Valid)
      end
    end

    describe "#error_from_value" do
      let(:updated_rule) { int_equal_to_10_rule.error_from_value { |value| "argument #{value} is not valid" } }

      it "returns valid when check successful" do
        expect(updated_rule.check(10)).to be_a(Mayak::ValidationResult::Valid)
      end

      it "updates the rule so it returns updated error" do
        result = updated_rule.check(0)

        expect(result).to be_a(Mayak::ValidationResult::Invalid)
        expect(result.errors).to contain_exactly("argument 0 is not valid")
      end
    end

    describe "#error_as" do
      let(:updated_rule) { int_equal_to_10_rule.error_as("error") }

      it "returns valid when check successful" do
        expect(updated_rule.check(10)).to be_a(Mayak::ValidationResult::Valid)
      end

      it "returns an updated rule" do
        result = updated_rule.check(0)

        expect(result).to be_a(Mayak::ValidationResult::Invalid)
        expect(result.errors).to contain_exactly("error")
      end
    end

    describe "#any" do
      let(:rule1) do
        ::Mayak::Validations::Rule::FromFunction[Integer, String].new do |checked|
          if checked == 3 || checked == 4
            ::Mayak::ValidationResult::Valid.new
          else
            ::Mayak::ValidationResult::Invalid.new(errors: ["Rule 1 failed"])
          end
        end
      end

      let(:rule2) do
        ::Mayak::Validations::Rule::FromFunction[Integer, String].new do |checked|
          if checked == 4 || checked == 5
            ::Mayak::ValidationResult::Valid.new
          else
            ::Mayak::ValidationResult::Invalid.new(errors: ["Rule 2 failed"])
          end
        end
      end

      it "returns valid when only first check successful" do
        expect(rule1.any(rule2).check(3)).to be_a(Mayak::ValidationResult::Valid)
      end

      it "returns valid when only second check successful" do
        expect(rule1.any(rule2).check(5)).to be_a(Mayak::ValidationResult::Valid)
      end

      it "returns valid when both checks successful" do
        expect(rule1.any(rule2).check(4)).to be_a(Mayak::ValidationResult::Valid)
      end

      context "when both checks fail" do
        it "returns invalid with both errors with no block provided" do
          expect(rule1.any(rule2).check(1)).to be_a(Mayak::ValidationResult::Invalid)
          expect(rule1.any(rule2).check(1).errors).to eq(["Rule 1 failed", "Rule 2 failed"])
        end
  
        it "combines error with block provided" do
          result = rule1.any(rule2) do |first, second|
            if first.is_a?(::Mayak::ValidationResult::Invalid) && second.is_a?(::Mayak::ValidationResult::Invalid)
              new_errors = first.errors.zip(second.errors).map do |first, second|
                second.nil? ? first : "#{first} and #{second}"
              end
              ::Mayak::ValidationResult::Invalid[String].new(errors: new_errors)
            else
              ::Mayak::ValidationResult::Valid[String].new
            end
          end

          expect(result.check(1)).to be_a(Mayak::ValidationResult::Invalid)
          expect(result.check(1).errors).to eq(["Rule 1 failed and Rule 2 failed"])
        end
      end

      context "when both checks fail" do
        it "returns invalid with both errors with no block provided" do
          expect(rule1.any(rule2).check(1)).to be_a(Mayak::ValidationResult::Invalid)
          expect(rule1.any(rule2).check(1).errors).to eq(["Rule 1 failed", "Rule 2 failed"])
        end
  
        it "combines error with block provided" do
          any_rule = rule1.any(rule2) do |first, second|
            if first.is_a?(::Mayak::ValidationResult::Invalid) && second.is_a?(::Mayak::ValidationResult::Invalid)
              new_errors = first.errors.zip(second.errors).map do |first, second|
                second.nil? ? first : "#{first} and #{second}"
              end
              ::Mayak::ValidationResult::Invalid[String].new(errors: new_errors)
            else
              ::Mayak::ValidationResult::Valid[String].new
            end
          end

          expect(any_rule.check(1)).to be_a(Mayak::ValidationResult::Invalid)
          expect(any_rule.check(1).errors).to eq(["Rule 1 failed and Rule 2 failed"])
        end
      end
    end

    describe "#both" do
      let(:rule1) do
        ::Mayak::Validations::Rule::FromFunction[Integer, String].new do |checked|
          if checked == 3 || checked == 4
            ::Mayak::ValidationResult::Valid.new
          else
            ::Mayak::ValidationResult::Invalid.new(errors: ["Rule 1 failed"])
          end
        end
      end

      let(:rule2) do
        ::Mayak::Validations::Rule::FromFunction[Integer, String].new do |checked|
          if checked == 4 || checked == 5
            ::Mayak::ValidationResult::Valid.new
          else
            ::Mayak::ValidationResult::Invalid.new(errors: ["Rule 2 failed"])
          end
        end
      end

      it "returns invalid when only first check successful" do
        result = rule1.both(rule2).check(3)

        expect(result).to be_a(Mayak::ValidationResult::Invalid)
        expect(result.errors).to eq(["Rule 2 failed"])
      end

      it "returns valid when only second check successful" do
        result = rule1.both(rule2).check(5)

        expect(result).to be_a(Mayak::ValidationResult::Invalid)
        expect(result.errors).to eq(["Rule 1 failed"])
      end

      it "returns valid when both checks successful" do
        expect(rule1.both(rule2).check(4)).to be_a(Mayak::ValidationResult::Valid)
      end

      context "when both checks fail" do
        it "returns invalid with both errors with no block provided" do
          expect(rule1.both(rule2).check(1)).to be_a(Mayak::ValidationResult::Invalid)
          expect(rule1.both(rule2).check(1).errors).to eq(["Rule 1 failed", "Rule 2 failed"])
        end
  
        it "combines error with block provided" do
          both_rule = rule1.both(rule2) do |first, second|
            if first.is_a?(::Mayak::ValidationResult::Invalid) && second.is_a?(::Mayak::ValidationResult::Invalid)
              new_errors = first.errors.zip(second.errors).map do |first, second|
                second.nil? ? first : "#{first} and #{second}"
              end
              ::Mayak::ValidationResult::Invalid[String].new(errors: new_errors)
            else
              ::Mayak::ValidationResult::Valid[String].new
            end
          end

          expect(both_rule.check(1)).to be_a(Mayak::ValidationResult::Invalid)
          expect(both_rule.check(1).errors).to eq(["Rule 1 failed and Rule 2 failed"])
        end
      end
    end

    describe "#negate" do
      let(:rule) do
        ::Mayak::Validations::Rule::FromFunction[Integer, String].new do |checked|
          if checked == 0
            ::Mayak::ValidationResult::Valid.new
          else
            ::Mayak::ValidationResult::Invalid.new(errors: ["Rule 1 failed"])
          end
        end
      end

      let(:negated_rule) do
        rule.negate { |value| ::Mayak::ValidationResult::Invalid[String].new(errors: ["Value should not be zero"]) }
      end

      it "returns valid when original rule returns invalid" do
        expect(negated_rule.check(10)).to be_a(::Mayak::ValidationResult::Valid[String])
      end

      it "returns invalid when original rule returns valid" do
        expect(negated_rule.check(0)).to be_a(::Mayak::ValidationResult::Invalid[String])
        expect(negated_rule.check(0).errors).to eq(["Value should not be zero"])
      end
    end

    describe "#with_key" do
      let(:rule) do
        ::Mayak::Validations::Rule::FromFunction[Integer, String].new do |checked|
          if checked == 0
            ::Mayak::ValidationResult::Valid.new
          else
            ::Mayak::ValidationResult::Invalid.new(errors: ["Value should be zero"])
          end
        end
      end

      let(:updated_rule) { rule.with_key(:value) }

      it "returns valid when check passes" do
        expect(updated_rule.check(0)).to be_a(::Mayak::ValidationResult::Valid[[Symbol, String]])
      end

      it "returns invalid with pair if check fails" do
        expect(updated_rule.check(10)).to be_a(::Mayak::ValidationResult::Invalid[[Symbol, String]])
        expect(updated_rule.check(10).errors).to eq([[:value, "Value should be zero"]])
      end
    end
  end
end