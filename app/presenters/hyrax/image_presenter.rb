# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImagePresenter < Hyku::WorkShowPresenter
    # We do not use this generated ImagePresenter. Instead we use the
    # WorkShowPresenter
    delegate :aark_id, :abstract, :date_issued, :alt, :part_of, :place_of_publication, :remote_url, to: :solr_document
  end
end
