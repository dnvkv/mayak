# frozen_string_literal: true
# typed: strict

module Mayak
  module Validations
    class Contract
      extend T::Sig
      extend T::Generic

      Value = type_member
      Error = type_member

      sig {
        returns(
          T::Hash[
            Symbol,
            T::Set[Rule[Value, [Symbol, Error]]]
          ]
        )
      }
      attr_reader :rule_set

      sig {
        params(
          rule_set: T::Hash[
            Symbol,
            T::Set[Rule[Value, [Symbol, Error]]]]
        ).void
      }
      def initialize(rule_set = Hash.new)
        @rule_set = T.let(
          rule_set,
          T::Hash[
            Symbol,
            T::Set[Rule[Value, [Symbol, Error]]]
          ]
        )
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
        built_rule = Rule::FromFunction[Value, Error].new do |checked|
          rule.check(blk.call(checked))
        end
        Contract.new(
          rule_set.merge(
            key: rule_set.fetch(:key, Set.new).add(built_rule.with_key(key))
          )
        )
      end

      sig { params(value: Value).returns(ValidationResult[[Symbol, Error]]) }
      def check(value)
        initial = T.let(
          ValidationResult::Valid[[Symbol, Error]].new,
          ValidationResult[[Symbol, Error]]
        )
        all_rules = rule_set.values.flat_map(&:to_a)
        all_rules.reduce(initial) do |aggreated_result, rule|
          aggreated_result.combine(rule.check(value))
        end
      end

      sig { params(key: Symbol).returns(T.nilable(T::Set[Rule[Value, [Symbol, Error]]])) }
      def rules_for(key)
        rule_set[key]
      end

      sig { returns(::Mayak::Validations::Rule[Value, [Symbol, Error]]) }
      def to_rule
        Rule::FromFunction[Value, [Symbol, Error]].new { |value| check(value) }
      end
    end
  end
end