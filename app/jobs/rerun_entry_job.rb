# frozen_string_literal: true

##
# This class is responsible for running a single bulkrax entry.
#
# @note This class is starting it's life in the Adventist repository but is being designed so that
#       we could copy it rather easily into Bulkrax.
#
# separating this into a job will allow us to run multiple jobs concurrently in the background
class RerunEntryJob < ApplicationJob
  ##
  # @param entry [Entry Object] the entry to run
  def perform(entry_class_name:, entry_id:, importer_run: last_run)
    bulkrax_entry = entry_class_name.constantize.find(entry_id)
    logger = Rails.logger
    logger.info("Submitting re-import for #{bulkrax_entry.class} ID=#{bulkrax_entry.id}")

    begin
      bulkrax_entry.build
      bulkrax_entry.save
    rescue StandardError => e
      logger.error("Error re-submitting entry for #{bulkrax_entry.class} ID=#{bulkrax_entry.id}: #{e.message}")
    end

    if bulkrax_entry.status == "Complete"
      # rubocop:disable Rails/SkipsModelValidations
      importer_run.increment!(:processed_works)
      importer_run.decrement!(:failed_records)
      # rubocop:enable Rails/SkipsModelValidations
    end

    bulkrax_entry.importer.current_run = importer_run
    bulkrax_entry.importer.record_status

    # rubocop:disable Metrics/LineLength
    logger.info("Finished re-submitting entry for #{bulkrax_entry.class} ID=#{bulkrax_entry.id}. entry status=#{bulkrax_entry.status}")
    # rubocop:enable Metrics/LineLength
  end
end
