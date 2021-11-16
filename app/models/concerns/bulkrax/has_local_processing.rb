# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    if self.parsed_metadata['model'] == 'Collection'
      self.parsed_metadata.delete('admin_set_id')
      nested_collections = self.parsed_metadata.delete('member_of_collections_attributes')
      self.parsed_metadata['collection'] = nested_collections.map { |k, v| v[:id] } if nested_collections.is_a?(Hash)

      if self.parsed_metadata['part_of'].present?
        self.parsed_metadata['part_of'].each do |collection_title|
          collection = Collection.where(title_sim: collection_title).first || Collection.create(title: [collection_title], collection_type: Hyrax::CollectionType.find_by(title: 'User Collection'))
          self.parsed_metadata['collection'] ||= []
          self.parsed_metadata['collection'] << collection.id
        end
      end
    else
      if self.parsed_metadata['part_of'].present?
        self.parsed_metadata['part_of'].each do |collection_title|
          collection = Collection.where(title_sim: collection_title).first || Collection.create(title: [collection_title], collection_type: Hyrax::CollectionType.find_by(title: 'User Collection'))
          self.parsed_metadata['member_of_collections_attributes'] || {}
          top_key = self.parsed_metadata['member_of_collections_attributes'].keys.map {|k| k.to_i}.sort.last || -1
          self.parsed_metadata['member_of_collections_attributes']["#{top_key + 1}"] = {id: collection.id}
        end
      end
    end

  end
end
