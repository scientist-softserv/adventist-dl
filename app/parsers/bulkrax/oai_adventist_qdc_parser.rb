# frozen_string_literal: true

module Bulkrax
  class OaiAdventistQdcParser < OaiQualifiedDcParser
    def entry_class
      Bulkrax::OaiAdventistQdcEntry
    end

    def collection_entry_class
      OaiSetEntry
    end

    def file_set_entry_class
      RdfFileSetEntry
    end

    def create_file_sets
      create_objects(['file_set'])
    end

    def create_objects(types_array = nil)
      index = 0
      (types_array || %w[collection work file_set relationship]).each do |type|
        if type.eql?('relationship')
          ScheduleRelationshipsJob.set(wait: 5.minutes).perform_later(importer_id: importerexporter.id)
          next
        end
        send(type.pluralize).each do |current_record|
          next unless record_has_source_identifier(current_record, index)
          break if limit_reached?(limit, index)

          seen[current_record[source_identifier]] = true
          create_entry_and_job(current_record, type)
          increment_counters(index, "#{type}": true)
          index += 1
        end
        importer.record_status
      end
      true
    rescue StandardError => e
      status_info(e)
    end

    def model_field_mappings
      model_mappings = Bulkrax.field_mappings[self.class.to_s]&.dig('model', :from) || []
      model_mappings ||= ['model']

      model_mappings
    end

    def build_records
      @collections = []
      @works = []
      @file_sets = []

      if model_field_mappings.map { |mfm| records.first.metadata.find("//#{mfm}").first }.any?
        records.map do |r|
          model_field_mappings.each do |model_mapping|
            next unless r.metadata.find("//#{model_mapping}").first

            if r.metadata.find("//#{model_mapping}").first.content.casecmp('collection').zero?
              @collections << r
            elsif r.metadata.find("//#{model_mapping}").first.content.casecmp('fileset').zero?
              @file_sets << r
            else
              @works << r
            end
          end
        end
        @collections = @collections.flatten.compact.uniq
        @file_sets = @file_sets.flatten.compact.uniq
        @works = @works.flatten.compact.uniq
      else # if no model is specified, assume all records are works
      @works = records.flatten.compact.uniq
      end

      true
    end

    def works
      build_records if @works.nil?
      @works
    end

    def file_sets
      build_records if @file_sets.nil?
      @file_sets
    end

    def works_total
      works.size
    end

    def file_sets_total
      file_sets.size
    end
  end
end
