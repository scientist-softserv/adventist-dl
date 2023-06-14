# frozen_string_literal: true

require 'csv'

class AddWorksToCollections
  def self.call(csv_path: "lib/data/articles_parent_child_relationships_final.csv")
    csv_data = File.read(csv_path)
    CSV.parse(csv_data, headers: true) do |row|
      record_data = row.to_hash.symbolize_keys
      convert_to_relationship(record_data: record_data)
    end
  end

  def self.convert_to_relationship(record_data:)
    AddWorksToCollectionsJob.perform_later(record_data: record_data)

    Rails.logger.info("🎁🎁🎁🎁")
  end
end
