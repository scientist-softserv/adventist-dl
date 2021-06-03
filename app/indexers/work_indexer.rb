# frozen_string_literal: true

class WorkIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['creator_ssi'] = object.creator.first.titlecase
      solr_doc['date_created_ssi'] = object.date_created.first
      solr_doc['title_ssi'] = object.title.first.titlecase
    end
  end
end
