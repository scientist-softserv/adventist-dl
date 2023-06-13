# frozen_string_literal: true

# app/jobs/destroy_collections_job.rb
class DestroyCollectionsJob < ApplicationJob
  def perform
    # Find specific collection
    Collection.find_each do |collection|
      next if collection.title.first == 'Journal of Adventist Education'

      # Destroy the collections
      collection.destroy!
      Rails.logger.debug "#{collection.title.first} was destroyed!"
    end
  end
end
