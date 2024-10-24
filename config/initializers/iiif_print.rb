# frozen_string_literal: true

IiifPrint.config do |config|
  # NOTE: WorkTypes and models are used synonymously here.
  # Add models to be excluded from search so the user
  # would not see them in the search results.
  # by default, use the human readable versions like:
  # @example
  #   # config.excluded_model_name_solr_field_values = ['Generic Work', 'Image']
  #
  # config.excluded_model_name_solr_field_values = []

  # Add configurable solr field key for searching,
  # default key is: 'human_readable_type_sim'
  # if another key is used, make sure to adjust the
  # config.excluded_model_name_solr_field_values to match
  # @example
  #   config.excluded_model_name_solr_field_key = 'some_solr_field_key'

  # Configure how the manifest sorts the canvases, by default it sorts by :title,
  # but a different model property may be desired such as :date_published
  # @example
  #   config.sort_iiif_manifest_canvases_by = :date_published

  # NOTE: As part of the docker build, we install an "eng_best".  And based on
  #       conversations with the client)
  config.additional_tesseract_options = "-l eng_best"

  # Reconfigure the title generated by the PDF splitter
  # rubocop:disable Metrics/LineLength
  config.unique_child_title_generator_function = lambda { |original_pdf_path:, parent_work:, page_number:, page_padding:, **|
    identifier = parent_work.to_param # ref Slug Bug
    filename = File.basename(original_pdf_path)
    # FileSetIndexer#human_readable_label_name uses this string to generate labels for the UV.
    page_suffix = "Page #{(page_number.to_i + 1).to_s.rjust(page_padding.to_i, '0')}"
    "#{filename} - #{page_suffix} || #{identifier}"
  }

  config.all_text_generator_function = lambda do |object:|
    IiifPrint::Data::WorkDerivatives.data(from: object, of_type: 'xml')
  end

  config.metadata_fields = {
    creator: { render_as: :faceted },
    resource_type: { render_as: :faceted },
    abstract: {},
    presented_at: {},
    location: {},
    event_date: {},
    part_of: { render_as: :faceted },
    editor: {},
    publisher: { render_as: :faceted },
    place_of_publication: {},
    date_published: {},
    publication_status: {},
    refereed: {},
    pagination: {},
    doi: {},
    related_url: {},
    identifier: {},
    subject: { render_as: :faceted },
    keyword: { render_as: :faceted },
    language: { render_as: :faceted },
    based_near: {},
    rights_statement: { render_as: :rights_statement },
    license: { render_as: :license },
    aark_id: {},
    date_created: {},
    department: {},
    qualification_level: {},
    qualification_name: {},
    module_code: {},
    description: {},
    source: { render_as: :faceted },
    volume_number: {},
    issue_number: {},
    date_submitted: {},
    date_accepted: {},
    date_available: {},
    remote_url: {},
    contributor: { render_as: :faceted },
    output_of: {},
    date_issued: {},
    bibliographic_citation: {},
    alt: {},
    advisor: {},
    awarding_institution: {},
    date_of_award: {},
    funder: {},
    isbn: {},
    extent: {},
    part: { render_as: :faceted },
    series: {},
    edition: {},
    collection: {}
  }

  config.skip_splitting_pdf_files_that_end_with_these_texts = CreateDerivativesJobDecorator::NON_ARCHIVAL_PDF_SUFFIXES
  # rubocop:enable Metrics/LineLength
end

require "iiif_print/split_pdfs/adventist_pages_to_jpgs_splitter"

# Adventist wants to reduce storage size of their split pages; JPGs are a reasonable storage size
# compared to TIFFs
DerivativeRodeo::Generators::PdfSplitGenerator.output_extension = 'jpg'

####################################################################################################
# The DerivativeRodeo is responsible for finding, moving, and/or generating files from various
# places.  I have found it invaluable to have a segmented logger for that particular set of
# functions.  Imagine importing 25 works from an OAI feed, and all of the chatter you'll see.  Now
# try to find the DerivativeRodeo specific calls, as it:
#
# - Checks if the file exists at the output location
# - Checks if the file exists at the preprocessed location
# - Copies the preprocessed file to the output location
# - Generates the file to the output location based on the input uri (by copying that locally)
# - Sniffs out if a PDF has been split into constituent pages
#
# Uncomment the `DerivativeRodeo.config.logger` line, spin up They Might Be Giants's "Doctor Worm"
# and start tailing good ol' "Dr. Log".  It is what helped me see, in detail, what was happening
# with all of these bits flying hither and yon.
#
# NOTE: By default `DerivativeRodeo.config.logger` will be automatically set to `Rails.logger` when
# `Rails.logger` is defined.
####################################################################################################

if ENV.fetch('LOCAL_RODEO_LOG', 'false') == 'true'
  FileUtils.mkdir_p(Rails.root.join('log').to_s)
  DerivativeRodeo.config.logger = Logger.new(Rails.root.join("log/dr.log").to_s, level: Logger::DEBUG)
else
  DerivativeRodeo.config.logger = Rails.logger
end
