# typed: strict
# frozen_string_literal: true

module Mayak
  module Csv
    class Header < T::Struct
      extend T::Sig
      extend T::Generic
    
      Value = type_member
    
      const :columns, T::Array[Column[Value]]
    
      sig {
        params(
          name:       String,
          serializer: T.proc.params(value: Value).returns(String)
        ).returns(::Mayak::Csv::Header[Value])
      }
      def with_column(name, &serializer)
        new_column = ::Mayak::Csv::Column[Value].new(
          name:       name,
          serializer: -> (value) { serializer.call(value) }
        )
        Header[Value].new(columns: columns.concat([new_column]))
      end
    
      sig { params(values: T::Enumerable[Value]).returns(Body[Value]) }
      def build_body(values)
        rows = values.map do |value|
          Row.new(cells: columns.map { |column| [column, column.serializer.call(value)] })
        end
        Body.new(rows: rows)
      end
    
      sig { params(values: T::Enumerable[Value]).returns(Document[Value]) }
      def build_document(values)
        Document[Value].new(header: self, body: build_body(values))
      end

      sig { params(separator: String).returns(String) }
      def serialize_to_csv(separator: ",")
        columns.map(&:name).join(separator)
      end
    
      sig { params(separator: String).returns(::Mayak::Csv::Encoder[Value]) }
      def to_encoder(separator: ",")
        ::Mayak::Csv::Encoder::FromFunction[Value].new(
          fn: -> (values) { build_document(values).serialize_to_csv(separator: separator) }
        )
      end
    end
  end
end