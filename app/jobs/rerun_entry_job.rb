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
    logger.info("Submitting re-import for #{bulkrax_entry.class} ID=#{bulkrax_entry.id}")

    bulkrax_entry.build
    bulkrax_entry.save

    # rubocop:disable Metrics/LineLength
    logger.info("Finished re-submitting entry for for #{bulkrax_entry.class} ID=#{bulkrax_entry.id}. entry status=#{bulkrax_entry.status}")
    # rubocop:enable Metrics/LineLength
  end
end
