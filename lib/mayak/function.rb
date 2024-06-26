# frozen_string_literal: true
# typed: strict

module Mayak
  class Function
    extend T::Sig
    extend T::Helpers
    extend T::Generic

    Input  = type_member
    Output = type_member

    sig { returns(T.proc.params(input: Input).returns(Output)) }
    attr_reader :blk

    sig { params(blk: T.proc.params(input: Input).returns(Output)).void }
    def initialize(&blk)
      @blk = T.let(blk, T.proc.params(input: Input).returns(Output))
    end

    sig {
      type_parameters(
        :Input,
        :Output
      ).params(
        proc: T.proc.params(arg0: T.type_parameter(:Input)).returns(T.type_parameter(:Output))
      ).returns(
        ::Mayak::Function[T.type_parameter(:Input), T.type_parameter(:Output)]
      )
    }
    def self.from_proc(proc)
      ::Mayak::Function[T.type_parameter(:Input), T.type_parameter(:Output)].new { |input| proc.call(input) }
    end

    sig { params(input: Input).returns(Output) }
    def call(input)
      blk.call(input)
    end

    sig {
      type_parameters(:Output2)
        .params(another: Mayak::Function[Output, T.type_parameter(:Output2)])
        .returns(Mayak::Function[Input, T.type_parameter(:Output2)])
    }
    def and_then(another)
      Mayak::Function[Input, T.type_parameter(:Output2)].new { |a| another.call(blk.call(a)) }
    end
    alias >> and_then

    sig {
      type_parameters(:Input2)
        .params(another: Mayak::Function[T.type_parameter(:Input2), Input])
        .returns(Mayak::Function[T.type_parameter(:Input2), Output])
    }
    def compose(another)
      Mayak::Function[T.type_parameter(:Input2), Output].new { |a| blk.call(another.call(a)) }
    end
    alias << compose
  end
end
