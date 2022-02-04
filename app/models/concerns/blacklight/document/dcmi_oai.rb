# frozen_string_literal: true

require 'builder'

# This module provide Dublin Core terms export
module Blacklight
  module Document
    module DcmiOai
      def self.extended(document)
        # Register our exportable formats
        Blacklight::Document::DcmiOai.register_export_formats(document)
      end

      def self.register_export_formats(document)
        document.will_export_as(:xml)
        document.will_export_as(:dcmi_xml, "text/xml")
        document.will_export_as(:oai_dcmi_xml, "text/xml")
      end

      def dublin_core_term_names
        %i[abstract accessRights accrualMethod accrualPeriodicity
           accrualPolicy alternative audience available
           bibliographicCitation conformsTo contributor coverage
           created creator date dateAccepted dateCopyrighted
           dateSubmitted description educationLevel extent format
           hasFormat hasPart hasVersion identifier
           instructionalMethod isFormatOf isPartOf isReferencedBy
           isReplacedBy isRequiredBy issued isVersionOf language
           license mediator medium modified provenance publisher
           references relation replaces requires rights
           rightsHolder source spatial subject tableOfContents
           temporal title type valid]
      end

      # rubocop:disable Layout/LineLength
      def export_as_oai_dcmi_xml
        xml = Builder::XmlMarkup.new
        xml.tag!("oai_dcmi:dcmi",
                 'xmlns:oai_dcmi' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
                 'xmlns:dcmi' => "http://purl.org/dc/terms/",
                 'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
                 'xsi:schemaLocation' => %(http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd)) do
          custom_sets.select { |custom_set| dublin_core_term_name? custom_set.label }.each do |set|
            Array.wrap(set.value).each do |v|
              xml.tag! "dc:#{set.label}", v
            end
          end
        end
        xml.target!
      end
      # rubocop:enable Layout/LineLength

      alias export_as_xml export_as_oai_dcmi_xml
      alias export_as_dcmi_xml export_as_oai_dcmi_xml

      private

        def dublin_core_term_name?(field)
          dublin_core_term_names.include? field.to_sym
        end
    end
  end
end
