# typed: false
# frozen_string_literal: true

require "spec_helper"
describe Mayak::Monads::Maybe do
  describe "#==" do
    it "returns true if both are None" do
      first  = T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer])
      second = T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer])

      expect(first == second).to be_truthy
    end

    it "returns false if one is some and another is none" do
      first  = T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer])
      second = T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer])

      expect(first == second).to be_falsey
      expect(second == first).to be_falsey
    end

    it "returns false if both are some but they have different content" do
      first  = T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer])
      second = T.let(Mayak::Monads::Maybe::Some[Integer].new(20), Mayak::Monads::Maybe[Integer])

      expect(first == second).to be_falsey
      expect(second == first).to be_falsey
    end

    it "returns true if both are some and they have same content" do
      first  = T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer])
      second = T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer])

      expect(first == second).to be_truthy
      expect(second == first).to be_truthy
    end
  end

  describe "#map" do
    let(:some) { T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer]) }
    let(:none) { T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer]) }

    it "modifies value for Some" do
      expect(some.map { |value| value + 10 }).to eq(Mayak::Monads::Maybe::Some[Integer].new(20))
    end

    it "returns itself for None" do
      expect(none.map { |value| value + 10 }).to eq(Mayak::Monads::Maybe::None[Integer].new)
    end
  end

  describe "#flat_map" do
    let(:some) { T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer]) }
    let(:none) { T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer]) }

    it "returns None if a monad is None" do
      expect(
        none.flat_map { |value| Mayak::Monads::Maybe::Some[Integer].new(value + 10) }
      ).to eq(Mayak::Monads::Maybe::None[Integer].new)

      expect(
        none.flat_map { |_value| Mayak::Monads::Maybe::None[Integer].new }
      ).to eq(Mayak::Monads::Maybe::None[Integer].new)
    end

    it "returns None if a monad is Some and block returns None" do
      expect(
        some.flat_map { |_value| Mayak::Monads::Maybe::None[Integer].new }
      ).to eq(Mayak::Monads::Maybe::None[Integer].new)
    end

    it "returns Some if a monad is Some and block returns Some" do
      expect(
        some.flat_map { |value| Mayak::Monads::Maybe::Some[Integer].new(value + 10) }
      ).to eq(Mayak::Monads::Maybe::Some[Integer].new(20))
    end
  end

  describe "#filter" do
    let(:some) { T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer]) }
    let(:none) { T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer]) }

    it "returns None if a monad is None" do
      expect(none.filter { |value| value > 5 }).to eq(Mayak::Monads::Maybe::None[Integer].new)
    end

    it "returns None if a monad is Some and block returns false" do
      expect(some.filter { |value| value < 5 }).to eq(Mayak::Monads::Maybe::None[Integer].new)
    end

    it "returns self if a monad is Some and block returns true" do
      expect(some.filter { |value| value > 5 }).to eq(some)
    end
  end

  describe "#some?" do
    let(:some) { T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer]) }
    let(:none) { T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer]) }

    it "returns true for Some" do
      expect(some.some?).to be_truthy
    end

    it "returns false for None" do
      expect(none.some?).to be_falsey
    end
  end

  describe "#none?" do
    let(:some) { T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer]) }
    let(:none) { T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer]) }

    it "returns false for Some" do
      expect(some.none?).to be_falsey
    end

    it "returns true for None" do
      expect(none.none?).to be_truthy
    end
  end

  describe "#value_or" do
    let(:some) { T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer]) }
    let(:none) { T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer]) }

    it "retrieves values from Some" do
      expect(some.value_or(0)).to eq(10)
    end

    it "returns provided fallback value for None" do
      expect(none.value_or(0)).to eq(0)
    end
  end

  describe "#tee" do
    let(:some)  { T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer]) }
    let(:none)  { T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer]) }

    it "calls a block and returns itself for Some" do
      buffer = []
      expect(some.tee { |value| buffer << value }).to eq(some)
      expect(buffer).to eq([10])
    end

    it "doesn't call a block and returns itself for None" do
      buffer = []
      expect(none.tee { |value| buffer << value }).to eq(none)
      expect(buffer).to eq([])
    end
  end

  describe "#either" do
    let(:some)  { T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer]) }
    let(:none)  { T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer]) }

    it "calls a block and return result for Some" do
      expect(
        some.either(
          -> { 10 },
          -> (value) { value + 10 }
        )
      ).to eq(20)
    end

    it "returns provided fallback for for None" do
      expect(
        none.either(
          -> { 10 },
          -> (value) { value + 10 }
        )
      ).to eq(10)
    end
  end

  describe "#to_result" do
    let(:some)  { T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer]) }
    let(:none)  { T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer]) }
    let(:error) { StandardError.new("Error") }

    it "returns Success with a value of Some" do
      expect(some.to_result(error)).to eq(Mayak::Monads::Result::Success.new(10))
    end

    it "returns Failure with a provided error for None" do
      expect(none.to_result(error)).to eq(Mayak::Monads::Result::Failure.new(error))
    end
  end

  describe "#to_try" do
    let(:some)  { T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer]) }
    let(:none)  { T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer]) }
    let(:error) { StandardError.new("Error") }

    it "turns Some into Success" do
      expect(some.to_try(error)).to eq(Mayak::Monads::Try::Success.new(10))
    end

    it "turns None into Failure" do
      expect(none.to_try(error)).to eq(Mayak::Monads::Try::Failure.new(error))
    end
  end

  describe "#recover" do
    let(:some) { T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer]) }
    let(:none) { T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer]) }

    it "returns itself if a monad is Some" do
      expect(some.recover(0)).to eq(some)
    end

    it "returns Some with a provided value if a monad is None" do
      expect(none.recover(0)).to eq(Mayak::Monads::Maybe::Some.new(0))
    end
  end

  describe "#recover_with_maybe" do
    let(:some) { T.let(Mayak::Monads::Maybe::Some[Integer].new(10), Mayak::Monads::Maybe[Integer]) }
    let(:none) { T.let(Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe[Integer]) }

    let(:some_recovered) { T.let(Mayak::Monads::Maybe::Some[Integer].new(0), Mayak::Monads::Maybe[Integer]) }

    it "returns itself if a monad is Some" do
      expect(some.recover_with_maybe(some_recovered)).to eq(some)
      expect(some.recover_with_maybe(none)).to eq(some)
    end

    it "returns Some if a monad is None and provided monad is Some" do
      expect(none.recover_with_maybe(some_recovered)).to eq(Mayak::Monads::Maybe::Some.new(0))
    end

    it "returns None if a monad is None and provided monad is Some" do
      expect(none.recover_with_maybe(none)).to eq(none)
    end
  end

  describe ".sequence" do
    it "returns None if some element is None" do
      values1 = [Mayak::Monads::Maybe::None[Integer].new]
      expect(Mayak::Monads::Maybe.sequence(values1)).to eq(Mayak::Monads::Maybe::None[Array[Integer]].new)

      values2 = [Mayak::Monads::Maybe::None[Integer].new, Mayak::Monads::Maybe::Some[Integer].new(1)]
      expect(Mayak::Monads::Maybe.sequence(values2)).to eq(Mayak::Monads::Maybe::None[Array[Integer]].new)
    end

    it "returns Some containing aggregated array of values if all elements are Some" do
      values = [
        Mayak::Monads::Maybe::Some[Integer].new(1),
        Mayak::Monads::Maybe::Some[Integer].new(2),
        Mayak::Monads::Maybe::Some[Integer].new(3)
      ]
      expect(Mayak::Monads::Maybe.sequence(values)).to eq(Mayak::Monads::Maybe::Some[Array[Integer]].new([1, 2, 3]))
    end

    it "returns Some containing empty array if array is empty" do
      expect(Mayak::Monads::Maybe.sequence([])).to eq(Mayak::Monads::Maybe::Some[Array[Integer]].new([]))
    end
  end

  describe ".check" do
    it "returns value wrapped into Some if block returns true" do
      expect(Mayak::Monads::Maybe.check(10) { true }).to eq(Mayak::Monads::Maybe::Some[Integer].new(10))
    end

    it "returns None if block returns false" do
      expect(Mayak::Monads::Maybe.check(10) { false }).to eq(Mayak::Monads::Maybe::None[Integer].new)
    end
  end

  describe ".guard" do
    it "returns Some containing nil if block returns true" do
      expect(Mayak::Monads::Maybe.guard { true }).to eq(Mayak::Monads::Maybe::Some[NilClass].new(nil))
    end

    it "returns None if block returns false" do
      expect(Mayak::Monads::Maybe.guard { false }).to eq(Mayak::Monads::Maybe::None[NilClass].new)
    end
  end

  describe "Mixin" do
    include Mayak::Monads::Maybe::Mixin

    describe "#None" do
      it "returns None" do
        expect(None()).to eq(Mayak::Monads::Maybe::None.new)
      end
    end

    describe "#Maybe" do
      it "returns Some if value is present" do
        expect(Maybe(10)).to eq(Mayak::Monads::Maybe::Some.new(10))
      end

      it "returns None if value is nil" do
        expect(Maybe(nil)).to eq(Mayak::Monads::Maybe::None.new)
      end
    end

    describe "Do-notation" do
      it "automatically wraps last expression into a monad" do
        result = for_maybe {
          10
        }
        expect(result).to eq(Mayak::Monads::Maybe::Some[Integer].new(10))
      end

      it "allows to unpack values" do
        result = for_maybe {
          a = do_maybe! Maybe(10)
          b = do_maybe! Maybe(5)
          a + b
        }
        expect(result).to eq(Mayak::Monads::Maybe::Some[Integer].new(15))
      end

      it "short-circuits execution on None and returns None" do
        buffer = []
        result = for_maybe {
          a = do_maybe! Maybe(10)
          b = do_maybe! None()
          buffer << 1
          a + b
        }
        expect(result).to eq(Mayak::Monads::Maybe::None.new)
        expect(buffer).to eq([])
      end

      describe "#check_maybe!" do
        it "returns value if condition block returns true" do
          result = for_maybe {
            check_maybe!(10) { true }
          }
          expect(result).to eq(Mayak::Monads::Maybe::Some[Integer].new(10))
        end

        it "returns None if block condition block returns false" do
          result = for_maybe {
            check_maybe!(10) { false }
          }
          expect(result).to eq(Mayak::Monads::Maybe::None[Integer].new)
        end

        it "short-circuits execution if condition block returns false" do
          buffer = []
          result = for_maybe {
            check_maybe!(10) { false }
            buffer << 1
            10
          }
          expect(result).to eq(Mayak::Monads::Maybe::None[Integer].new)
          expect(buffer).to eq([])
        end
      end

      describe "#guard_maybe!" do
        it "doesn't do anything if condition block returns true" do
          buffer = []
          result = for_maybe {
            guard_maybe! { true }
            buffer << 1
            10
          }
          expect(result).to eq(Mayak::Monads::Maybe::Some[Integer].new(10))
          expect(buffer).to eq([1])
        end

        it "returns None if block condition block returns false" do
          result = for_maybe {
            guard_maybe! { false }
          }
          expect(result).to eq(Mayak::Monads::Maybe::None[Integer].new)
        end

        it "short-circuits execution if condition block returns false" do
          buffer = []
          result = for_maybe {
            guard_maybe! { false }
            buffer << 1
            10
          }
          expect(result).to eq(Mayak::Monads::Maybe::None[Integer].new)
          expect(buffer).to eq([])
        end
      end
    end
  end
end
