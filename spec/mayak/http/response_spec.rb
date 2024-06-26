# typed: false
# frozen_string_literal: true

require 'spec_helper'

describe Mayak::Http::Response do
  let(:status) { 200 }
  let(:headers) { {} }
  let(:body) { '' }

  subject { Mayak::Http::Response.new(status: status, headers: headers, body: body) }

  context 'successful response' do
    let(:status) { 200 }

    describe '#success?' do
      it { expect(subject).to be_success }
    end

    describe '#failure?' do
      it { expect(subject).not_to be_failure }
    end
  end

  context 'failure response' do
    let(:status) { 404 }

    describe '#success?' do
      it { expect(subject).not_to be_success }
    end

    describe '#failure?' do
      it { expect(subject).to be_failure }
    end
  end
end
