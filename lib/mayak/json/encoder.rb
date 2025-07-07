# frozen_string_literal: true
# typed: strict

require "json"

module Mayak
  module Json
    module Encoder
      extend T::Sig
      extend T::Generic
      extend T::Helpers

      abstract!

      include ::Mayak::Encoder

      In = type_member
      Out = type_member {{ fixed: ::Mayak::Json::JsonType }}
    end
  end
end
