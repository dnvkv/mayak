# frozen_string_literal: true
# typed: strict

require 'uri'
require_relative 'verb'

module Mayak
  module Http
    class Request < T::Struct
      extend T::Sig

      const :verb,    Mayak::Http::Verb
      const :url,     URI
      const :headers, T::Hash[String, String], default: {}
      const :body,    T.nilable(String)
      
      CONTENT_TYPE_HEADER = T.let("Content-Type", String)

      sig(:final) { params(other: Mayak::Http::Request).returns(T::Boolean) }
      def ==(other)
        verb == other.verb && url.to_s == other.url.to_s && headers && other.headers && body == other.body
      end

      sig(:final) { params(other: Mayak::Http::Request).returns(T::Boolean) }
      def eql?(other)
        self == other
      end

      sig { returns(Integer) }
      def hash
        [verb, url.to_s, headers, body].hash
      end

      sig { returns(T.nilable(String)) }
      def content_type
        headers[CONTENT_TYPE_HEADER]
      end

      sig { params(type: String).returns(Mayak::Http::Request) }
      def with_content_type(type)
        Mayak::Http::Request.new(
          verb:    verb,
          url:     url,
          headers: headers.merge(CONTENT_TYPE_HEADER => type),
          body:    body
        )
      end

      sig { params(url: URI, headers: T::Hash[String, String], body: T.nilable(String)).returns(Mayak::Http::Request) }
      def self.get(url:, headers: {}, body: nil)
        Mayak::Http::Request.new(
          verb:    Mayak::Http::Verb::Get,
          url:     url,
          headers: headers,
          body:    body
        )
      end

      sig { params(url: URI, headers: T::Hash[String, String], body: T.nilable(String)).returns(Mayak::Http::Request) }
      def self.head(url:, headers: {}, body: nil)
        Mayak::Http::Request.new(
          verb:    Mayak::Http::Verb::Head,
          url:     url,
          headers: headers,
          body:    body
        )
      end

      sig { params(url: URI, headers: T::Hash[String, String], body: T.nilable(String)).returns(Mayak::Http::Request) }
      def self.post(url:, headers: {}, body: nil)
        Mayak::Http::Request.new(
          verb:    Mayak::Http::Verb::Post,
          url:     url,
          headers: headers,
          body:    body
        )
      end

      sig { params(url: URI, headers: T::Hash[String, String], body: T.nilable(String)).returns(Mayak::Http::Request) }
      def self.put(url:, headers: {}, body: nil)
        Mayak::Http::Request.new(
          verb:    Mayak::Http::Verb::Put,
          url:     url,
          headers: headers,
          body:    body
        )
      end

      sig { params(url: URI, headers: T::Hash[String, String], body: T.nilable(String)).returns(Mayak::Http::Request) }
      def self.patch(url:, headers: {}, body: nil)
        Mayak::Http::Request.new(
          verb:    Mayak::Http::Verb::Patch,
          url:     url,
          headers: headers,
          body:    body
        )
      end

      sig { params(url: URI, headers: T::Hash[String, String], body: T.nilable(String)).returns(Mayak::Http::Request) }
      def self.delete(url:, headers: {}, body: nil)
        Mayak::Http::Request.new(
          verb:    Mayak::Http::Verb::Delete,
          url:     url,
          headers: headers,
          body:    body
        )
      end
    end
  end
end
