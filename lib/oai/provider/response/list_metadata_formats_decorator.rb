# frozen_string_literal: true

module OAI::Provider::Response::ListMetadataFormatsDecorator
  def record_supports(record, prefix)
    (prefix == 'oai_dc') ||
      (prefix == 'oai_qdc') ||
      (prefix == 'oai_adl') ||
      record.respond_to?("to_#{prefix}") ||
      record.respond_to?("map_#{prefix}")
  end
end

OAI::Provider::Response::ListMetadataFormats.prepend(OAI::Provider::Response::ListMetadataFormatsDecorator)
