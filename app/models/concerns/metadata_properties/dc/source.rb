# frozen_string_literal: true
# OVERRRIDE dog_biscuits gem to make :source facetable

module DogBiscuits
  module Source
    extend ActiveSupport::Concern

    included do
      property :source, predicate: ::RDF::Vocab::DC.source do |index|
        index.as :stored_searchable, :facetable
      end
    end
  end
end