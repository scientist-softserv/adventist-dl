# frozen_string_literal: true

class AddWorksToCollectionsJob < ApplicationJob
  queue_as :relationships

  def perform(record_data:)
    work = record_data[:model].constantize.where(identifier: record_data[:identifier]).first
    collection = Collection.where(identifier: record_data[:parents]).first

    collection.try(:reindex_extent=, Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX)
    work.member_of_collections << collection
    work.save!
    Rails.logger.info("🦄🪺👩‍👩‍👧‍👦 #{record_data[:identifier]} processed")
  rescue StandardError => e
    notice = "😈😈😈 ERROR: unable to create relationship for #{record_data[:identifier]}"
    Rails.logger.error(notice)
    Rails.logger.error(e.message)
    File.open('uploads/add_works_to_collection_errors.txt', 'a') do |f|
      f.puts Time.zone.now
      f.puts notice
      f.puts e.message
    end
  end
end
