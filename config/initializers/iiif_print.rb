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
  config.additional_tessearct_options = "-l eng_best"

  # def unique_child_title_generator_function
  #   @unique_child_title_generator_function ||= lambda { |original_pdf_path:, image_path:, parent_work:, page_number:, page_padding:|
  #     identifier = parent_work.id
  #     filename = File.basename(original_pdf_path)
  #     page_suffix = "Page #{(page_number.to_i + 1).to_s.rjust(page_padding.to_i, '0')}"
  #     "#{identifier} - #{filename} #{page_suffix}"
  #   }
  # end
  config.unique_child_title_generator_function = lambda { |original_pdf_path:, parent_work:, page_number:, page_padding:, **| 
    identifier = parent_work.to_param # ref Slug Bug
    filename = File.basename(original_pdf_path)
    page_suffix = "Page #{(page_number.to_i + 1).to_s.rjust(page_padding.to_i, '0')}"
    "#{identifier} || #{filename} #{page_suffix}"
  }
end

require "iiif_print/split_pdfs/adventist_pages_to_jpgs_splitter"
