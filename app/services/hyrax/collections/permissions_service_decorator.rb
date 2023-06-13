# frozen_string_literal: true

# OVERRIDE class Hyrax::Collections::PermissionsService from Hyrax v2.9.5
module Hyrax
  module Collections
    module PermissionsServiceDecorator
      # OVERRIDE: use `post` rather than `get` to handle larger query sizes
      def filter_source(source_type:, ids:)
        return [] if ids.empty?
        id_clause = "{!terms f=id}#{ids.join(',')}"
        query = case source_type
                when 'admin_set'
                  "_query_:\"{!raw f=has_model_ssim}AdminSet\""
                when 'collection'
                  "_query_:\"{!raw f=has_model_ssim}Collection\""
                end
        query += " AND #{id_clause}"
        ActiveFedora::SolrService.query(query, fl: 'id', rows: ids.count, method: :post).map { |hit| hit['id'] }
      end
    end
  end
end

Hyrax::Collections::PermissionsService.singleton_class.send(:prepend, Hyrax::Collections::PermissionsServiceDecorator)
