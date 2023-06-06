# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include VideoEmbedViewer
  include ::Hyrax::WorkBehavior
  include DogBiscuits::Abstract
  include DogBiscuits::BibliographicCitation
  include DogBiscuits::DateIssued
  include DogBiscuits::Geo
  include DogBiscuits::PartOf
  include DogBiscuits::PlaceOfPublication
  include SlugMetadata
  include AdventistMetadata
  include SlugBug
  include IiifPrint.model_configuration(
    pdf_split_child_model: self,
    pdf_splitter_service: IiifPrint::SplitPdfs::AdventistPagesToJpgsSplitter,
    derivative_service_plugins: [
      IiifPrint::TextExtractionDerivativeService
    ]
  )

  validates :title, presence: { message: 'Your work must have a title.' }

  self.indexer = WorkIndexer
  self.human_readable_type = 'Work'

  prepend OrderAlready.for(:creator)
end
