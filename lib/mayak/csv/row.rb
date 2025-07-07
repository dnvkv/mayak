# typed: strict
# frozen_string_literal: true

module Mayak
  module Csv
    class Row < T::Struct
      extend T::Sig
      extend T::Generic
    
      Value = type_member
    
      const :cells, T::Array[[Column[Value], String]]

      sig { params(separator: String).returns(String) }
      def serialize_to_csv(separator: ",")
        cells.map { |cell| cell[1] }.join(separator)
      end
    end
  end
end