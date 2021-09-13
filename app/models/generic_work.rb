# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include DogBiscuits::DateIssued
  include DogBiscuits::Geo
  include DogBiscuits::PartOf
  include DogBiscuits::PlaceOfPublication
  include SlugMetadata
  include AdventistMetadata
  include SlugBug

  validates :title, presence: { message: 'Your work must have a title.' }

  self.indexer = WorkIndexer
  self.human_readable_type = 'Work'
end
