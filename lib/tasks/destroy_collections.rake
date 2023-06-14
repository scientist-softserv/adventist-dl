# frozen_string_literal: true

namespace :hyku do
  desc "delete all collections but 1"
  task :destroy_collections, [:account_name] => :environment do |_, args|
    switch!(args[:account_name])

    progressbar = ProgressBar.create(total: Collection.count, title: 'sdapi', format: "%t %c of %C %a %B %p%%")
    collection_count = Collection.count
    counter = 0

    Collection.all.find_each do |collection|
      next if collection.title.first == 'Journal of Adventist Education'

      DestroyCollectionsJob.perform_later(collection.id)
      counter += 1
      progressbar.increment
      Rails.logger.info "#{counter} of #{collection_count} collections were destroyed!"
    end
  end
end
