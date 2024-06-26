# frozen_string_literal: true
# typed: strict

module Mayak
  module Http
    class Verb < T::Enum
      enums do
        Get     = new("GET")
        Post    = new("POST")
        Head    = new("HEAD")
        Put     = new("PUT")
        Patch   = new("PATCH")
        Delete  = new("DELETE")
        Connect = new("CONNECT")
        Options = new("OPTIONS")
        Trace   = new("TRACE")
      end
    end
  end
end
