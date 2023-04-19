require 'csv'
require 'oai'
require_relative "../lib/oai/client_decorator"

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

  sets = [
    "adl:thesis",
    "adl:periodical",
    "adl:issue",
    "adl:article",
    "adl:image",
    "adl:book",
    "adl:other"
  ]

  sets.each do |set|
    records = client.list_records(opts.merge(set: set))
    # For the first 25 records
    records.each_with_index do |r|
    # For the full set of records, comment out previous line and comment in the following line.
    # records.full.each_with_index do |r|
      identifier = r.header.identifier
      
      thumbnail_urls = r.metadata.first.find('thumbnail_url') || [ ]
      thumbnail_urls = thumbnail_urls.map(&:content).map { |url| url.split(';') }.flatten
      related_urls = r.metadata.first.find('related_url') || [ ]
      related_urls = related_urls.map(&:content).map { |url| url.split(';') }.flatten

      thumbnail_urls.each do |thumbnail_url|
        derivative_type = "thumbnail"
        csv << [set, identifier, derivative_type, thumbnail_url]
      end

      related_urls.each do |related_url|
        derivative_type = if related_url.end_with?(".ARCHIVAL.pdf")
                             'original'
                          elsif related_url.end_with?(".RAW.txt")
                            'text'
                          else
                            'unknown'
                          end

        csv << [set, identifier, derivative_type, related_url]
      end
    end
  end
end
