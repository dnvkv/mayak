# frozen_string_literal: true
# typed: strict

require "json"

module Mayak
  class Lazy
    extend T::Sig
    extend T::Generic

    Value = type_member

    sig { params(blk: T.proc.returns(Value)).void }
    def initialize(&blk)
      @thunk = T.let(blk, T.proc.returns(Value))
      @value = T.let(nil, T.nilable(Value))
      @forced = T.let(false, T::Boolean)
    end

    sig { returns(Value) }
    def value
      if @forced
        T.must(@value)
      else
        @forced = true
        @value = @thunk.call
        @value
      end
    end

    sig {
      type_parameters(
        :NewValue
      ).params(
        blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewValue))
      ).returns(
        ::Mayak::Lazy[T.type_parameter(:NewValue)]
      )
    }
    def map(&blk)
      ::Mayak::Lazy.new { blk.call(value) }
    end

    sig {
      type_parameters(
        :NewValue
      ).params(
        blk: T.proc.params(arg0: Value).returns(::Mayak::Lazy[T.type_parameter(:NewValue)])
      ).returns(
        ::Mayak::Lazy[T.type_parameter(:NewValue)]
      )
    }
    def flat_map(&blk)
      ::Mayak::Lazy.new { blk.call(value).value }
    end

    sig {
      type_parameters(
        :AnotherValue,
        :NewValue
      ).params(
        another: ::Mayak::Lazy[T.type_parameter(:AnotherValue)],
        blk:     T.proc.params(arg0: Value, arg1: T.type_parameter(:AnotherValue)).returns(T.type_parameter(:NewValue))
      ).returns(
        ::Mayak::Lazy[T.type_parameter(:NewValue)]
      )
    }
    def combine(another, &blk)
      ::Mayak::Lazy[T.type_parameter(:NewValue)].new do
        blk.call(value, another.value)
      end
    end

    sig {
      type_parameters(
        :Value
      ).params(
        lazies: T::Array[::Mayak::Lazy[T.type_parameter(:Value)]]
      ).returns(
        ::Mayak::Lazy[T::Array[T.type_parameter(:Value)]]
      )
    }
    def self.sequence(lazies)
      ::Mayak::Lazy[T::Array[T.type_parameter(:Value)]].new { lazies.map(&:value) }
    end

    sig {
      type_parameters(
        :FirstValue,
        :SecondValue,
        :ResultValue
      ).params(
        first: ::Mayak::Lazy[T.type_parameter(:FirstValue)],
        second: ::Mayak::Lazy[T.type_parameter(:SecondValue)],
        blk: T.proc.params(
          arg0: T.type_parameter(:FirstValue),
          arg1: T.type_parameter(:SecondValue)
        ).returns(
          T.type_parameter(:ResultValue)
        )
      ).returns(
        ::Mayak::Lazy[T.type_parameter(:ResultValue)]
      )
    }
    def self.combine_two(first, second, &blk)
      ::Mayak::Lazy[T.type_parameter(:ResultValue)].new do
        blk.call(first.value, second.value)
      end
    end

    sig {
      type_parameters(
        :FirstValue,
        :SecondValue,
        :ThirdValue,
        :ResultValue
      ).params(
        first: ::Mayak::Lazy[T.type_parameter(:FirstValue)],
        second: ::Mayak::Lazy[T.type_parameter(:SecondValue)],
        third: ::Mayak::Lazy[T.type_parameter(:ThirdValue)],
        blk: T.proc.params(
          arg0: T.type_parameter(:FirstValue),
          arg1: T.type_parameter(:SecondValue),
          arg2: T.type_parameter(:ThirdValue)
        ).returns(
          T.type_parameter(:ResultValue)
        )
      ).returns(
        ::Mayak::Lazy[T.type_parameter(:ResultValue)]
      )
    }
    def self.combine_three(first, second, third, &blk)
      ::Mayak::Lazy[T.type_parameter(:ResultValue)].new do
        blk.call(first.value, second.value, third.value)
      end
    end

    sig {
      type_parameters(
        :FirstValue,
        :SecondValue,
        :ThirdValue,
        :FourthValue,
        :ResultValue
      ).params(
        first: ::Mayak::Lazy[T.type_parameter(:FirstValue)],
        second: ::Mayak::Lazy[T.type_parameter(:SecondValue)],
        third: ::Mayak::Lazy[T.type_parameter(:ThirdValue)],
        fourth: ::Mayak::Lazy[T.type_parameter(:FourthValue)],
        blk: T.proc.params(
          arg0: T.type_parameter(:FirstValue),
          arg1: T.type_parameter(:SecondValue),
          arg2: T.type_parameter(:ThirdValue),
          arg3: T.type_parameter(:FourthValue)
        ).returns(
          T.type_parameter(:ResultValue)
        )
      ).returns(
        ::Mayak::Lazy[T.type_parameter(:ResultValue)]
      )
    }
    def self.combine_four(first, second, third, fourth, &blk)
      ::Mayak::Lazy[T.type_parameter(:ResultValue)].new do
        blk.call(first.value, second.value, third.value, fourth.value)
      end
    end

    sig {
      type_parameters(
        :FirstValue,
        :SecondValue,
        :ThirdValue,
        :FourthValue,
        :FifthValue,
        :ResultValue
      ).params(
        first: ::Mayak::Lazy[T.type_parameter(:FirstValue)],
        second: ::Mayak::Lazy[T.type_parameter(:SecondValue)],
        third: ::Mayak::Lazy[T.type_parameter(:ThirdValue)],
        fourth: ::Mayak::Lazy[T.type_parameter(:FourthValue)],
        fifth: ::Mayak::Lazy[T.type_parameter(:FifthValue)],
        blk: T.proc.params(
          arg0: T.type_parameter(:FirstValue),
          arg1: T.type_parameter(:SecondValue),
          arg2: T.type_parameter(:ThirdValue),
          arg3: T.type_parameter(:FourthValue),
          arg4: T.type_parameter(:FifthValue)
        ).returns(
          T.type_parameter(:ResultValue)
        )
      ).returns(
        ::Mayak::Lazy[T.type_parameter(:ResultValue)]
      )
    }
    def self.combine_five(first, second, third, fourth, fifth, &blk)
      ::Mayak::Lazy[T.type_parameter(:ResultValue)].new do
        blk.call(first.value, second.value, third.value, fourth.value, fifth.value)
      end
    end

    sig {
      type_parameters(
        :FirstValue,
        :SecondValue,
        :ThirdValue,
        :FourthValue,
        :FifthValue,
        :SixthValue,
        :ResultValue
      ).params(
        first: ::Mayak::Lazy[T.type_parameter(:FirstValue)],
        second: ::Mayak::Lazy[T.type_parameter(:SecondValue)],
        third: ::Mayak::Lazy[T.type_parameter(:ThirdValue)],
        fourth: ::Mayak::Lazy[T.type_parameter(:FourthValue)],
        fifth: ::Mayak::Lazy[T.type_parameter(:FifthValue)],
        sixth: ::Mayak::Lazy[T.type_parameter(:SixthValue)],
        blk: T.proc.params(
          arg0: T.type_parameter(:FirstValue),
          arg1: T.type_parameter(:SecondValue),
          arg2: T.type_parameter(:ThirdValue),
          arg3: T.type_parameter(:FourthValue),
          arg4: T.type_parameter(:FifthValue),
          arg5: T.type_parameter(:SixthValue)
        ).returns(
          T.type_parameter(:ResultValue)
        )
      ).returns(
        ::Mayak::Lazy[T.type_parameter(:ResultValue)]
      )
    }
    def self.combine_six(first, second, third, fourth, fifth, sixth, &blk)
      ::Mayak::Lazy[T.type_parameter(:ResultValue)].new do
        blk.call(first.value, second.value, third.value, fourth.value, fifth.value, sixth.value)
      end
    end

    sig {
      type_parameters(
        :FirstValue,
        :SecondValue,
        :ThirdValue,
        :FourthValue,
        :FifthValue,
        :SixthValue,
        :SeventhValue,
        :ResultValue
      ).params(
        first:   ::Mayak::Lazy[T.type_parameter(:FirstValue)],
        second:  ::Mayak::Lazy[T.type_parameter(:SecondValue)],
        third:   ::Mayak::Lazy[T.type_parameter(:ThirdValue)],
        fourth:  ::Mayak::Lazy[T.type_parameter(:FourthValue)],
        fifth:   ::Mayak::Lazy[T.type_parameter(:FifthValue)],
        sixth:   ::Mayak::Lazy[T.type_parameter(:SixthValue)],
        seventh: ::Mayak::Lazy[T.type_parameter(:SeventhValue)],
        blk: T.proc.params(
          arg0: T.type_parameter(:FirstValue),
          arg1: T.type_parameter(:SecondValue),
          arg2: T.type_parameter(:ThirdValue),
          arg3: T.type_parameter(:FourthValue),
          arg4: T.type_parameter(:FifthValue),
          arg5: T.type_parameter(:SixthValue),
          arg6: T.type_parameter(:SeventhValue),
        ).returns(
          T.type_parameter(:ResultValue)
        )
      ).returns(
        ::Mayak::Lazy[T.type_parameter(:ResultValue)]
      )
    }
    def self.combine_seven(first, second, third, fourth, fifth, sixth, seventh, &blk)
      ::Mayak::Lazy[T.type_parameter(:ResultValue)].new do
        blk.call(first.value, second.value, third.value, fourth.value, fifth.value, sixth.value, seventh.value)
      end
    end

    sig {
      type_parameters(
        :Value,
        :Result
      ).params(
        lazies:  T::Array[::Mayak::Lazy[T.type_parameter(:Value)]],
        initial: T.type_parameter(:Result),
        blk: T.proc.params(arg0: T.type_parameter(:Result), arg1: T.type_parameter(:Value)).returns(T.type_parameter(:Result))
      ).returns(
        ::Mayak::Lazy[T.type_parameter(:Result)]
      )
    }
    def self.combine_many(lazies, initial, &blk)
      ::Mayak::Lazy[T.type_parameter(:Result)].new do
        lazies.reduce(initial) { |acc, element| blk.call(acc, element.value) }
      end
    end

    sig {
      type_parameters(
        :Value
      ).params(
        lazies:  T::Array[::Mayak::Lazy[T.type_parameter(:Value)]]
      ).returns(
        ::Mayak::Lazy[T::Array[T.type_parameter(:Value)]]
      )
    }
    def self.sequence(lazies)
      combine_many(lazies, []) { |acc, element| acc.concat([element]) }
    end
  end
end