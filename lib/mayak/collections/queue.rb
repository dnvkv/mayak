# frozen_string_literal: true
# typed: strict

module Mayak
  module Collections
    class Queue
      extend T::Sig
      extend T::Helpers
      extend T::Generic

      Value = type_member

      class Node < T::Struct
        extend T::Sig
        extend T::Generic

        Value = type_member

        const :value, Value
        prop  :next,  T.nilable(Node[Value])
      end
      private_constant :Node

      sig { returns(Integer) }
      attr_reader :size

      sig { params(initial: T::Array[Value]).void }
      def initialize(initial: [])
        @head = T.let(nil, T.nilable(Node[Value]))
        @tail = T.let(nil, T.nilable(Node[Value]))
        @size = T.let(0, Integer)
        initial.each { |element| enqueue(element) }
      end

      sig { params(element: Value).void }
      def enqueue(element)
        if @head.nil?
          @head = Node[Value].new(value: element, next: nil)
          @tail = @head
          @size += 1
        else
          T.must(@tail).next = Node[Value].new(value: element, next: nil)
          @tail = T.must(@tail).next
          @size += 1
        end
      end

      sig { returns(T.nilable(Value)) }
      def peak
        return if @head.nil?

        @head.value
      end

      sig { returns(T.nilable(Value)) }
      def dequeue
        return if @size == 0
        return if @head.nil?

        element = @head.value
        @head = @head.next
        @size -= 1
        @tail = nil if @size == 0
        element
      end

      sig { returns(T::Boolean) }
      def empty?
        @size == 0
      end
    end
  end
end