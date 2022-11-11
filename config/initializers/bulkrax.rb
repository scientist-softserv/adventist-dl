# frozen_string_literal: true

if Settings.bulkrax.enabled

  Bulkrax.setup do |config|
    # Setting the available parsers for Adventist.
    config.parsers = [
      { name: "OAI - Adventist Digital Library", class_name: "Bulkrax::OaiAdventistQdcParser", partial: "oai_adventist_fields" },
      { name: "CSV - Comma Separated Values", class_name: "Bulkrax::CsvParser", partial: "csv_fields" },
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

    shared_parser_mappings = {
        'abstract' =>  { from: ['Abstract', 'description.abstract'] },
        'aark_id' =>  { from: ['AIN', 'identifier.ark', 'aark_id'] },
        'identifier' =>  { from: ['CallNumber', 'RefID', 'identifier'], source_identifier: true  },
        'bibliographic_citation' =>  { from: ['Citation', 'identifier.bibliographicCitation'] },
        'creator' =>  { from: ['Contributors', 'creator'] },
        'contributor' =>  { from: ['Alt.Contributors', 'contributor'] },
        'edition' =>  { from: ['Edition', 'title.release', 'edition'] },
        'alternative_title' =>  { from: ['EnglishTranslation', 'EnglishTitle', 'TransliterationTitle', 'title.alternative'] },
        'resource_type' =>  { from: ['Genre', 'TypeOfResource', 'type'] },
        'issue_number' =>  { from: ['Issue', 'relation.isPartOfIssue'] },
        'language' =>  { from: ['Language', 'language'] },
        'description' =>  { from: ['Notes', 'TableOfContents', 'description'] },
        'pagination' =>  { from: ['PageRange', 'format.extent'] },
        'extent' =>  { from: ['PhysicalDescription', 'format.extent', 'extent'], split: ';' },
        'source' =>  { from: ['Provinance', 'source'] },
        'date_issued' =>  { from: ['PublishedOrIssuedDate', 'date'] },
        'alt' =>  { from: ['PublicationGeoCode', 'coverage.spatial'] },
        'place_of_publication' =>  { from: ['PublicationPlace', 'publisher', 'place_of_publication'] },
        'publisher' =>  { from: ['Publisher', 'publisher'] },
        'rights_statement' =>  { from: ['Rights', 'rights'] },
        'part' => { from: ['part_name', 'volume'] },
        'part_of' =>  { from: ['SeriesOrCollection', 'relation.isPartOf', 'part_of'] },
        'date_created' =>  { from: ['SortDate', 'date.other'] },
        'title' =>  { from: ['Subtitle', 'Title', 'title'] },
        'subject' =>  { from: ['TopicKeywords', 'TopicConference', 'TopicSubjectHeadings', 'TopicOrganizations', 'TopicPeople', 'TopicGeographic', 'subject'], split: ';'  },
        'related_url' =>  { from: ['Url', 'related_url'] },
        'volume_number' =>  { from: ['Volume', 'relation.isPartOfVolume'] },
        'keyword' => { from: ['keyword'], split: ';' },
        'location' => { from: ['location'], split: ';' },
        'model' => { from: ['work_type'] },
        'remote_files' => { from: ['related_url'], split: ';', parsed: true },
        'remote_url' => { from: ['official_url', 'remote_url'], split: ';' },
        'thumbnail_url' => { from: ['thumbnail_url'], default_thumbnail: true, parsed: true }
    }

    config.field_mappings['Bulkrax::OaiAdventistQdcParser'] = shared_parser_mappings
    config.field_mappings['Bulkrax::CsvParser'] = shared_parser_mappings

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
