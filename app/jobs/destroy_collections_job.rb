# frozen_string_literal: true

# app/jobs/destroy_collections_job.rb
class DestroyCollectionsJob < ApplicationJob
  def perform(collection_id)
    collection = Collection.find(collection_id)
    begin
      collection.destroy!
      Rails.logger.info "Collection Title =#{collection.title.first} was destroyed!"
    rescue StandardError => e
      failed_records << collection_id
      Rails.logger.error "Failed to destroy the collection: #{e.message}."
    end
  end
end
