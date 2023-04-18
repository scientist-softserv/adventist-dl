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
      thumbnail_urls = r.metadata.first.find('thumbnail_url').map(&:content)
      related_urls = r.metadata.first.find('related_url').map(&:content)

      thumbnail_urls.each do |thumbnail_url|
        # Split thumbnail_url and extract file type
        thumbnail_file_type = thumbnail_url.split('.').last
        if thumbnail_file_type == 'pdf'
          thumbnail_url = thumbnail_url.split('?').first
          derivative_type = 'unknown'
        else
          derivative_type = thumbnail_file_type
        end
        # Split thumbnail URL if it contains a semicolon
        thumbnail_url.split(';').each do |url|
          # Write thumbnail URL to CSV
          csv << [set, identifier, derivative_type, url]
        end
      end

      related_urls.each do |related_url|
        # Split related_url and extract file type
        related_file_type = related_url.split('.').last
        # Split related URL if it contains a semicolon
        related_url.split(';').each do |url|
          # Write related URL to CSV
          csv << [set, identifier, related_file_type, url]
        end
      end
    end
  end
end
