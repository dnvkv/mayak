# typed: strict
# frozen_string_literal: true

module Mayak
  module Csv
    module Decoder
      extend T::Sig
      extend T::Generic
    
      Value = type_member
    
      abstract!
    
      sig {
        abstract
          .params(csv: T.any(String, T::Enumerable[String]))
          .returns(Mayak::Monads::Try[T::Array[Value]])
      }
      def decode(csv)
      end

      sig {
        type_parameters(:NewValue)
          .params(blk: T.proc.params(arg: Value).returns(T.type_parameter(:NewValue)))
          .returns(::Mayak::Csv::Decoder[T.type_parameter(:NewValue)])
      }
      def map(&blk)
        ::Mayak::Csv::Decoder::FromFunction[T.type_parameter(:NewValue)].new(fn: -> (csv) do
          decode(csv).map do |values|
            values.map { |value| blk.call(value) }
          end
        end)
      end

      sig {
        type_parameters(:NewValue)
          .params(blk: T.proc.params(arg: Value).returns(Mayak::Monads::Try[T.type_parameter(:NewValue)]))
          .returns(::Mayak::Csv::Decoder[T.type_parameter(:NewValue)])
      }
      def map_try(&blk)
        ::Mayak::Csv::Decoder::FromFunction[T.type_parameter(:NewValue)].new(fn: -> (csv) do
          decode(csv).flat_map do |values|
            Mayak::Monads::Try.sequence(
              values.map { |value| blk.call(value) }
            )
          end
        end)
      end

      sig { params(separator: String).returns(Mayak::Csv::Decoder[T::Hash[String, String]]) }
      def self.hash_decoder_strict(separator: ",")
        HashDecoderStrict.new(separator: separator)
      end

      sig { params(separator: String).returns(Mayak::Csv::Decoder[T::Hash[String, T.nilable(String)]]) }
      def self.hash_decoder(separator: ",")
        HashDecoder.new(separator: separator)
      end

      class HashDecoder < T::Struct
        extend T::Sig
        extend T::Generic
      
        Value = type_member {{ fixed: T::Hash[String, T.nilable(String)] }}

        const :separator, String, default: ","

        include ::Mayak::Csv::Decoder
      
        sig {
          override
            .params(csv: T.any(String, T::Enumerable[String]))
            .returns(Mayak::Monads::Try[T::Array[Value]])
        }
        def decode(csv)
          csv_string = begin
            case csv
            when String then csv
            else csv.to_a.join("\n")
            end
          end
          Mayak::Monads::Try::Success.new(CSV.parse(csv_string, headers: :first_row, col_sep: separator).map(&:to_h))
        end
      end

      class HashDecoderStrict < T::Struct
        extend T::Sig
        extend T::Generic
      
        Value = type_member {{ fixed: T::Hash[String, String] }}

        const :separator, String, default: ","

        include ::Mayak::Csv::Decoder
      
        sig {
          override
            .params(csv: T.any(String, T::Enumerable[String]))
            .returns(Mayak::Monads::Try[T::Array[Value]])
        }
        def decode(csv)
          lines = begin
            case csv
            when String then csv.split("\n")
            else csv.to_a
            end
          end
          header, *rows = lines

          return Mayak::Monads::Try::Success.new([]) if rows.empty?
          return Mayak::Monads::Try::Success.new([]) if header.nil? || header.empty?
          keys = header.split(separator)
          parse_results = rows.map.with_index do |row, index|
            values = row.split(separator)
            if values.length != keys.length
              Mayak::Monads::Try::Failure.new(
                ::Mayak::Csv::ParseError.new(build_error_message(keys.length, row.length, index))
              )
            else
              keys.zip(values).to_h
            end
          end
          Mayak::Monads::Try.sequence(parse_results).map(&:to_h)
        end

        private

        sig { params(keys_length: Integer, rows_length: Integer, index: Integer).returns(String) }
        def build_error_message(keys_length, rows_length, index)
          "Invalid number of columns on line #{index + 2}: expected #{keys_length}, found #{rows_length}"
        end
      end
    
      class FromFunction < T::Struct
        extend T::Sig
        extend T::Generic
    
        Value = type_member
    
        include ::Mayak::Csv::Decoder
    
        const :fn, T.proc.params(csv: T.any(String, T::Enumerable[String])).returns(Mayak::Monads::Try[T::Array[Value]])
    
        sig {
          override
            .params(csv: T.any(String, T::Enumerable[String]))
            .returns(Mayak::Monads::Try[T::Array[Value]])
        }
        def decode(csv)
          fn.call(csv)
        end
      end
    end
  end
end