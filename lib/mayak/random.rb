# frozen_string_literal: true
# typed: strict

module Mayak
  module Random
    extend T::Sig

    DEFAULT_JITTER = T.let(0.15, Float)

    sig { params(number: T.any(Integer, Float), jitter: Float).returns(Float) }
    def self.jittered(number, jitter: DEFAULT_JITTER)
      (number + Kernel.rand(number * jitter)).to_f
    end
  end
end
