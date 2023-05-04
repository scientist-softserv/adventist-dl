# frozen_string_literal: true

# OVERRIDE IiifPrint v1.0.0 to not render thumbnail files in the UV

IiifPrint::ManifestBuilderServiceBehavior.module_eval do
  def sanitize_v2(hash:, presenter:, hits:)
    hash['label'] = sanitize_label(hash['label']) if hash.key?('label')
    hash.delete('description') # removes default description since it's in the metadata fields
    hash['sequences']&.each do |sequence|
      # removes canvases if there are thumbnail files
      sequence['canvases'].reject! do |canvas|
        sanitize_label(canvas['label']).end_with?('.TN.jpg')
      end

      sequence['canvases']&.each do |canvas|
        canvas['label'] = sanitize_label(canvas['label'])
        apply_metadata_to_canvas(canvas: canvas, presenter: presenter, hits: hits)
      end
    end
    hash
  end

  def sanitize_label(label)
    CGI.unescapeHTML(sanitize_value(label))
  end
end
