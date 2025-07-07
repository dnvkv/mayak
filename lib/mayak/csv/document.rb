# typed: strict
# frozen_string_literal: true

module Mayak
  module Csv
    class Document < T::Struct
      extend T::Sig
      extend T::Generic
    
      Value = type_member
    
      const :header, Header[Value]
      const :body,   Body[Value]

      sig { params(separator: String).returns(String) }
      def serialize_to_csv(separator: ",")
        buffer = String.new
        buffer << header.serialize_to_csv(separator: separator)
        buffer << "\n"
        body.rows.each do |row|
          buffer << row.serialize_to_csv(separator: separator)
          buffer << "\n"
        end
        buffer
      end
    end
  end
end