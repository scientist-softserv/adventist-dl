# frozen_string_literal: true

# Generated via
#  `rails generate dog_biscuits:work ConferenceItem`
class ConferenceItem < DogBiscuits::ConferenceItem
  include ::Hyrax::WorkBehavior

  self.indexer = ::ConferenceItemIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  # include ::Hyrax::BasicMetadata
  include DogBiscuits::ConferenceItemMetadata
  before_save :combine_dates
end
