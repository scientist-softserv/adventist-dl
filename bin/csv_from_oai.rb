# frozen_string_literal: true

# OAI client setup
puts "Enter your email address:"
email = gets.chomp
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
  csv << ['aark_id', 'identifier', 'creator',
          'title', 'resource_type', 'date_created',
          'language', 'extent', 'source',
          'geocode', 'place_of_publication', 'publisher',
          'rights_statement', 'subject', 'related_url',
          'thumbnail_url', 'work_type']
  sets = ["adl:thesis"]
  # "adl:periodical",
  # "adl:issue",
  # "adl:article",
  # "adl:image",
  # "adl:book",
  # "adl:other"]

  # Create a new CSV file
  sets.each do |set|
    records = client.list_records(opts.merge(set: set))
    records.each_with_index do |r, _i|
      # Extract the data from the OAI record
      aark_id = r.metadata.children.first.find('aark_id').first.content
      identifier = r.metadata.children.first.find('identifier').first.content
      creator = r.metadata.children.first.find('creator').first.content
      title = r.metadata.children.first.find('title').first.content
      resource_type = r.metadata.first.find('resource_type').first.content
      date_created = r.metadata.children.first.find('date_created').first.to_s
      language = r.metadata.children.first.find('language').first.content
      extent = r.metadata.children.first.find('extent').first.content
      source = r.metadata.children.first.find('source').first.content
      geocode = r.metadata.children.first.find('geocode').first.to_s
      place_of_publication = r.metadata.children.first.find('place_of_publication').first.to_s
      publisher = r.metadata.children.first.find('publisher').first.to_s
      rights_statement = r.metadata.children.first.find('rights_statement').first
      subject = r.metadata.children.first.find('subject').first.to_s
      related_url = r.metadata.children.first.find('related_url').first.content
      thumbnail_url = r.metadata.children.first.find('thumbnail_url').first.content
      work_type = r.metadata.children.first.find('work_type').first.content
      # volume_number = r.metadata.children.first.find('volume_number').first.content
      # issue_number = r.metadata.children.first.find('issue_number').first.content

      # # Write the data to the CSV file
      csv << [aark_id, identifier, creator,
              title, resource_type, date_created,
              language, extent, source, geocode, place_of_publication,
              publisher, rights_statement, subject,
              related_url, thumbnail_url, work_type]
    end
  end
end
