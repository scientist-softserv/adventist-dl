# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`

RSpec.describe Image do
  describe 'indexer' do
    subject { described_class.indexer }

    it { is_expected.to eq WorkIndexer }
  end
end
