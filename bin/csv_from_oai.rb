# frozen_string_literal: true
require 'csv'
require 'oai'
require 'byebug'

# Input for dynamic email
# puts "Enter your email address:"
# email = gets.chomp

# OAI client setup
client = OAI::Client.new(
  "http://oai.adventistdigitallibrary.org/OAI-script",
  headers: { from: 'deon.franklin@scientist.com' },
  parser: 'libxml'
)

opts = {
  metadata_prefix: "oai_adl"
}

CSV.open('csv_from_oai.csv', 'wb') do |csv|
  # Write the headers to the CSV file
  csv << ['set', 'identifier', 'resource_type', 'URL']

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
        # begin
        identifier = r.metadata.first.find('identifier').first&.content
        resource_type = r.metadata.first.find('resource_type').first&.content
        related_url = r.metadata.first.find('related_url').first&.content
        thumbnail_url = r.metadata.first.find('thumbnail_url').first&.content        
          # Write records to the CSV file
          csv << [set, identifier, resource_type, related_url || thumbnail_url]

    end
  end
end
