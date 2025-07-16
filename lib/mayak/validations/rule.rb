# frozen_string_literal: true
# typed: strict

module Mayak
  module Validations
    module Rule
      extend T::Sig
      extend T::Helpers
      extend T::Generic
    
      Value = type_member
      Error = type_member

      abstract!

      sig { abstract.params(value: Value).returns(ValidationResult[Error]) }
      def check(value)
      end

      sig {
        type_parameters(:FromValue)
          .abstract
          .params(
            fn: T.any(
              ::Mayak::Function[T.type_parameter(:FromValue), Value],
              T.proc.params(arg0: T.type_parameter(:FromValue)).returns(Value)
            )
          ).returns(::Mayak::Validations::Rule[T.type_parameter(:FromValue), Error])
        }
      def transform(fn)
      end

      class FromFunction
        extend T::Sig
        extend T::Helpers
        extend T::Generic
      
        Value = type_member
        Error = type_member

        include ::Mayak::Validations::Rule

        sig { params(blk: T.proc.params(arg0: Value).returns(ValidationResult[Error])).void }
        def initialize(&blk)
          @blk = T.let(blk, T.proc.params(arg0: Value).returns(ValidationResult[Error]))
        end
      
        sig { override.params(value: Value).returns(ValidationResult[Error]) }
        def check(value)
          @blk.call(value)
        end

        sig {
          type_parameters(:FromValue)
            .override
            .params(
              fn: T.any(
                ::Mayak::Function[T.type_parameter(:FromValue), Value],
                T.proc.params(arg0: T.type_parameter(:FromValue)).returns(Value)
              )
            ).returns(::Mayak::Validations::Rule[T.type_parameter(:FromValue), Error])
          }
        def transform(fn)
          ::Mayak::Validations::Rule::FromFunction[T.type_parameter(:FromValue), Error].new do |value|
            check(fn.call(value))
          end
        end
      end
    
      sig {
        type_parameters(:NewError)
          .params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewError)))
          .returns(Rule[Value, T.type_parameter(:NewError)])
      }
      def error_from_value(&blk)
        Rule::FromFunction[Value, T.type_parameter(:NewError)].new do |checked|
          result = check(checked)
    
          case result
          when ValidationResult::Valid
            ValidationResult::Valid[T.type_parameter(:NewError)].new
          when ValidationResult::Invalid
            ValidationResult::Invalid[T.type_parameter(:NewError)].new(errors: [blk.call(checked)])
          else
            T.absurd(result)
          end
        end
      end
    
      sig {
        type_parameters(:NewError)
          .params(new_error: T.type_parameter(:NewError))
          .returns(Rule[Value, T.type_parameter(:NewError)])
      }
      def error_as(new_error)
        error_from_value { |_| new_error }
      end
    
      sig {
        params(
          another: Rule[Value, Error],
          blk: T.nilable(
            T.proc.params(arg0: ValidationResult[Error], arg1: ValidationResult[Error]).returns(ValidationResult[Error])
          )
        ).returns(Rule[Value, Error])
      }
      def any(another, &blk)
        combine = T.let(
          blk.nil? ? -> (first, second) { first.combine(second) } : blk,
          T.proc.params(arg0: ValidationResult[Error], arg1: ValidationResult[Error]).returns(ValidationResult[Error])
        )

        Rule::FromFunction[Value, Error].new do |checked|
          first_result = check(checked)
          case first_result
          when ValidationResult::Valid
            first_result
          when ValidationResult::Invalid
            second_result = another.check(checked)
            case second_result
            when ValidationResult::Valid
              second_result
            when ValidationResult::Invalid
              combine.call(first_result, second_result)
            else
              T.absurd(second_result)
            end
          else
            T.absurd(first_result)
          end
        end
      end
    
      alias | any
    
      sig {
        params(
          another: Rule[Value, Error],
          blk: T.nilable(
            T.proc.params(arg0: ValidationResult[Error], arg1: ValidationResult[Error]).returns(ValidationResult[Error])
          )
        ).returns(Rule[Value, Error])
      }
      def both(another, &blk)
        combine = T.let(
          blk.nil? ? -> (first, second) { first.combine(second) } : blk,
          T.proc.params(arg0: ValidationResult[Error], arg1: ValidationResult[Error]).returns(ValidationResult[Error])
        )
        Rule::FromFunction[Value, Error].new do |checked|
          first_result = check(checked)
          case first_result
          when ValidationResult::Valid
            another.check(checked)
          when ValidationResult::Invalid
            second_result = another.check(checked)
            case second_result
            when ValidationResult::Valid
              first_result
            when ValidationResult::Invalid
              combine.call(first_result, second_result)
            else
              T.absurd(first_result)
            end
          else
            T.absurd(first_result)
          end
        end
      end
    
      alias & both

      sig {
        params(
          build_error: T.proc.params(arg0: Value).returns(::Mayak::ValidationResult::Invalid[Error])
        ).returns(Rule::FromFunction[Value, Error])
      }
      def negate(&build_error)
        Rule::FromFunction[Value, Error].new do |checked|
          result = check(checked)
          case result
          when ValidationResult::Valid
            build_error.call(checked)
          when ValidationResult::Invalid
            ::Mayak::ValidationResult::Valid[Error].new
          else
            T.absurd(result)
          end
        end
      end
    
      sig { params(key: Symbol).returns(Rule[Value, [Symbol, Error]]) }
      def with_key(key)
        Rule::FromFunction[Value, [Symbol, Error]].new do |checked|
          result = check(checked)
          case result
          when ValidationResult::Valid
            ValidationResult::Valid[[Symbol, Error]].new
          when ValidationResult::Invalid
            ValidationResult::Invalid[[Symbol, Error]].new(
              errors: result.errors.map { |error| [key, error] }
            )
          else
            T.absurd(result)
          end
        end
      end
    
      sig { params(value: T.any(Float, Integer)).returns(Rule[T.any(Float, Integer), String]) }
      def self.greater_than(value)
        Rule::FromFunction[T.any(Float, Integer), String].new do |checked|
          if checked > value
            ValidationResult::Valid.new
          else
            ValidationResult::Invalid.new(
              errors: ["Value #{checked} should be greater than the #{value}"]
            )
          end
        end
      end
    
      sig {
        params(
          value: T.any(Float, Integer)
        ).returns(Rule[T.any(Float, Integer), String])
      }
      def self.less_than(value)
        Rule::FromFunction[T.any(Float, Integer), String].new do |checked|
          if checked < value
            ValidationResult::Valid.new
          else
            ValidationResult::Invalid.new(
              errors: ["Value #{checked} should be less than the #{value}"]
            )
          end
        end
      end

      sig {
        params(
          value: Integer
        ).returns(Rule[T.any(String, T::Array[T.anything], T::Set[T.anything], T::Hash[T.anything, T.anything]), String])
      }
      def self.length_less_than(value)
        Rule::FromFunction[T.any(String, T::Array[T.anything], T::Set[T.anything], T::Hash[T.anything, T.anything]), String].new do |checked|
          if checked.length < value
            ValidationResult::Valid.new
          else
            ValidationResult::Invalid.new(
              errors: ["Value #{checked} length should be less than the #{value}"]
            )
          end
        end
      end

      sig {
        params(
          value: Integer
        ).returns(Rule[T.any(String, T::Array[T.anything], T::Set[T.anything], T::Hash[T.anything, T.anything]), String])
      }
      def self.length_greater_than(value)
        Rule::FromFunction[T.any(String, T::Array[T.anything], T::Set[T.anything], T::Hash[T.anything, T.anything]), String].new do |checked|
          if checked.length > value
            ValidationResult::Valid.new
          else
            ValidationResult::Invalid.new(
              errors: ["Value #{checked} length should be less than the #{value}"]
            )
          end
        end
      end

      sig {
        params(
          value: Integer
        ).returns(Rule[T.any(String, T::Array[T.anything], T::Set[T.anything], T::Hash[T.anything, T.anything]), String])
      }
      def self.length_equal_to(value)
        Rule::FromFunction[T.any(String, T::Array[T.anything], T::Set[T.anything], T::Hash[T.anything, T.anything]), String].new do |checked|
          if checked.length == value
            ValidationResult::Valid.new
          else
            ValidationResult::Invalid.new(
              errors: ["Value #{checked} length should be less than the #{value}"]
            )
          end
        end
      end
    
      sig {
        params(
          value: T.any(Float, Integer)
        ).returns(Rule[T.any(Float, Integer), String])
      }
      def self.equal_to(value)
        Rule::FromFunction[T.any(Float, Integer), String].new do |checked|
          if checked == value
            ValidationResult::Valid.new
          else
            ValidationResult::Invalid.new(
              errors: ["Value #{checked} should equal to #{value}"]
            )
          end
        end
      end
    
      sig { params(value: T.any(Float, Integer)).returns(Rule[T.any(Float, Integer), String]) }
      def self.greater_than_or_equal_to(value)
        (greater_than(value) | equal_to(value)).error_from_value do |checked|
          "Value #{checked} should be greater than or equal to #{value}"
        end
      end
    
      sig { params(value: T.any(Float, Integer)).returns(Rule[T.any(Float, Integer), String]) }
      def self.less_than_or_equal_to(value)
        (less_than(value) | equal_to(value)).error_from_value do |checked|
          "Value #{checked} should be less than or equal to #{value}"
        end
      end
    
      sig {params(value: T.any(Float, Integer)).returns(Rule[T.any(Float, Integer), String]) }
      def self.positive(value)
        greater_than(0)
      end
    
      sig { params(value: T.any(Float, Integer)).returns(Rule[T.any(Float, Integer), String]) }
      def self.negative(value)
        less_than(0)
      end
    
      sig {
        returns(Rule[T.any(String, T::Array[T.untyped], T::Hash[T.untyped, T.untyped], String), String])
      }
      def self.not_empty
        Rule::FromFunction[T.any(String, Array, Hash, String), String].new do |checked|
          if checked.empty?
            ValidationResult::Invalid.new(errors: ["Value should not be empty"])
          else
            ValidationResult::Valid.new
          end
        end
      end
    
      sig {
        type_parameters(:Value, :Error)
          .params(rule: Rule[T.type_parameter(:Value), T.type_parameter(:Error)])
          .returns(Rule[T.nilable(T.type_parameter(:Value)), T.type_parameter(:Error)])
      }
      def self.not_nil(rule)
        Rule::FromFunction[T.nilable(T.type_parameter(:Value)), T.type_parameter(:Error)].new do |checked|
          case checked
          when NilClass
            ValidationResult::Invalid.new(errors: ["Should not be nil"])
          else
            rule.check(checked)
          end
        end
      end
    
      sig {
        type_parameters(:Value, :Error)
          .params(rule: Rule[T.type_parameter(:Value), [Symbol, T.type_parameter(:Error)]])
          .returns(Rule[T.type_parameter(:Value), T::Hash[Symbol, T.type_parameter(:Error)]])
      }
      def self.with_keys_aggregated(rule)
        Rule::FromFunction[T.type_parameter(:Value), T::Hash[Symbol, T.type_parameter(:Error)]].new do |checked|
          result = rule.check(checked)
          case result
          when ValidationResult::Valid
            ValidationResult::Valid[T::Hash[Symbol, T.type_parameter(:Error)]].new
          when ValidationResult::Invalid
            accumulated = result.errors.reduce({}) do |acc, tuple|
              key, error = tuple
              if acc.key?(key)
                acc[key] << error
              else
                acc[key] = [error]
              end
            end
            ValidationResult::Invalid[T::Hash[Symbol, T.type_parameter(:Error)]].new(
              errors: accumulated
            )
          else
            T.absurd(result)
          end
        end
      end
    end
  end
end