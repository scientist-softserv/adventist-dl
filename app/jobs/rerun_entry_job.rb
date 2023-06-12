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
  def perform(bulkrax_entry: entry)
    logger = Rails.logger
    # rubocop:disable Metrics/LineLength
    logger.info("Submitting re-import for #{bulkrax_entry.class} ID=#{bulkrax_entry.id} with previous error of #{bulkrax_entry.error_class}.  Part of re-importing #{reimport_logging_context}.")
    # rubocop:enable Metrics/LineLength
    
    bulkrax_entry.build
    bulkrax_entry.save

    logger.info("Finished re-submitting entry for for #{bulkrax_entry.class} ID=#{bulkrax_entry.id}. entry status=#{bulkrax_entry.status}")
  end
end