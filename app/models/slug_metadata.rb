# frozen_string_literal: true

module SlugMetadata
  extend ActiveSupport::Concern

  included do
    # adding aark_id to metadata, correct mapping to be completed by client
    property :aark_id,
             predicate: ::RDF::URI.intern('https://adl-hyku-staging.notch8.cloud/terms/aark_id'),
             multiple: false do |index|
               index.as :stored_searchable
             end
    # adding slug field for custom work urls
    property :slug, predicate: ::RDF::Vocab::DC.alternative, multiple: false do |index|
      index.as :stored_searchable
    end

    # TODO: Remove these overrides after mass index
    def after_update_nested_collection_relationship_indices
      @during_save = false
    end

    def update_nested_collection_relationship_indices
      return if @during_save
      # reindex_nested_relationships_for(id: id, extent: reindex_extent)
    end
  end
end
