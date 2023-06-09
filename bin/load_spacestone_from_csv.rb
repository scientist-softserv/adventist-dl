#!/usr/bin/env ruby

require 'csv'
require 'httparty'
gem 'aws-sdk-sqs'
require 'aws-sdk-sqs'

SERVERLESS_S3_URL = 's3://space-stone-dev-preprocessedbucketf21466dd-bxjjlz4251re.s3.us-west-1.amazonaws.com/'
SERVERLESS_TEMPLATE = '{{dir_parts[-1..-1]}}/{{ filename }}'

SQS_QUEUE_NAMES = {
  copy:  'space-stone-dev-copy',
  split: 'space-stone-dev-split-ocr-thumbnail',
  ocr: 'space-stone-dev-ocr',
  thumbnail: 'space-stone-dev-thumbnail',
}

## Read csv file
## if there is an archival pdf
## if there is a reader pdf
## if there is a text file
## if there is a thumbnail

## if there is an original, a reader, text and a thumbnail
#- what do we do with a reader?
#- TODO text copy
#- copy original to s3
#- copy thumbnail in to the thumbnail place
#- split-ocr-thumbnail the original pdf

## if there is an original only
#- copy original to s3
#- create a thumbnail of the original pdf
#- split-ocr-thumbnail the original pdf

## if there is an image in the original slot and an access copy and there is a thumbnail
#- copy original to s3
#- copy the thumbnail to the thumbnail place
#- TODO access copy

## if there is an image in the original slot but no thumbnail
#- copy original to s3
#- create thumbnail for the original

class LoadSpaceStoneFromCsv
  def initialize
    @csv = CSV.read('csv_from_oai.csv', headers: true)
    @sqs_client = Aws::SQS::Client.new(
      region: ENV.fetch('AWS_REGION'),
      credentials: Aws::Credentials.new(
        ENV.fetch('AWS_ACCESS_KEY_ID'),
        ENV.fetch('AWS_SECRET_ACCESS_KEY')
      )
    )
    @queue_urls = SQS_QUEUE_NAMES.each_with_object({}) do |(key, name), hash|
      hash[key] = @sqs_client.get_queue_url(queue_name: name).queue_url
    end
  end
  attr_reader :csv, :sqs_client, :queue_urls

  def insert_into_spacestone
    csv.each do |row|
      puts row.inspect
      needs_thumbnail = !has_thumbnail?(row)
      copy_original(row, needs_thumbnail)
      copy_access(row, needs_thumbnail)
    end
  end

  ##
  # For an original file:
  #
  # - Copy the original file to the SpaceStone location
  # - When it is a PDF, enqueue splitting it
  # - When it does not have a thumbnail, enqueue creating a thumbnail
  #
  # @param row [CSV::Row]
  # @param needs_thumbnail [Boolean] when true we will need to enqueue a thumbnail generation job.
  def copy_original(row, needs_thumbnail)
    original_extention = File.extname(row['original'])
    jobs = [original_destination(row)]

    # TODO: In the case of PDF, Split; in the case of images, OCR.  In all cases thumbnail.
    if original_extention == '.pdf'
      jobs << enqueue_destination(row, key: 'original', url: queue_urls.fetch(:split))
    else
      jobs << enqueue_destination(row, key: 'original', url: queue_urls.fetch(:ocr))
    end
    if needs_thumbnail
      jobs << enqueue_destination(row, key: 'original', url: queue_urls.fetch(:thumbnail))
    end

    post_to_serverless_copy({ row['original'] => jobs })
  end

  def copy_access(row, needs_thumbnail)
    return if row['reader'].to_s.strip.empty?
    original_extention = File.extname(row['original'])
    return unless original_extention == '.pdf'

    jobs = [original_destination(row, key: 'reader')]

    if needs_thumbnail
      jobs << enqueue_destination(row, key: 'reader', url: queue_urls.fetch(:thumbnail))
    end

    post_to_serverless_copy({ row['original'] => jobs })
  end

  def post_to_serverless_copy(workload)
    body = JSON.generate([workload])
    puts "\t#{queue_urls.fetch(:copy)}\n\t#{body}"

    return unless ENV['DRY_RUN']

    sqs_client.send_message(
      queue_url: queue_urls.fetch(:copy),
      message_body: body
    )
  end

  def thumbnail_destination(row, key: 'original')
    # We might have multiple periods in the filename, remove the extension.
    thumbnail_name = File.basename(row[key]).sub(/\.[^\.]*\z/, ".thumbnail.jpeg")
    "#{SERVERLESS_S3_URL}#{row['aark_id']}/#{thumbnail_name}"
  end

  def enqueue_destination(row, url:, key: 'original')
    basename = File.basename(row[key])
    "#{url}#{row['aark_id']}/#{basename}?template=#{SERVERLESS_S3_URL}#{SERVERLESS_TEMPLATE}"
  end

  def original_destination(row, key: 'original')
    "#{SERVERLESS_S3_URL}#{row['aark_id']}/#{File.basename(row[key])}"
  end

  def has_thumbnail?(row)
    if row['thumbnail'] && row['thumbnail'].match(/^https/)
      jobs = [ thumbnail_destination(row) ]
      if !row['reader'].to_s.strip.empty? && row['reader'].end_with?('.pdf')
        jobs << thumbnail_destination(row, key: 'reader')
      end
      post_to_serverless_copy(row['thumbnail'] => jobs)
      true
    end
  end
end

loader = LoadSpaceStoneFromCsv.new
loader.insert_into_spacestone
