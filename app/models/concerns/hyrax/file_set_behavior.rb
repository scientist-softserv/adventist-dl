# OVERRIDE Hyrax 2.9.5 to override default_thumbnail

module Hyrax
  module FileSetBehavior
    extend ActiveSupport::Concern
    include Hyrax::WithEvents
    include Hydra::Works::FileSetBehavior
    include Hydra::Works::VirusCheck
    include Hyrax::FileSet::Characterization
    include Hydra::WithDepositor
    include Serializers
    include Hyrax::Noid
    include Hyrax::FileSet::Derivatives
    include Permissions
    include Hyrax::FileSet::Indexing
    include Hyrax::FileSet::BelongsToWorks
    include Hyrax::FileSet::Querying
    include HumanReadableType
    include CoreMetadata
    include Hyrax::BasicMetadata
    include Naming
    include Hydra::AccessControls::Embargoable
    include GlobalID::Identification

    included do
      # OVERRIDE Hyrax 2.9.5 to override default_thumbnail
      attr_accessor :file, :default_thumbnail
    end

    def representative_id
      to_param
    end

    def thumbnail_id
      to_param
    end

    # Cast to a SolrDocument by querying from Solr
    def to_presenter
      CatalogController.new.fetch(id).last
    end
  end
end
