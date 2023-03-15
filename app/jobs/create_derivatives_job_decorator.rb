# frozen_string_literal: true

# OVERRIDE HYRAX 2.9.5 to conditionally skip derivative generation

module CreateDerivativesJobDecorator
  # @note Override to include conditional validation
  def perform(file_set, file_id, filepath = nil)
    return unless CreateDerivativesJobDecorator.create_derivative_for?(file_set: file_set)
    super
  end

  # @see https://github.com/scientist-softserv/adventist-dl/issues/311 for discussion on structure
  #      of non-Archival PDF.
  NON_ARCHIVAL_PDF_SUFFIX = ".reader.pdf"

  def self.create_derivative_for?(file_set:)
    # Our options appear to be `file_set.label` or `file_set.original_file.original_name`; in
    # favoring `#label` we are avoiding a call to Fedora.  Is the label likely to be the original
    # file name?  I hope so.
    return false if file_set.label.downcase.end_with?(NON_ARCHIVAL_PDF_SUFFIX)

    true
  end
end

CreateDerivativesJob.prepend(CreateDerivativesJobDecorator)
