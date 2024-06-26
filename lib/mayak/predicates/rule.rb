# frozen_string_literal: true
# typed: strict

module Mayak
  module Predicates
    class Rule
      extend T::Sig
      extend T::Helpers
      extend T::Generic

      A = type_member

      sig { returns(T.proc.params(arg0: A).returns(T::Boolean)) }
      attr_reader :fn

      sig { params(blk: T.proc.params(arg0: A).returns(T::Boolean)).void }
      def initialize(&blk)
        @fn = T.let(blk, T.proc.params(arg0: A).returns(T::Boolean))
      end

      sig { params(object: A).returns(T::Boolean) }
      def call(object)
        fn.call(object)
      end

      sig { params(another: Mayak::Predicates::Rule[A]).returns(Mayak::Predicates::Rule[A]) }
      def both(another)
        Mayak::Predicates::Rule[A].new do |object|
          fn.call(object) && another.call(object)
        end
      end
      alias & both

      sig { params(another: Mayak::Predicates::Rule[A]).returns(Mayak::Predicates::Rule[A]) }
      def any(another)
        Mayak::Predicates::Rule[A].new do |object|
          fn.call(object) || another.call(object)
        end
      end
      alias | any

      sig { returns(Mayak::Predicates::Rule[A]) }
      def negate
        Mayak::Predicates::Rule[A].new do |object|
          !fn.call(object)
        end
      end
      alias ! negate

      sig {
        type_parameters(:B)
          .params(function: Mayak::Function[T.type_parameter(:B), A])
          .returns(Mayak::Predicates::Rule[T.type_parameter(:B)])
      }
      def from(function)
        Mayak::Predicates::Rule.new do |object|
          fn.call(function.call(object))
        end
      end

      sig { returns(Mayak::Predicates::Rule[T.nilable(A)]) }
      def presence
        Mayak::Predicates::Rule[T.nilable(A)].new do |object|
          case object
          when nil
            false
          else
            fn.call(object)
          end
        end
      end
    end
  end
end
