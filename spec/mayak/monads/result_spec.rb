# typed: false
# frozen_string_literal: true

require "spec_helper"

describe Mayak::Monads::Result do
  describe "#==" do
    it "returns false if one is Success and another is Failure" do
      error  = "Error"
      first  = T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer])
      second = T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer])

      expect(first == second).to be_falsey
    end

    it "returns true if both are Failure and have the same content" do
      error  = "Error"
      first  = T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer])
      second = T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer])

      expect(first == second).to be_truthy
    end

    it "returns false if both are Failure but have different content" do
      error1 = "Error1"
      error2 = "Error2"
      first  = T.let(Mayak::Monads::Result::Failure[String, Integer].new(error1), Mayak::Monads::Result[String, Integer])
      second = T.let(Mayak::Monads::Result::Failure[String, Integer].new(error2), Mayak::Monads::Result[String, Integer])

      expect(first == second).to be_falsey
    end

    it "returns true if both are Success and have the same value" do
      first  = T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer])
      second = T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer])

      expect(first == second).to be_truthy
    end

    it "returns false if both are Success but have different value" do
      first  = T.let(Mayak::Monads::Result::Success[Integer].new(10), Mayak::Monads::Result[String, Integer])
      second = T.let(Mayak::Monads::Result::Success[Integer].new(20), Mayak::Monads::Result[String, Integer])

      expect(first == second).to be_falsey
    end
  end

  describe "#map" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "modifies value for Success" do
      expect(success.map { |value| value + 10 }).to eq(Mayak::Monads::Result::Success[String, Integer].new(20))
    end

    it "returns itself for Failure" do
      expect(failure.map { |value| value + 10 }).to eq(failure)
    end
  end

  describe "#flat_map" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "returns Failure if a monad is Failure" do
      expect(
        failure.flat_map { |value| Mayak::Monads::Result::Success[String, Integer].new(value + 10) }
      ).to eq(failure)

      expect(
        failure.flat_map { |_value| Mayak::Monads::Result::Failure[String, Integer].new(error) }
      ).to eq(failure)
    end

    it "returns Failure if a monad is Success and block returns Failure" do
      expect(
        success.flat_map { |_value| Mayak::Monads::Result::Failure[String, Integer].new(error) }
      ).to eq(Mayak::Monads::Result::Failure[String, Integer].new(error))
    end

    it "returns Success if a monad is Success and block returns Success" do
      expect(
        success.flat_map { |value| Mayak::Monads::Result::Success[String, Integer].new(value + 10) }
      ).to eq(Mayak::Monads::Result::Success[String, Integer].new(20))
    end
  end

  describe "#filter_or" do
    let(:error1)  { "Error1" }
    let(:error2)  { "Error2" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error1), Mayak::Monads::Result[String, Integer]) }

    it "returns Failure if a monad is Failure" do
      expect(failure.filter_or(error2) { |value| value > 5 }).to eq(failure)
    end

    it "returns Failure with provided error if a monad is Success and block returns false" do
      expect(success.filter_or(error2) { |value| value < 5 }).to eq(Mayak::Monads::Result::Failure[String, Integer].new(error2))
    end

    it "returns self if a monad is Success and block returns true" do
      expect(success.filter_or(error2) { |value| value > 5 }).to eq(success)
    end
  end

  describe "#as" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "changes the value for Success" do
      expect(success.as("Success")).to eq(Mayak::Monads::Result::Success[String, String].new("Success"))
    end

    it "returns itself for Failure" do
      expect(failure.as(20)).to eq(failure)
    end
  end

  describe "#failure_as" do
    let(:error1)  { "Error1" }
    let(:error2)  { "Error2" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error1), Mayak::Monads::Result[String, Integer]) }

    it "changes the value for Success" do
      expect(success.failure_as(error2)).to eq(success)
    end

    it "returns itself for Failure" do
      expect(failure.failure_as(error2)).to eq(Mayak::Monads::Result::Failure[String, Integer].new(error2))
    end
  end

  describe "#success?" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "returns true on Success" do
      expect(success.success?).to be_truthy
    end

    it "returns false on Failure" do
      expect(failure.success?).to be_falsey
    end
  end

  describe "#failure?" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "returns false on Success" do
      expect(success.failure?).to be_falsey
    end

    it "returns true on Failure" do
      expect(failure.failure?).to be_truthy
    end
  end

  describe "#success_or" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "retrieves value from Success" do
      expect(success.success_or(0)).to eq(10)
    end

    it "returns provided fallback value for Failure" do
      expect(failure.success_or(0)).to eq(0)
    end
  end

  describe "#failure_or" do
    let(:error1)  { "Error1" }
    let(:error2)  { "Error2" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error1), Mayak::Monads::Result[String, Integer]) }

    it "returns provided fallback error for Success" do
      expect(success.failure_or(error2)).to eq(error2)
    end

    it "retrieves error from Failure" do
      expect(failure.failure_or(error2)).to eq(error1)
    end
  end

  describe "#either" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "executes success branch on Success" do
      expect(
        success.either(
          -> (error) { ["failure", error] },
          -> (value) { ["success", value] }
        )
      ).to eq(["success", 10])
    end

    it "executes failure branch on Failure" do
      expect(
        failure.either(
          -> (error) { ["failure", error] },
          -> (value) { ["success", value] }
        )
      ).to eq(["failure", error])
    end
  end

  describe "#tee" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "calls a block and returns itself for Success" do
      buffer = []
      expect(success.tee { |value| buffer << value }).to eq(success)
      expect(buffer).to eq([10])
    end

    it "doesn't call a block and returns itself for Failure" do
      buffer = []
      expect(failure.tee { |value| buffer << value }).to eq(failure)
      expect(buffer).to eq([])
    end
  end

  describe "#map_failure" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "returns itself for Success" do
      expect(success.map_failure { |error| error + " updated" }).to eq(success)
    end

    it "modifies error fo Failure" do
      expect(failure.map_failure { |error| error + " updated" }).to eq(
        Mayak::Monads::Result::Failure[String, Integer].new("Error updated")
      )
    end
  end

  describe "#flat_map_failure" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "returns self if a monad is Success" do
      expect(
        success.flat_map_failure { |error| Mayak::Monads::Result::Success[String, Integer].new(error) }
      ).to eq(success)

      expect(
        success.flat_map_failure { |error| Mayak::Monads::Result::Failure[String, Integer].new(error + " updated") }
      ).to eq(success)
    end

    it "returns Failure if a monad is Failure and block returns Failure" do
      expect(
        failure.flat_map_failure do |error|
          Mayak::Monads::Result::Failure[String, Integer].new(error + " updated")
        end
      ).to eq(Mayak::Monads::Result::Failure[String, Integer].new(error + " updated"))
    end

    it "returns Success if a monad is Failure and block returns Success" do
      expect(
        failure.flat_map_failure do |error|
          Mayak::Monads::Result::Success[String, Integer].new(error.length)
        end
      ).to eq(Mayak::Monads::Result::Success[String, Integer].new(5))
    end
  end

  describe "#flip" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "moves success value into failure channel" do
      expect(success.flip).to eq(Mayak::Monads::Result::Failure[Integer, String].new(10))
    end

    it "moves failure value into success channel" do
      expect(failure.flip).to eq(Mayak::Monads::Result::Success[Integer, String].new("Error"))
    end
  end

  describe "#to_try" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "turns Success into successful task" do
      expect(success.to_try { |error| StandardError.new(error) }).to eq(Mayak::Monads::Try::Success[Integer].new(10))
    end

    it "turns Failure into task failed with an error returned by block" do
      expect(
        failure.to_try { |error| StandardError.new(error) }
      ).to eq(Mayak::Monads::Try::Failure[Integer].new(StandardError.new(error)))
    end
  end

  describe "#to_maybe" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "turns Success into Maybe" do
      expect(success.to_maybe).to eq(Mayak::Monads::Maybe::Some.new(10))
    end

    it "turns Failure into None" do
      expect(failure.to_maybe).to eq(Mayak::Monads::Maybe::None.new)
    end
  end

  describe "#recover" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "returns self if it's Success" do
      expect(success.recover(0)).to eq(success)
    end

    it "returns Success with value calculated by block from error if Failure" do
      expect(failure.recover(0)).to eq(Mayak::Monads::Result::Success[String, Integer].new(0))
    end
  end

  describe "#recover_with" do
    let(:error)   { "Error" }
    let(:success) { T.let(Mayak::Monads::Result::Success[String, Integer].new(10), Mayak::Monads::Result[String, Integer]) }
    let(:failure) { T.let(Mayak::Monads::Result::Failure[String, Integer].new(error), Mayak::Monads::Result[String, Integer]) }

    it "returns self if it's Success" do
      expect(success.recover_with(&:length)).to eq(success)
    end

    it "returns Success with value calculated by block from error if Failure" do
      expect(failure.recover_with(&:length)).to eq(Mayak::Monads::Result::Success[String, Integer].new(5))
    end
  end

  describe ".sequence" do
    it "returns Failure if some element is Failure" do
      error   = "Error"
      values1 = [Mayak::Monads::Result::Failure[String, Integer].new(error)]
      expect(
        Mayak::Monads::Result.sequence(values1)
      ).to eq(Mayak::Monads::Result::Failure[String, Array[Integer]].new(error))

      values2 = [
        Mayak::Monads::Result::Failure[String, Integer].new(error),
        Mayak::Monads::Result::Success[String, Integer].new(1)
      ]
      expect(
        Mayak::Monads::Result.sequence(values2)
      ).to eq(Mayak::Monads::Result::Failure[String, Array[Integer]].new(error))
    end

    it "returns Failure which contains first error if there are multiple errors" do
      error1 = "Error1"
      error2 = "Error2"
      values = [
        Mayak::Monads::Result::Failure[String, Integer].new(error1),
        Mayak::Monads::Result::Failure[String, Integer].new(error2)
      ]
      expect(Mayak::Monads::Result.sequence(values)).to eq(Mayak::Monads::Result::Failure[String, Array[Integer]].new(error1))
    end

    it "returns Success containing aggregated array of values if all elements are Success" do
      values = [
        Mayak::Monads::Result::Success[String, Integer].new(1),
        Mayak::Monads::Result::Success[String, Integer].new(2),
        Mayak::Monads::Result::Success[String, Integer].new(3)
      ]
      expect(
        Mayak::Monads::Result.sequence(values)
      ).to eq(Mayak::Monads::Result::Success[String, Array[Integer]].new([1, 2, 3]))
    end

    it "returns Success containing empty array if array is empty" do
      expect(Mayak::Monads::Result.sequence([])).to eq(Mayak::Monads::Result::Success[String, Array[Integer]].new([]))
    end
  end
end
