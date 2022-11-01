# frozen_string_literal: true
require "rails_helper"

# From Hyrax
require "hyrax/specs/shared_specs/derivative_service"

RSpec.describe Adventist::TextFileTextExtractionService do
  let(:valid_file_set) do
    FileSet.new.tap do |f|
      allow(f).to receive(:mime_type).and_return(described_class::VALID_MIME_TYPES.first)
    end
  end

  let(:invalid_file_set) do
    FileSet.new.tap do |f|
      allow(f).to receive(:mime_type).and_return("image/jpeg")
    end
  end

  subject { described_class.new(valid_file_set) }

  it_behaves_like "a Hyrax::DerivativeService"

  describe '#valid?' do
    context 'when given a non-text format' do
      subject { described_class.new(invalid_file_set) }
      it { is_expected.not_to be_valid }
    end
  end

  describe '#create_derivatives' do
    let(:filename) { __FILE__ }
    let(:valid_file_set) do
      FactoryBot.create(:file_set, file: filename).tap do |f|
        allow(f).to receive(:mime_type).and_return(described_class::VALID_MIME_TYPES.first)
      end
    end

    it 'assigns the extracted text to the file_set', aggregate_failures: true do
      expect(subject.create_derivatives(filename)).to be_truthy
      expect(valid_file_set.extracted_text.content).to eq(File.read(filename))
    end
  end
end