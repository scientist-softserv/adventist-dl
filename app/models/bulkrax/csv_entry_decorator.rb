# frozen_string_literal: true

module Bulkrax
  module CsvEntryDecorator
    # read_data is a class method for Bulkrax::CsvEntry
    def read_data(path)
      raise StandardError, 'CSV path empty' if path.blank?
      CSV.read(path,
               headers: true,
               # Prior to https://github.com/samvera-labs/bulkrax/pull/670; the following line was:
               # `header_converters: :symbol`
               #
               # The result is that CSV column names of `title.alternate` were converted to
               # `titlealternate`; and thus our existing parsers would not match.  This change will
               # likely be removable when https://github.com/samvera-labs/bulkrax/pull/670 is
               # merged.
               header_converters: ->(h) { h.to_sym },
               encoding: 'utf-8')
    end
  end
end
# We're overriding a class method, so we need to prepend to the singleton class.
Bulkrax::CsvEntry.singleton_class.prepend(Bulkrax::CsvEntryDecorator)
