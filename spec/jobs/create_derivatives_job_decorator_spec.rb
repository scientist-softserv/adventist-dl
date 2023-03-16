# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateDerivativesJobDecorator do
  it "is prepended into CreateDerivativesJob" do
    expect(CreateDerivativesJob.included_modules).to include(described_class)
  end

  describe '.create_derivative_for?' do
    subject { described_class.create_derivative_for?(file_set: file_set) }

    let(:file_set) { double(FileSet, label: label) }

    context 'when the file set is for a non-archival PDF' do
      let(:label) { "my-non-archival#{described_class::NON_ARCHIVAL_PDF_SUFFIX}" }

      it { is_expected.to be_falsey }
    end

    context 'when the file set is for anything else' do
      let(:label) { "any-other.jpg.or.pdf" }

      it { is_expected.to be_truthy }
    end
  end
end
