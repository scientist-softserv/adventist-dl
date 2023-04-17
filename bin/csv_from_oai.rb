# frozen_string_literal: true
require 'csv'
require 'oai'
require 'byebug'

# Input for dynamic email
puts "Enter your email address:"
email = gets.chomp

# OAI client setup
client = OAI::Client.new(
  "http://oai.adventistdigitallibrary.org/OAI-script",
  headers: { from: email },
  parser: 'libxml'
)

opts = {
  metadata_prefix: "oai_adl"
}

CSV.open('csv_from_oai.csv', 'wb') do |csv|
  # Write the headers to the CSV file
  csv << ['set', 'identifier', 'derivative_type', 'URL']

  sets = ["adl:thesis",
    "adl:periodical",
    "adl:issue",
    "adl:article",
    "adl:image",
    "adl:book",
    "adl:other"
  ]

  sets.each do |set|
    records = client.list_records(opts.merge(set: set))
    records.each do |r|
      identifier = r.header.identifier
      thumbnail_url = r.metadata.first.find('thumbnail_url').first&.content
      related_url = r.metadata.first.find('related_url').first&.content

      # Split thumbnail_url and extract file type
      thumbnail_file_type = thumbnail_url.split('.').last if thumbnail_url
      # Split related_url and extract file type
      related_file_type = related_url.split('.').last if related_url

      # Write thumbnail URL to CSV
      if thumbnail_url
        csv << [set, identifier, thumbnail_file_type, thumbnail_url]
      end

      # Write related URL to CSV
      if related_url
        csv << [set, identifier, related_file_type, related_url]
      end
    end
  end
end