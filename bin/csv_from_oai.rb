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
        if thumbnail_url.include?(';')
          thumbnail_url, query_string = thumbnail_url.split(';')
        end
        thumbnail_file_type = thumbnail_url.split('.').last

        # Set derivative type to "thumbnail" by default
        derivative_type = "thumbnail"

        # Check if thumbnail URL should have derivative type of "original"
        if thumbnail_file_type == "pdf" && thumbnail_url.include?(".ARCHIVAL.pdf")
          derivative_type = "original"
        end

        # Write thumbnail URL to CSV
        csv << [set, identifier, derivative_type, thumbnail_url]
      end

      related_urls.each do |related_url|
        # Split related_url and extract file type
        if related_url.include?(';')
          related_url, query_string = related_url.split(';')
        end
        related_file_type = related_url.split('.').last

        # Set derivative type to "original" if URL contains ".ARCHIVAL.pdf"
        if related_file_type == "pdf" && related_url.include?(".ARCHIVAL.pdf")
          derivative_type = "original"
        elsif related_file_type == "txt" && related_url.include?(".RAW.txt")
          derivative_type = "text"
        else
          derivative_type = "unknown"
        end

        # Write related URL to CSV
        csv << [set, identifier, derivative_type, related_url]
      end
    end
  end
end
