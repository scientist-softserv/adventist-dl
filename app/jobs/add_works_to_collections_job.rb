# frozen_string_literal: true

class AddWorksToCollectionsJob < ApplicationJob
  queue_as :relationships

  def perform(record_data:)
    begin
      work = record_data[:model].constantize.where(identifier: record_data[:identifier]).first
      collection = Collection.where(identifier: record_data[:parents]).first

      collection.try(:reindex_extent=, Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX)
      work.member_of_collections << collection
      work.save!
      Rails.logger.info("🦄🪺👩‍👩‍👧‍👦 #{record_data[:identifier]} processed")
    rescue StandardError => e
      Rails.logger.error("😈😈😈 ERROR: unable to create relationship for #{record_data[:identifier]}")
      Rails.logger.error(e.message)
    end
  end
end