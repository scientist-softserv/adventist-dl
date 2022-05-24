module OAI
  module Provider
    module MetadataFormat
      class AdlDublinCore < OAI::Provider::Metadata::Format
        def initialize
          @prefix = 'oai_adl'
          @schema = 'http://dublincore.org/schemas/xmls/qdc/dcterms.xsd'
          @namespace = 'http://purl.org/dc/terms/'
          @element_namespace = 'dcterms'

          # Dublin Core Terms Fields
          # For new fields, add here first then add to oai_qdc_map
          @fields = [:abstract, :alternativeTitle, :arkId, :bibliographicCitation, :contributor, :created, :creator, :date, :dateAccepted, :dateIssued, :description, :edition, :extent, :geocode, :hasPart, :identifier, :isPartOf, :isVersionOf, :issueNumber, :language, :license, :location, :modified, :pagination, :partOf, :placeOfPublication, :publisher, :relation, :remoteUrl, :resourceType, :rights, :source, :subject, :title, :volumeNumber]
        end

        def header_specification
          {
            'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
            'xmlns:oai_qdc' => "http://worldcat.org/xmlschemas/qdc-1.0/",
            'xmlns:oai_adl' => "http://worldcat.org/xmlschemas/qdc-1.0/",
            'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
            'xmlns:dcterms' => "http://purl.org/dc/terms/",
            'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
            'xsi:schemaLocation' => "http://dublincore.org/schemas/xmls/qdc/dcterms.xsd"
          }
        end

      end
    end
  end
end
OAI::Provider::Base.register_format(OAI::Provider::MetadataFormat::AdlDublinCore.instance)
