# frozen_string_literal: true

# OVERRIDE Hyrax 2.9.5 filter canvases to display "OBJ.jpg" files only

require_dependency Hyrax::Engine.root.join('app', 'services', 'hyrax', 'manifest_builder_service').to_s

Hyrax::ManifestBuilderService.class_eval do
  ##
  # @api private
  # @param presenter [Hyrax::WorkShowPresenter]
  def sanitized_manifest(presenter:)
    # ::IIIFManifest::ManifestBuilder#to_h returns a
    # IIIFManifest::ManifestBuilder::IIIFManifest, not a Hash.
    # to get a Hash, we have to call its #to_json, then parse.
    #
    # wild times. maybe there's a better way to do this with the
    # ManifestFactory interface?
    manifest = manifest_factory.new(presenter).to_h
    hash = JSON.parse(manifest.to_json)

    hash['label'] = sanitize_value(hash['label']) if hash.key?('label')
    hash['description'] = Array(hash['description'])&.collect { |elem| sanitize_value(elem) } if hash.key?('description')

    hash['sequences']&.each do |sequence|
      # OVERRIDE Hyrax 2.9.5 filter canvases to display "OBJ.jpg" files only
      sequence['canvases'] = sequence['canvases']&.select do |canvas|
        sanitize_value(canvas['label']).include?('OBJ.jpg')
      end

      sequence['canvases'].each do |canvas|
        canvas['label'] = sanitize_value(canvas['label'])
      end
    end

    hash
  end
end
