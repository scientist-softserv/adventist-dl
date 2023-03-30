# frozen_string_literal: true

require 'oai'
require 'csv'
  
  # OAI client setup
  client = OAI::Client.new(
    "http://oai.adventistdigitallibrary.org/OAI-script",
    headers: { from: "jeremy@scientist.com" },
    parser: 'libxml'
  )

  opts = {
    metadata_prefix: "oai_adl"
  }

  sets = ["adl:thesis",
          "adl:periodical",
          "adl:issue",
          "adl:article",
          "adl:image",
          "adl:book",
          "adl:other"]

sets.each do |set|
records = client.list_records(opts.merge(set: set))
records.each_with_index do |r, i|
  # Extract the data from the OAI record
  # header = r.header
  # metadata = r.metadata
  # aark_id = r.identifier
  identifier = r.metadata('//dc:identifier', 'dc' => 'http://purl.org/dc/elements/1.1/').text
  # title = r.metadata('//dc:title', 'dc' => 'http://purl.org/dc/elements/1.1/').text
  # resource_type = r.metadata('//dc:type', 'dc' => 'http://purl.org/dc/elements/1.1/').text
  # volume_number = r.metadata('//adl:volume_number', 'adl' => 'http://adventistdigitallibrary.org/adl').text
  # issue_number = r.metadata('//adl:issue_number', 'adl' => 'http://adventistdigitallibrary.org/adl').text
  # language = r.metadata('//dc:language', 'dc' => 'http://purl.org/dc/elements/1.1/').text
  # source = r.metadata('//dc:source', 'dc' => 'http://purl.org/dc/elements/1.1/').text
  # geocode = r.metadata('//adl:geocode', 'adl' => 'http://adventistdigitallibrary.org/adl').text
  # place_of_publication = r.metadata('//dc:publisher', 'dc' => 'http://purl.org/dc/elements/1.1/').text
  # publisher = r.metadata('//dc:publisher', 'dc' => 'http://purl.org/dc/elements/1.1/').text
  # related_url = r.metadata('//dc:relation', 'dc' => 'http://purl.org/dc/elements/1.1/').text
  # thumbnail_url = r.metadata('//adl:thumbnail_url', 'adl' => 'http://adventistdigitallibrary.org/adl').text
  # work_type = r.metadata('//adl:work_type', 'adl' => 'http://adventistdigitallibrary.org/adl').text
end

# Create a new CSV file
  CSV.open('output.csv', 'wb') do |csv|

    # Write the headers to the CSV file
    csv << ['identifier']
    # Write the data to the CSV file
    csv << [identifier]
    csv << ['aark_id','identifier', 'title', 'resource_type', 'volume_number', 'issue_number', 'language', 'source', 'geocode', 'place_of_publication', 'publisher', 'related_url', 'thumbnail_url', 'work_type']
    csv << [aark_id, identifier, title, resource_type, volume_number, issue_number, language, source, geocode, place_of_publication, publisher, related_url, thumbnail_url, work_type]
  end
end
