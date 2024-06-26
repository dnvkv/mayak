# frozen_string_literal: true
# typed: strict

require 'bigdecimal'

module Mayak
  module Numeric
    extend T::Sig

    sig { params(value: T.any(NilClass, String, BigDecimal, Integer, Float)).returns(Mayak::Monads::Maybe[Float]) }
    def self.parse_float(value)
      return Mayak::Monads::Maybe::None[Float].new if value.nil?

      Mayak::Monads::Maybe::Some[Float].new(Float(value))
    rescue ArgumentError, TypeError, FloatDomainError
      Mayak::Monads::Maybe::None[Float].new
    end

    sig { params(value: T.any(NilClass, String, BigDecimal, Integer)).returns(Mayak::Monads::Maybe[Integer]) }
    def self.parse_integer(value)
      return Mayak::Monads::Maybe::None[Integer].new if value.nil?

      Mayak::Monads::Maybe::Some[Integer].new(Integer(value))
    rescue ArgumentError, TypeError
      Mayak::Monads::Maybe::None[Integer].new
    end

    sig { params(value: T.any(NilClass, String, Integer, BigDecimal, Float)).returns(Mayak::Monads::Maybe[BigDecimal]) }
    def self.parse_decimal(value)
      return Mayak::Monads::Maybe::None[BigDecimal].new if value.nil?

      case value
      when String
        Mayak::Monads::Maybe::Some[BigDecimal].new(BigDecimal(value))
      when Integer
        Mayak::Monads::Maybe::Some[BigDecimal].new(BigDecimal(value))
      when BigDecimal
        Mayak::Monads::Maybe::Some[BigDecimal].new(value)
      when Float
        Mayak::Monads::Maybe::Some[BigDecimal].new(BigDecimal(value, Float::DIG + 1))
      end
    rescue ArgumentError, TypeError
      Mayak::Monads::Maybe::None[BigDecimal].new
    end

    sig { params(value: BigDecimal, total: BigDecimal).returns(BigDecimal) }
    def self.percent_of(value:, total:)
      return BigDecimal(0) if total.zero?

      value / total * BigDecimal(100)
    end
  end
end
