# frozen_string_literal: true

# OVERRIDE: IIIF Print v1.0.0 to work with slugs
IiifPrint::LineageService.module_eval do
  def self.ancestor_ids_for(object)
    ancestor_ids ||= []
    object.in_works.each do |work|
      # looking for the #slug instead of #id
      ancestor_ids << work&.slug || work.id
      ancestor_ids += ancestor_ids_for(work) if work.is_child
    end
    ancestor_ids.flatten.compact.uniq
  end
end
