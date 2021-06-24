# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include AdventistMetadata

  validates :title, presence: { message: 'Your work must have a title.' }

  self.indexer = WorkIndexer
  self.human_readable_type = 'Work'
end
