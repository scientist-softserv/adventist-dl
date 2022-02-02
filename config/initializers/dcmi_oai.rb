module OAI::Provider::Metadata

  # Simple implementation of the Dublin Core metadata format.
  class DcmiOai < Format

    def initialize
      @prefix = 'oai_dcmi'
      @schema = 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd'
      @namespace = 'http://www.openarchives.org/OAI/2.0/oai_dc/'
      @element_namespace = 'dc'
      @fields = [ :abstract, :accessRights, :accrualMethod, :accrualPeriodicity,
                  :accrualPolicy, :alternative, :audience, :available,
                  :bibliographicCitation, :conformsTo, :contributor, :coverage,
                  :created, :creator, :date, :dateAccepted, :dateCopyrighted,
                  :dateSubmitted, :description, :educationLevel, :extent, :format,
                  :hasFormat, :hasPart, :hasVersion, :identifier,
                  :instructionalMethod, :isFormatOf, :isPartOf, :isReferencedBy,
                  :isReplacedBy, :isRequiredBy, :issued, :isVersionOf, :language,
                  :license, :mediator, :medium, :modified, :provenance, :publisher,
                  :references, :relation, :replaces, :requires, :rights,
                  :rightsHolder, :source, :spatial, :subject, :tableOfContents,
                  :temporal, :title, :type, :valid ]
    end

    def header_specification
      {
          'xmlns:oai_dcmi' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
          'xmlns:dc' => "http://purl.org/dc/terms/",
          'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
          'xsi:schemaLocation' =>
              %{http://www.openarchives.org/OAI/2.0/oai_dc/
            http://www.openarchives.org/OAI/2.0/oai_dc.xsd}.gsub(/\s+/, ' ')
      }
    end

  end
end

module Blacklight::DocumentDecorator
  autoload :DcmiOai, 'blacklight/document/dcmi_oai'
end
Blacklight::Document.prepend(Blacklight::DocumentDecorator)