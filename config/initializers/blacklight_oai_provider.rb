module BlacklightOaiProvider
  class Set
    class << self
      attr_accessor :custom_fields
    end
  end

  class SolrDocumentProvider < ::OAI::Provider::Base

    def initialize(controller, options = {})
      options[:provider] ||= {}
      options[:document] ||= {}

      self.class.model = SolrDocumentWrapper.new(controller, options[:document])

      if self.class.model.use_custom
        options[:provider][:register_format] ||= OAI::Provider::Metadata::HykuOai.instance
      end

      options[:provider][:repository_name] ||= controller.view_context.application_name
      options[:provider][:repository_url] ||= controller.view_context.oai_catalog_url

      options[:provider].each do |k, v|
        v = v.call(controller) if v.is_a?(Proc)
        self.class.send k, v
      end
    end
  end

  class SolrDocumentWrapper < ::OAI::Provider::Model
    attr_accessor :use_custom, :custom_prefix

    def initialize(controller, options = {})
      @controller      = controller
      @document_model  = @controller.blacklight_config.document_model
      @solr_timestamp  = document_model.timestamp_key
      @timestamp_field = 'timestamp' # method name used by ruby-oai
      @limit           = options[:limit] || 15
      @use_custom      = options[:use_custom_prefix].present?
      @custom_prefix   = options[:use_custom_prefix]
      @set             = options[:set_model] || BlacklightOaiProvider::SolrSet

      @set.controller = @controller
      @set.fields = options[:set_fields]
      @set.custom_fields = options[:custom_fields]
    end

    def custom_sets
      @set.custom_fields
    end

    def custom_fields
      @set.all_custom
    end
  end

  class SolrSet < BlacklightOaiProvider::Set
    class << self
      # Return an array of all sets, or nil if sets are not supported
      def all_custom
        all("custom_")
      end

      def all(custom = "")
        return if instance_variable_get("@#{custom}fields").nil?

        params = { rows: 0, facet: true, 'facet.field' => send("#{custom}solr_fields") }
        send("#{custom}solr_fields").each { |field| params["f.#{field}.facet.limit"] = -1 } # override any potential blacklight limits

        builder = @controller.search_builder.merge(params)
        response = @controller.repository.search(builder)

        sets_from_facets(response.facet_fields) if response.facet_fields
      end

      # Returns array of sets for a solr document, or empty array if none are available.
      def custom_sets_for(record)
        sets_for(record, "custom_")
      end

      # Returns array of sets for a solr document, or empty array if none are available.
      def sets_for(record, custom = "")
        Array.wrap(instance_variable_get("@#{custom}fields")).map do |field|
          Array.wrap(record.fetch(field[:solr_field], [])).map do |value|
            new("#{field[:label]}:#{value}")
          end
        end.flatten
      end

      def field_config_for(label)
        Array.wrap(@fields + @custom_fields).find { |f| f[:label] == label } || {}
      end

      private

      def sets_from_facets(facet_results)
        sets = Array.wrap(@fields + @custom_fields).map do |f|
          facet_results.fetch(f[:solr_field], [])
              .each_slice(2)
              .map { |t| new("#{f[:label]}:#{t.first}") }
        end.flatten

        sets.empty? ? nil : sets
      end
    end
  end
end

module BlacklightOaiProvider
  module SolrDocumentDecorator
    def to_oai_hyku
      export_as('oai_hyku_xml')
    end

    def to_oai_dcmi
      export_as('oai_dcmi_xml')
    end

    def use_custom?
      custom_sets.present?
    end

    def custom_sets
      BlacklightOaiProvider::SolrSet.custom_sets_for(self)
    end
  end
end
BlacklightOaiProvider::SolrDocument.prepend(BlacklightOaiProvider::SolrDocumentDecorator)