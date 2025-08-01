# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

require_relative 'mayak/cache'
require_relative 'mayak/function'
require_relative 'mayak/failable_function'
require_relative 'mayak/optional_function'
require_relative 'mayak/validation_result'
require_relative 'mayak/json'
require_relative 'mayak/numeric'
require_relative 'mayak/random'
require_relative 'mayak/version'
require_relative 'mayak/weak_ref'
require_relative 'mayak/decoder'
require_relative 'mayak/encoder'
require_relative 'mayak/codec'
require_relative 'mayak/hash_serializable'
require_relative 'mayak/lazy'

require_relative 'mayak/json_codec/from_hash_serializable'

require_relative 'mayak/caching/unbounded_cache'
require_relative 'mayak/caching/lru_cache'

require_relative 'mayak/collections/priority_queue'
require_relative 'mayak/collections/queue'

require_relative 'mayak/http/decoder'
require_relative 'mayak/http/encoder'
require_relative 'mayak/http/request'
require_relative 'mayak/http/response'
require_relative 'mayak/http/verb'
require_relative 'mayak/http/client'
require_relative 'mayak/monads/maybe'
require_relative 'mayak/monads/result'
require_relative 'mayak/monads/try'

require_relative 'mayak/predicates/rule'

module Mayak
end