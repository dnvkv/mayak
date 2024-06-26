# frozen_string_literal: true
# typed: strict

module Mayak
  module ValidationResult
    extend T::Sig
    extend T::Generic

    include Kernel

    sealed!
    abstract!

    Error = type_member(:out)

    sig {
      abstract.type_parameters(
        :NewError
      ).params(
        blk: T.proc.params(arg: Error).returns(T.type_parameter(:NewError))
      ).returns(
        ::Mayak::ValidationResult[T.any(Error, T.type_parameter(:NewError))]
      )
    }
    def map_errors(&blk)
    end

    sig { returns(T::Boolean) }
    def valid?
      is_a?(::Mayak::ValidationResult::Valid)
    end

    sig { returns(T::Boolean) }
    def invalid?
      !valid?
    end

    sig {
      type_parameters(:A)
        .params(blk: T.proc.returns(T.type_parameter(:A)))
        .returns(T.any(::Mayak::ValidationResult::Invalid[Error], T.type_parameter(:A)))
    }
    def on_valid(&blk)
      if is_a?(::Mayak::ValidationResult::Valid)
        blk.call
      else
        self
      end
    end

    sig { params(exceptions: T::Array[StandardError]).returns(::Mayak::ValidationResult[StandardError]) }
    def self.from_exceptions(exceptions)
      if exceptions.empty?
        ::Mayak::ValidationResult::Valid[StandardError].new
      else
        ::Mayak::ValidationResult::Invalid[StandardError].new(errors: exceptions)
      end
    end

    sig { params(strings: T::Array[String]).returns(::Mayak::ValidationResult[String]) }
    def self.from_strings(strings)
      if strings.empty?
        ::Mayak::ValidationResult::Valid[String].new
      else
        ::Mayak::ValidationResult::Invalid[String].new(errors: strings)
      end
    end

    class Valid
      extend T::Sig
      extend T::Generic

      include ::Mayak::ValidationResult

      Error = type_member

      sig {
        override.type_parameters(
          :NewError
        ).params(
          blk: T.proc.params(arg: Error).returns(T.type_parameter(:NewError))
        ).returns(
          ::Mayak::ValidationResult[T.any(Error, T.type_parameter(:NewError))]
        )
      }
      def map_errors(&blk)
        self
      end
    end

    class Invalid < T::Struct
      extend T::Sig
      extend T::Generic

      include ::Mayak::ValidationResult

      Error = type_member

      const :errors, T::Array[Error]

      sig {
        override.type_parameters(
          :NewError
        ).params(
          blk: T.proc.params(arg: Error).returns(T.type_parameter(:NewError))
        ).returns(
          ::Mayak::ValidationResult[T.any(Error, T.type_parameter(:NewError))]
        )
      }
      def map_errors(&blk)
        ::Mayak::ValidationResult::Invalid[T.any(Error, T.type_parameter(:NewError))].new(errors: errors.map(&blk))
      end
    end
  end
end
