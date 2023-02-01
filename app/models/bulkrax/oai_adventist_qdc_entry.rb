# frozen_string_literal: true

module Bulkrax
  class OaiAdventistQdcEntry < OaiQualifiedDcEntry
    # Note: We're overriding the setting of the thumbnail_url as per prior implementations in
    # Adventist's code-base.
    def add_thumbnail_url
      true
    end

    def collections_created?
      true
    end

    def find_collection_ids
      return self.collection_ids if collections_created?
      if sets.blank? || parser.collection_name != 'all'
        collection = find_collection(importerexporter.unique_collection_identifier(parser.collection_name))
        self.collection_ids << collection.id if collection.present? && !self.collection_ids.include?(collection.id)
      else # All - collections should exist for all sets
        sets.each do |set|
          c = find_collection(importerexporter.unique_collection_identifier(set.content))
          self.collection_ids << c.id if c.present? && !self.collection_ids.include?(c.id)
        end
      end
      self.collection_ids
    end
  end
end
