# frozen_string_literal: true
# typed: strict

module Mayak
  module Validations
    class Contract
      extend T::Sig
      extend T::Generic
    
      Value = type_member
      Error = type_member
    
      sig { returns(T::Set[Rule[Value, [Symbol, Error]]]) }
      attr_reader :rule_set
    
      sig { params(rule_set: T::Set[Rule[Value, [Symbol, Error]]]).void }
      def initialize(rule_set = Set.new)
        @rule_set = T.let(rule_set, T::Set[Rule[Value, [Symbol, Error]]])
      end
    
      sig {
        type_parameters(:MappedValue)
          .params(
            rule: Rule[T.type_parameter(:MappedValue), Error],
            key:  Symbol,
            blk:  T.proc.params(arg0: Value).returns(T.type_parameter(:MappedValue))
          ).returns(Contract[Value, Error])
      }
      def validate(rule, key:, &blk)
        rule = Rule[Value, Error].new do |checked|
          rule.check(blk.call(checked))
        end
        Contract.new(rule_set.add(rule.with_key(key)))
      end
    
      sig { params(value: Value).returns(::Mayak::ValidationResult[T::Hash[Symbol, Error]]) }
      def check(value)
        initial = T.let(
          ::Mayak::ValidationResult::Valid[T::Hash[Symbol, Error]].new,
          ::Mayak::ValidationResult[T::Hash[Symbol, Error]]
        )
        rule_set.reduce(initial) do |aggreated_result, rule|
          current_result = Rule.with_keys_aggregated(rule).check(value)
          case aggreated_result
          when ::Mayak::ValidationResult::Valid
            current_result
          when ::Mayak::ValidationResult::Invalid
            case current_result
            when ::Mayak::ValidationResult::Valid
              aggreated_result
            when ::Mayak::ValidationResult::Invalid
              ::Mayak::ValidationResult::Invalid[T::Hash[Symbol, Error]].new(errors: [ ])
            else
              T.absurd(current_result)
            end
          else
            T.absurd(aggreated_result)
          end
        end
      end
    end
  end
end


