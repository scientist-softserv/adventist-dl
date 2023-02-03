# frozen_string_literal: true

# Generated via
#  `rails generate dog_biscuits:work JournalArticle`
class JournalArticle < DogBiscuits::JournalArticle
  include ::Hyrax::WorkBehavior
  include SlugBug
  include DogBiscuits::BibliographicCitation
  include DogBiscuits::DateIssued
  include DogBiscuits::Geo
  include DogBiscuits::PlaceOfPublication
  include DogBiscuits::RemoteUrl

  self.indexer = ::JournalArticleIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  # include ::Hyrax::BasicMetadata
  include SlugMetadata
  include DogBiscuits::JournalArticleMetadata
  before_save :combine_dates

  prepend OrderAlready.for(:creator)
end
