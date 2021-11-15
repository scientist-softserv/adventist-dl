# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    if self.parsed_metadata['model'] == 'Collection'
      self.parsed_metadata.delete('admin_set_id')
    end
  end
end
