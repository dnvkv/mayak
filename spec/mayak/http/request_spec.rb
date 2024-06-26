# typed: false
# frozen_string_literal: true

require 'spec_helper'

describe Mayak::Http::Request do
  let(:verb) { Mayak::Http::Verb.values.sample }
  let(:url) { URI.parse("https://example.com/page") }
  let(:headers) { {} }
  let(:body) { '' }

  subject { Mayak::Http::Request.new(verb: verb, url: url, headers: headers, body: body) }

  describe '#content_type' do
    let(:content_type) { 'application/text' }
    let(:headers) { { "Content-Type" => content_type } }

    it { expect(subject.content_type).to eq(content_type) }
  end

  describe '#with_content_type' do
    let(:content_type) { 'application/text' }

    it 'creates new instance with Content-Type header' do
      new_instance = subject.with_content_type(content_type)

      expect(subject).not_to eq(new_instance)
      expect(new_instance.content_type).to eq(content_type)
    end
  end
end
