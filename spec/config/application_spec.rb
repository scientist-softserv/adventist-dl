# frozen_string_literal: true

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'config/application.rb' do
  # rubocop:enable RSpec/DescribeClass
  describe 'IiifPrint::DerivativeRodeoService.named_derivatives_and_generators_filter' do
    subject do
      IiifPrint::DerivativeRodeoService
        .named_derivatives_and_generators_filter
        .call(file_set: file_set,
              filename: filename,
              named_derivatives_and_generators: named_derivatives_and_generators).keys
    end

    let(:file_set) { double('file_set') }
    let(:named_derivatives_and_generators) do
      IiifPrint::DerivativeRodeoService.named_derivatives_and_generators_by_type.fetch(:image).deep_dup
    end

    context 'for a thumbnail file' do
      let(:filename) { 'image.TN.jpg' }

      it 'will only generate a thumbnail' do
        expect(subject).to eq [:thumbnail]
      end
    end

    context 'for a non-thumbnail file' do
      let(:filename) { 'image.jpg' }

      it 'will generate all derivatives' do
        expect(subject).to eq %i[thumbnail json xml txt]
      end
    end
  end
end
