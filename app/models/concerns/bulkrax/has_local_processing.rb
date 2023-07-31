# frozen_string_literal: true

module Bulkrax
  module HasLocalProcessing
    # This method is called during build_metadata
    # add any special processing here, for example to reset a metadata property
    # to add a custom property from outside of the import data
    def add_local
      # Because of the DerivativeRodeo and SpaceStone, we may already have the appropriate thumbnail
      # ready to attach to the file_sets.  If we proceed with using the thumbnail_url, we end up
      # attaching that thumbnail as it's own file_set.  Which is likely non-desirous behavior.
      #
      # TODO: What is the impact of changing this assumption?
      if parser.parser_fields['skip_thumbnail_url'] == "1"
        parsed_metadata.delete('thumbnail_url')
      end

      true
    end
  end
end
