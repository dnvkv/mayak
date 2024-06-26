# typed: false
# frozen_string_literal: true

require "spec_helper"

describe Mayak::Monads::Try do
  describe "#==" do
    it "returns false if one is Success and another is Failure" do
      error  = StandardError.new("Error")
      first  = T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer])
      second = T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer])

      expect(first == second).to be_falsey
    end

    it "returns true if both are Failure and have the same content" do
      error  = StandardError.new("Error")
      first  = T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer])
      second = T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer])

      expect(first == second).to be_truthy
    end

    it "returns false if both are Failure but have different content" do
      error1 = StandardError.new("Error1")
      error2 = StandardError.new("Error2")
      first  = T.let(Mayak::Monads::Try::Failure[Integer].new(error1), Mayak::Monads::Try[Integer])
      second = T.let(Mayak::Monads::Try::Failure[Integer].new(error2), Mayak::Monads::Try[Integer])

      expect(first == second).to be_falsey
    end

    it "returns true if both are Success and have the same value" do
      first  = T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer])
      second = T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer])

      expect(first == second).to be_truthy
    end

    it "returns false if both are Success but have different value" do
      first  = T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer])
      second = T.let(Mayak::Monads::Try::Success[Integer].new(20), Mayak::Monads::Try[Integer])

      expect(first == second).to be_falsey
    end
  end

  describe "#map" do
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

    it "modifies value for Success" do
      expect(success.map { |value| value + 10 }).to eq(Mayak::Monads::Try::Success[Integer].new(20))
    end

    it "returns itself for Failure" do
      expect(failure.map { |value| value + 10 }).to eq(failure)
    end
  end

  describe "#flat_map" do
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

    it "returns Failure if a monad is Failure" do
      expect(
        failure.flat_map { |value| Mayak::Monads::Try::Success[Integer].new(value + 10) }
      ).to eq(failure)

      expect(
        failure.flat_map { |_value| Mayak::Monads::Try::Failure[Integer].new(error) }
      ).to eq(failure)
    end

    it "returns Failure if a monad is Success and block returns Failure" do
      expect(
        success.flat_map { |_value| Mayak::Monads::Try::Failure[Integer].new(error) }
      ).to eq(Mayak::Monads::Try::Failure[Integer].new(error))
    end

    it "returns Success if a monad is Success and block returns Success" do
      expect(
        success.flat_map { |value| Mayak::Monads::Try::Success[Integer].new(value + 10) }
      ).to eq(Mayak::Monads::Try::Success[Integer].new(20))
    end
  end

  describe "#filter_or" do
    let(:error1)  { StandardError.new("Error1") }
    let(:error2)  { StandardError.new("Error2") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error1), Mayak::Monads::Try[Integer]) }

    it "returns Failure if a monad is Failure" do
      expect(failure.filter_or(error2) { |value| value > 5 }).to eq(failure)
    end

    it "returns Failure with provided error if a monad is Success and block returns false" do
      expect(success.filter_or(error2) { |value| value < 5 }).to eq(Mayak::Monads::Try::Failure[Integer].new(error2))
    end

    it "returns self if a monad is Success and block returns true" do
      expect(success.filter_or(error2) { |value| value > 5 }).to eq(success)
    end
  end

  describe "#as" do
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

    it "changes the value for Success" do
      expect(success.as(20)).to eq(Mayak::Monads::Try::Success[Integer].new(20))
    end

    it "returns itself for Failure" do
      expect(failure.as(20)).to eq(failure)
    end
  end

  describe "#failure_as" do
    let(:error)   { StandardError.new("Error") }
    let(:error2)  { StandardError.new("NewError") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

    it "changes the value for Success" do
      expect(success.failure_as(error2)).to eq(success)
    end

    it "returns itself for Failure" do
      expect(failure.failure_as(error2)).to eq(Mayak::Monads::Try::Failure[Integer].new(error2))
    end
  end

  describe "#success?" do
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

    it "returns true on Success" do
      expect(success.success?).to be_truthy
    end

    it "returns false on Failure" do
      expect(failure.success?).to be_falsey
    end
  end

  describe "#failure?" do
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

    it "returns false on Success" do
      expect(success.failure?).to eq(false)
    end

    it "returns true on Failure" do
      expect(failure.failure?).to eq(true)
    end
  end

  describe "#success_or" do
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

    it "retrieves value from Success" do
      expect(success.success_or(0)).to eq(10)
    end

    it "returns provided fallback value for Failure" do
      expect(failure.success_or(0)).to eq(0)
    end
  end

  describe "#failure_or" do
    let(:error1)  { StandardError.new("Error1") }
    let(:error2)  { StandardError.new("Error2") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error1), Mayak::Monads::Try[Integer]) }

    it "returns provided fallback error for Success" do
      expect(success.failure_or(error2)).to eq(error2)
    end

    it "retrieves error from Failure" do
      expect(failure.failure_or(error2)).to eq(error1)
    end
  end

  describe "#either" do
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

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
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

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
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

    it "returns itself for Success" do
      expect(success.map_failure { |error| ArgumentError.new(error.message) }).to eq(success)
    end

    it "modifies error fo Failure" do
      expect(failure.map_failure { |error| ArgumentError.new(error.message) }).to eq(
        Mayak::Monads::Try::Failure[Integer].new(ArgumentError.new("Error"))
      )
    end
  end

  describe "#flat_map_failure" do
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

    it "returns self if a monad is Success" do
      expect(
        success.flat_map_failure { |error| Mayak::Monads::Try::Success[Integer].new(error.message) }
      ).to eq(success)

      expect(
        success.flat_map_failure { |error| Mayak::Monads::Try::Failure[Integer].new(ArgumentError.new(error)) }
      ).to eq(success)
    end

    it "returns Failure if a monad is Failure and block returns Failure" do
      expect(
        failure.flat_map_failure { |error| Mayak::Monads::Try::Failure[Integer].new(ArgumentError.new(error.message)) }
      ).to eq(Mayak::Monads::Try::Failure[Integer].new(ArgumentError.new(error.message)))
    end

    it "returns Success if a monad is Failure and block returns Success" do
      expect(
        failure.flat_map_failure { |error| Mayak::Monads::Try::Success[Integer].new(error.message.length) }
      ).to eq(Mayak::Monads::Try::Success[Integer].new(5))
    end
  end

  describe "#to_result" do
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

    it "returns Success if it's Success" do
      expect(success.to_result(&:message)).to eq(Mayak::Monads::Result::Success[String, Integer].new(10))
    end

    it "returns Failure with value modified by block if Failure" do
      expect(failure.to_result(&:message)).to eq(Mayak::Monads::Result::Failure[String, Integer].new("Error"))
    end
  end

  describe "#to_maybe" do
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

    it "turns Success into Maybe" do
      expect(success.to_maybe).to eq(Mayak::Monads::Maybe::Some.new(10))
    end

    it "turns Failure into None" do
      expect(failure.to_maybe).to eq(Mayak::Monads::Maybe::None.new)
    end
  end

  describe "#recover_on" do
    class CustomError1 < StandardError
    end

    class CustomError2 < StandardError
    end

    let(:custom_error1) { CustomError1.new("Custom1") }
    let(:custom_error2) { CustomError2.new("Custom2") }

    let(:success)  { T.let(Mayak::Monads::Try::Success[String].new("success"), Mayak::Monads::Try[String]) }
    let(:failure1) { T.let(Mayak::Monads::Try::Failure[String].new(custom_error1), Mayak::Monads::Try[String]) }
    let(:failure2) { T.let(Mayak::Monads::Try::Failure[String].new(custom_error2), Mayak::Monads::Try[String]) }

    it "returns self if it's Success" do
      expect(success.recover_on(CustomError1, &:message)).to eq(success)
    end

    it "returns itself if failure has different type on Failure" do
      expect(failure1.recover_on(CustomError2) { |error| error.message }).to eq(failure1)
    end

    it "returns Success with result of the block if failure type is matched on Failure" do
      expect(failure1.recover_on(CustomError1) { |error| error.message }).to eq(
        Mayak::Monads::Try::Success[String].new("Custom1")
      )
    end
  end

  describe "#recover" do
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

    it "returns Success if it's Success" do
      expect(success.recover(0)).to eq(success)
    end

    it "returns Success with value calculated by block from error if Failure" do
      expect(failure.recover(0)).to eq(Mayak::Monads::Try::Success[Integer].new(0))
    end
  end

  describe "#recover_with" do
    let(:error)   { StandardError.new("Error") }
    let(:success) { T.let(Mayak::Monads::Try::Success[Integer].new(10), Mayak::Monads::Try[Integer]) }
    let(:failure) { T.let(Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try[Integer]) }

    it "returns Success if it's Success" do
      expect(success.recover_with(&:message)).to eq(success)
    end

    it "returns Success with value calculated by block from error if Failure" do
      expect(failure.recover_with(&:message)).to eq(Mayak::Monads::Try::Success[String].new("Error"))
    end
  end

  describe ".sequence" do
    it "returns Failure if some element is Failure" do
      error = StandardError.new("Error")
      values1 = [Mayak::Monads::Try::Failure[Integer].new(error)]
      expect(Mayak::Monads::Try.sequence(values1)).to eq(Mayak::Monads::Try::Failure[Array[Integer]].new(error))

      values2 = [Mayak::Monads::Try::Failure[Integer].new(error), Mayak::Monads::Try::Success[Integer].new(1)]
      expect(Mayak::Monads::Try.sequence(values2)).to eq(Mayak::Monads::Try::Failure[Array[Integer]].new(error))
    end

    it "returns Failure which contains first error if there are multiple errors" do
      error1 = StandardError.new("Error1")
      error2 = StandardError.new("Error2")
      values = [Mayak::Monads::Try::Failure[Integer].new(error1), Mayak::Monads::Try::Failure[Integer].new(error2)]
      expect(Mayak::Monads::Try.sequence(values)).to eq(Mayak::Monads::Try::Failure[Array[Integer]].new(error1))
    end

    it "returns Success containing aggregated array of values if all elements are Success" do
      values = [
        Mayak::Monads::Try::Success[Integer].new(1),
        Mayak::Monads::Try::Success[Integer].new(2),
        Mayak::Monads::Try::Success[Integer].new(3)
      ]
      expect(Mayak::Monads::Try.sequence(values)).to eq(Mayak::Monads::Try::Success[Array[Integer]].new([1, 2, 3]))
    end

    it "returns Success containing empty array if array is empty" do
      expect(Mayak::Monads::Try.sequence([])).to eq(Mayak::Monads::Try::Success[Array[Integer]].new([]))
    end
  end

  describe ".check" do
    let(:error) { StandardError.new("Error") }

    it "returns value wrapped into Success if block returns true" do
      expect(Mayak::Monads::Try.check(10, error) { true }).to eq(Mayak::Monads::Try::Success[Integer].new(10))
    end

    it "returns Failure if block returns false" do
      expect(Mayak::Monads::Try.check(10, error) { false }).to eq(Mayak::Monads::Try::Failure[Integer].new(error))
    end
  end

  describe ".guard" do
    let(:error) { StandardError.new("Error") }

    it "returns Success containing nil if block returns true" do
      expect(Mayak::Monads::Try.guard(error) { true }).to eq(Mayak::Monads::Try::Success[NilClass].new(nil))
    end

    it "returns Failure if block returns false" do
      expect(Mayak::Monads::Try.guard(error) { false }).to eq(Mayak::Monads::Try::Failure[NilClass].new(error))
    end
  end

  describe "Mixin" do
    include Mayak::Monads::Try::Mixin

    describe "#Try" do
      it "captures an exception" do
        result = Try { raise StandardError.new("Error") }
        expect(result.failure?).to be_truthy
        expect(result.failure_or(StandardError.new("")).message).to eq("Error")
      end

      it "captures only specified exceptions" do
        expect do
          Try(ArgumentError) { raise ArgumentError.new("Error") }
        end.not_to raise_error

        expect do
          Try(ArgumentError, ZeroDivisionError) { raise ZeroDivisionError.new("Error") }
        end.not_to raise_error

        expect(
          Try(ArgumentError) { raise ArgumentError.new("Error") }.failure_or(StandardError.new(""))
        ).to be_instance_of(ArgumentError)

        expect do
          Try(ArgumentError) { raise ZeroDivisionError.new("Error") }
        end.to raise_error(ZeroDivisionError, "Error")
      end

      it "wraps successful value" do
        result = Try { 10 }
        expect(result).to eq(Mayak::Monads::Try::Success[Integer].new(10))
      end
    end

    describe "Do-notation" do
      it "automatically wraps last expression into a monad" do
        result = for_try {
          10
        }
        expect(result).to eq(Mayak::Monads::Try::Success[Integer].new(10))
      end

      it "allows to unpack values" do
        result = for_try {
          a = do_try! Try { 10 }
          b = do_try! Try { 5 }
          a + b
        }
        expect(result).to eq(Mayak::Monads::Try::Success[Integer].new(15))
      end

      it "short-circuits execution on Failure and returns Failure" do
        buffer = []
        error = StandardError.new("Error")
        result = for_try {
          a = do_try! Try { 10 }
          b = do_try! Try { raise error }
          buffer << 1
          a + b
        }
        expect(result).to eq(Mayak::Monads::Try::Failure.new(error))
        expect(buffer).to eq([])
      end
    end

    describe "#check_try!" do
      let(:error) { StandardError.new("Error") }
      it "returns value if condition block returns true" do
        result = for_try {
          check_try!(10, StandardError.new("Error")) { true }
        }
        expect(result).to eq(Mayak::Monads::Try::Success[Integer].new(10))
      end

      it "returns Failure with error if block condition block returns false" do
        result = for_try {
          check_try!(10, error) { false }
        }
        expect(result).to eq(Mayak::Monads::Try::Failure[Integer].new(error))
      end

      it "short-circuits execution if condition block returns false" do
        buffer = []
        error  = StandardError.new("Error")
        result = for_try {
          check_try!(10, error) { false }
          buffer << 1
          10
        }
        expect(result).to eq(Mayak::Monads::Try::Failure[Integer].new(error))
        expect(buffer).to eq([])
      end
    end

    describe "#guard_try!" do
      it "doesn't do anything if condition block returns true" do
        buffer = []
        error  = StandardError.new("Error")
        result = for_try {
          guard_try!(error) { true }
          buffer << 1
          10
        }
        expect(result).to eq(Mayak::Monads::Try::Success[Integer].new(10))
        expect(buffer).to eq([1])
      end

      it "returns Failure if block condition block returns false" do
        error  = StandardError.new("Error")
        result = for_try {
          guard_try!(error) { false }
        }
        expect(result).to eq(Mayak::Monads::Try::Failure[Integer].new(error))
      end

      it "short-circuits execution if condition block returns false" do
        buffer = []
        error  = StandardError.new("Error")
        result = for_try {
          guard_try!(error) { false }
          buffer << 1
          10
        }
        expect(result).to eq(Mayak::Monads::Try::Failure[Integer].new(error))
        expect(buffer).to eq([])
      end
    end
  end
end
