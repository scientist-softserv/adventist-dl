# frozen_string_literal: true

# copied from hyrax/app/models/concerns/hyrax/basic_metadata.rb v3.0.0
# to override date created to accept scalar data from the date picker

module Hyrax
  # An optional model mixin to define some simple properties. This must be mixed
  # after all other properties are defined because no other properties will
  # be defined once  accepts_nested_attributes_for is called
  module BasicMetadata
    extend ActiveSupport::Concern

    included do
      property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false

      property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false

      property :import_url, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#importUrl'), multiple: false
      property :resource_type, predicate: ::RDF::Vocab::DC.type
      property :creator, predicate: ::RDF::Vocab::DC11.creator
      property :contributor, predicate: ::RDF::Vocab::DC11.contributor
      property :description, predicate: ::RDF::Vocab::DC11.description
      property :keyword, predicate: ::RDF::Vocab::DC11.relation
      # Used for a license
      property :license, predicate: ::RDF::Vocab::DC.rights

      # This is for the rights statement
      property :rights_statement, predicate: ::RDF::Vocab::EDM.rights
      property :publisher, predicate: ::RDF::Vocab::DC11.publisher
      property :date_created, predicate: ::RDF::Vocab::DC.created, multiple: false do |index|
        index.as :stored_searchable
      end
      property :subject, predicate: ::RDF::Vocab::DC11.subject
      property :language, predicate: ::RDF::Vocab::DC11.language
      property :identifier, predicate: ::RDF::Vocab::DC.identifier
      property :based_near, predicate: ::RDF::Vocab::FOAF.based_near, class_name: Hyrax::ControlledVocabularies::Location
      property :related_url, predicate: ::RDF::RDFS.seeAlso
      property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation
      property :source, predicate: ::RDF::Vocab::DC.source

      id_blank = proc { |attributes| attributes[:id].blank? }

      class_attribute :controlled_properties
      self.controlled_properties = [:based_near]
      accepts_nested_attributes_for :based_near, reject_if: id_blank, allow_destroy: true

      def self.multiple?(field)
        field.to_s == 'date_created' ? false : super
      end
    end
  end
end
