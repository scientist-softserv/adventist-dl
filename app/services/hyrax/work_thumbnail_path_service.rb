# frozen_string_literal: true

module Hyrax
  class WorkThumbnailPathService < Hyrax::ThumbnailPathService
    class << self
      def call(object)
        return default_image unless object.thumbnail_id

        thumb = fetch_thumbnail(object)
        return unless thumb
        return call(thumb) unless thumb.is_a?(::FileSet)
        return_path(thumb)
      end

      def default_image
        Site.instance.default_work_image&.url || ActionController::Base.helpers.image_path('default.png')
      end
    end
  end
end
