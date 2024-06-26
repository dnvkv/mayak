# frozen_string_literal: true
# typed: strict

module Mayak
  module Collections
    class PriorityQueue
      extend T::Sig
      extend T::Generic

      Element  = type_member
      Priority = type_member

      sig { returns(Integer) }
      attr_reader :size

      sig { params(compare: T.proc.params(arg0: Priority, arg2: Priority).returns(T::Boolean)).void }
      def initialize(&compare)
        @array   = T.let([], T::Array[T.nilable([Element, Priority])])
        @compare = T.let(compare, T.proc.params(arg0: Priority, arg2: Priority).returns(T::Boolean))
        @size    = T.let(0, Integer)
      end

      sig { params(element: Element, priority: Priority).void }
      def enqueue(element, priority)
        @array[@size] = [element, priority]
        @size += 1
        sift_up(size - 1)
      end

      sig { returns(T.nilable([Element, Priority])) }
      def dequeue
        element_index = 0
        result = @array[element_index]

        if @size > 1
          @size -= 1
          @array[element_index] = @array[@size]
          sift_down(element_index)
        else
          @size = 0
        end

        @array[@size] = nil

        result
      end

      sig { returns(T.nilable([Element, Priority])) }
      def peak
        @array.first
      end

      sig { void }
      def clear
        @array = []
        @size = 0
      end

      sig { returns(T::Array[[Element, Priority]]) }
      def to_a
        @array.compact
      end

      sig { returns(T::Boolean) }
      def empty?
        size == 0
      end

      private

      sig { params(element_index: Integer).void }
      def sift_up(element_index)
        index = element_index

        while !root?(index) && compare(index, parent_index(index))
          swap(index, parent_index(index))
          index = parent_index(index)
        end
      end

      sig { params(element_index: Integer).void }
      def sift_down(element_index)
        index = element_index

        loop do
          left_index = left_child_index(index)
          right_index = right_child_index(index)

          if has_left_child(index) && compare(left_index, index)
            swap(index, left_index)
            index = left_index
          elsif has_right_child(index) && compare(right_index, index)
            swap(index, right_index)
            index = right_index
          else
            break
          end
        end
      end

      sig { params(index1: Integer, index2: Integer).void }
      def swap(index1, index2)
        @array[index1], @array[index2] = @array[index2], @array[index1]
      end

      sig { params(index1: Integer, index2: Integer).returns(T::Boolean) }
      def compare(index1, index2)
        value1 = @array[index1]
        value2 = @array[index2]

        raise StandardError.new("index out of bound") if value1.nil? || value2.nil?

        _, priority1 = value1
        _, priority2 = value2

        @compare.call(priority1, priority2)
      end

      sig { params(index: Integer).returns(T::Boolean) }
      def has_parent(index)
        index >= 1
      end

      sig { params(index: Integer).returns(Integer) }
      def parent_index(index)
        ((index - 1) / 2).floor
      end

      sig { params(index: Integer).returns(T::Boolean) }
      def has_left_child(index)
        left_child_index(index) < @size
      end

      sig { params(index: Integer).returns(Integer) }
      def left_child_index(index)
        index * 2 + 1
      end

      sig { params(index: Integer).returns(T::Boolean) }
      def has_right_child(index)
        right_child_index(index) < @size
      end

      sig { params(index: Integer).returns(Integer) }
      def right_child_index(index)
        index * 2 + 2
      end

      sig { params(index: Integer).returns(T::Boolean) }
      def root?(index)
        index == 0
      end
    end
  end
end
