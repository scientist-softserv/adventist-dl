# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImageForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Image
    self.terms += %i[
      aark_id
      abstract
      alt
      bibliographic_citation
      date_issued
      extent
      part_of
      place_of_publication
      remote_url
      resource_type
    ]
  end
end
