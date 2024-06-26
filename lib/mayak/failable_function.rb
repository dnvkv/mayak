# frozen_string_literal: true
# typed: strict

module Mayak
  class FailableFunction
    extend T::Sig
    extend T::Helpers
    extend T::Generic

    Input  = type_member
    Output = type_member

    sig { params(blk: T.proc.params(input: Input).returns(Mayak::Monads::Try[Output])).void }
    def initialize(&blk)
      @blk = T.let(blk, T.proc.params(input: Input).returns(Mayak::Monads::Try[Output]))
    end

    sig {
      type_parameters(
        :Input,
        :Output
      ).params(
        proc: T.proc.params(
          arg0: T.type_parameter(:Input)
        ).returns(
          ::Mayak::Monads::Try[T.type_parameter(:Output)]
        )
      ).returns(
        ::Mayak::FailableFunction[T.type_parameter(:Input), T.type_parameter(:Output)]
      )
    }
    def self.from_proc(proc)
      ::Mayak::FailableFunction[T.type_parameter(:Input), T.type_parameter(:Output)].new { |input| proc.call(input) }
    end

    sig { params(input: Input).returns(Mayak::Monads::Try[Output]) }
    def call(input)
      @blk.call(input)
    end

    sig { returns(T.proc.params(arg0: Input).returns(Mayak::Monads::Try[Output])) }
    def to_proc
      -> (input) { call(input) }
    end

    sig { returns(Mayak::Function[Input, Mayak::Monads::Try[Output]]) }
    def to_function
      Mayak::Function[Input, Mayak::Monads::Try[Output]].new { |input| call(input) }
    end

    sig {
      type_parameters(:Output2)
        .params(another: Mayak::FailableFunction[Output, T.type_parameter(:Output2)])
        .returns(Mayak::FailableFunction[Input, T.type_parameter(:Output2)])
    }
    def and_then(another)
      Mayak::FailableFunction[Input, T.type_parameter(:Output2)].new do |input|
        @blk.call(input).flat_map { |output| another.call(output) }
      end
    end
    alias >> and_then

    sig {
      type_parameters(:Input2)
        .params(another: Mayak::FailableFunction[T.type_parameter(:Input2), Input])
        .returns(Mayak::FailableFunction[T.type_parameter(:Input2), Output])
    }
    def compose(another)
      Mayak::FailableFunction[T.type_parameter(:Input2), Output].new { |input| another.call(input).flat_map { |new_input| @blk.call(new_input) } }
    end
    alias << compose

    sig {
      type_parameters(
        :Input,
        :Output
      ).params(
        function: Mayak::Function[T.type_parameter(:Input), Mayak::Monads::Try[T.type_parameter(:Output)]]
      ).returns(
        Mayak::FailableFunction[T.type_parameter(:Input), T.type_parameter(:Output)]
      )
    }
    def self.from_function(function)
      Mayak::FailableFunction[T.type_parameter(:Input), T.type_parameter(:Output)].new { |input| function.call(input) }
    end
  end
end