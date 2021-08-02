# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
class Image < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  before_save :set_slug

  property :extent, predicate: ::RDF::Vocab::DC.extent, multiple: true do |index|
    index.as :stored_searchable
  end

  # This must come after the properties because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include AdventistMetadata

  self.indexer = ImageIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Image'

  def to_param
    slug || id
  end

  def self.find(slug)
    # rubocop:disable Rails/FindBy
    results = where(slug: slug).first
    # rubocop:enable Rails/FindBy
    results = ActiveFedora::Base.find(slug) if results.blank?

    results
  end

  def set_slug
    self.slug = if aark_id.present?
                  (aark_id + "_" + title.first).truncate(75, omission: '').parameterize.underscore
                else
                  id
                end
  end
end
