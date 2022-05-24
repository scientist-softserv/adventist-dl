module OAI::Provider::Response::ListMetadataFormatsDecorator
    def record_supports(record, prefix)
      prefix == 'oai_dc' or
        prefix == 'oai_qdc' or
        prefix == 'oai_adl' or
        record.respond_to?("to_#{prefix}") or
        record.respond_to?("map_#{prefix}")
    end
end

OAI::Provider::Response::ListMetadataFormats.prepend(OAI::Provider::Response::ListMetadataFormatsDecorator)
