# frozen_string_literal: true

# copied from hyrax commit aebd41f621b680e933a13fb6ccdf2eeaf9ab2952 to provide ability to blacklight range limit
module Hyrax
  module My
    class SharesController < MyController
      configure_blacklight do |config|
        config.search_builder_class = Hyrax::My::SharesSearchBuilder
      end

      def index
        super
      end

      private

        def search_action_url(*args)
          hyrax.dashboard_shares_url(*args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          hyrax.dashboard_shares_facet_path(args[:id])
        end
    end
  end
end
