# frozen_string_literal: true

module SlugBug
  extend ActiveSupport::Concern

  included do
    before_save :set_slug
  end

  class_methods do
  end

  def to_param
    slug || id
  end

  def set_slug
    self.slug = if aark_id.present?
                  (aark_id + "_" + title.first).truncate(75, omission: '').parameterize.underscore
                else
                  id
                end
  end
end
