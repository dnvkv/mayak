# frozen_string_literal: true
# typed: strict

module Mayak
  module Monads
    module Try
      extend T::Sig
      extend T::Generic

      abstract!
      sealed!

      Value = type_member(:out)

      sig {
        abstract
          .type_parameters(:NewValue)
          .params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewValue)))
          .returns(Try[T.type_parameter(:NewValue)])
      }
      def map(&blk)
      end

      sig {
        abstract
          .type_parameters(:NewValue)
          .params(
            blk: T.proc.params(arg0: Value).returns(Try[T.type_parameter(:NewValue)])
          )
          .returns(Try[T.type_parameter(:NewValue)])
      }
      def flat_map(&blk)
      end

      sig {
        abstract
          .params(error: StandardError, blk: T.proc.params(arg0: Value).returns(T::Boolean))
          .returns(Try[Value])
      }
      def filter_or(error, &blk)
      end

      sig { abstract.returns(T::Boolean) }
      def success?
      end

      sig { abstract.returns(T::Boolean) }
      def failure?
      end

      sig {
        abstract
          .type_parameters(:NewValue)
          .params(value: T.type_parameter(:NewValue))
          .returns(T.any(T.type_parameter(:NewValue), Value))
      }
      def success_or(value)
      end

      sig { abstract.params(value: StandardError).returns(StandardError) }
      def failure_or(value)
      end

      sig {
        abstract
          .type_parameters(:Result)
          .params(
            failure_branch: T.proc.params(arg0: StandardError).returns(T.type_parameter(:Result)),
            success_branch: T.proc.params(arg0: Value).returns(T.type_parameter(:Result))
          ).returns(
            T.type_parameter(:Result)
          )
      }
      def either(failure_branch, success_branch)
      end

      sig {
        abstract
          .params(blk: T.proc.params(arg0: Value).void)
          .returns(Try[Value])
      }
      def tee(&blk)
      end

      sig {
        abstract
          .params(blk: T.proc.params(arg0: StandardError).returns(StandardError))
          .returns(Try[Value])
      }
      def map_failure(&blk)
      end

      sig {
        type_parameters(:NewValue)
          .abstract
          .params(blk: T.proc.params(arg0: StandardError).returns(Try[T.type_parameter(:NewValue)]))
          .returns(Try[T.any(T.type_parameter(:NewValue), Value)])
      }
      def flat_map_failure(&blk)
      end

      sig {
        abstract
          .type_parameters(:Failure)
          .params(blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:Failure)))
          .returns(Mayak::Monads::Result[T.type_parameter(:Failure), Value])
      }
      def to_result(&blk)
      end

      sig { abstract.returns(Mayak::Monads::Maybe[Value]) }
      def to_maybe
      end

      sig(:final) { params(other: Mayak::Monads::Try[T.untyped]).returns(T::Boolean) }
      def ==(other)
        case self
        when Mayak::Monads::Try::Success
          case other
          when Mayak::Monads::Try::Success then T.unsafe(success) == other.success
          when Mayak::Monads::Try::Failure then false
          else T.absurd(other)
          end
        when Mayak::Monads::Try::Failure
          case other
          when Mayak::Monads::Try::Success then false
          when Mayak::Monads::Try::Failure then T.unsafe(failure) == other.failure
          else T.absurd(other)
          end
        else
          T.absurd(self)
        end
      end

      sig(:final) {
        type_parameters(:NewValue)
          .params(new_value: T.type_parameter(:NewValue))
          .returns(Try[T.type_parameter(:NewValue)])
      }
      def as(new_value)
        map { |_| new_value }
      end

      sig(:final) { params(new_failure: StandardError).returns(Try[Value]) }
      def failure_as(new_failure)
        map_failure { |_| new_failure }
      end

      sig {
        type_parameters(:NewValue)
          .abstract
          .params(value: T.type_parameter(:NewValue))
          .returns(Try[T.any(T.type_parameter(:NewValue), Value)])
      }
      def recover(value)
      end

      sig {
        type_parameters(:NewValue)
          .abstract
          .params(blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:NewValue)))
          .returns(Try[T.any(T.type_parameter(:NewValue), Value)])
      }
      def recover_with(&blk)
      end

      sig {
        type_parameters(:NewValue)
          .abstract
          .params(
            error_type: T.class_of(StandardError),
            blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:NewValue))
          )
          .returns(Try[T.any(T.type_parameter(:NewValue), Value)])
      }
      def recover_on(error_type, &blk)
      end

      sig(:final) {
        type_parameters(:NewValue)
          .params(blk: T.proc.params(arg0: StandardError).returns(Try[T.type_parameter(:NewValue)]))
          .returns(Try[T.any(T.type_parameter(:NewValue), Value)])
      }
      def recover_with_try(&blk)
        flat_map_failure(&blk)
      end

      sig {
        type_parameters(:Value)
          .params(results: T::Array[Mayak::Monads::Try[T.type_parameter(:Value)]])
          .returns(Mayak::Monads::Try[T::Array[T.type_parameter(:Value)]])
      }
      def self.sequence(results)
        init = T.let(Try::Success.new([]), Try[T::Array[T.type_parameter(:Value)]])
        results.reduce(init) do |result, element|
          result.flat_map do |array|
            element.map { |value| array + [value] }
          end
        end
      end

      sig {
        type_parameters(:Value)
          .params(
            value: T.type_parameter(:Value),
            error: StandardError,
            blk:   T.proc.returns(T::Boolean)
          ).returns(Mayak::Monads::Try[T.type_parameter(:Value)])
      }
      def self.check(value, error, &blk)
        if blk.call
          Mayak::Monads::Try::Success[T.type_parameter(:Value)].new(value)
        else
          Mayak::Monads::Try::Failure[T.type_parameter(:Value)].new(error)
        end
      end

      sig { params(error: StandardError, blk: T.proc.returns(T::Boolean)).returns(Mayak::Monads::Try[NilClass]) }
      def self.guard(error, &blk)
        check(nil, error, &blk)
      end

      class Success
        extend T::Sig
        extend T::Generic

        Value = type_member

        include Mayak::Monads::Try

        sig(:final) { params(value: Value).void }
        def initialize(value)
          @value = T.let(value, Value)
        end

        sig(:final) {
          override
            .type_parameters(:NewValue)
            .params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewValue)))
            .returns(Try[T.type_parameter(:NewValue)])
        }
        def map(&blk)
          Mayak::Monads::Try::Success.new(blk.call(@value))
        end

        sig(:final) {
          override
            .type_parameters(:NewValue)
            .params(blk: T.proc.params(arg0: Value).returns(Try[T.type_parameter(:NewValue)]))
            .returns(Try[T.type_parameter(:NewValue)])
        }
        def flat_map(&blk)
          blk.call(@value)
        end

        sig(:final) {
          override
            .params(error: StandardError, blk: T.proc.params(arg0: Value).returns(T::Boolean))
            .returns(Try[Value])
        }
        def filter_or(error, &blk)
          if blk.call(@value)
            self
          else
            Mayak::Monads::Try::Failure[Value].new(error)
          end
        end

        sig(:final) { returns(Value) }
        def success
          @value
        end

        sig(:final) { override.returns(T::Boolean) }
        def success?
          true
        end

        sig(:final) { override.returns(T::Boolean) }
        def failure?
          false
        end

        sig(:final) {
          override
            .type_parameters(:NewValue)
            .params(value: T.any(T.type_parameter(:NewValue), Value))
            .returns(T.any(T.type_parameter(:NewValue), Value))
        }
        def success_or(value)
          @value
        end

        sig(:final) { override.params(value: StandardError).returns(StandardError) }
        def failure_or(value)
          value
        end

        sig(:final) {
          override
            .type_parameters(:Result)
            .params(
              failure_branch: T.proc.params(arg0: StandardError).returns(T.type_parameter(:Result)),
              success_branch: T.proc.params(arg0: Value).returns(T.type_parameter(:Result))
            ).returns(
              T.type_parameter(:Result)
            )
        }
        def either(failure_branch, success_branch)
          success_branch.call(@value)
        end

        sig(:final) {
          override
            .params(blk: T.proc.params(arg0: Value).void)
            .returns(Try[Value])
        }
        def tee(&blk)
          blk.call(@value)
          self
        end

        sig(:final) {
          override
            .params(blk: T.proc.params(arg0: StandardError).returns(StandardError))
            .returns(Try[Value])
        }
        def map_failure(&blk)
          self
        end

        sig(:final) {
          type_parameters(:NewValue)
            .override
            .params(blk: T.proc.params(arg0: StandardError).returns(Try[T.type_parameter(:NewValue)]))
            .returns(Try[T.any(T.type_parameter(:NewValue), Value)])
        }
        def flat_map_failure(&blk)
          self
        end

        sig(:final) {
          override
            .type_parameters(:Failure)
            .params(blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:Failure)))
            .returns(Mayak::Monads::Result[T.type_parameter(:Failure), Value])
        }
        def to_result(&blk)
          Mayak::Monads::Result::Success.new(@value)
        end

        sig(:final) { override.returns(Mayak::Monads::Maybe[Value]) }
        def to_maybe
          Mayak::Monads::Maybe::Some.new(@value)
        end

        sig(:final) {
          type_parameters(:NewValue)
            .override
            .params(
              error_type: T.class_of(StandardError),
              blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:NewValue))
            )
            .returns(Try[T.any(T.type_parameter(:NewValue), Value)])
        }
        def recover_on(error_type, &blk)
          self
        end

        sig(:final) {
          type_parameters(:NewValue)
            .override
            .params(value: T.type_parameter(:NewValue))
            .returns(Try[T.any(T.type_parameter(:NewValue), Value)])
        }
        def recover(value)
          self
        end

        sig(:final) {
          type_parameters(:NewValue)
            .override
            .params(blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:NewValue)))
            .returns(Try[T.any(T.type_parameter(:NewValue), Value)])
        }
        def recover_with(&blk)
          self
        end
      end

      class Failure
        extend T::Sig
        extend T::Generic

        Value = type_member

        include Mayak::Monads::Try

        sig(:final) { params(value: StandardError).void }
        def initialize(value)
          @failure = T.let(value, StandardError)
        end

        sig(:final) {
          override
            .type_parameters(:NewValue)
            .params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewValue)))
            .returns(Try[T.type_parameter(:NewValue)])
        }
        def map(&blk)
          T.cast(
            self,
            Try[T.type_parameter(:NewValue)]
          )
        end

        sig(:final) {
          override
            .type_parameters(:NewValue)
            .params(blk: T.proc.params(arg0: Value).returns(Try[T.type_parameter(:NewValue)]))
            .returns(Try[T.type_parameter(:NewValue)])
        }
        def flat_map(&blk)
          T.cast(
            self,
            Try[T.type_parameter(:NewValue)]
          )
        end

        sig(:final) {
          override
            .params(error: StandardError, blk: T.proc.params(arg0: Value).returns(T::Boolean))
            .returns(Try[Value])
        }
        def filter_or(error, &blk)
          self
        end

        sig(:final) { returns(StandardError) }
        def failure
          @failure
        end

        sig(:final) { override.returns(T::Boolean) }
        def success?
          false
        end

        sig(:final) { override.returns(T::Boolean) }
        def failure?
          true
        end

        sig(:final) {
          override
            .type_parameters(:NewValue)
            .params(value: T.any(T.type_parameter(:NewValue), Value))
            .returns(T.any(T.type_parameter(:NewValue), Value))
        }
        def success_or(value)
          value
        end

        sig(:final) { override.params(value: StandardError).returns(StandardError) }
        def failure_or(value)
          @failure
        end

        sig(:final) {
          override
            .type_parameters(:Result)
            .params(
              failure_branch: T.proc.params(arg0: StandardError).returns(T.type_parameter(:Result)),
              success_branch: T.proc.params(arg0: Value).returns(T.type_parameter(:Result))
            ).returns(
              T.type_parameter(:Result)
            )
        }
        def either(failure_branch, success_branch)
          failure_branch.call(@failure)
        end

        sig(:final) {
          override
            .params(blk: T.proc.params(arg0: Value).void)
            .returns(Try[Value])
        }
        def tee(&blk)
          self
        end

        sig(:final) {
          override
            .params(blk: T.proc.params(arg0: StandardError).returns(StandardError))
            .returns(Try[Value])
        }
        def map_failure(&blk)
          Mayak::Monads::Try::Failure[Value].new(blk.call(@failure))
        end

        sig(:final) {
          type_parameters(:NewValue)
            .override
            .params(blk: T.proc.params(arg0: StandardError).returns(Try[T.type_parameter(:NewValue)]))
            .returns(Try[T.any(T.type_parameter(:NewValue), Value)])
        }
        def flat_map_failure(&blk)
          blk.call(@failure)
        end

        sig(:final) {
          override
            .type_parameters(:Failure)
            .params(blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:Failure)))
            .returns(Mayak::Monads::Result[T.type_parameter(:Failure), Value])
        }
        def to_result(&blk)
          Mayak::Monads::Result::Failure.new(blk.call(@failure))
        end

        sig(:final) { override.returns(Mayak::Monads::Maybe[Value]) }
        def to_maybe
          ::Mayak::Monads::Maybe::None[Value].new
        end

        sig(:final) {
          type_parameters(:NewValue)
            .override
            .params(
              error_type: T.class_of(StandardError),
              blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:NewValue))
            )
            .returns(Try[T.any(T.type_parameter(:NewValue), Value)])
        }
        def recover_on(error_type, &blk)
          if @failure.is_a?(error_type)
            ::Mayak::Monads::Try::Success[T.any(T.type_parameter(:NewValue), Value)].new(blk.call(@failure))
          else
            self
          end
        end

        sig(:final) {
          type_parameters(:NewValue)
            .override
            .params(value: T.type_parameter(:NewValue))
            .returns(Try[T.any(T.type_parameter(:NewValue), Value)])
        }
        def recover(value)
          ::Mayak::Monads::Try::Success[T.any(T.type_parameter(:NewValue), Value)].new(value)
        end

        sig(:final) {
          type_parameters(:NewValue)
            .override
            .params(blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:NewValue)))
            .returns(Try[T.any(T.type_parameter(:NewValue), Value)])
        }
        def recover_with(&blk)
          ::Mayak::Monads::Try::Success[T.any(T.type_parameter(:NewValue), Value)].new(blk.call(@failure))
        end
      end

      module Mixin
        extend T::Sig

        include Kernel

        sig {
          type_parameters(:Value)
            .params(
              exception_classes: T.class_of(StandardError),
              blk: T.proc.returns(T.type_parameter(:Value))
            )
            .returns(Try[T.type_parameter(:Value)])
        }
        def Try(*exception_classes, &blk)
          exception_classes = [StandardError] if exception_classes.empty?
          begin
            Mayak::Monads::Try::Success[T.type_parameter(:Value)].new(blk.call)
          rescue *exception_classes => e
            Mayak::Monads::Try::Failure[T.type_parameter(:Value)].new(T.unsafe(e))
          end
        end

        sig {
          type_parameters(:Value)
            .params(blk: T.proc.returns(T.type_parameter(:Value)))
            .returns(Try[T.type_parameter(:Value)])
        }
        def for_try(&blk)
          result = blk.call
          Mayak::Monads::Try::Success[T.type_parameter(:Value)].new(result)
        rescue Halt => e
          e.result
        end

        sig {
          type_parameters(:Value)
            .params(value: Try[T.type_parameter(:Value)])
            .returns(T.type_parameter(:Value))
        }
        def do_try!(value)
          case value
          when Mayak::Monads::Try::Success
            value.success
          when Mayak::Monads::Try::Failure
            raise Halt[T.type_parameter(:Value)].new(value)
          else
            T.absurd(value)
          end
        end

        sig {
          type_parameters(:Value)
            .params(
              value: T.type_parameter(:Value),
              error: StandardError,
              blk: T.proc.returns(T::Boolean)
            ).returns(T.type_parameter(:Value))
        }
        def check_try!(value, error, &blk)
          do_try!(Mayak::Monads::Try.check(value, error, &blk))
        end

        sig { params(error: StandardError, blk: T.proc.returns(T::Boolean)).void }
        def guard_try!(error, &blk)
          do_try!(Mayak::Monads::Try.guard(error, &blk))
        end

        class Halt < StandardError
          extend T::Sig
          extend T::Generic
          extend T::Helpers

          SuccessType = type_member

          sig { returns(Mayak::Monads::Try[SuccessType]) }
          attr_reader :result

          sig { params(result: Mayak::Monads::Try[SuccessType]).void }
          def initialize(result)
            super()

            @result = T.let(result, Mayak::Monads::Try[SuccessType])
          end
        end
        private_constant :Halt
      end
    end
  end
end