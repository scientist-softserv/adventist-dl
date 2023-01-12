# frozen_string_literal: true

module Bulkrax
  class OaiAdventistQdcEntry < OaiQualifiedDcEntry
    # Note: We're overriding the setting of the thumbnail_url as per prior implementations in
    # Adventist's code-base.
    def add_thumbnail_url
      true
    end
  end
end
