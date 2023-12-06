# frozen_string_literal: true

# OVERRIDE IiifPrint v1.0.0 to not render thumbnail files in the UV

IiifPrint::ManifestBuilderServiceBehavior.module_eval do
  def build_manifest(presenter:)
    manifest = manifest_factory.new(presenter).to_h
    hash = JSON.parse(manifest.to_json)
    parent_and_child_solr_hits = parent_and_child_solr_hits(presenter) if @child_works.present?
    hash = send("sanitize_v#{@version}", hash: hash, presenter: presenter, solr_doc_hits: parent_and_child_solr_hits)
    if @child_works.present? && IiifPrint.config.sort_iiif_manifest_canvases_by
      send("sort_canvases_v#{@version}",
           hash: hash,
           sort_field: IiifPrint.config.sort_iiif_manifest_canvases_by)
    end
    hash['rendering'] = rendering(presenter: presenter)
    hash
  end

  def rendering(presenter:)
    file_set_presenters = presenter.file_set_presenters.select do |fsp|
      fsp.mime_type && !fsp.mime_type.include?('image')
    end

    file_set_presenters.map do |fsp|
      {
        # Yes, we are using `#send` because `#hostname` is a private method, though I think it's okay here
        "@id": Hyrax::Engine.routes.url_helpers.download_url(fsp.id, host: presenter.send(:hostname)),
        "label": fsp.label,
        "format": fsp.mime_type
      }
    end
  end
end
