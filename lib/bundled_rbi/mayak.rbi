# typed: strong
module Mayak
  VERSION = T.let("0.0.1", String)

  module Cache
    interface!

    extend T::Sig
    extend T::Generic
    extend T::Helpers
    Key = type_member
    Value = type_member

    sig { abstract.params(key: Key).returns(T.nilable(Value)) }
    def read(key); end

    sig { abstract.params(key: Key, value: Value).void }
    def write(key, value); end

    sig { abstract.params(key: Key, blk: T.proc.returns(Value)).returns(Value) }
    def fetch(key, &blk); end

    sig { abstract.void }
    def clear; end

    sig { abstract.params(key: Key).void }
    def delete(key); end
  end

  class Function
    extend T::Sig
    extend T::Helpers
    extend T::Generic
    Input = type_member
    Output = type_member

    sig { returns(T.proc.params(input: Input).returns(Output)) }
    attr_reader :blk

    sig { params(blk: T.proc.params(input: Input).returns(Output)).void }
    def initialize(&blk); end

    sig { params(input: Input).returns(Output) }
    def call(input); end

    sig { type_parameters(:Output2).params(another: Mayak::Function[Output, T.type_parameter(:Output2)]).returns(Mayak::Function[Input, T.type_parameter(:Output2)]) }
    def and_then(another); end

    sig { type_parameters(:Input2).params(another: Mayak::Function[T.type_parameter(:Input2), Input]).returns(Mayak::Function[T.type_parameter(:Input2), Output]) }
    def compose(another); end
  end

  module Json
    extend T::Sig
    JsonType = T.type_alias { T.any(
        T::Array[T.untyped],
        T::Hash[T.untyped, T.untyped],
        String,
        Integer,
        Float
      ) }

    class ParsingError < StandardError
    end

    sig { params(string: String).returns(Mayak::Monads::Try[JsonType]) }
    def self.parse(string); end

    sig { params(string: String).returns(JsonType) }
    def self.parse_unsafe!(string); end
  end

  module Numeric
    extend T::Sig

    sig { params(value: T.any(NilClass, String, BigDecimal, Integer, Float)).returns(Mayak::Monads::Maybe[Float]) }
    def self.parse_float(value); end

    sig { params(value: T.any(NilClass, String, BigDecimal, Integer)).returns(Mayak::Monads::Maybe[Integer]) }
    def self.parse_integer(value); end

    sig { params(value: T.any(NilClass, String, Integer, BigDecimal, Float)).returns(Mayak::Monads::Maybe[BigDecimal]) }
    def self.parse_decimal(value); end

    sig { params(value: BigDecimal, total: BigDecimal).returns(BigDecimal) }
    def self.percent_of(value:, total:); end
  end

  module Predicates
    class Rule
      extend T::Sig
      extend T::Helpers
      extend T::Generic
      A = type_member

      sig { returns(T.proc.params(arg0: A).returns(T::Boolean)) }
      attr_reader :fn

      sig { params(blk: T.proc.params(arg0: A).returns(T::Boolean)).void }
      def initialize(&blk); end

      sig { params(object: A).returns(T::Boolean) }
      def call(object); end

      sig { params(another: Mayak::Predicates::Rule[A]).returns(Mayak::Predicates::Rule[A]) }
      def both(another); end

      sig { params(another: Mayak::Predicates::Rule[A]).returns(Mayak::Predicates::Rule[A]) }
      def any(another); end

      sig { returns(Mayak::Predicates::Rule[A]) }
      def negate; end

      sig { type_parameters(:B).params(function: Mayak::Function[T.type_parameter(:B), A]).returns(Mayak::Predicates::Rule[T.type_parameter(:B)]) }
      def from(function); end

      sig { returns(Mayak::Predicates::Rule[T.nilable(A)]) }
      def presence; end
    end
  end

  module Random
    extend T::Sig
    DEFAULT_JITTER = T.let(0.15, Float)

    sig { params(number: T.any(Integer, Float), jitter: Float).returns(Float) }
    def self.jittered(number, jitter: DEFAULT_JITTER); end
  end

  class WeakRef
    extend T::Sig
    extend T::Generic
    Value = type_member

    class EmptyReferenceError < StandardError
    end

    sig { params(value: Value).void }
    def initialize(value); end

    sig { returns(Value) }
    def deref!; end

    sig { returns(Mayak::Monads::Maybe[Value]) }
    def deref; end
  end

  module Caching
    class LRUCache
      include Mayak::Cache
      extend T::Sig
      extend T::Generic
      extend T::Helpers
      Key = type_member
      Value = type_member

      sig { returns(Integer) }
      attr_reader :max_size

      sig { params(max_size: Integer).void }
      def initialize(max_size:); end

      sig { override.params(key: Key).returns(T.nilable(Value)) }
      def read(key); end

      sig { override.params(key: Key, value: Value).void }
      def write(key, value); end

      sig { override.params(key: Key, blk: T.proc.returns(Value)).returns(Value) }
      def fetch(key, &blk); end

      sig { override.void }
      def clear; end

      sig { override.params(key: Key).void }
      def delete(key); end

      sig { void }
      def evict!; end
    end

    class UnboundedCache
      include Mayak::Cache
      extend T::Sig
      extend T::Generic
      extend T::Helpers
      Key = type_member
      Value = type_member

      sig { void }
      def initialize; end

      sig { override.params(key: Key).returns(T.nilable(Value)) }
      def read(key); end

      sig { override.params(key: Key, value: Value).void }
      def write(key, value); end

      sig { override.params(key: Key, blk: T.proc.returns(Value)).returns(Value) }
      def fetch(key, &blk); end

      sig { override.void }
      def clear; end

      sig { override.params(key: Key).void }
      def delete(key); end
    end
  end

  module Collections
    class PriorityQueue
      extend T::Sig
      extend T::Generic
      Element = type_member
      Priority = type_member

      sig { returns(Integer) }
      attr_reader :size

      sig { params(compare: T.proc.params(arg0: Priority, arg2: Priority).returns(T::Boolean)).void }
      def initialize(&compare); end

      sig { params(element: Element, priority: Priority).void }
      def enqueue(element, priority); end

      sig { returns(T.nilable([Element, Priority])) }
      def dequeue; end

      sig { returns(T.nilable([Element, Priority])) }
      def peak; end

      sig { void }
      def clear; end

      sig { returns(T::Array[[Element, Priority]]) }
      def to_a; end

      sig { returns(T::Boolean) }
      def empty?; end

      sig { params(element_index: Integer).void }
      def sift_up(element_index); end

      sig { params(element_index: Integer).void }
      def sift_down(element_index); end

      sig { params(index1: Integer, index2: Integer).void }
      def swap(index1, index2); end

      sig { params(index1: Integer, index2: Integer).returns(T::Boolean) }
      def compare(index1, index2); end

      sig { params(index: Integer).returns(T::Boolean) }
      def has_parent(index); end

      sig { params(index: Integer).returns(Integer) }
      def parent_index(index); end

      sig { params(index: Integer).returns(T::Boolean) }
      def has_left_child(index); end

      sig { params(index: Integer).returns(Integer) }
      def left_child_index(index); end

      sig { params(index: Integer).returns(T::Boolean) }
      def has_right_child(index); end

      sig { params(index: Integer).returns(Integer) }
      def right_child_index(index); end

      sig { params(index: Integer).returns(T::Boolean) }
      def root?(index); end
    end

    class Queue
      extend T::Sig
      extend T::Helpers
      extend T::Generic
      Value = type_member

      class Node < T::Struct
        prop :value, Value, immutable: true
        prop :next, T.nilable(Node[Value])

        extend T::Sig
        extend T::Generic
        Value = type_member
      end

      sig { returns(Integer) }
      attr_reader :size

      sig { params(initial: T::Array[Value]).void }
      def initialize(initial: []); end

      sig { params(element: Value).void }
      def enqueue(element); end

      sig { returns(T.nilable(Value)) }
      def peak; end

      sig { returns(T.nilable(Value)) }
      def dequeue; end

      sig { returns(T::Boolean) }
      def empty?; end
    end
  end

  module Http
    module Client
      interface!

      extend T::Sig
      extend T::Generic

      sig { abstract.params(request: Http::Request).returns(Mayak::Monads::Try[Mayak::Http::Response]) }
      def send_request(request); end
    end

    module Codec
      interface!

      include Mayak::Http::Encoder
      include Mayak::Http::Decoder
      extend T::Sig
      extend T::Generic
      extend T::Helpers
      RequestEntity = type_member
      ResponseEntity = type_member
    end

    module Decoder
      interface!

      extend T::Sig
      extend T::Generic
      extend T::Helpers
      ResponseEntity = type_member

      sig { abstract.params(response: Mayak::Http::Response).returns(Mayak::Monads::Try[ResponseEntity]) }
      def decode(response); end

      class IdentityDecoder
        include ::Mayak::Http::Decoder
        extend T::Sig
        extend T::Generic
        extend T::Helpers
        ResponseEntity = type_member { { fixed: ::Mayak::Http::Response } }

        sig { override.params(response: Mayak::Http::Response).returns(Mayak::Monads::Try[ResponseEntity]) }
        def decode(response); end
      end
    end

    module Encoder
      interface!

      extend T::Sig
      extend T::Generic
      extend T::Helpers
      RequestEntity = type_member

      sig { abstract.params(entity: RequestEntity).returns(Mayak::Http::Request) }
      def encode(entity); end

      class IdentityEncoder
        include ::Mayak::Http::Encoder
        extend T::Sig
        extend T::Generic
        extend T::Helpers
        RequestEntity = type_member { { fixed: ::Mayak::Http::Request } }

        sig { override.params(entity: RequestEntity).returns(Mayak::Http::Request) }
        def encode(entity); end
      end

      class FromFunction
        include ::Mayak::Http::Encoder
        extend T::Sig
        extend T::Generic
        extend T::Helpers
        RequestEntity = type_member

        sig { params(function: Mayak::Function[RequestEntity, Mayak::Http::Request]).void }
        def initialize(function); end

        sig { override.params(entity: RequestEntity).returns(Mayak::Http::Request) }
        def encode(entity); end
      end
    end

    class Request < T::Struct
      prop :verb, Mayak::Http::Verb, immutable: true
      prop :url, URI, immutable: true
      prop :headers, T::Hash[String, String], default: {}, immutable: true
      prop :body, T.nilable(String), immutable: true

      extend T::Sig
      CONTENT_TYPE_HEADER = T.let("Content-Type", String)

      sig(:final) { params(other: Mayak::Http::Request).returns(T::Boolean) }
      def ==(other); end

      sig(:final) { params(other: Mayak::Http::Request).returns(T::Boolean) }
      def eql?(other); end

      sig { returns(Integer) }
      def hash; end

      sig { returns(T.nilable(String)) }
      def content_type; end

      sig { params(type: String).returns(Mayak::Http::Request) }
      def with_content_type(type); end

      sig { params(url: URI, headers: T::Hash[String, String], body: T.nilable(String)).returns(Mayak::Http::Request) }
      def self.get(url:, headers: {}, body: nil); end

      sig { params(url: URI, headers: T::Hash[String, String], body: T.nilable(String)).returns(Mayak::Http::Request) }
      def self.head(url:, headers: {}, body: nil); end

      sig { params(url: URI, headers: T::Hash[String, String], body: T.nilable(String)).returns(Mayak::Http::Request) }
      def self.post(url:, headers: {}, body: nil); end

      sig { params(url: URI, headers: T::Hash[String, String], body: T.nilable(String)).returns(Mayak::Http::Request) }
      def self.put(url:, headers: {}, body: nil); end

      sig { params(url: URI, headers: T::Hash[String, String], body: T.nilable(String)).returns(Mayak::Http::Request) }
      def self.patch(url:, headers: {}, body: nil); end

      sig { params(url: URI, headers: T::Hash[String, String], body: T.nilable(String)).returns(Mayak::Http::Request) }
      def self.delete(url:, headers: {}, body: nil); end
    end

    class Response < T::Struct
      prop :status, Integer, immutable: true
      prop :headers, T::Hash[String, String], default: {}, immutable: true
      prop :body, String, default: "", immutable: true

      extend T::Sig
      SuccessfulStatuses = T.let(::Set.new(200..299).freeze, T::Set[Integer])
      StatusesWithoutBody = T.let(::Set.new([204, 304]).freeze, T::Set[Integer])

      sig { returns(T::Boolean) }
      def success?; end

      sig { returns(T::Boolean) }
      def failure?; end
    end

    class Verb < T::Enum
      enums do
        Get = new("GET")
        Post = new("POST")
        Head = new("HEAD")
        Put = new("PUT")
        Patch = new("PATCH")
        Delete = new("DELETE")
        Connect = new("CONNECT")
        Options = new("OPTIONS")
        Trace = new("TRACE")
      end

    end
  end

  module Monads
    module Maybe
      abstract!

      sealed!

      extend T::Sig
      extend T::Generic
      extend T::Helpers
      Value = type_member(:out)

      sig { abstract.type_parameters(:NewValue).params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewValue))).returns(Maybe[T.type_parameter(:NewValue)]) }
      def map(&blk); end

      sig { abstract.type_parameters(:NewValue).params(blk: T.proc.params(arg0: Value).returns(Maybe[T.type_parameter(:NewValue)])).returns(Maybe[T.type_parameter(:NewValue)]) }
      def flat_map(&blk); end

      sig { abstract.params(blk: T.proc.params(arg0: Value).returns(T::Boolean)).returns(Maybe[Value]) }
      def filter(&blk); end

      sig { abstract.returns(T::Boolean) }
      def some?; end

      sig { abstract.returns(T::Boolean) }
      def none?; end

      sig { abstract.type_parameters(:AnotherValue).params(value: T.type_parameter(:AnotherValue)).returns(T.any(T.type_parameter(:AnotherValue), Value)) }
      def value_or(value); end

      sig { abstract.params(blk: T.proc.params(arg0: Value).void).returns(Maybe[Value]) }
      def tee(&blk); end

      sig { abstract.type_parameters(:NoneResult, :SomeResult).params(none_branch: T.proc.returns(T.type_parameter(:NoneResult)), some_branch: T.proc.params(arg0: Value).returns(T.type_parameter(:SomeResult))).returns(T.any(T.type_parameter(:NoneResult), T.type_parameter(:SomeResult))) }
      def either(none_branch, some_branch); end

      sig { abstract.type_parameters(:Failure).params(failure: T.type_parameter(:Failure)).returns(Mayak::Monads::Result[T.type_parameter(:Failure), Value]) }
      def to_result(failure); end

      sig { abstract.params(error: StandardError).returns(Mayak::Monads::Try[Value]) }
      def to_try(error); end

      sig(:final) { type_parameters(:NewValue).params(new_value: T.type_parameter(:NewValue)).returns(Maybe[T.type_parameter(:NewValue)]) }
      def as(new_value); end

      sig { abstract.type_parameters(:NewValue).params(value: T.type_parameter(:NewValue)).returns(Maybe[T.any(T.type_parameter(:NewValue), Value)]) }
      def recover(value); end

      sig { abstract.type_parameters(:NewValue).params(maybe: Maybe[T.type_parameter(:NewValue)]).returns(Maybe[T.any(T.type_parameter(:NewValue), Value)]) }
      def recover_with_maybe(maybe); end

      sig(:final) { params(another: Mayak::Monads::Maybe[T.untyped]).returns(T::Boolean) }
      def ==(another); end

      sig { type_parameters(:Value).params(results: T::Array[Mayak::Monads::Maybe[T.type_parameter(:Value)]]).returns(Mayak::Monads::Maybe[T::Array[T.type_parameter(:Value)]]) }
      def self.sequence(results); end

      sig { type_parameters(:Value).params(value: T.type_parameter(:Value), blk: T.proc.returns(T::Boolean)).returns(Mayak::Monads::Maybe[T.type_parameter(:Value)]) }
      def self.check(value, &blk); end

      sig { params(blk: T.proc.returns(T::Boolean)).returns(Mayak::Monads::Maybe[NilClass]) }
      def self.guard(&blk); end

      class Some
        final!

        include ::Mayak::Monads::Maybe
        extend T::Sig
        extend T::Generic
        extend T::Helpers
        Value = type_member

        sig(:final) { params(value: Value).void }
        def initialize(value); end

        sig(:final) { override.type_parameters(:NewValue).params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewValue))).returns(Maybe[T.type_parameter(:NewValue)]) }
        def map(&blk); end

        sig(:final) { override.type_parameters(:NewValue).params(blk: T.proc.params(arg0: Value).returns(Maybe[T.type_parameter(:NewValue)])).returns(Maybe[T.type_parameter(:NewValue)]) }
        def flat_map(&blk); end

        sig(:final) { override.params(blk: T.proc.params(arg0: Value).returns(T::Boolean)).returns(Maybe[Value]) }
        def filter(&blk); end

        sig(:final) { returns(Value) }
        def value; end

        sig(:final) { override.returns(T::Boolean) }
        def some?; end

        sig(:final) { override.returns(T::Boolean) }
        def none?; end

        sig(:final) { override.type_parameters(:AnotherValue).params(value: T.any(T.type_parameter(:AnotherValue), Value)).returns(T.any(T.type_parameter(:AnotherValue), Value)) }
        def value_or(value); end

        sig(:final) { override.params(blk: T.proc.params(arg0: Value).void).returns(Maybe[Value]) }
        def tee(&blk); end

        sig(:final) { override.type_parameters(:NoneResult, :SomeResult).params(none_branch: T.proc.returns(T.type_parameter(:NoneResult)), some_branch: T.proc.params(arg0: Value).returns(T.type_parameter(:SomeResult))).returns(T.any(T.type_parameter(:NoneResult), T.type_parameter(:SomeResult))) }
        def either(none_branch, some_branch); end

        sig(:final) { override.type_parameters(:Failure).params(failure: T.type_parameter(:Failure)).returns(Mayak::Monads::Result[T.type_parameter(:Failure), Value]) }
        def to_result(failure); end

        sig(:final) { override.params(error: StandardError).returns(Mayak::Monads::Try[Value]) }
        def to_try(error); end

        sig(:final) { override.type_parameters(:NewValue).params(value: T.type_parameter(:NewValue)).returns(Maybe[T.any(Value, T.type_parameter(:NewValue))]) }
        def recover(value); end

        sig(:final) { override.type_parameters(:NewValue).params(maybe: Maybe[T.type_parameter(:NewValue)]).returns(Maybe[T.any(Value, T.type_parameter(:NewValue))]) }
        def recover_with_maybe(maybe); end
      end

      class None
        final!

        include Mayak::Monads::Maybe
        extend T::Sig
        extend T::Generic
        extend T::Helpers
        Value = type_member

        sig(:final) { override.type_parameters(:NewValue).params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewValue))).returns(Maybe[T.type_parameter(:NewValue)]) }
        def map(&blk); end

        sig(:final) { override.type_parameters(:NewValue).params(blk: T.proc.params(arg0: Value).returns(Maybe[T.type_parameter(:NewValue)])).returns(Maybe[T.type_parameter(:NewValue)]) }
        def flat_map(&blk); end

        sig(:final) { override.params(blk: T.proc.params(arg0: Value).returns(T::Boolean)).returns(Maybe[Value]) }
        def filter(&blk); end

        sig(:final) { override.returns(T::Boolean) }
        def some?; end

        sig(:final) { override.returns(T::Boolean) }
        def none?; end

        sig(:final) { override.type_parameters(:AnotherValue).params(value: T.any(T.type_parameter(:AnotherValue), Value)).returns(T.any(T.type_parameter(:AnotherValue), Value)) }
        def value_or(value); end

        sig(:final) { override.params(blk: T.proc.params(arg0: Value).void).returns(Maybe[Value]) }
        def tee(&blk); end

        sig(:final) { override.type_parameters(:NoneResult, :SomeResult).params(none_branch: T.proc.returns(T.type_parameter(:NoneResult)), some_branch: T.proc.params(arg0: Value).returns(T.type_parameter(:SomeResult))).returns(T.any(T.type_parameter(:NoneResult), T.type_parameter(:SomeResult))) }
        def either(none_branch, some_branch); end

        sig(:final) { override.type_parameters(:Failure).params(failure: T.type_parameter(:Failure)).returns(Mayak::Monads::Result[T.type_parameter(:Failure), Value]) }
        def to_result(failure); end

        sig(:final) { override.params(error: StandardError).returns(Mayak::Monads::Try[Value]) }
        def to_try(error); end

        sig(:final) { override.type_parameters(:NewValue).params(value: T.type_parameter(:NewValue)).returns(Maybe[T.any(Value, T.type_parameter(:NewValue))]) }
        def recover(value); end

        sig(:final) { override.type_parameters(:NewValue).params(maybe: Maybe[T.type_parameter(:NewValue)]).returns(Maybe[T.any(Value, T.type_parameter(:NewValue))]) }
        def recover_with_maybe(maybe); end
      end

      module Mixin
        include Kernel
        extend T::Sig

        sig { type_parameters(:Value).params(value: T.nilable(T.type_parameter(:Value))).returns(Maybe[T.type_parameter(:Value)]) }
        def Maybe(value); end

        sig { returns(Maybe[T.untyped]) }
        def None; end

        sig { type_parameters(:Value).params(blk: T.proc.returns(T.type_parameter(:Value))).returns(Maybe[T.type_parameter(:Value)]) }
        def for_maybe(&blk); end

        sig { type_parameters(:Value).params(value: Maybe[T.type_parameter(:Value)]).returns(T.type_parameter(:Value)) }
        def do_maybe!(value); end

        sig { type_parameters(:Value).params(value: T.type_parameter(:Value), blk: T.proc.returns(T::Boolean)).returns(T.type_parameter(:Value)) }
        def check_maybe!(value, &blk); end

        sig { params(blk: T.proc.returns(T::Boolean)).void }
        def guard_maybe!(&blk); end

        class Halt < StandardError
          extend T::Sig
          extend T::Generic
          extend T::Helpers
          SuccessType = type_member

          sig { returns(Mayak::Monads::Maybe[SuccessType]) }
          attr_reader :result

          sig { params(result: Mayak::Monads::Maybe[SuccessType]).void }
          def initialize(result); end
        end
      end
    end

    module Result
      abstract!

      sealed!

      extend T::Sig
      extend T::Generic
      extend T::Helpers
      FailureType = type_member(:out)
      SuccessType = type_member(:out)

      sig { abstract.type_parameters(:NewSuccess).params(blk: T.proc.params(arg0: SuccessType).returns(T.type_parameter(:NewSuccess))).returns(Result[FailureType, T.type_parameter(:NewSuccess)]) }
      def map(&blk); end

      sig { abstract.type_parameters(:NewSuccess, :NewFailure).params(blk: T.proc.params(arg0: SuccessType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])).returns(Result[T.any(FailureType, T.type_parameter(:NewFailure)), T.type_parameter(:NewSuccess)]) }
      def flat_map(&blk); end

      sig { abstract.type_parameters(:NewSuccess, :NewFailure).params(error: T.type_parameter(:NewFailure), blk: T.proc.params(arg0: SuccessType).returns(T::Boolean)).returns(Result[T.any(FailureType, T.type_parameter(:NewFailure)), SuccessType]) }
      def filter_or(error, &blk); end

      sig { abstract.returns(T::Boolean) }
      def success?; end

      sig { abstract.returns(T::Boolean) }
      def failure?; end

      sig { abstract.type_parameters(:NewSuccessType).params(value: T.type_parameter(:NewSuccessType)).returns(T.any(T.type_parameter(:NewSuccessType), SuccessType)) }
      def success_or(value); end

      sig { abstract.type_parameters(:NewFailureType).params(value: T.type_parameter(:NewFailureType)).returns(T.any(T.type_parameter(:NewFailureType), FailureType)) }
      def failure_or(value); end

      sig { abstract.returns(Result[SuccessType, FailureType]) }
      def flip; end

      sig { abstract.params(blk: T.proc.params(arg0: FailureType).returns(StandardError)).returns(Mayak::Monads::Try[SuccessType]) }
      def to_try(&blk); end

      sig { abstract.returns(Mayak::Monads::Maybe[SuccessType]) }
      def to_maybe; end

      sig { abstract.type_parameters(:Result).params(failure_branch: T.proc.params(arg0: FailureType).returns(T.type_parameter(:Result)), success_branch: T.proc.params(arg0: SuccessType).returns(T.type_parameter(:Result))).returns(T.type_parameter(:Result)) }
      def either(failure_branch, success_branch); end

      sig(:final) { type_parameters(:NewFailure).params(new_failure: T.type_parameter(:NewFailure)).returns(Result[T.type_parameter(:NewFailure), SuccessType]) }
      def failure_as(new_failure); end

      sig { abstract.params(blk: T.proc.params(arg0: SuccessType).void).returns(Result[FailureType, SuccessType]) }
      def tee(&blk); end

      sig { abstract.type_parameters(:NewFailure).params(blk: T.proc.params(arg0: FailureType).returns(T.type_parameter(:NewFailure))).returns(Result[T.type_parameter(:NewFailure), SuccessType]) }
      def map_failure(&blk); end

      sig { abstract.type_parameters(:NewFailure, :NewSuccess).params(blk: T.proc.params(arg0: FailureType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])).returns(Result[T.type_parameter(:NewFailure), T.any(T.type_parameter(:NewSuccess), SuccessType)]) }
      def flat_map_failure(&blk); end

      sig(:final) { params(another: Mayak::Monads::Result[T.untyped, T.untyped]).returns(T::Boolean) }
      def ==(another); end

      sig(:final) { type_parameters(:NewValue).params(new_value: T.type_parameter(:NewValue)).returns(Result[FailureType, T.type_parameter(:NewValue)]) }
      def as(new_value); end

      sig { abstract.type_parameters(:NewSuccess).params(value: T.type_parameter(:NewSuccess)).returns(Result[FailureType, T.any(T.type_parameter(:NewSuccess), SuccessType)]) }
      def recover(value); end

      sig { abstract.type_parameters(:NewSuccessType).params(blk: T.proc.params(arg0: FailureType).returns(T.type_parameter(:NewSuccessType))).returns(Result[FailureType, T.any(SuccessType, T.type_parameter(:NewSuccessType))]) }
      def recover_with(&blk); end

      sig { abstract.type_parameters(:NewFailure, :NewSuccess).params(blk: T.proc.params(arg0: FailureType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])).returns(Result[T.type_parameter(:NewFailure), T.any(T.type_parameter(:NewSuccess), SuccessType)]) }
      def recover_with_result(&blk); end

      sig { type_parameters(:SuccessType, :FailureType).params(results: T::Array[
              Mayak::Monads::Result[
                T.type_parameter(:FailureType),
                T.type_parameter(:SuccessType)
              ]
            ]).returns(Mayak::Monads::Result[
              T.type_parameter(:FailureType),
              T::Array[T.type_parameter(:SuccessType)]
            ]) }
      def self.sequence(results); end

      class Success
        final!

        include Mayak::Monads::Result
        extend T::Sig
        extend T::Generic
        extend T::Helpers
        FailureType = type_member
        SuccessType = type_member

        sig(:final) { params(value: SuccessType).void }
        def initialize(value); end

        sig(:final) { override.type_parameters(:NewSuccess).params(blk: T.proc.params(arg0: SuccessType).returns(T.type_parameter(:NewSuccess))).returns(Result[FailureType, T.type_parameter(:NewSuccess)]) }
        def map(&blk); end

        sig(:final) { override.type_parameters(:NewSuccess, :NewFailure).params(blk: T.proc.params(arg0: SuccessType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])).returns(Result[T.any(FailureType, T.type_parameter(:NewFailure)), T.type_parameter(:NewSuccess)]) }
        def flat_map(&blk); end

        sig(:final) { override.type_parameters(:NewSuccess, :NewFailure).params(error: T.type_parameter(:NewFailure), blk: T.proc.params(arg0: SuccessType).returns(T::Boolean)).returns(Result[T.any(FailureType, T.type_parameter(:NewFailure)), SuccessType]) }
        def filter_or(error, &blk); end

        sig(:final) { returns(SuccessType) }
        def success; end

        sig(:final) { override.returns(T::Boolean) }
        def success?; end

        sig(:final) { override.returns(T::Boolean) }
        def failure?; end

        sig(:final) { override.type_parameters(:NewSuccessType).params(value: T.type_parameter(:NewSuccessType)).returns(T.any(T.type_parameter(:NewSuccessType), SuccessType)) }
        def success_or(value); end

        sig(:final) { override.type_parameters(:NewFailureType).params(value: T.any(T.type_parameter(:NewFailureType), FailureType)).returns(T.any(T.type_parameter(:NewFailureType), FailureType)) }
        def failure_or(value); end

        sig(:final) { override.returns(Result[SuccessType, FailureType]) }
        def flip; end

        sig(:final) { override.params(blk: T.proc.params(arg0: FailureType).returns(StandardError)).returns(Mayak::Monads::Try[SuccessType]) }
        def to_try(&blk); end

        sig(:final) { override.returns(Mayak::Monads::Maybe[SuccessType]) }
        def to_maybe; end

        sig(:final) { override.type_parameters(:Result).params(failure_branch: T.proc.params(arg0: FailureType).returns(T.type_parameter(:Result)), success_branch: T.proc.params(arg0: SuccessType).returns(T.type_parameter(:Result))).returns(T.type_parameter(:Result)) }
        def either(failure_branch, success_branch); end

        sig(:final) { override.params(blk: T.proc.params(arg0: SuccessType).void).returns(Result[FailureType, SuccessType]) }
        def tee(&blk); end

        sig(:final) { override.type_parameters(:NewFailure).params(blk: T.proc.params(arg0: FailureType).returns(T.type_parameter(:NewFailure))).returns(Result[T.type_parameter(:NewFailure), SuccessType]) }
        def map_failure(&blk); end

        sig(:final) { override.type_parameters(:NewFailure, :NewSuccess).params(blk: T.proc.params(arg0: FailureType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])).returns(Result[T.type_parameter(:NewFailure), T.any(T.type_parameter(:NewSuccess), SuccessType)]) }
        def flat_map_failure(&blk); end

        sig(:final) { override.type_parameters(:NewSuccess).params(value: T.type_parameter(:NewSuccess)).returns(Result[FailureType, T.any(T.type_parameter(:NewSuccess), SuccessType)]) }
        def recover(value); end

        sig(:final) { override.type_parameters(:NewSuccessType).params(blk: T.proc.params(arg0: FailureType).returns(T.type_parameter(:NewSuccessType))).returns(Result[FailureType, T.any(SuccessType, T.type_parameter(:NewSuccessType))]) }
        def recover_with(&blk); end

        sig(:final) { override.type_parameters(:NewFailure, :NewSuccess).params(blk: T.proc.params(arg0: FailureType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])).returns(Result[T.type_parameter(:NewFailure), T.any(T.type_parameter(:NewSuccess), SuccessType)]) }
        def recover_with_result(&blk); end
      end

      class Failure
        final!

        include Mayak::Monads::Result
        extend T::Sig
        extend T::Generic
        extend T::Helpers
        FailureType = type_member
        SuccessType = type_member

        sig(:final) { params(value: FailureType).void }
        def initialize(value); end

        sig(:final) { override.type_parameters(:NewSuccess).params(blk: T.proc.params(arg0: SuccessType).returns(T.type_parameter(:NewSuccess))).returns(Result[FailureType, T.type_parameter(:NewSuccess)]) }
        def map(&blk); end

        sig(:final) { override.type_parameters(:NewSuccess, :NewFailure).params(blk: T.proc.params(arg0: SuccessType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])).returns(Result[T.any(FailureType, T.type_parameter(:NewFailure)), T.type_parameter(:NewSuccess)]) }
        def flat_map(&blk); end

        sig(:final) { override.type_parameters(:NewSuccess, :NewFailure).params(error: T.type_parameter(:NewFailure), blk: T.proc.params(arg0: SuccessType).returns(T::Boolean)).returns(Result[T.any(FailureType, T.type_parameter(:NewFailure)), SuccessType]) }
        def filter_or(error, &blk); end

        sig(:final) { returns(FailureType) }
        def failure; end

        sig(:final) { override.returns(T::Boolean) }
        def success?; end

        sig(:final) { override.returns(T::Boolean) }
        def failure?; end

        sig(:final) { override.type_parameters(:NewSuccessType).params(value: T.type_parameter(:NewSuccessType)).returns(T.any(T.type_parameter(:NewSuccessType), SuccessType)) }
        def success_or(value); end

        sig(:final) { override.type_parameters(:NewFailureType).params(value: T.any(T.type_parameter(:NewFailureType), FailureType)).returns(T.any(T.type_parameter(:NewFailureType), FailureType)) }
        def failure_or(value); end

        sig(:final) { override.returns(Result[SuccessType, FailureType]) }
        def flip; end

        sig(:final) { override.params(blk: T.proc.params(arg0: FailureType).returns(StandardError)).returns(Mayak::Monads::Try[SuccessType]) }
        def to_try(&blk); end

        sig(:final) { override.returns(Mayak::Monads::Maybe[SuccessType]) }
        def to_maybe; end

        sig(:final) { override.type_parameters(:Result).params(failure_branch: T.proc.params(arg0: FailureType).returns(T.type_parameter(:Result)), success_branch: T.proc.params(arg0: SuccessType).returns(T.type_parameter(:Result))).returns(T.type_parameter(:Result)) }
        def either(failure_branch, success_branch); end

        sig(:final) { override.params(blk: T.proc.params(arg0: SuccessType).void).returns(Result[FailureType, SuccessType]) }
        def tee(&blk); end

        sig(:final) { override.type_parameters(:NewFailure).params(blk: T.proc.params(arg0: FailureType).returns(T.type_parameter(:NewFailure))).returns(Result[T.type_parameter(:NewFailure), SuccessType]) }
        def map_failure(&blk); end

        sig(:final) { override.type_parameters(:NewFailure, :NewSuccess).params(blk: T.proc.params(arg0: FailureType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])).returns(Result[T.type_parameter(:NewFailure), T.any(T.type_parameter(:NewSuccess), SuccessType)]) }
        def flat_map_failure(&blk); end

        sig(:final) { override.type_parameters(:NewSuccess).params(value: T.type_parameter(:NewSuccess)).returns(Result[FailureType, T.any(T.type_parameter(:NewSuccess), SuccessType)]) }
        def recover(value); end

        sig(:final) { override.type_parameters(:NewSuccessType).params(blk: T.proc.params(arg0: FailureType).returns(T.type_parameter(:NewSuccessType))).returns(Result[FailureType, T.any(SuccessType, T.type_parameter(:NewSuccessType))]) }
        def recover_with(&blk); end

        sig(:final) { override.type_parameters(:NewFailure, :NewSuccess).params(blk: T.proc.params(arg0: FailureType).returns(Result[T.type_parameter(:NewFailure), T.type_parameter(:NewSuccess)])).returns(Result[T.type_parameter(:NewFailure), T.any(T.type_parameter(:NewSuccess), SuccessType)]) }
        def recover_with_result(&blk); end
      end
    end

    module Try
      abstract!

      sealed!

      extend T::Sig
      extend T::Generic
      Value = type_member(:out)

      sig { abstract.type_parameters(:NewValue).params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewValue))).returns(Try[T.type_parameter(:NewValue)]) }
      def map(&blk); end

      sig { abstract.type_parameters(:NewValue).params(blk: T.proc.params(arg0: Value).returns(Try[T.type_parameter(:NewValue)])).returns(Try[T.type_parameter(:NewValue)]) }
      def flat_map(&blk); end

      sig { abstract.params(error: StandardError, blk: T.proc.params(arg0: Value).returns(T::Boolean)).returns(Try[Value]) }
      def filter_or(error, &blk); end

      sig { abstract.returns(T::Boolean) }
      def success?; end

      sig { abstract.returns(T::Boolean) }
      def failure?; end

      sig { abstract.type_parameters(:NewValue).params(value: T.type_parameter(:NewValue)).returns(T.any(T.type_parameter(:NewValue), Value)) }
      def success_or(value); end

      sig { abstract.params(value: StandardError).returns(StandardError) }
      def failure_or(value); end

      sig { abstract.type_parameters(:Result).params(failure_branch: T.proc.params(arg0: StandardError).returns(T.type_parameter(:Result)), success_branch: T.proc.params(arg0: Value).returns(T.type_parameter(:Result))).returns(T.type_parameter(:Result)) }
      def either(failure_branch, success_branch); end

      sig { abstract.params(blk: T.proc.params(arg0: Value).void).returns(Try[Value]) }
      def tee(&blk); end

      sig { abstract.params(blk: T.proc.params(arg0: StandardError).returns(StandardError)).returns(Try[Value]) }
      def map_failure(&blk); end

      sig { abstract.type_parameters(:NewValue).params(blk: T.proc.params(arg0: StandardError).returns(Try[T.type_parameter(:NewValue)])).returns(Try[T.any(T.type_parameter(:NewValue), Value)]) }
      def flat_map_failure(&blk); end

      sig { abstract.type_parameters(:Failure).params(blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:Failure))).returns(Mayak::Monads::Result[T.type_parameter(:Failure), Value]) }
      def to_result(&blk); end

      sig { abstract.returns(Mayak::Monads::Maybe[Value]) }
      def to_maybe; end

      sig(:final) { params(other: Mayak::Monads::Try[T.untyped]).returns(T::Boolean) }
      def ==(other); end

      sig(:final) { type_parameters(:NewValue).params(new_value: T.type_parameter(:NewValue)).returns(Try[T.type_parameter(:NewValue)]) }
      def as(new_value); end

      sig(:final) { params(new_failure: StandardError).returns(Try[Value]) }
      def failure_as(new_failure); end

      sig { abstract.type_parameters(:NewValue).params(value: T.type_parameter(:NewValue)).returns(Try[T.any(T.type_parameter(:NewValue), Value)]) }
      def recover(value); end

      sig { abstract.type_parameters(:NewValue).params(blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:NewValue))).returns(Try[T.any(T.type_parameter(:NewValue), Value)]) }
      def recover_with(&blk); end

      sig { abstract.type_parameters(:NewValue).params(error_type: T.class_of(StandardError), blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:NewValue))).returns(Try[T.any(T.type_parameter(:NewValue), Value)]) }
      def recover_on(error_type, &blk); end

      sig(:final) { type_parameters(:NewValue).params(blk: T.proc.params(arg0: StandardError).returns(Try[T.type_parameter(:NewValue)])).returns(Try[T.any(T.type_parameter(:NewValue), Value)]) }
      def recover_with_try(&blk); end

      sig { type_parameters(:Value).params(results: T::Array[Mayak::Monads::Try[T.type_parameter(:Value)]]).returns(Mayak::Monads::Try[T::Array[T.type_parameter(:Value)]]) }
      def self.sequence(results); end

      sig { type_parameters(:Value).params(value: T.type_parameter(:Value), error: StandardError, blk: T.proc.returns(T::Boolean)).returns(Mayak::Monads::Try[T.type_parameter(:Value)]) }
      def self.check(value, error, &blk); end

      sig { params(error: StandardError, blk: T.proc.returns(T::Boolean)).returns(Mayak::Monads::Try[NilClass]) }
      def self.guard(error, &blk); end

      class Success
        final!

        include Mayak::Monads::Try
        extend T::Sig
        extend T::Generic
        Value = type_member

        sig(:final) { params(value: Value).void }
        def initialize(value); end

        sig(:final) { override.type_parameters(:NewValue).params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewValue))).returns(Try[T.type_parameter(:NewValue)]) }
        def map(&blk); end

        sig(:final) { override.type_parameters(:NewValue).params(blk: T.proc.params(arg0: Value).returns(Try[T.type_parameter(:NewValue)])).returns(Try[T.type_parameter(:NewValue)]) }
        def flat_map(&blk); end

        sig(:final) { override.params(error: StandardError, blk: T.proc.params(arg0: Value).returns(T::Boolean)).returns(Try[Value]) }
        def filter_or(error, &blk); end

        sig(:final) { returns(Value) }
        def success; end

        sig(:final) { override.returns(T::Boolean) }
        def success?; end

        sig(:final) { override.returns(T::Boolean) }
        def failure?; end

        sig(:final) { override.type_parameters(:NewValue).params(value: T.any(T.type_parameter(:NewValue), Value)).returns(T.any(T.type_parameter(:NewValue), Value)) }
        def success_or(value); end

        sig(:final) { override.params(value: StandardError).returns(StandardError) }
        def failure_or(value); end

        sig(:final) { override.type_parameters(:Result).params(failure_branch: T.proc.params(arg0: StandardError).returns(T.type_parameter(:Result)), success_branch: T.proc.params(arg0: Value).returns(T.type_parameter(:Result))).returns(T.type_parameter(:Result)) }
        def either(failure_branch, success_branch); end

        sig(:final) { override.params(blk: T.proc.params(arg0: Value).void).returns(Try[Value]) }
        def tee(&blk); end

        sig(:final) { override.params(blk: T.proc.params(arg0: StandardError).returns(StandardError)).returns(Try[Value]) }
        def map_failure(&blk); end

        sig(:final) { override.type_parameters(:NewValue).params(blk: T.proc.params(arg0: StandardError).returns(Try[T.type_parameter(:NewValue)])).returns(Try[T.any(T.type_parameter(:NewValue), Value)]) }
        def flat_map_failure(&blk); end

        sig(:final) { override.type_parameters(:Failure).params(blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:Failure))).returns(Mayak::Monads::Result[T.type_parameter(:Failure), Value]) }
        def to_result(&blk); end

        sig(:final) { override.returns(Mayak::Monads::Maybe[Value]) }
        def to_maybe; end

        sig(:final) { override.type_parameters(:NewValue).params(error_type: T.class_of(StandardError), blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:NewValue))).returns(Try[T.any(T.type_parameter(:NewValue), Value)]) }
        def recover_on(error_type, &blk); end

        sig(:final) { override.type_parameters(:NewValue).params(value: T.type_parameter(:NewValue)).returns(Try[T.any(T.type_parameter(:NewValue), Value)]) }
        def recover(value); end

        sig(:final) { override.type_parameters(:NewValue).params(blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:NewValue))).returns(Try[T.any(T.type_parameter(:NewValue), Value)]) }
        def recover_with(&blk); end
      end

      class Failure
        final!

        include Mayak::Monads::Try
        extend T::Sig
        extend T::Generic
        Value = type_member

        sig(:final) { params(value: StandardError).void }
        def initialize(value); end

        sig(:final) { override.type_parameters(:NewValue).params(blk: T.proc.params(arg0: Value).returns(T.type_parameter(:NewValue))).returns(Try[T.type_parameter(:NewValue)]) }
        def map(&blk); end

        sig(:final) { override.type_parameters(:NewValue).params(blk: T.proc.params(arg0: Value).returns(Try[T.type_parameter(:NewValue)])).returns(Try[T.type_parameter(:NewValue)]) }
        def flat_map(&blk); end

        sig(:final) { override.params(error: StandardError, blk: T.proc.params(arg0: Value).returns(T::Boolean)).returns(Try[Value]) }
        def filter_or(error, &blk); end

        sig(:final) { returns(StandardError) }
        def failure; end

        sig(:final) { override.returns(T::Boolean) }
        def success?; end

        sig(:final) { override.returns(T::Boolean) }
        def failure?; end

        sig(:final) { override.type_parameters(:NewValue).params(value: T.any(T.type_parameter(:NewValue), Value)).returns(T.any(T.type_parameter(:NewValue), Value)) }
        def success_or(value); end

        sig(:final) { override.params(value: StandardError).returns(StandardError) }
        def failure_or(value); end

        sig(:final) { override.type_parameters(:Result).params(failure_branch: T.proc.params(arg0: StandardError).returns(T.type_parameter(:Result)), success_branch: T.proc.params(arg0: Value).returns(T.type_parameter(:Result))).returns(T.type_parameter(:Result)) }
        def either(failure_branch, success_branch); end

        sig(:final) { override.params(blk: T.proc.params(arg0: Value).void).returns(Try[Value]) }
        def tee(&blk); end

        sig(:final) { override.params(blk: T.proc.params(arg0: StandardError).returns(StandardError)).returns(Try[Value]) }
        def map_failure(&blk); end

        sig(:final) { override.type_parameters(:NewValue).params(blk: T.proc.params(arg0: StandardError).returns(Try[T.type_parameter(:NewValue)])).returns(Try[T.any(T.type_parameter(:NewValue), Value)]) }
        def flat_map_failure(&blk); end

        sig(:final) { override.type_parameters(:Failure).params(blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:Failure))).returns(Mayak::Monads::Result[T.type_parameter(:Failure), Value]) }
        def to_result(&blk); end

        sig(:final) { override.returns(Mayak::Monads::Maybe[Value]) }
        def to_maybe; end

        sig(:final) { override.type_parameters(:NewValue).params(error_type: T.class_of(StandardError), blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:NewValue))).returns(Try[T.any(T.type_parameter(:NewValue), Value)]) }
        def recover_on(error_type, &blk); end

        sig(:final) { override.type_parameters(:NewValue).params(value: T.type_parameter(:NewValue)).returns(Try[T.any(T.type_parameter(:NewValue), Value)]) }
        def recover(value); end

        sig(:final) { override.type_parameters(:NewValue).params(blk: T.proc.params(arg0: StandardError).returns(T.type_parameter(:NewValue))).returns(Try[T.any(T.type_parameter(:NewValue), Value)]) }
        def recover_with(&blk); end
      end

      module Mixin
        include Kernel
        extend T::Sig

        sig { type_parameters(:Value).params(exception_classes: T.class_of(StandardError), blk: T.proc.returns(T.type_parameter(:Value))).returns(Try[T.type_parameter(:Value)]) }
        def Try(*exception_classes, &blk); end

        sig { type_parameters(:Value).params(blk: T.proc.returns(T.type_parameter(:Value))).returns(Try[T.type_parameter(:Value)]) }
        def for_try(&blk); end

        sig { type_parameters(:Value).params(value: Try[T.type_parameter(:Value)]).returns(T.type_parameter(:Value)) }
        def do_try!(value); end

        sig { type_parameters(:Value).params(value: T.type_parameter(:Value), error: StandardError, blk: T.proc.returns(T::Boolean)).returns(T.type_parameter(:Value)) }
        def check_try!(value, error, &blk); end

        sig { params(error: StandardError, blk: T.proc.returns(T::Boolean)).void }
        def guard_try!(error, &blk); end

        class Halt < StandardError
          extend T::Sig
          extend T::Generic
          extend T::Helpers
          SuccessType = type_member

          sig { returns(Mayak::Monads::Try[SuccessType]) }
          attr_reader :result

          sig { params(result: Mayak::Monads::Try[SuccessType]).void }
          def initialize(result); end
        end
      end
    end
  end
end
