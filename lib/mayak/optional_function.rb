# frozen_string_literal: true
# typed: strict

module Mayak
  class OptionalFunction
    extend T::Sig
    extend T::Helpers
    extend T::Generic

    Input  = type_member
    Output = type_member

    sig { params(blk: T.proc.params(input: Input).returns(Mayak::Monads::Maybe[Output])).void }
    def initialize(&blk)
      @blk = T.let(blk, T.proc.params(input: Input).returns(Mayak::Monads::Maybe[Output]))
    end

    sig { params(input: Input).returns(Mayak::Monads::Maybe[Output]) }
    def call(input)
      @blk.call(input)
    end

    sig { returns(T.proc.params(arg0: Input).returns(Mayak::Monads::Maybe[Output])) }
    def to_proc
      -> (input) { call(input) }
    end

    sig { returns(Mayak::Function[Input, Mayak::Monads::Maybe[Output]]) }
    def to_function
      Mayak::Function[Input, Mayak::Monads::Maybe[Output]].new { |input| call(input) }
    end

    sig {
      type_parameters(:Output2)
        .params(another: Mayak::OptionalFunction[Output, T.type_parameter(:Output2)])
        .returns(Mayak::OptionalFunction[Input, T.type_parameter(:Output2)])
    }
    def and_then(another)
      Mayak::OptionalFunction[Input, T.type_parameter(:Output2)].new do |input|
        @blk.call(input).flat_map { |output| another.call(output) }
      end
    end
    alias >> and_then

    sig {
      type_parameters(:Input2)
        .params(another: Mayak::OptionalFunction[T.type_parameter(:Input2), Input])
        .returns(Mayak::OptionalFunction[T.type_parameter(:Input2), Output])
    }
    def compose(another)
      Mayak::OptionalFunction[T.type_parameter(:Input2), Output].new { |input| another.call(input).flat_map { |new_input| @blk.call(new_input) } }
    end
    alias << compose

    sig {
      type_parameters(
        :Input,
        :Output
      ).params(
        function: Mayak::Function[T.type_parameter(:Input), Mayak::Monads::Maybe[T.type_parameter(:Output)]]
      ).returns(
        Mayak::OptionalFunction[T.type_parameter(:Input), T.type_parameter(:Output)]
      )
    }
    def self.from_function(function)
      Mayak::OptionalFunction[T.type_parameter(:Input), T.type_parameter(:Output)].new { |input| function.call(input) }
    end
  end
end