# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    if self.parsed_metadata['model'] == 'Collection'
      self.parsed_metadata.delete('admin_set_id')
      nested_collections = self.parsed_metadata.delete('member_of_collection_attributes')
      self.parsed_metadata['collection'] = nested_collections.map { |k, v| v['id'] } if nested_collections.is_a?(Hash)
    end
  end
end
