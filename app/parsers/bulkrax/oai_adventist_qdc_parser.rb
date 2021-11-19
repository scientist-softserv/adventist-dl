# frozen_string_literal: true

module Bulkrax
  class OaiAdventistQdcParser < OaiQualifiedDcParser
    def entry_class
      Bulkrax::OaiAdventistQdcEntry
    end
  end
end
