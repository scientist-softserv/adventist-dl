# frozen_string_literal: true

module Hyrax
  # The purpose of this module is to consolidate the decorations necessary to leverage the native
  # SOLR graph searches.  That native SOLR graph searches replaces the venerable and non-performant
  # nested indexing.
  #
  # These decorations are inspired from the following pull requests:
  #
  # - https://github.com/samvera/hyrax/pull/5858/
  # - https://github.com/samvera/hyrax/pull/5916/
  #
  # This `lib` file is intended to stand in the place of minting a 2.9.x release (or 2.10.0
  # release).  In constructing these changes, I have opted not to backport the configuration.
  # Meaning, if you include this `lib` file, you are stating that you will use the native SOLR graph
  # searches.  This simplifies some of the logic; most notably avoiding the conditional include of
  # the `Hyrax::CollectionNesting` based on a configuration.  Instead we have a module that shadows
  # the methods introduced in the `Hyrax::CollectionNesting`.
  module SolrNativeNestingIndexerDecorator
    # @note from https://github.com/samvera/hyrax/pull/5916
    module NestCollectionFormDecorator
      def nesting_within_maximum_depth
        true
      end
    end

    # @note from https://github.com/samvera/hyrax/pull/5916
    module NestedCollectionQueryServiceDecorator
      module ClassMethods
        def query_solr(collection:, access:, scope:, limit_to_id:, nest_direction:)
          query_builder = Hyrax::Dashboard::NestedCollectionsSearchBuilder.new(
            access: access,
            collection: collection,
            scope: scope,
            nesting_attributes: nil,
            nest_direction: nest_direction
          )

          query_builder.where(id: limit_to_id.to_s) if limit_to_id
          query = clean_lucene_error(builder: query_builder)
          scope.repository.search(query)
        end
      end
    end

    # @note from https://github.com/samvera/hyrax/pull/5858/
    #
    # This module is responsible for shadowing the methods of Hyrax::CollectionIndexing; we can't
    # easily replace the inclusion of that module.  However we can override it's behavior.
    module CollectionNestingDecorator
      def before_update_nested_collection_relationship_indices
        true
      end

      def after_update_nested_collection_relationship_indices
        true
      end

      def update_nested_collection_relationship_indices
        true
      end

      def update_child_nested_collection_relationship_indices
        true
      end

      def find_children_of(*)
        true
      end

      def use_nested_reindexing?
        true
      end

      def reindex_extent
        true
      end

      def reindex_extent=(val)
        @reindex_extent = val
      end

      private

        def reindex_nested_relationships_for(*)
          true
        end
    end

    # @note from https://github.com/samvera/hyrax/pull/5858/ with modifications based on v2.9.6 of
    #       Hyrax.
    module NestedCollectionsSearchBuilderDecorator
      # rubocop:disable Metrics/LineLength
      def show_only_other_collections_of_the_same_collection_type(solr_parameters)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] += [
          ActiveFedora::SolrQueryBuilder.construct_query(Collection.collection_type_gid_document_field_name => @collection.collection_type_gid),
          "-{!graph from=id to=member_of_collection_ids_ssim#{' maxDepth=1' if @nest_direction == :as_parent}}id:#{@collection.id}",
          "-{!graph to=id from=member_of_collection_ids_ssim#{' maxDepth=1' if @nest_direction == :as_child}}id:#{@collection.id}"
        ]
      end
      # rubocop:enable Metrics/LineLength
    end

    module NestedCollectionPersistenceServiceDecorator
      # These overrides are needed because nothing in the 2.9.x implementation was explicitly
      # **saving** the collection membership changes; they were being indexed but not saved.  It's
      # possible the indexing service was saving the objects.
      module ClassMethods
        def persist_nested_collection_for(parent:, child:)
          child.member_of_collections.push(parent)
          child.save
        end

        def remove_nested_relationship_for(parent:, child:)
          child.member_of_collections.delete(parent)
          child.save
          true
        end
      end
    end
  end
end

Hyrax::Collections::NestedCollectionPersistenceService.singleton_class.prepend(
  Hyrax::SolrNativeNestingIndexerDecorator::NestedCollectionPersistenceServiceDecorator::ClassMethods
)

Hyrax::Forms::Dashboard::NestCollectionForm.prepend(
  Hyrax::SolrNativeNestingIndexerDecorator::NestCollectionFormDecorator
)

Hyrax::Collections::NestedCollectionQueryService.singleton_class.prepend(
  Hyrax::SolrNativeNestingIndexerDecorator::NestedCollectionQueryServiceDecorator::ClassMethods
)

Hyrax::WorkBehavior.prepend(
  Hyrax::SolrNativeNestingIndexerDecorator::CollectionNestingDecorator
)

Hyrax::CollectionBehavior.prepend(
  Hyrax::SolrNativeNestingIndexerDecorator::CollectionNestingDecorator
)

Hyrax::Dashboard::NestedCollectionsSearchBuilder.prepend(
  Hyrax::SolrNativeNestingIndexerDecorator::NestedCollectionsSearchBuilderDecorator
)
