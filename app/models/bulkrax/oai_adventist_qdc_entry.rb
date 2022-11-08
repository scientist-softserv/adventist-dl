# frozen_string_literal: true

require 'erb'
require 'ostruct'

module Bulkrax
  class OaiAdventistQdcEntry < OaiQualifiedDcEntry
    # override to swap out the thumbnail_url
    def build_metadata
      self.parsed_metadata = {}
      self.parsed_metadata[work_identifier] = [record.header.identifier]

      record.metadata.children.each do |child|
        child.children.each do |node|
          add_metadata(node.name, node.content)
        end
      end
      #add file sets to 'children' in parsed md
      add_visibility
      add_rights_statement
      add_admin_set_id
      add_collections
      add_local

      self.parsed_metadata
    end
  end
end
