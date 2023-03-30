# frozen_string_literal: true

gem 'oai'
gem 'byebug'
require 'nokogiri'
require 'byebug'
require 'oai'
require 'csv'

  # OAI client setup
  client = OAI::Client.new(
    "http://oai.adventistdigitallibrary.org/OAI-script",
    headers: { from: "jeremy@scientist.com" },
    parser: 'libxml'
  )
  
  opts = {
    metadata_prefix: "oai_adl",
  }

  sets = ["adl:thesis",
          "adl:periodical",
          "adl:issue",
          "adl:article",
          "adl:image",
          "adl:book",
          "adl:other"]


records = client.list_records(opts.merge(set: set))
records.each_with_index do |r, i|
  # Extract the data from the OAI record
  aark_id = aark_id = metadata.aark_id

  byebug
  # identifier = URI('//dc:identifier[@qualifier="oai_adl/aark_id"]', 'dc' => 'http://purl.org/dc/elements/1.1/').text  
  # title = r.metadata
  # resource_type = r.metadata
  # volume_number = r.metadata
  # issue_number = r.metadata
  # language = r.metadata
  # source = r.metadata
  # geocode = r.metadata
  # place_of_publicaion = r.metadata
  # publisher = r.metadata
  # related_url = r.metadata
  # thumbnail_url = r.metadata
  # work_type = r.metadata
end

# Create a new CSV file
  CSV.open('oaifromcsv.csv', 'wb') do |csv|

    # Write the headers to the CSV file
    
    # csv << ['aark_id','identifier', 'title', 'resource_type', 'volume_number', 'issue_number', 'language', 'source', 'geocode', 'place_of_publication', 'publisher', 'related_url', 'thumbnail_url', 'work_type']
    
    csv << ['aark_id']

    # Write the data to the CSV file
    
    # csv << [aark_id, identifier, title, resource_type, volume_number, issue_number, language, source, geocode, place_of_publication, publisher, related_url, thumbnail_url, work_type]
    
    csv << [aark_id]
  end         