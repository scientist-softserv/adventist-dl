# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include AdventistMetadata

  before_save :set_slug

  validates :title, presence: { message: 'Your work must have a title.' }

  self.indexer = WorkIndexer
  self.human_readable_type = 'Work'

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
