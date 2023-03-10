# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
class Image < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include SlugBug
  include DogBiscuits::Abstract
  include DogBiscuits::BibliographicCitation
  include DogBiscuits::DateIssued
  include DogBiscuits::Geo
  include DogBiscuits::PartOf
  include DogBiscuits::PlaceOfPublication
  include IiifPrint.model_configuration(
    pdf_split_child_model: self,
    derivative_service_plugins: [
      IiifPrint::TextExtractionDerivativeService
    ]
  )

  property :extent, predicate: ::RDF::Vocab::DC.extent, multiple: true do |index|
    index.as :stored_searchable
  end

  # This must come after the properties because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include SlugMetadata
  include AdventistMetadata

  self.indexer = WorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Image'

  prepend OrderAlready.for(:creator)
end
