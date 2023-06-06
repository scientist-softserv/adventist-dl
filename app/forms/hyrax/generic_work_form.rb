# frozen_string_literal: true

# Generated via
#  `rails generate curation_concerns:work GenericWork`
module Hyrax
  class GenericWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    self.terms += %i[
      aark_id
      abstract
      alt
      bibliographic_citation
      date_issued
      part_of
      place_of_publication
      remote_url
      resource_type
      video_embed
    ]
  end
end
