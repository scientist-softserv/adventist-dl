# frozen_string_literal: true

require "rails_helper"

RSpec.describe RemoveAccountRelationshipsJob do
  let(:account) { FactoryBot.create(:account) }
  let(:importer) do
    importer = nil
    account.switch { importer = Bulkrax::Importer.create!(name: "hello", admin_set_id: "fake", parser_klass: "Bulkrax::CsvParser") }
    importer
  end

  describe '#perform' do
    it "calls ForImporterJob.perform_later for all importers (for the given account)" do
      expect(described_class::ForImporterJob).to receive(:perform_later).with(account, importer.id)
      described_class.perform_now(account)
    end
  end

  describe "ForImporterJob" do
    describe "#perform" do
      it "calls Bulkrax::RemoveAccountRelationshipsJob.break_relationships_for!" do
        expect(Bulkrax::RemoveRelationshipsForImporter).to receive(:break_relationships_for!)
          .with(importer: importer, with_progress_bar: false)
          .and_call_original

        described_class::ForImporterJob.perform_now(account, importer.id)
      end
    end
  end
end
