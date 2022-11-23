# frozen_string_literal: true

class CollectionIndexer < Hyrax::CollectionIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # This is echoing the JournalArticleIndexer; see
  # https://github.com/scientist-softserv/adventist-dl/issues/49
  include DogBiscuits::IndexesCommon

  # Uncomment this block if you want to add custom indexing behavior:
  # def generate_solr_document
  #  super.tap do |solr_doc|
  #    solr_doc['my_custom_field_ssim'] = object.my_custom_property
  #  end
  # end

  # Add any custom indexing into here. Method must exist, but can be empty.
  def do_local_indexing(solr_doc); end
end
