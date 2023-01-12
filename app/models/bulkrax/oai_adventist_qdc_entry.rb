# frozen_string_literal: true

module Bulkrax
  class OaiAdventistQdcEntry < OaiQualifiedDcEntry
    # override to swap out the thumbnail_url
    def build_metadata
      self.parsed_metadata = {}
      self.parsed_metadata[work_identifier] = [record.header.identifier]
      self.raw_metadata = { record_level_xml: record._source.to_s }

      record.metadata.children.each do |child|
        child.children.each do |node|
          add_metadata(node.name, node.content)
        end
      end

      add_visibility
      add_rights_statement
      add_admin_set_id
      add_collections
      # see app/models/concerns/bulkrax/has_local_processing.rb
      add_local

      self.parsed_metadata
    end
  end
end
