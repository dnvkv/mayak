# typed: false
# frozen_string_literal: true

require "spec_helper"

describe Mayak::Validations::Contract do
  class User < T::Struct
    const :email, String
    const :age,   Integer
  end

  class Post < T::Struct
    const :content, String
    const :author,  User
  end

  let(:user_contract) do
    Mayak::Validations::Contract[User, String].new
      .validate(Mayak::Validations::Rule.not_empty, key: :email, &:email)
      .validate(Mayak::Validations::Rule.greater_than_or_equal_to(18), key: :age, &:age)
  end

  describe "#check" do
    it "returns success if there's not errors" do
      expect(user_contract.check(User.new(email: "foo@bar.com", age: 20))).to be_a(Mayak::ValidationResult::Valid)
    end

    it "returns single error if there is one error" do
      result1 = user_contract.check(User.new(email: "", age: 20))
      expect(result1).to be_a(Mayak::ValidationResult::Invalid)
      expect(result1.errors.length).to eq(1)
      expect(result1.errors.first).to eq([:email, "Value should not be empty"])

      result2 = user_contract.check(User.new(email: "foo@bar.com", age: 15))
      expect(result2).to be_a(Mayak::ValidationResult::Invalid)
      expect(result2.errors.length).to eq(1)
      expect(result2.errors.first).to eq([:age, "Value 15 should be greater than or equal to 18"])
    end

    context "with nested contracts" do
      let(:content_rule) do
        Mayak::Validations::Rule.not_empty & Mayak::Validations::Rule.length_less_than(250)
      end

      let(:post_contract) do
        Mayak::Validations::Contract[Post, String].new
          .validate(content_rule, key: :content, &:content)
          .validate(user_contract.to_rule, key: :author, &:author)
      end

      it "returns success if there's not errors" do
        expect(
          post_contract.check(
            Post.new(
              content: "Some valid content",
              author: User.new(email: "foo@bar.com", age: 20)
            )
          )
        ).to be_a(Mayak::ValidationResult::Valid)
      end
    end
  end
end