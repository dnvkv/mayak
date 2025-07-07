# typed: strict
# frozen_string_literal: true

module Mayak
  module Csv
    module Encoder
      extend T::Sig
      extend T::Generic
    
      Value = type_member
    
      abstract!
    
      sig { abstract.params(values: T::Enumerable[Value]).returns(String) }
      def encode(values)
      end
    
      class FromFunction < T::Struct
        extend T::Sig
        extend T::Generic
    
        Value = type_member
    
        include ::Mayak::Csv::Encoder
    
        const :fn, T.proc.params(value: T::Enumerable[Value]).returns(String)
    
        sig { override.params(values: T::Enumerable[Value]).returns(String) }
        def encode(values)
          fn.call(values)
        end
      end
    end
  end
end