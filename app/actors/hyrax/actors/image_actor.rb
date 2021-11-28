# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  module Actors
    class ImageActor < Hyrax::Actors::BaseActor
      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if create was successful
      def create(env)
        env.curation_concern.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX

        super
      end


    end
  end
end
