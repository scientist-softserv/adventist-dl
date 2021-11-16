# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    if self.parsed_metadata['model'] == 'Collection'
      add_collection_nesting
    else
      add_part_of_collections if self.parsed_metadata['part_of'].present?
      add_set_collections if self.parsed_metadata['resource_type'].include?('Issue')
    end
  end

  def add_set_collections
    sets = record.header.set_spec.map(&:content)
    aark_ids = sets.select { |s| s.match(/^\d+$/) }
    aark_ids.each do |aark|
      collection = Collection.where(aark_id_tesim: aark).first
      add_collection_to_work(collection) if collection
    end
  end

  def add_part_of_collections
    self.parsed_metadata['part_of'].each do |collection_title|
      collection = find_or_create_collection(collection_title)
      add_collection_to_work(collection)
    end
  end

  def add_collection_to_work(collection)
    self.parsed_metadata['member_of_collections_attributes'] || {}
    top_key = self.parsed_metadata['member_of_collections_attributes'].keys.map {|k| k.to_i}.sort.last || -1
    self.parsed_metadata['member_of_collections_attributes']["#{top_key + 1}"] = { id: collection.id }
  end

  def add_collection_nesting
    self.parsed_metadata.delete('admin_set_id')
    nested_collections = self.parsed_metadata.delete('member_of_collections_attributes')
    self.parsed_metadata['collection'] = nested_collections.map { |k, v| v[:id] } if nested_collections.is_a?(Hash)

    if self.parsed_metadata['part_of'].present?
      self.parsed_metadata['part_of'].each do |collection_title|
        collection = find_or_create_collection(collection_title)
        self.parsed_metadata['collection'] ||= []
        self.parsed_metadata['collection'] << collection.id
      end
    end
  end

  def find_or_create_collection(collection_title)
    Collection.where(title_sim: collection_title).first || Collection.create(title: [collection_title], collection_type: Hyrax::CollectionType.find_by(title: 'User Collection'))
  end
end
