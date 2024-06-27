# frozen_string_literal: true
# typed: strict

module Mayak
  module Validations
    class Rule
      extend T::Sig
      extend T::Helpers
      extend T::Generic
    
      Value = type_member
      Error = type_member
    
      sig {
        params(
          blk: T.proc.params(arg0: Value).returns(::Mayak::ValidationResult[Error])
        ).void
      }
      def initialize(&blk)
        @blk = T.let(@blk, T.proc.params(arg0: Value).returns(::Mayak::ValidationResult[Error]))
      end
    
      sig { params(value: Value).returns(::Mayak::ValidationResult[Error]) }
      def check(value)
        @blk.call(value)
      end
    
      sig {
        type_parameters(:NewError)
          .params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewError)))
          .returns(Rule[Value, T.type_parameter(:NewError)])
      }
      def error_from_value(&blk)
        Rule[Value, T.type_parameter(:NewError)].new do |checked|
          result = check(checked)
    
          case result
          when ::Mayak::ValidationResult::Valid
            ::Mayak::ValidationResult::Valid[T.type_parameter(:NewError)].new
          when ::Mayak::ValidationResult::Invalid
            ::Mayak::ValidationResult::Invalid[T.type_parameter(:NewError)].new(errors: [blk.call(checked)])
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
      def error(new_error)
        error_from_value { |_| new_error }
      end
    
      sig {
        params(another: Rule[Value, Error]).returns(Rule[Value, Error])
      }
      def any(another)
        Rule[Value, Error].new do |checked|
          first_result = check(checked)
          case first_result
          when ::Mayak::ValidationResult::Valid
            another.check(checked)
          when ::Mayak::ValidationResult::Invalid
            first_result
          else
            T.absurd(first_result)
          end
        end
      end
    
      alias | any
    
      sig {
        params(another: Rule[Value, Error]).returns(Rule[Value, Error])
      }
      def both(another)
        Rule[Value, Error].new do |checked|
          first_result = check(checked)
          case first_result
          when ::Mayak::ValidationResult::Valid
            another.check(checked)
          when ::Mayak::ValidationResult::Invalid
            second_result = another.check(checked)
            case second_result
            when ::Mayak::ValidationResult::Valid
              first_result
            when ::Mayak::ValidationResult::Invalid
              ::Mayak::ValidationResult::Invalid.new(errors: first_result.errors + second_result.errors)
            else
              T.absurd(first_result)
            end
          else
            T.absurd(first_result)
          end
        end
      end
    
      alias & both
    
      sig { params(key: Symbol).returns(Rule[Value, [Symbol, Error]]) }
      def with_key(key)
        Rule[Value, [Symbol, Error]].new do |checked|
          result = check(checked)
          case result
          when ::Mayak::ValidationResult::Valid
            ::Mayak::ValidationResult::Valid[[Symbol, Error]].new
          when ::Mayak::ValidationResult::Invalid
            ::Mayak::ValidationResult::Invalid[[Symbol, Error]].new(
              errors: result.errors.map { |error| [key, error] }
            )
          else
            T.absurd(result)
          end
        end
      end
    
    
      sig {
        params(
          value: T.any(Float, Integer)
        ).returns(Rule[T.any(Float, Integer), String])
      }
      def self.greater_than(value)
        Rule[T.any(Float, Integer), String].new do |checked|
          if checked > value
            ::Mayak::ValidationResult::Valid.new
          else
            ::Mayak::ValidationResult::Invalid.new(
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
        Rule[T.any(Float, Integer), String].new do |checked|
          if checked < value
            ::Mayak::ValidationResult::Valid.new
          else
            ::Mayak::ValidationResult::Invalid.new(
              errors: ["Value #{checked} should be less than the #{value}"]
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
        Rule[T.any(Float, Integer), String].new do |checked|
          if checked == value
            ::Mayak::ValidationResult::Valid.new
          else
            ::Mayak::ValidationResult::Invalid.new(
              errors: ["Value #{checked} should equal to #{value}"]
            )
          end
        end
      end
    
      sig {
        params(
          value: T.any(Float, Integer)
        ).returns(Rule[T.any(Float, Integer), String])
      }
      def self.greater_than_or_equal_to(value)
        (greater_than(value) | equal_to(value)).error_from_value do |checked|
          "Value #{checked} should greater than or equal to #{value}"
        end
      end
    
      sig {
        params(
          value: T.any(Float, Integer)
        ).returns(Rule[T.any(Float, Integer), String])
      }
      def self.less_than_or_equal_to(value)
        (less_than(value) | equal_to(value)).error_from_value do |checked|
          "Value #{checked} should less than or equal to #{value}"
        end
      end
    
      sig {
        params(
          value: T.any(Float, Integer)
        ).returns(Rule[T.any(Float, Integer), String])
      }
      def self.positive(value)
        greater_than(0)
      end
    
      sig {
        params(
          value: T.any(Float, Integer)
        ).returns(Rule[T.any(Float, Integer), String])
      }
      def self.negative(value)
        less_than(0)
      end
    
      sig {
        returns(Rule[T.any(String, T::Array[T.anything], T::Hash[T.anything, T.anything], String), String])
      }
      def self.not_empty
        Rule[T.any(String, Array, Hash, String), String].new do |checked|
          if checked.empty?
            ::Mayak::ValidationResult::Invalid.new(
              errors: ["Value #{checked} should not be empty equal"]
            )
          else
            ::Mayak::ValidationResult::Valid.new
          end
        end
      end
    
      sig {
        type_parameters(:Value, :Error)
          .params(rule: Rule[T.type_parameter(:Value), T.type_parameter(:Error)])
          .returns(Rule[T.nilable(T.type_parameter(:Value)), T.type_parameter(:Error)])
      }
      def self.not_nil(rule)
        Rule[T.nilable(T.type_parameter(:Value)), T.type_parameter(:Error)].new do |checked|
          case checked
          when NilClass
            ::Mayak::ValidationResult::Invalid.new(errors: ["Should not be nil"])
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
        Rule[T.type_parameter(:Value), T::Hash[Symbol, T.type_parameter(:Error)]].new do |checked|
          result = rule.check(checked)
          case result
          when ::Mayak::ValidationResult::Valid
            ::Mayak::ValidationResult::Valid[T::Hash[Symbol, T.type_parameter(:Error)]].new
          when ::Mayak::ValidationResult::Invalid
            accumulated = result.errors.reduce({}) do |acc, tuple|
              key, error = tuple
              if acc.key?(key)
                acc[key] << error
              else
                acc[key] = [error]
              end
            end
            ::Mayak::ValidationResult::Invalid[T::Hash[Symbol, T.type_parameter(:Error)]].new(
              accumulated
            )
          else
            T.absurd(result)
          end
        end
      end
    end
  end
end