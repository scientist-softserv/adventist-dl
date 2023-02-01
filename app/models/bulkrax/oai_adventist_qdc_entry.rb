# frozen_string_literal: true

module Bulkrax
  class OaiAdventistQdcEntry < OaiQualifiedDcEntry
    # Note: We're overriding the setting of the thumbnail_url as per prior implementations in
    # Adventist's code-base.
    def add_thumbnail_url
      true
    end

    # @note Adding this to make testing easier.  This is something to push up into Bulkrax default.
    attr_writer :raw_record
  end
end
