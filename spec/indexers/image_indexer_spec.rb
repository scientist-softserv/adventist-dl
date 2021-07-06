# frozen_string_literal: true

RSpec.describe ImageIndexer do
  subject(:solr_document) { service.generate_solr_document }

  let(:user) { create(:user) }
  let(:service) { described_class.new(work) }
  let(:work) { create(:generic_work) }

  context 'without explicit visibility set' do
    it 'indexes visibility' do
      expect(solr_document['visibility_ssi']).to eq 'restricted' # default
    end
  end

  context 'with explicit visibility set' do
    before { allow(work).to receive(:visibility).and_return('authenticated') }
    it 'indexes visibility' do
      expect(solr_document['visibility_ssi']).to eq 'authenticated'
    end
  end

  context 'with custom indexing' do
    it 'creates additional fields' do
      expect(solr_document['creator_ssi']).to eq 'Name, Human'
      expect(solr_document['date_created_ssi']).to eq '2021-04-01'
      expect(solr_document['title_ssi']).to eq 'Test Title'
      expect(solr_document['sorted_date_isi']).to eq 20_210_401
      expect(solr_document['sorted_month_isi']).to eq 202_104
      expect(solr_document['sorted_year_isi']).to eq 2021
    end
  end
end
