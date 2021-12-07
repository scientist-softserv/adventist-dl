# frozen_string_literal: true

if Settings.bulkrax.enabled

  Bulkrax.setup do |config|
    # Add local parsers
    config.parsers += [
      { name: "OAI - Adventist Digital Library", class_name: "Bulkrax::OaiAdventistQdcParser", partial: "oai_adventist_fields" }
    ]

    # disable parsers
    config.parsers -= [
      { name: "OAI - Qualified Dublin Core", class_name: "Bulkrax::OaiQualifiedDcParser", partial: "oai_fields" },
      { name: "OAI - Dublin Core", class_name: "Bulkrax::OaiDcParser", partial: "oai_fields" },
      { name: "CSV - Comma Separated Values", class_name: "Bulkrax::CsvParser", partial: "csv_fields" },
      { name: "Bagit", class_name: "Bulkrax::BagitParser", partial: "bagit_fields" },
      { name: "XML", class_name: "Bulkrax::XmlParser", partial: "xml_fields" }
    ]

    # Should Bulkrax make up source identifiers for you? This allow round tripping
    # and download errored entries to still work, but does mean if you upload the
    # same source record in two different files you WILL get duplicates.
    # It is given two aruguments, self at the time of call and the index of the reocrd
    #    config.fill_in_blank_source_identifiers = ->(parser, index) { "b-#{parser.importer.id}-#{index}"}
    # or use a uuid
    #    config.fill_in_blank_source_identifiers = ->(parser, index) { SecureRandom.uuid }

    # Field mappings
    # Create a completely new set of mappings by replacing the whole set as follows
    #   config.field_mappings = {
    #     "Bulkrax::OaiDcParser" => { **individual field mappings go here*** }
    #   }

    # Add to, or change existing mappings as follows
    #   e.g. to exclude date
    #   config.field_mappings["Bulkrax::OaiDcParser"]["date"] = { from: ["date"], excluded: true  }
    #
    # #   e.g. to add the required source_identifier field
    #   #   config.field_mappings["Bulkrax::CsvParser"]["source_id"] = { from: ["old_source_id"], source_identifier: true  }
    # If you want Bulkrax to fill in source_identifiers for you, see below

    # To duplicate a set of mappings from one parser to another
    #   config.field_mappings["Bulkrax::OaiOmekaParser"] = {}
    #   config.field_mappings["Bulkrax::OaiDcParser"].each {|key,value| config.field_mappings["Bulkrax::OaiOmekaParser"][key] = value }

    config.field_mappings['Bulkrax::OaiAdventistQdcParser'] = {
      'aark_id' => { from: ['aark_id'] },
      'abstract' => { from: ['abstract'] },
      'alt' => { from: ['geocode'] },
      'alternative_title' => { from: ['alternative_title'] },
      'bibliographic_citation' => { from: ['bibliographic_citation'] },
      'contributor' => { from: ['contributor'] },
      'creator' => { from: ['creator'] },
      'date_created' => { from: ['date_created'] },
      'date_issued' => { from: ['date_issued'] },
      'description' => { from: ['description'] },
      'edition' => { from: ['edition'] },
      'extent' => { from: ['extent'] },
      'identifier' => { from: ['identifier'], source_identifier: true },
      'issue_number' => { from: ['issue_number'] },
      'language' => { from: ['language'] },
      'model' => { from: ['work_type'] },
      'official_url' => { from: ['remote_url'], split: ';' },
      'pagination' => { from: ['pagination'] },
      'part_of' => { from: ['part_of'] },
      'place_of_publication' => { from: ['place_of_publication'] },
      'publisher' => { from: ['publisher'] },
      'remote_files' => { from: ['related_url'], split: ';', parsed: true },
      'remote_url' => { from: ['remote_url'], split: ';' },
      'resource_type' => { from: ['resource_type'] },
      'rights_statement' => { from: ['rights_statement'] },
      'source' => { from: ['source'] },
      'subject' => { from: ['subject'], split: ';' },
      'thumbnail_url' => { from: ['thumbnail_url'], default_thumbnail: true, parsed: true },
      'title' => { from: ['title'] },
      'volume_number' => { from: ['volume_number'] }
    }

    # Lambda to set the default field mapping
    config.default_field_mapping = lambda do |field|
      return if field.blank?
      {
        field.to_s =>
        {
          from: [field.to_s],
          split: false,
          parsed: Bulkrax::ApplicationMatcher.method_defined?("parse_#{field}"),
          if: nil,
          excluded: false,
          default_thumbnail: false
        }
      }
    end

    # WorkType to use as the default if none is specified in the import
    # Default is the first returned by Hyrax.config.curation_concerns
    # config.default_work_type = MyWork

    # Path to store pending imports
    # config.import_path = 'tmp/imports'

    # Path to store exports before download
    # config.export_path = 'tmp/exports'

    # Server name for oai request header
    # config.server_name = 'my_server@name.com'

    # Field_mapping for establishing a parent-child relationship (FROM parent TO child)
    # This can be a Collection to Work, or Work to Work relationship
    # This value IS NOT used for OAI, so setting the OAI Entries here will have no effect
    # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
    # Example:
    #   {
    #     'Bulkrax::RdfEntry'  => 'http://opaquenamespace.org/ns/contents',
    #     'Bulkrax::CsvEntry'  => 'children'
    #   }
    # By default no parent-child relationships are added
    # config.parent_child_field_mapping = { }

    # Field_mapping for establishing a collection relationship (FROM work TO collection)
    # This value IS NOT used for OAI, so setting the OAI parser here will have no effect
    # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
    # The default value for CSV is collection
    # Add/replace parsers, for example:
    # config.collection_field_mapping['Bulkrax::RdfEntry'] = 'http://opaquenamespace.org/ns/set'

    # Properties that should not be used in imports/exports. They are reserved for use by Hyrax.
    # config.reserved_properties += ['my_field']
  end
end
