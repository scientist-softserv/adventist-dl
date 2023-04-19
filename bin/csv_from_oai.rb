
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
    # For all records, comment out previous line and comment in the following.
    # records.full.each_with_index do |r|
      identifier = r.header.identifier
      
      thumbnail_urls = r.metadata.first.find('thumbnail_url').map(&:content)
      related_urls = r.metadata.first.find('related_url').map(&:content)

      thumbnail_urls.each do |thumbnail_url|
        thumbnail_urls.nil? ? "This value returned as nil." : thumbnail_urls
        derivative_type = "thumbnail"
        if thumbnail_file_type = thumbnail_url.split(/[.;]/).each
          derivative_type = thumbnail_file_type == 'pdf' && thumbnail_url.include?(".ARCHIVAL.pdf") ? 'original' : 'thumbnail'
        end
        csv << [set, identifier, derivative_type, thumbnail_url]
      end

      related_urls.each do |related_url|
        related_urls.nil? ? "This value returned as nil." : related_urls
        derivative_type = case related_file_type = related_url.split(/[.;]/).each
                          when 'pdf'
                            related_url.include?(".0.pdf") ? 'original' : 'unknown'
                          when 'txt'
                            related_url.include?(".RAW.txt") ? 'text' : 'unknown'
                          else
                            'unknown'
                          end

        csv << [set, identifier, derivative_type, related_url]
      end
    end
  end
end
