# frozen_string_literal: true

# Generated via
#  `rails generate dog_biscuits:work ExamPaper`
class ExamPaper < DogBiscuits::ExamPaper
  include ::Hyrax::WorkBehavior
  include SlugBug

  self.indexer = ::ExamPaperIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  # include ::Hyrax::BasicMetadata
  include SlugMetadata
  include OrderedMetadata
  include DogBiscuits::ExamPaperMetadata
  before_save :combine_dates
end
