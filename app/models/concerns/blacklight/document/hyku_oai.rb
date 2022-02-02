# frozen_string_literal: true
require 'builder'

# This module provide field export based on the catalog_controller custom fields
module Blacklight::Document::HykuOai
  def self.extended(document)
    # Register our exportable formats
    Blacklight::Document::HykuOai.register_export_formats(document)
  end

  def self.register_export_formats(document)
    document.will_export_as(:xml)
    document.will_export_as(:hyku_xml, "text/xml")
    document.will_export_as(:oai_hyku_xml, "text/xml")
  end

  def export_as_oai_hyku_xml
    xml = Builder::XmlMarkup.new
    xml.tag!("oai_hyku:hyku",
             'xmlns:oai_hyku' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
             'xmlns:hyku' => "http://purl.org/dc/elements/1.1/",
             'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
             'xsi:schemaLocation' => %(http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd)) do
      custom_sets.each do |set|
        Array.wrap(set.value).each do |v|
          xml.tag! "hyku:#{set.label}", v
        end
      end
    end
    xml.target!
  end

  alias_method :export_as_xml, :export_as_oai_hyku_xml
  alias_method :export_as_hyku_xml, :export_as_oai_hyku_xml
end