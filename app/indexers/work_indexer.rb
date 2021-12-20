# frozen_string_literal: true

class WorkIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata
  include DogBiscuits::IndexesCommon

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['creator_ssi'] = object.creator.first.titlecase if object.creator.present?
      solr_doc['date_created_ssi'] = object.date_created if object.date_created.present?
      solr_doc['title_ssi'] = object.title.first.titlecase if object.title.present?
      solr_doc['fedora_id_ssi'] = object.id
      solr_doc[ActiveFedora.id_field.to_sym] = object.to_param
      solr_doc['source_sim'] = solr_doc['source_tesim']

      if object.date_created.present?
        # rubocop:disable Metrics/LineLength
        date_created = object.date_created.is_a?(ActiveTriples::Relation) ? object.date_created.first : object.date_created
        # rubocop:enable Metrics/LineLength
        # expects date created to be array with single string in yyyy-mm-dd format
        solr_doc['sorted_date_isi'] = date_created.tr('-', '').to_i
        solr_doc['sorted_month_isi'] = date_created.tr('-', '').slice(0..5).to_i
        solr_doc['sorted_year_isi'] = date_created.slice(0..3).to_i
      end
    end
  end
end
