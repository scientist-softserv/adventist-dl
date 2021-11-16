# frozen_string_literal: true

module Bulkrax
  class OaiAdventistQdcParser < OaiQualifiedDcParser
    def entry_class
      OaiQualifiedDcEntry
    end
  end
end
