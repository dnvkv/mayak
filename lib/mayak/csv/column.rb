# typed: strict
# frozen_string_literal: true

module Mayak
  module Csv
    class Column < T::Struct
      extend T::Sig
      extend T::Generic
    
      Value = type_member
    
      const :name,       String
      const :serializer, T.proc.params(value: Value).returns(String)
    end
  end
end