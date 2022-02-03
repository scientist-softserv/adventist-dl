module OAI::Provider::Metadata

  # Simple implementation of a custom metadata format.
  class HykuOai < Format

    def initialize
      @prefix = 'oai_hyku'
      @schema = 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd'
      @namespace = 'http://www.openarchives.org/OAI/2.0/oai_dc/'
      @element_namespace = 'hyku'
      @fields = [ :abstract, :title, :creator, :subject, :description, :publisher,
                  :contributor, :date, :type, :format, :identifier,
                  :source, :language, :relation, :coverage, :rights]
    end

    def header_specification
      {
          'xmlns:oai_hyku' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
          'xmlns:hyku' => "http://purl.org/dc/elements/1.1/",
          'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
          'xsi:schemaLocation' =>
              %{http://www.openarchives.org/OAI/2.0/oai_dc/
            http://www.openarchives.org/OAI/2.0/oai_dc.xsd}.gsub(/\s+/, ' ')
      }
    end
  end

  class Format
    # Provided a model, and a record belonging to that model this method
    # will return an xml represention of the record.  This is the method
    # that should be extended if you need to create more complex xml
    # representations.
    def encode(model, record)
      if model.use_custom
        prefix = model.custom_prefix
      end
      if record.respond_to?("to_#{prefix}")
        record.send("to_#{prefix}")
      else
        xml = Builder::XmlMarkup.new
        map = model.respond_to?("map_#{prefix}") ? model.send("map_#{prefix}") : {}
        xml.tag!("#{prefix}:#{element_namespace}", header_specification) do
          fields.each do |field|
            values = value_for(field, record, map)
            if values.respond_to?(:each)
              values.each do |value|
                xml.tag! "#{element_namespace}:#{field}", value
              end
            else
              xml.tag! "#{element_namespace}:#{field}", values
            end
          end
        end
        xml.target!
      end
    end
  end
end

module Blacklight::DocumentDecorator
  autoload :HykuOai, 'blacklight/document/hyku_oai'
end
Blacklight::Document.prepend(Blacklight::DocumentDecorator)