# typed: strict
# frozen_string_literal: true

module Mayak
  module Csv
    class Body < T::Struct
      extend T::Sig
      extend T::Generic
    
      Value = type_member
    
      const :rows, T::Array[Row[Value]]
    end
  end
end