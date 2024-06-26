# frozen_string_literal: true
# typed: strict

module Mayak
  module Monads
    module Result
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      abstract!
      sealed!

      FailureType = type_member(:out)
      SuccessType = type_member(:out)

      sig {
        abstract
          .type_parameters(:NewSuccess)
          .params(blk: T.proc.params(arg0: SuccessType).returns(T.type_parameter(:NewSuccess)))
          .returns(Result[FailureType, T.type_parameter(:NewSuccess)])
      }
      def map(&blk)
      end

      sig {
        type_parameters(:NewSuccess, :NewFailure)
          .abstract
          .params(
            blk: T.proc.params(arg0: SuccessType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])
          )
          .returns(Result[T.any(FailureType, T.type_parameter(:NewFailure)), T.type_parameter(:NewSuccess)])
      }
      def flat_map(&blk)
      end

      sig {
        type_parameters(:NewSuccess, :NewFailure)
          .abstract
          .params(error: T.type_parameter(:NewFailure), blk: T.proc.params(arg0: SuccessType).returns(T::Boolean))
          .returns(Result[T.any(FailureType, T.type_parameter(:NewFailure)), SuccessType])
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
          .type_parameters(:NewSuccessType)
          .params(value: T.type_parameter(:NewSuccessType))
          .returns(T.any(T.type_parameter(:NewSuccessType), SuccessType))
      }
      def success_or(value)
      end

      sig {
        abstract
          .type_parameters(:NewFailureType)
          .params(value: T.type_parameter(:NewFailureType))
          .returns(T.any(T.type_parameter(:NewFailureType), FailureType))
      }
      def failure_or(value)
      end

      sig { abstract.returns(Result[SuccessType, FailureType]) }
      def flip
      end

      sig {
        abstract
          .params(blk: T.proc.params(arg0: FailureType).returns(StandardError))
          .returns(Mayak::Monads::Try[SuccessType])
      }
      def to_try(&blk)
      end

      sig { abstract.returns(Mayak::Monads::Maybe[SuccessType]) }
      def to_maybe
      end

      sig {
        abstract
          .type_parameters(:Result)
          .params(
            failure_branch: T.proc.params(arg0: FailureType).returns(T.type_parameter(:Result)),
            success_branch: T.proc.params(arg0: SuccessType).returns(T.type_parameter(:Result))
          ).returns(
            T.type_parameter(:Result)
          )
      }
      def either(failure_branch, success_branch)
      end

      sig(:final) {
        type_parameters(:NewFailure)
          .params(new_failure: T.type_parameter(:NewFailure))
          .returns(Result[T.type_parameter(:NewFailure), SuccessType])
      }
      def failure_as(new_failure)
        map_failure { |_| new_failure }
      end

      sig {
        abstract
          .params(blk: T.proc.params(arg0: SuccessType).void)
          .returns(Result[FailureType, SuccessType])
      }
      def tee(&blk)
      end

      sig {
        abstract
          .type_parameters(:NewFailure)
          .params(
            blk: T.proc.params(arg0: FailureType).returns(T.type_parameter(:NewFailure))
          ).returns(
            Result[T.type_parameter(:NewFailure), SuccessType]
          )
      }
      def map_failure(&blk)
      end

      sig {
        abstract
          .type_parameters(:NewFailure, :NewSuccess)
          .params(
            blk: T.proc.params(arg0: FailureType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])
          ).returns(
            Result[T.type_parameter(:NewFailure), T.any(T.type_parameter(:NewSuccess), SuccessType)]
          )
      }
      def flat_map_failure(&blk)
      end

      sig(:final) { params(another: Mayak::Monads::Result[T.untyped, T.untyped]).returns(T::Boolean) }
      def ==(another)
        case self
        when Mayak::Monads::Result::Success
          case another
          when Mayak::Monads::Result::Success then T.unsafe(success) == another.success
          when Mayak::Monads::Result::Failure then false
          else T.absurd(another)
          end
        when Mayak::Monads::Result::Failure
          case another
          when Mayak::Monads::Result::Success then false
          when Mayak::Monads::Result::Failure then T.unsafe(failure) == another.failure
          else T.absurd(another)
          end
        else
          T.absurd(self)
        end
      end

      sig(:final) {
        type_parameters(:NewValue)
          .params(new_value: T.type_parameter(:NewValue))
          .returns(Result[FailureType, T.type_parameter(:NewValue)])
      }
      def as(new_value)
        map { |_| new_value }
      end

      sig {
        type_parameters(:NewSuccess)
          .abstract
          .params(value: T.type_parameter(:NewSuccess))
          .returns(Result[FailureType, T.any(T.type_parameter(:NewSuccess), SuccessType)])
      }
      def recover(value)
      end

      sig {
        type_parameters(:NewSuccessType)
          .abstract
          .params(blk: T.proc.params(arg0: FailureType).returns(T.type_parameter(:NewSuccessType)))
          .returns(Result[FailureType, T.any(SuccessType, T.type_parameter(:NewSuccessType))])
      }
      def recover_with(&blk)
      end

      sig {
        abstract
          .type_parameters(:NewFailure, :NewSuccess)
          .params(
            blk: T.proc.params(arg0: FailureType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])
          ).returns(
            Result[T.type_parameter(:NewFailure), T.any(T.type_parameter(:NewSuccess), SuccessType)]
          )
      }
      def recover_with_result(&blk)
      end

      sig {
        type_parameters(:SuccessType, :FailureType)
          .params(
            results: T::Array[
              Mayak::Monads::Result[
                T.type_parameter(:FailureType),
                T.type_parameter(:SuccessType)
              ]
            ]
          ).returns(
            Mayak::Monads::Result[
              T.type_parameter(:FailureType),
              T::Array[T.type_parameter(:SuccessType)]
            ]
          )
      }
      def self.sequence(results)
        init = Success[T.type_parameter(:FailureType), T::Array[T.type_parameter(:SuccessType)]].new([])
        results.reduce(init) do |result, element|
          result.flat_map do |array|
            element.map { |value| array + [value] }
          end
        end
      end

      class Success
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        FailureType = type_member
        SuccessType = type_member

        include Mayak::Monads::Result

        sig(:final) { params(value: SuccessType).void }
        def initialize(value)
          @success_value = T.let(value, SuccessType)
        end

        sig(:final) {
          override
            .type_parameters(:NewSuccess)
            .params(blk: T.proc.params(arg0: SuccessType).returns(T.type_parameter(:NewSuccess)))
            .returns(Result[FailureType, T.type_parameter(:NewSuccess)])
        }
        def map(&blk)
          Mayak::Monads::Result::Success.new(blk.call(@success_value))
        end


        sig(:final) {
          override
            .type_parameters(:NewSuccess, :NewFailure)
            .params(
              blk: T.proc.params(arg0: SuccessType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])
            )
            .returns(Result[T.any(FailureType, T.type_parameter(:NewFailure)), T.type_parameter(:NewSuccess)])
        }
        def flat_map(&blk)
          blk.call(@success_value)
        end

        sig(:final) {
          type_parameters(:NewSuccess, :NewFailure)
            .override
            .params(error: T.type_parameter(:NewFailure), blk: T.proc.params(arg0: SuccessType).returns(T::Boolean))
            .returns(Result[T.any(FailureType, T.type_parameter(:NewFailure)), SuccessType])
        }
        def filter_or(error, &blk)
          if blk.call(@success_value)
            self
          else
            ::Mayak::Monads::Result::Failure[T.any(FailureType, T.type_parameter(:NewFailure)), SuccessType].new(error)
          end
        end

        sig(:final) { returns(SuccessType) }
        def success
          @success_value
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
            .type_parameters(:NewSuccessType)
            .params(value: T.type_parameter(:NewSuccessType))
            .returns(T.any(T.type_parameter(:NewSuccessType), SuccessType))
        }
        def success_or(value)
          @success_value
        end

        sig(:final) {
          override
            .type_parameters(:NewFailureType)
            .params(value: T.any(T.type_parameter(:NewFailureType), FailureType))
            .returns(T.any(T.type_parameter(:NewFailureType), FailureType))
        }
        def failure_or(value)
          value
        end

        sig(:final) { override.returns(Result[SuccessType, FailureType]) }
        def flip
          Mayak::Monads::Result::Failure[SuccessType, FailureType].new(@success_value)
        end

        sig(:final) {
          override
            .params(blk: T.proc.params(arg0: FailureType).returns(StandardError))
            .returns(Mayak::Monads::Try[SuccessType])
        }
        def to_try(&blk)
          Mayak::Monads::Try::Success.new(@success_value)
        end

        sig(:final) { override.returns(Mayak::Monads::Maybe[SuccessType]) }
        def to_maybe
          Mayak::Monads::Maybe::Some.new(@success_value)
        end

        sig(:final) {
          override
            .type_parameters(:Result)
            .params(
              failure_branch: T.proc.params(arg0: FailureType).returns(T.type_parameter(:Result)),
              success_branch: T.proc.params(arg0: SuccessType).returns(T.type_parameter(:Result))
            ).returns(
              T.type_parameter(:Result)
            )
        }
        def either(failure_branch, success_branch)
          success_branch.call(@success_value)
        end

        sig(:final) {
          override
            .params(blk: T.proc.params(arg0: SuccessType).void)
            .returns(Result[FailureType, SuccessType])
        }
        def tee(&blk)
          blk.call(@success_value)
          self
        end

        sig(:final) {
          override
            .type_parameters(:NewFailure)
            .params(
              blk: T.proc.params(arg0: FailureType).returns(T.type_parameter(:NewFailure))
            ).returns(
              Result[T.type_parameter(:NewFailure), SuccessType]
            )
        }
        def map_failure(&blk)
          T.cast(
            self,
            Mayak::Monads::Result[T.type_parameter(:NewFailure), SuccessType]
          )
        end

        sig(:final) {
          type_parameters(:NewFailure, :NewSuccess)
            .override
            .params(
              blk: T.proc.params(arg0: FailureType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])
            ).returns(
              Result[T.type_parameter(:NewFailure), T.any(T.type_parameter(:NewSuccess), SuccessType)]
            )
        }
        def flat_map_failure(&blk)
          T.cast(
            self,
            Mayak::Monads::Result[T.type_parameter(:NewFailure), SuccessType]
          )
        end

        sig(:final) {
          type_parameters(:NewSuccess)
            .override
            .params(value: T.type_parameter(:NewSuccess))
            .returns(Result[FailureType, T.any(T.type_parameter(:NewSuccess), SuccessType)])
        }
        def recover(value)
          self
        end

        sig(:final) {
          type_parameters(:NewSuccessType)
            .override
            .params(blk: T.proc.params(arg0: FailureType).returns(T.type_parameter(:NewSuccessType)))
            .returns(Result[FailureType, T.any(SuccessType, T.type_parameter(:NewSuccessType))])
        }
        def recover_with(&blk)
          self
        end

        sig(:final) {
          type_parameters(:NewFailure, :NewSuccess)
            .override
            .params(
              blk: T.proc.params(arg0: FailureType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])
            ).returns(
              Result[T.type_parameter(:NewFailure), T.any(T.type_parameter(:NewSuccess), SuccessType)]
            )
        }
        def recover_with_result(&blk)
          T.cast(
            self,
            Mayak::Monads::Result[T.type_parameter(:NewFailure), SuccessType]
          )
        end
      end

      class Failure
        extend T::Sig
        extend T::Generic
        extend T::Helpers

        FailureType = type_member
        SuccessType = type_member

        include Mayak::Monads::Result

        sig(:final) { params(value: FailureType).void }
        def initialize(value)
          @failure_value = T.let(value, FailureType)
        end

        sig(:final) {
          override
            .type_parameters(:NewSuccess)
            .params(blk: T.proc.params(arg0: SuccessType).returns(T.type_parameter(:NewSuccess)))
            .returns(Result[FailureType, T.type_parameter(:NewSuccess)])
        }
        def map(&blk)
          T.cast(
            self,
            Mayak::Monads::Result[FailureType, T.type_parameter(:NewSuccess)]
          )
        end

        sig(:final) {
          override
            .type_parameters(:NewSuccess, :NewFailure)
            .params(
              blk: T.proc.params(arg0: SuccessType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])
            )
            .returns(Result[T.any(FailureType, T.type_parameter(:NewFailure)), T.type_parameter(:NewSuccess)])
        }
        def flat_map(&blk)
          T.cast(
            self,
            Mayak::Monads::Result[FailureType, T.type_parameter(:NewSuccess)]
          )
        end

        sig(:final) {
          type_parameters(:NewSuccess, :NewFailure)
            .override
            .params(error: T.type_parameter(:NewFailure), blk: T.proc.params(arg0: SuccessType).returns(T::Boolean))
            .returns(Result[T.any(FailureType, T.type_parameter(:NewFailure)), SuccessType])
        }
        def filter_or(error, &blk)
          self
        end

        sig(:final) { returns(FailureType) }
        def failure
          @failure_value
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
            .type_parameters(:NewSuccessType)
            .params(value: T.type_parameter(:NewSuccessType))
            .returns(T.any(T.type_parameter(:NewSuccessType), SuccessType))
        }
        def success_or(value)
          value
        end

        sig(:final) {
          override
            .type_parameters(:NewFailureType)
            .params(value: T.any(T.type_parameter(:NewFailureType), FailureType))
            .returns(T.any(T.type_parameter(:NewFailureType), FailureType))
        }
        def failure_or(value)
          @failure_value
        end

        sig(:final) { override.returns(Result[SuccessType, FailureType]) }
        def flip
          Mayak::Monads::Result::Success[SuccessType, FailureType].new(@failure_value)
        end

        sig(:final) {
          override
            .params(blk: T.proc.params(arg0: FailureType).returns(StandardError))
            .returns(Mayak::Monads::Try[SuccessType])
        }
        def to_try(&blk)
          Mayak::Monads::Try::Failure.new(blk.call(@failure_value))
        end

        sig(:final) { override.returns(Mayak::Monads::Maybe[SuccessType]) }
        def to_maybe
          Mayak::Monads::Maybe::None.new
        end

        sig(:final) {
          override
            .type_parameters(:Result)
            .params(
              failure_branch: T.proc.params(arg0: FailureType).returns(T.type_parameter(:Result)),
              success_branch: T.proc.params(arg0: SuccessType).returns(T.type_parameter(:Result))
            ).returns(
              T.type_parameter(:Result)
            )
        }
        def either(failure_branch, success_branch)
          failure_branch.call(@failure_value)
        end

        sig(:final) {
          override
            .params(blk: T.proc.params(arg0: SuccessType).void)
            .returns(Result[FailureType, SuccessType])
        }
        def tee(&blk)
          self
        end

        sig(:final) {
          override
            .type_parameters(:NewFailure)
            .params(
              blk: T.proc.params(arg0: FailureType).returns(T.type_parameter(:NewFailure))
            ).returns(
              Result[T.type_parameter(:NewFailure), SuccessType]
            )
        }
        def map_failure(&blk)
          Mayak::Monads::Result::Failure[T.type_parameter(:NewFailure), SuccessType].new(blk.call(@failure_value))
        end

        sig(:final) {
          type_parameters(:NewFailure, :NewSuccess)
            .override
            .params(
              blk: T.proc.params(arg0: FailureType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])
            ).returns(
              Result[T.type_parameter(:NewFailure), T.any(T.type_parameter(:NewSuccess), SuccessType)]
            )
        }
        def flat_map_failure(&blk)
          blk.call(@failure_value)
        end

        sig(:final) {
          type_parameters(:NewSuccess)
            .override
            .params(value: T.type_parameter(:NewSuccess))
            .returns(Result[FailureType, T.any(T.type_parameter(:NewSuccess), SuccessType)])
        }
        def recover(value)
          ::Mayak::Monads::Result::Success[FailureType, T.any(T.type_parameter(:NewSuccess), SuccessType)].new(value)
        end


        sig(:final) {
          type_parameters(:NewSuccessType)
            .override
            .params(blk: T.proc.params(arg0: FailureType).returns(T.type_parameter(:NewSuccessType)))
            .returns(Result[FailureType, T.any(SuccessType, T.type_parameter(:NewSuccessType))])
        }
        def recover_with(&blk)
          ::Mayak::Monads::Result::Success[FailureType, T.any(SuccessType, T.type_parameter(:NewSuccessType))].new(
            blk.call(@failure_value)
          )
        end

        sig(:final) {
          type_parameters(:NewFailure, :NewSuccess)
            .override
            .params(
              blk: T.proc.params(arg0: FailureType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])
            ).returns(
              Result[T.type_parameter(:NewFailure), T.any(T.type_parameter(:NewSuccess), SuccessType)]
            )
        }
        def recover_with_result(&blk)
          blk.call(@failure_value)
        end
      end
    end
  end
end
