# frozen_string_literal: true

module Bulkrax
  class OaiAdventistQdcEntry < OaiQualifiedDcEntry
    # @note Adding this to make testing easier.  This is something to push up into Bulkrax default.
    attr_writer :raw_record

    # Note: We're overriding the setting of the thumbnail_url as per prior implementations in
    # Adventist's code-base.
    def add_thumbnail_url
      true
    end

    def collections_created?
      true
    end

    def find_collection_ids
      # Using memoization to cache what could be expensive queries.
      return self.collection_ids if defined?(@found_collection_ids)

      if sets.blank? || parser.collection_name != 'all'
        collection = find_collection(importerexporter.unique_collection_identifier(parser.collection_name))
        self.collection_ids << collection.id if collection.present? && !self.collection_ids.include?(collection.id)
      else # All - collections should exist for all sets
        sets.each do |set|
          c = find_collection(importerexporter.unique_collection_identifier(set.content))
          self.collection_ids << c.id if c.present? && !self.collection_ids.include?(c.id)
        end
      end

      # We've completed our expensive queries, now let's make sure we don't need to do this again.
      @found_collection_ids = true

      self.collection_ids
    end
  end
end
