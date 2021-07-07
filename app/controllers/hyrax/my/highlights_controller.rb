# frozen_string_literal: true

# copied from hyrax commit aebd41f621b680e933a13fb6ccdf2eeaf9ab2952 to provide ability to blacklight range limit
module Hyrax
  module My
    class HighlightsController < MyController
      configure_blacklight do |config|
        config.search_builder_class = Hyrax::My::HighlightsSearchBuilder
      end

      def index
        super
      end

      private

        def search_action_url(*args)
          hyrax.dashboard_highlights_url(*args)
        end

        def query_solr
          return empty_search_result if Hyrax::TrophyPresenter.find_by(user: @user).count.zero?
          super
        end

        def empty_search_result
          solr_response = Blacklight::Solr::Response.new(empty_request, {})
          docs = []
          [solr_response, docs]
        end

        def empty_request
          {
            responseHeader: {
              status: 0,
              params: { wt: 'ruby', rows: '11', q: '*:*' }
            },
            response: { numFound: 0, start: 0, docs: [] }
          }
        end
    end
  end
end
