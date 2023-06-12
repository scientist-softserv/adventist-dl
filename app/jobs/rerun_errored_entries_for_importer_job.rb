# frozen_string_literal: true

##
# This class is responsible for rescheduling all failed entry imports.
#
# @note This class is starting it's life in the Adventist repository but is being designed so that
#       we could copy it rather easily into Bulkrax.
#
# @see https://github.com/scientist-softserv/adventist-dl/issues/430
#
# @example
#   switch!('sdapi'); RerunErroredEntriesForImporterJob.perform_later(importer_id: 123, last_run_id: 456)
class RerunErroredEntriesForImporterJob < ApplicationJob
  ##
  # @param importer_id [Integer]
  # @param last_run_id [Integer]
  # @param error_classes [Array<String>] only re-run for entries that had failures matching the given
  #        :error_classes.
  # @param logger [Logger]
  def perform(importer_id:, last_run_id: nil, error_classes: [], logger: Rails.logger)
    @logger = logger
    @importer = Bulkrax::Importer.find(importer_id)
    @last_run = if last_run_id
                  @importer.importer_runs.find(last_run_id)
                else
                  @importer.last_run
                end
    @error_classes = Array.wrap(error_classes).map(&:to_s)

    do_it!
  end

  attr_reader :importer, :last_run, :new_run, :logger, :error_classes

  def do_it!
    reimport_logging_context = "#{importer.class} ID=#{importer.id} with #{last_run.class} ID=#{last_run.id}"
    relation = last_run.statuses.where(statusable_type: 'Bulkrax::Entry')

    if error_classes.empty?
      logger.info("Starting re-importing #{reimport_logging_context} with entries that had any error.")
      relation = relation.where.not(error_class: nil)
    else
      # rubocop:disable Metrics/LineLength
      logger.info("Starting re-importing #{reimport_logging_context} with entries that had the following errors: #{error_classes.inspect}.")
      # rubocop:enable Metrics/LineLength
      relation = relation.where(error_class: error_classes)
    end

    # relation.select("statusable_id", "statusable_type").distinct.find_each do |status|
    relation = relation.select("statusable_id", "statusable_type").distinct
    counter = 0

    relation.in_batches do |batch|

      batch.each do |status|
        entry = status.statusable
        counter += 1
        logger.info("Enqueuing re-import for #{reimport_logging_context} entry ID=#{entry.id} (#{counter}).")
        RerunEntryJob.perform_later(bulkrax_entry: entry)
      end
    end

    logger.info("Finished submitting re-imports for #{reimport_logging_context}.")
  end
end
