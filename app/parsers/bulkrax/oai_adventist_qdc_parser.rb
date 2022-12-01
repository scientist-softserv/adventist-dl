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

    def create_collections
      create_objects(['collection'])
    end

    def create_file_sets
      create_objects(['file_set'])
    end

    def create_relationships
      ScheduleRelationshipsJob.set(wait: 5.minutes).perform_later(importer_id: importerexporter.id)
    end

    def create_objects(types_array = nil)
      index = 0
      (types_array || %w[collection work file_set relationship]).each do |type|
        if type.eql?('relationship')
          ScheduleRelationshipsJob.set(wait: 5.minutes).perform_later(importer_id: importerexporter.id)
          next
        elsif type.eql?('work')
          create_works
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

    def create_entry_and_job(current_record, type)
      new_entry = find_or_create_entry(send("#{type}_entry_class"),
                                       current_record[source_identifier],
                                       'Bulkrax::Importer',
                                       current_record.to_h)
      if current_record[:delete].present?
        "Bulkrax::Delete#{type.camelize}Job".constantize.send(perform_method, new_entry, current_run)
      else
        "Bulkrax::Import#{type.camelize}Job".constantize.send(perform_method, new_entry.id, current_run.id)
      end
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

            generate_collection r.header.set_spec if r.header.set_spec.present?
            if r.metadata.find("//#{model_mapping}").first.content.casecmp('collection').zero?
              @collections << r
            elsif r.metadata.find("//#{model_mapping}").first.content.casecmp('fileset').zero?
              @file_sets << r
            else
              @works << r
            end
          end
        end
        flatten_arrays(%w[@collections @file_sets @works])
      else # if no model is specified, assume all records are works
        @works = records
        flatten_arrays(%w[@works])
      end
      true
    end

    def flatten_arrays(record_arrays)
      record_arrays.each do |a|
        instance_variable_set(a, instance_variable_get(a).flatten.compact.uniq)
      end
    end

    def generate_collection(set_spec)
      set_spec.each do |set|
        @collections << { source_identifier => [importerexporter.unique_collection_identifier(set.content)],
                          'title' => [importerexporter.unique_collection_identifier(set.content)] }
      end
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
