require 'oai'

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

# Request records
records = client.list_records(opts.merge(set: sets))

# Extract information from records
records.each do |record|
  identifier = record.header.identifier
  datestamp = record.header.datestamp

  # Access metadata using the desired metadata prefix
  metadata = record.metadata.oai_adl
  aark_id = metadata.aark_id
  identifier = metadata.identifier
  title = metadata.title
  resource_type = metadata.resource_type
  volume_number = metadata.volume_number
  issue_number = metadata.issue_number
  language = metadata.language
  source = metadata.source
  geocode = metadata.geocode
  place_of_publication = metadata.place_of_publication
  publisher = metadata.publisher
  related_url = metadata.related_url
  thumbnail_url = metadata.thumbnail_url
  work_type = metadata.work_type

  # Print information for each record
  puts "Identifier: #{identifier}"
  puts "Datestamp: #{datestamp}"
  puts "AARK ID: #{aark_id}"
  puts "Title: #{title}"
  puts "Resource Type: #{resource_type}"
  puts "Volume Number: #{volume_number}"
  puts "Issue Number: #{issue_number}"
  puts "Language: #{language}"
  puts "Source: #{source}"
  puts "Geocode: #{geocode}"
  puts "Place of Publication: #{place_of_publication}"
  puts "Publisher: #{publisher}"
  puts "Related URL: #{related_url}"
  puts "Thumbnail URL: #{thumbnail_url}"
  puts "Work Type: #{work_type}"
  puts "--------------------------------------------------"
e
nd