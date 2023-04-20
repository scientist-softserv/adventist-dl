# frozen_string_literal: true

module IiifPrint
  module SplitPdfs
    module AdventistPagesToJpgsSplitter
      ##
      # We do not always want to split a PDF; this provides a decision point.
      #
      # @param path [String] the path of the file we're attempting to run derivatives against.
      # @param args [Array<Object>] pass through args
      # @param splitter [IiifPrint::SplitPdfs::BaseSplitter] (for dependency injection)
      # @param suffix [String] (for dependency injection)
      #
      # @return [#to_a] when we are going to skip splitting, return an empty array; otherwise return
      #         an instance of {IiifPrint::SplitPdfs::AdventistPagesToJpgsSplitter}.
      # @note I am adding a {.new} method to a module to mimic the instantiation of a class.
      #
      # @see https://github.com/scientist-softserv/iiif_print/blob/a23706453f23e0f54c9d50bbf0ddf9311d82a0b9/lib/iiif_print/jobs/child_works_from_pdf_job.rb#L39-L63
      # rubocop:disable Metrics/LineLength
      def self.new(path, *args, splitter: PagesToJpgsSplitter, suffixes: CreateDerivativesJobDecorator::NON_ARCHIVAL_PDF_SUFFIXES)
        return [] if suffixes.any? { |suffix| path.downcase.end_with?(suffix) }

        splitter.new(path, *args)
      end
      # rubocop:enable Metrics/LineLength
    end
  end
end
