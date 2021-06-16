# frozen_string_literal: true

# copied from hyrax commit aebd41f621b680e933a13fb6ccdf2eeaf9ab2952 to provide ability to blacklight range limit
module Hyrax
  module My
    class CollectionsController < MyController
      configure_blacklight do |config|
        config.search_builder_class = Hyrax::My::CollectionsSearchBuilder
      end
      # Define collection specific filter facets.
      def self.configure_facets
        configure_blacklight do |config|
          # Name of pivot facet must match field name that uses helper_method
          config.add_facet_field ::Collection.collection_type_gid_document_field_name,
                                 helper_method: :collection_type_label, limit: 5,
                                 pivot: ['has_model_ssim', ::Collection.collection_type_gid_document_field_name],
                                 label: I18n.t('hyrax.dashboard.my.heading.collection_type')
          # This causes AdminSets to also be shown with the Collection Type label
          config.add_facet_field 'has_model_ssim',
                                 label: I18n.t('hyrax.dashboard.my.heading.collection_type'),
                                 limit: 5, show: false
        end
      end
      configure_facets

      def index
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.collections'), hyrax.my_collections_path
        collection_type_list_presenter
        managed_collections_count
        super
      end

      private

        def search_action_url(*args)
          hyrax.my_collections_url(*args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          hyrax.my_dashboard_collections_facet_path(args[:id])
        end

        def collection_type_list_presenter
          @collection_type_list_presenter ||= Hyrax::SelectCollectionTypeListPresenter.new(current_user)
        end

        def managed_collections_count
          @managed_collection_count = Hyrax::Collections::ManagedCollectionsService.managed_collections_count(scope: self)
        end
    end
  end
end
