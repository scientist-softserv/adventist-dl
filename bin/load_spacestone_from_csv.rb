#!/usr/bin/env ruby

require 'csv'
require 'httparty'
require 'aws-sdk-sqs'

SERVERLESS_COPY_URL = 'https://v1vzxgta7f.execute-api.us-west-2.amazonaws.com/copy'
SERVERLESS_S3_URL = 's3://space-stone-dev-preprocessedbucketf21466dd-bxjjlz4251re.s3.us-west-1.amazonaws.com/'
SERVERLESS_TEMPLATE = '{{dir_parts[-1..-1]}}/{{ filename }}'
SERVERLESS_SPLIT_SQS_URL = 'sqs://us-west-2.amazonaws.com/559021623471/space-stone-dev-split-ocr-thumbnail/'
SERVERLESS_THUMBNAIL_SQS_URL = 'sqs://us-west-2.amazonaws.com/559021623471/space-stone-dev-thumbnail/'
SERVERLESS_COPY_SQS_URL = 'https://sqs.us-west-2.amazonaws.com/559021623471/space-stone-dev-copy'
BATCH_SIZE = 10

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
  end

  def csv
    @csv ||= CSV.read('csv_from_oai.csv', headers: true)
  end

  def post_to_serverless_copy(workload)
    puts "#{SERVERLESS_COPY_URL}\n#{JSON.generate(workload)}"
    HTTParty.post(SERVERLESS_COPY_URL, body: JSON.generate([workload]), headers: { 'Content-Type' => 'application/json' }) unless ENV['DRY_RUN']
  end

  def client
    @client ||= Aws::SQS::Client.new(region: 'us-west-2')
  end

  def post_to_sqs_copy(workload)
    @queue ||= []
    @queue << { id: SecureRandom.uuid, message_body: workload.to_json }
    if (@queue.size % BATCH_SIZE) == 0
      send_batch(@queue)
      @queue = []
    end
  end

  def send_batch(batch)
    client.send_message_batch({
      queue_url: SERVERLESS_COPY_SQS_URL,
      entries: batch
    })
  end

  def thumbnail_destination(row)
    thumbnail_name = File.basename(row['original']).sub(/\..*\z/, ".thumbnail.jpeg")
    "#{SERVERLESS_S3_URL}#{row['aark_id']}/#{thumbnail_name}"
  end

  def split_destination(row)
    "#{SERVERLESS_SPLIT_SQS_URL}#{row['aark_id']}/#{row['aark_id']}.pdf?template=#{SERVERLESS_S3_URL}#{SERVERLESS_TEMPLATE}"
  end

  def original_destination(row)
    original_extention = File.extname(row['original'])
    "#{SERVERLESS_S3_URL}#{row['aark_id']}/#{row['aark_id']}#{original_extention}"
  end

  def has_thumbnail?(row)
    if row['thumbnail'] && row['thumbnail'].match(/^https/)
      workload = {
        row['thumbnail'] => [ thumbnail_destination(row) ]
      }
      # post_to_serverless_copy(workload)
      post_to_sqs_copy(workload)
      true
    end
  end

  def copy_original(row, needs_thumbnail)
    original_extention = File.extname(row['original'])
    workload = { row['original'] => [original_destination(row)] }
    workload[row['original']] << split_destination(row) if original_extention == '.pdf'
    workload[row['original']] << thumbnail_destination(row) if needs_thumbnail
    post_to_sqs_copy(workload)
    # post_to_serverless_copy(workload)
  end

  def insert_into_spacestone
    csv.each do |row|
      needs_thumbnail = !has_thumbnail?(row)
      copy_original(row, needs_thumbnail)
      # TODO copy_access(row)
      puts row.inspect
    end
  end
end

LoadSpaceStoneFromCsv.new.insert_into_spacestone
