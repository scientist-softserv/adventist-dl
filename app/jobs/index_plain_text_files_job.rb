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
    def perform(account, file_set_id)
      account.switch do
        file_set = FileSet.find(file_set_id)
        file = file_set.original_file

        unless file
          raise RuntimeError, "FileSet ID=\"#{file_set_id}\" expected to have an original_file; however it was missing"
        end

        Adventist::TextFileTextExtractionService.assign_extracted_text(
          file_set: file_set,
          text: file.content,
          original_file_name: Array(file.file_name).first
        )
      end
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
