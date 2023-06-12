# frozen_string_literal: true

# OVERRIDE: use post instead of get to allow larger size queries
module ActiveFedora
  module SolrServiceDecorator
    # Get the count of records that match the query
    # @param [String] query a solr query
    # @param [Hash] args arguments to pass through to `args' param of SolrService.query (note that :rows will be overwritten to 0)
    # @return [Integer] number of records matching
    def count(query, args = {})
      args = args.merge(rows: 0)
      SolrService.post(query, args)['response']['numFound'].to_i
    end
  end
end

ActiveFedora::SolrService.singleton_class.send(:prepend, ActiveFedora::SolrServiceDecorator)
