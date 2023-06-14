# frozen_string_literal: true

# app/jobs/destroy_collections_job.rb
class DestroyCollectionsJob < ApplicationJob
  def perform
    # Find specific collection
    collection_count = Collection.count
    counter = 0

    Collection.find_each do |collection|
      next if collection.title.first == 'Journal of Adventist Education'

      # Destroy the collections
      collection.destroy!
      counter += 1
      Rails.logger.info "#{collection.title.first} was destroyed!"
    end

    Rails.logger.info "#{counter} of #{collection_count} collections were destroyed!"
  end
end
