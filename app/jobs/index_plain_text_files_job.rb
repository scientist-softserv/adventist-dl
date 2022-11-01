# frozen_string_literal: true

# IndexPlainTextFilesJob  is  responsible  for adding  each  plain  text
# files's content (e.g. the text)  to the file_set's extracted text.  In
# doing so, folks can then search for the text of the given file.
class IndexPlainTextFilesJob < ApplicationJob
  non_tenant_job

  # IndexPlainTextFilesJob  is  responsible  for adding  a single  plain  text
  # files's content (e.g. the text)  to the file_set's extracted text.
  #
  # @see Adventist::TextFileTextExtractionService
  # @see https://docs.ruby-lang.org/en/2.7.0/String.html#method-i-encode
  class One < ApplicationJob
    # @param file_set_id [String]
    def perform(account, file_set_id, time_to_live = 3, logger: default_logger)
      account.switch do
        file_set = FileSet.find(file_set_id)
        file = file_set.original_file

        unless file
          logger.error("ERROR: FileSet ID=\"#{file_set_id}\" expected to have an original_file; however it was missing.")
          return false
        end

        Adventist::TextFileTextExtractionService.assign_extracted_text(
          file_set: file_set,
          text: file.content,
          original_file_name: Array(file.file_name).first
        )
        logger.info("INFO: FileSet ID=\"#{file_set_id}\" text extracted from plain text file.")
        return true
      rescue => e
        if time_to_live > 0
          # It's possible we can recover from this, so we'll give it another go.
          logger.warn("WARNING: FileSet ID=\"#{file_set_id}\" error for #{self.class}: #{e}.  Retries remaining #{time_to_live - 1}.")
          One.perform_later(account, file_set_id, time_to_live - 1)
        else
          logger.error("ERROR: FileSet ID=\"#{file_set_id}\" error for #{self.class}: #{e}.  No retries remaining.  Backtrace: #{e.backtrace}")
        end
        return false
      end
    end

    def default_logger
      @default_logger ||= ActiveSupport::Logger.new(Rails.root.join("log/index_plain_text_files_job_log.log"))
    end
  end

  # @param account [Account]
  def perform(account)
    account.switch do
      FileSet.where(mime_type_ssi: 'text/plain').find_each do |file_set|
        next if file_set.extracted_text.present?

        One.perform_later(account, file_set.id)
      end
    end
  end
end
