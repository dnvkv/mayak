# typed: false
# frozen_string_literal: true

require "spec_helper"

describe Mayak::Lazy do
  describe ".new" do
    it "doesn't call a block" do
      buffer = []
      expect { ::Mayak::Lazy[Integer].new { buffer << 1; 1 } }.not_to change { buffer }
    end
  end

  describe "#value" do
    it "returns a value computed in a block" do
      expect(::Mayak::Lazy[Integer].new { 1 }.value).to eq(1)
    end

    it "executes a passed block" do
      buffer = []
      expect { ::Mayak::Lazy[Integer].new { buffer << 1; 1 }.value }.to change { buffer }.from([]).to([1])
    end


    it "executes block only once" do
      buffer = []
      lazy = ::Mayak::Lazy[Integer].new { buffer << 1; 1 }
      lazy.value
      expect { lazy.value }.not_to change { buffer }
    end
  end

  describe "#map" do
    it "returns updated lazy" do
      lazy = ::Mayak::Lazy[Integer].new { 1 }
      expect(lazy.map(&:to_s).value).to eq("1")
    end

    it "doesn't invoke thunk before forcing value" do
      buffer = []
      lazy = ::Mayak::Lazy[Integer].new { buffer << 1; 1 }
      expect do
        lazy.map do |value|
          buffer << 2
          value.to_s
        end
      end.not_to change { buffer }

      expect do
        lazy.map do |value|
          buffer << 2
          value.to_s
        end.value
      end.to change { buffer }.from([]).to([1, 2])
    end
  end

  describe "#flat_map" do
    it "returns updated lazy" do
      lazy = ::Mayak::Lazy[Integer].new { 1 }
      expect(lazy.flat_map { |value| ::Mayak::Lazy[String].new { value.to_s } }.value).to eq("1")
    end

    it "doesn't invoke thunk before forcing value" do
      buffer = []
      lazy = ::Mayak::Lazy[Integer].new { buffer << 1; 1 }
      expect do
        lazy.flat_map do |value|
          buffer << 2
          ::Mayak::Lazy[String].new { value.to_s }
        end
      end.not_to change { buffer }

      expect do
        lazy.flat_map do |value|
          buffer << 2
          ::Mayak::Lazy[String].new { value.to_s }
        end.value
      end.to change { buffer }.from([]).to([1, 2])
    end
  end

  describe "#combine" do
    it "combine two lazy into one" do
      lazy1 = ::Mayak::Lazy[Integer].new { 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { 2 }
      expect(lazy1.combine(lazy2) { |first, second| [first, second] }.value).to eq([1, 2])
    end

    it "doesn't invoke thunk before forcing value" do
      buffer = []
      lazy1 = ::Mayak::Lazy[Integer].new { buffer << 1; 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { buffer << 2; 2 }
      expect { lazy1.combine(lazy2) { |first, second| [first, second] } }.not_to change { buffer }
      expect { lazy1.combine(lazy2) { |first, second| [first, second] }.value }.to change { buffer }.from([]).to([1, 2])
    end
  end

  describe ".combine_two" do
    it "combine two lazy into one" do
      lazy1 = ::Mayak::Lazy[Integer].new { 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { 2 }
      expect(::Mayak::Lazy.combine_two(lazy1, lazy2) { |first, second| [first, second] }.value).to eq([1, 2])
    end

    it "doesn't invoke thunk before forcing value" do
      buffer = []
      lazy1 = ::Mayak::Lazy[Integer].new { buffer << 1; 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { buffer << 2; 2 }
      expect { ::Mayak::Lazy.combine_two(lazy1, lazy2) { |first, second| [first, second] } }.not_to change { buffer }
      expect { ::Mayak::Lazy.combine_two(lazy1, lazy2) { |first, second| [first, second] }.value }.to change { buffer }.from([]).to([1, 2])
    end
  end

  describe ".combine_two" do
    it "combine two lazy into one" do
      lazy1 = ::Mayak::Lazy[Integer].new { 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { 2 }
      expect(::Mayak::Lazy.combine_two(lazy1, lazy2) { |first, second| [first, second] }.value).to eq([1, 2])
    end

    it "doesn't invoke thunk before forcing value" do
      buffer = []
      lazy1 = ::Mayak::Lazy[Integer].new { buffer << 1; 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { buffer << 2; 2 }
      expect { ::Mayak::Lazy.combine_two(lazy1, lazy2) { |first, second| [first, second] } }.not_to change { buffer }
      expect { ::Mayak::Lazy.combine_two(lazy1, lazy2) { |first, second| [first, second] }.value }.to change { buffer }.from([]).to([1, 2])
    end
  end

  describe ".combine_three" do
    it "combine three lazy into one" do
      lazy1 = ::Mayak::Lazy[Integer].new { 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { 2 }
      lazy3 = ::Mayak::Lazy[Integer].new { 3 }
      expect(
        ::Mayak::Lazy.combine_three(
          lazy1, lazy2, lazy3
        ) { |first, second, third| [first, second, third] }.value
      ).to eq([1, 2, 3])
    end

    it "doesn't invoke thunk before forcing value" do
      buffer = []
      lazy1 = ::Mayak::Lazy[Integer].new { buffer << 1; 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { buffer << 2; 2 }
      lazy3 = ::Mayak::Lazy[Integer].new { buffer << 3; 3 }
      expect {
        ::Mayak::Lazy.combine_three(
          lazy1, lazy2, lazy3
        ) { |first, second, third| [first, second, third] }
      }.not_to change { buffer }

      expect {
        ::Mayak::Lazy.combine_three(
          lazy1, lazy2, lazy3
        ) { |first, second, third| [first, second, third] }.value
      }.to change { buffer }.from([]).to([1, 2, 3])
    end
  end

  describe ".combine_four" do
    it "combine four lazy into one" do
      lazy1 = ::Mayak::Lazy[Integer].new { 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { 2 }
      lazy3 = ::Mayak::Lazy[Integer].new { 3 }
      lazy4 = ::Mayak::Lazy[Integer].new { 4 }
      expect(
        ::Mayak::Lazy.combine_four(
          lazy1, lazy2, lazy3, lazy4
        ) { |first, second, third, fourth| [first, second, third, fourth] }.value
      ).to eq([1, 2, 3, 4])
    end

    it "doesn't invoke thunk before forcing value" do
      buffer = []
      lazy1 = ::Mayak::Lazy[Integer].new { buffer << 1; 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { buffer << 2; 2 }
      lazy3 = ::Mayak::Lazy[Integer].new { buffer << 3; 3 }
      lazy4 = ::Mayak::Lazy[Integer].new { buffer << 4; 4 }
      expect {
        ::Mayak::Lazy.combine_four(
          lazy1, lazy2, lazy3, lazy4
        ) { |first, second, third, fourth| [first, second, third, fourth] }
      }.not_to change { buffer }

      expect {
        ::Mayak::Lazy.combine_four(
          lazy1, lazy2, lazy3, lazy4
        ) { |first, second, third, fourth| [first, second, third, fourth] }.value
      }.to change { buffer }.from([]).to([1, 2, 3, 4])
    end
  end

  describe ".combine_five" do
    it "combine five lazy into one" do
      lazy1 = ::Mayak::Lazy[Integer].new { 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { 2 }
      lazy3 = ::Mayak::Lazy[Integer].new { 3 }
      lazy4 = ::Mayak::Lazy[Integer].new { 4 }
      lazy5 = ::Mayak::Lazy[Integer].new { 5 }
      expect(
        ::Mayak::Lazy.combine_five(
          lazy1, lazy2, lazy3, lazy4, lazy5
        ) { |first, second, third, fourth, fifth| [first, second, third, fourth, fifth] }.value
      ).to eq([1, 2, 3, 4, 5])
    end

    it "doesn't invoke thunk before forcing value" do
      buffer = []
      lazy1 = ::Mayak::Lazy[Integer].new { buffer << 1; 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { buffer << 2; 2 }
      lazy3 = ::Mayak::Lazy[Integer].new { buffer << 3; 3 }
      lazy4 = ::Mayak::Lazy[Integer].new { buffer << 4; 4 }
      lazy5 = ::Mayak::Lazy[Integer].new { buffer << 5; 5 }
      expect {
        ::Mayak::Lazy.combine_five(
          lazy1, lazy2, lazy3, lazy4, lazy5
        ) { |first, second, third, fourth, fifth| [first, second, third, fourth, fifth] }
      }.not_to change { buffer }

      expect {
        ::Mayak::Lazy.combine_five(
          lazy1, lazy2, lazy3, lazy4, lazy5
        ) { |first, second, third, fourth, fifth| [first, second, third, fourth, fifth] }.value
      }.to change { buffer }.from([]).to([1, 2, 3, 4, 5])
    end
  end

  describe ".combine_six" do
    it "combine six lazy into one" do
      lazy1 = ::Mayak::Lazy[Integer].new { 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { 2 }
      lazy3 = ::Mayak::Lazy[Integer].new { 3 }
      lazy4 = ::Mayak::Lazy[Integer].new { 4 }
      lazy5 = ::Mayak::Lazy[Integer].new { 5 }
      lazy6 = ::Mayak::Lazy[Integer].new { 6 }
      expect(
        ::Mayak::Lazy.combine_six(
          lazy1, lazy2, lazy3, lazy4, lazy5, lazy6
        ) { |first, second, third, fourth, fifth, sixth| [first, second, third, fourth, fifth, sixth] }.value
      ).to eq([1, 2, 3, 4, 5, 6])
    end

    it "doesn't invoke thunk before forcing value" do
      buffer = []
      lazy1 = ::Mayak::Lazy[Integer].new { buffer << 1; 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { buffer << 2; 2 }
      lazy3 = ::Mayak::Lazy[Integer].new { buffer << 3; 3 }
      lazy4 = ::Mayak::Lazy[Integer].new { buffer << 4; 4 }
      lazy5 = ::Mayak::Lazy[Integer].new { buffer << 5; 5 }
      lazy6 = ::Mayak::Lazy[Integer].new { buffer << 6; 6 }
      expect {
        ::Mayak::Lazy.combine_six(
          lazy1, lazy2, lazy3, lazy4, lazy5, lazy6
        ) { |first, second, third, fourth, fifth, sixth| [first, second, third, fourth, fifth, sixth] }
      }.not_to change { buffer }

      expect {
        ::Mayak::Lazy.combine_six(
          lazy1, lazy2, lazy3, lazy4, lazy5, lazy6
        ) { |first, second, third, fourth, fifth, sixth| [first, second, third, fourth, fifth, sixth] }.value
      }.to change { buffer }.from([]).to([1, 2, 3, 4, 5, 6])
    end
  end

  describe ".combine_seven" do
    it "combine seven lazy into one" do
      lazy1 = ::Mayak::Lazy[Integer].new { 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { 2 }
      lazy3 = ::Mayak::Lazy[Integer].new { 3 }
      lazy4 = ::Mayak::Lazy[Integer].new { 4 }
      lazy5 = ::Mayak::Lazy[Integer].new { 5 }
      lazy6 = ::Mayak::Lazy[Integer].new { 6 }
      lazy7 = ::Mayak::Lazy[Integer].new { 7 }
      expect(
        ::Mayak::Lazy.combine_seven(
          lazy1, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7
        ) { |first, second, third, fourth, fifth, sixth, seventh| [first, second, third, fourth, fifth, sixth, seventh] }.value
      ).to eq([1, 2, 3, 4, 5, 6, 7])
    end

    it "doesn't invoke thunk before forcing value" do
      buffer = []
      lazy1 = ::Mayak::Lazy[Integer].new { buffer << 1; 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { buffer << 2; 2 }
      lazy3 = ::Mayak::Lazy[Integer].new { buffer << 3; 3 }
      lazy4 = ::Mayak::Lazy[Integer].new { buffer << 4; 4 }
      lazy5 = ::Mayak::Lazy[Integer].new { buffer << 5; 5 }
      lazy6 = ::Mayak::Lazy[Integer].new { buffer << 6; 6 }
      lazy7 = ::Mayak::Lazy[Integer].new { buffer << 7; 7 }
      expect {
        ::Mayak::Lazy.combine_seven(
          lazy1, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7
        ) { |first, second, third, fourth, fifth, sixth, seventh| [first, second, third, fourth, fifth, sixth, seventh] }
      }.not_to change { buffer }

      expect {
        ::Mayak::Lazy.combine_seven(
          lazy1, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7
        ) { |first, second, third, fourth, fifth, sixth, seventh| [first, second, third, fourth, fifth, sixth, seventh] }.value
      }.to change { buffer }.from([]).to([1, 2, 3, 4, 5, 6, 7])
    end
  end

  describe ".combine_many" do
    it "combine many lazies into one" do
      lazy1 = ::Mayak::Lazy[Integer].new { 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { 1 }
      lazy3 = ::Mayak::Lazy[Integer].new { 1 }
      expect(
        ::Mayak::Lazy.combine_many([lazy1, lazy2, lazy3], 0) { |first, second| first + second }.value
      ).to eq(3)
    end
  end

  describe ".sequence" do
    it "combine array of lazies into lazy of array" do
      lazy1 = ::Mayak::Lazy[Integer].new { 1 }
      lazy2 = ::Mayak::Lazy[Integer].new { 2 }
      lazy3 = ::Mayak::Lazy[Integer].new { 3 }
      expect(
        ::Mayak::Lazy.sequence([lazy1, lazy2, lazy3]).value
      ).to eq([1, 2, 3])
    end
  end
end