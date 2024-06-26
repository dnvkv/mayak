# frozen_string_literal: true
# typed: strict

module Mayak
  module Monads
    module Maybe
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      abstract!
      sealed!

      Value = type_member(:out)

      sig {
        abstract
          .type_parameters(:NewValue)
          .params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewValue)))
          .returns(Maybe[T.type_parameter(:NewValue)])
      }
      def map(&blk)
      end

      sig {
        abstract
          .type_parameters(:NewValue)
          .params(
            blk: T.proc.params(arg0: Value).returns(Maybe[T.type_parameter(:NewValue)])
          )
          .returns(Maybe[T.type_parameter(:NewValue)])
      }
      def flat_map(&blk)
      end

      sig {
        abstract
          .params(blk: T.proc.params(arg0: Value).returns(T::Boolean))
          .returns(Maybe[Value])
      }
      def filter(&blk)
      end

      sig { abstract.returns(T::Boolean) }
      def some?
      end

      sig { abstract.returns(T::Boolean) }
      def none?
      end

      sig {
        abstract
          .type_parameters(:AnotherValue)
          .params(value: T.type_parameter(:AnotherValue))
          .returns(T.any(T.type_parameter(:AnotherValue), Value))
      }
      def value_or(value)
      end

      sig {
        abstract
          .params(blk: T.proc.params(arg0: Value).void)
          .returns(Maybe[Value])
      }
      def tee(&blk)
      end

      sig {
        abstract
          .type_parameters(:Result)
          .params(
            none_branch: T.proc.returns(T.type_parameter(:Result)),
            some_branch: T.proc.params(arg0: Value).returns(T.type_parameter(:Result))
          ).returns(T.type_parameter(:Result))
      }
      def either(none_branch, some_branch)
      end

      sig {
        abstract
          .type_parameters(:Failure)
          .params(failure: T.type_parameter(:Failure))
          .returns(Mayak::Monads::Result[T.type_parameter(:Failure), Value])
      }
      def to_result(failure)
      end

      sig { abstract.params(error: StandardError).returns(Mayak::Monads::Try[Value]) }
      def to_try(error)
      end

      sig(:final) {
        type_parameters(:NewValue)
          .params(new_value: T.type_parameter(:NewValue))
          .returns(Maybe[T.type_parameter(:NewValue)])
      }
      def as(new_value)
        map { |_| new_value }
      end

      sig {
        type_parameters(:NewValue)
          .abstract
          .params(value: T.type_parameter(:NewValue))
          .returns(Maybe[T.any(T.type_parameter(:NewValue), Value)])
      }
      def recover(value)
      end

      sig {
        type_parameters(:NewValue)
          .abstract
          .params(maybe: Maybe[T.type_parameter(:NewValue)])
          .returns(Maybe[T.any(T.type_parameter(:NewValue), Value)])
      }
      def recover_with_maybe(maybe)
      end

      sig(:final) { params(another: Mayak::Monads::Maybe[T.untyped]).returns(T::Boolean) }
      def ==(another)
        case self
        when Mayak::Monads::Maybe::Some
          case another
          when Mayak::Monads::Maybe::Some then T.unsafe(self.value) == another.value
          when Mayak::Monads::Maybe::None then false
          else T.absurd(another)
          end
        when Mayak::Monads::Maybe::None
          case another
          when Mayak::Monads::Maybe::Some then false
          when Mayak::Monads::Maybe::None then true
          else T.absurd(another)
          end
        else
          T.absurd(self)
        end
      end

      sig {
        type_parameters(:Value)
          .params(results: T::Array[Mayak::Monads::Maybe[T.type_parameter(:Value)]])
          .returns(Mayak::Monads::Maybe[T::Array[T.type_parameter(:Value)]])
      }
      def self.sequence(results)
        init = T.let(Maybe::Some.new([]), Maybe[T::Array[T.type_parameter(:Value)]])
        results.reduce(init) do |result, element|
          result.flat_map do |array|
            element.map { |value| array + [value] }
          end
        end
      end

      sig {
        type_parameters(:Value)
          .params(value: T.type_parameter(:Value), blk: T.proc.returns(T::Boolean))
          .returns(Mayak::Monads::Maybe[T.type_parameter(:Value)])
      }
      def self.check(value, &blk)
        if blk.call
          Mayak::Monads::Maybe::Some[T.type_parameter(:Value)].new(value)
        else
          Mayak::Monads::Maybe::None[T.type_parameter(:Value)].new
        end
      end

      sig { params(blk: T.proc.returns(T::Boolean)).returns(Mayak::Monads::Maybe[NilClass]) }
      def self.guard(&blk)
        check(nil, &blk)
      end

      class Some
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        final!

        Value = type_member

        include ::Mayak::Monads::Maybe

        sig(:final) { params(value: Value).void }
        def initialize(value)
          @value = T.let(value, Value)
        end

        sig(:final) {
          override
            .type_parameters(:NewValue)
            .params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewValue)))
            .returns(Maybe[T.type_parameter(:NewValue)])
        }
        def map(&blk)
          Mayak::Monads::Maybe::Some.new(blk.call(@value))
        end

        sig(:final) {
          override
            .type_parameters(:NewValue)
            .params(blk: T.proc.params(arg0: Value).returns(Maybe[T.type_parameter(:NewValue)]))
            .returns(Maybe[T.type_parameter(:NewValue)])
        }
        def flat_map(&blk)
          blk.call(@value)
        end

        sig(:final) {
          override
            .params(blk: T.proc.params(arg0: Value).returns(T::Boolean))
            .returns(Maybe[Value])
        }
        def filter(&blk)
          if blk.call(@value)
            self
          else
            Mayak::Monads::Maybe::None[Value].new
          end
        end

        sig(:final) { returns(Value) }
        def value
          @value
        end

        sig(:final) { override.returns(T::Boolean) }
        def some?
          true
        end

        sig(:final) { override.returns(T::Boolean) }
        def none?
          false
        end

        sig(:final) {
          override
            .type_parameters(:AnotherValue)
            .params(value: T.any(T.type_parameter(:AnotherValue), Value))
            .returns(T.any(T.type_parameter(:AnotherValue), Value))
        }
        def value_or(value)
          @value
        end

        sig(:final) {
          override
            .params(blk: T.proc.params(arg0: Value).void)
            .returns(Maybe[Value])
        }
        def tee(&blk)
          blk.call(@value)
          self
        end

        sig(:final) {
          override
            .type_parameters(:Result)
            .params(
              none_branch: T.proc.returns(T.type_parameter(:Result)),
              some_branch: T.proc.params(arg0: Value).returns(T.type_parameter(:Result))
            ).returns(T.type_parameter(:Result))
        }
        def either(none_branch, some_branch)
          some_branch.call(@value)
        end

        sig(:final) {
          override
            .type_parameters(:Failure)
            .params(failure: T.type_parameter(:Failure))
            .returns(Mayak::Monads::Result[T.type_parameter(:Failure), Value])
        }
        def to_result(failure)
          Mayak::Monads::Result::Success[T.type_parameter(:Failure), Value].new(@value)
        end

        sig(:final) { override.params(error: StandardError).returns(Mayak::Monads::Try[Value]) }
        def to_try(error)
          Mayak::Monads::Try::Success.new(@value)
        end

        sig(:final) {
          type_parameters(:NewValue)
            .override
            .params(value: T.type_parameter(:NewValue))
            .returns(Maybe[T.any(Value, T.type_parameter(:NewValue))])
        }
        def recover(value)
          self
        end

        sig(:final) {
          type_parameters(:NewValue)
            .override
            .params(maybe: Maybe[T.type_parameter(:NewValue)])
            .returns(Maybe[T.any(Value, T.type_parameter(:NewValue))])
        }
        def recover_with_maybe(maybe)
          self
        end
      end

      class None
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        final!

        Value = type_member

        include Mayak::Monads::Maybe

        sig(:final) {
          override
            .type_parameters(:NewValue)
            .params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewValue)))
            .returns(Maybe[T.type_parameter(:NewValue)])
        }
        def map(&blk)
          T.cast(
            self,
            Maybe[T.type_parameter(:NewValue)]
          )
        end

        sig(:final) {
          override
            .type_parameters(:NewValue)
            .params(blk: T.proc.params(arg0: Value).returns(Maybe[T.type_parameter(:NewValue)]))
            .returns(Maybe[T.type_parameter(:NewValue)])
        }
        def flat_map(&blk)
          T.cast(
            self,
            Maybe[T.type_parameter(:NewValue)]
          )
        end

        sig(:final) {
          override
            .params(blk: T.proc.params(arg0: Value).returns(T::Boolean))
            .returns(Maybe[Value])
        }
        def filter(&blk)
          self
        end

        sig(:final) { override.returns(T::Boolean) }
        def some?
          false
        end

        sig(:final) { override.returns(T::Boolean) }
        def none?
          true
        end

        sig(:final) {
          override
            .type_parameters(:AnotherValue)
            .params(value: T.any(T.type_parameter(:AnotherValue), Value))
            .returns(T.any(T.type_parameter(:AnotherValue), Value))
        }
        def value_or(value)
          value
        end

        sig(:final) {
          override
            .params(blk: T.proc.params(arg0: Value).void)
            .returns(Maybe[Value])
        }
        def tee(&blk)
          self
        end

        sig(:final) {
          override
            .type_parameters(:Result)
            .params(
              none_branch: T.proc.returns(T.type_parameter(:Result)),
              some_branch: T.proc.params(arg0: Value).returns(T.type_parameter(:Result))
            ).returns(T.type_parameter(:Result))
        }
        def either(none_branch, some_branch)
          none_branch.call
        end

        sig(:final) {
          override
            .type_parameters(:Failure)
            .params(failure: T.type_parameter(:Failure))
            .returns(Mayak::Monads::Result[T.type_parameter(:Failure), Value])
        }
        def to_result(failure)
          Mayak::Monads::Result::Failure[T.type_parameter(:Failure), Value].new(failure)
        end

        sig(:final) { override.params(error: StandardError).returns(Mayak::Monads::Try[Value]) }
        def to_try(error)
          Mayak::Monads::Try::Failure.new(error)
        end

        sig(:final) {
          type_parameters(:NewValue)
            .override
            .params(value: T.type_parameter(:NewValue))
            .returns(Maybe[T.any(Value, T.type_parameter(:NewValue))])
        }
        def recover(value)
          Mayak::Monads::Maybe::Some.new(value)
        end

        sig(:final) {
          type_parameters(:NewValue)
            .override
            .params(maybe: Maybe[T.type_parameter(:NewValue)])
            .returns(Maybe[T.any(Value, T.type_parameter(:NewValue))])
        }
        def recover_with_maybe(maybe)
          maybe
        end
      end

      module Mixin
        extend T::Sig

        include Kernel

        sig {
          type_parameters(:Value)
            .params(value: T.nilable(T.type_parameter(:Value)))
            .returns(Maybe[T.type_parameter(:Value)])
        }
        def Maybe(value)
          case value
          when nil
            Mayak::Monads::Maybe::None[T.type_parameter(:Value)].new
          else
            Mayak::Monads::Maybe::Some[T.type_parameter(:Value)].new(value)
          end
        end

        sig { returns(Maybe[T.untyped]) }
        def None
          Mayak::Monads::Maybe::None.new
        end

        sig {
          type_parameters(:Value)
            .params(blk: T.proc.returns(T.type_parameter(:Value)))
            .returns(Maybe[T.type_parameter(:Value)])
        }
        def for_maybe(&blk)
          result = blk.call
          Mayak::Monads::Maybe::Some[T.type_parameter(:Value)].new(result)
        rescue Halt => e
          e.result
        end

        sig {
          type_parameters(:Value)
            .params(value: Maybe[T.type_parameter(:Value)])
            .returns(T.type_parameter(:Value))
        }
        def do_maybe!(value)
          case value
          when Mayak::Monads::Maybe::Some
            value.value
          when Mayak::Monads::Maybe::None
            raise Halt[T.type_parameter(:Value)].new(value)
          else
            T.absurd(value)
          end
        end

        sig {
          type_parameters(:Value)
            .params(value: T.type_parameter(:Value), blk: T.proc.returns(T::Boolean))
            .returns(T.type_parameter(:Value))
        }
        def check_maybe!(value, &blk)
          do_maybe!(Mayak::Monads::Maybe.check(value, &blk))
        end

        sig { params(blk: T.proc.returns(T::Boolean)).void }
        def guard_maybe!(&blk)
          do_maybe!(Mayak::Monads::Maybe.guard(&blk))
        end

        class Halt < StandardError
          extend T::Sig
          extend T::Generic
          extend T::Helpers

          SuccessType = type_member

          sig { returns(Mayak::Monads::Maybe[SuccessType]) }
          attr_reader :result

          sig { params(result: Mayak::Monads::Maybe[SuccessType]).void }
          def initialize(result)
            super()

            @result = T.let(result, Mayak::Monads::Maybe[SuccessType])
          end
        end
        private_constant :Halt
      end
    end
  end
end
