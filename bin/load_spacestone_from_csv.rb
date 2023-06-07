#!/usr/bin/env ruby

require 'csv'
require 'httparty'
SERVERLESS_COPY_URL = 'https://v1vzxgta7f.execute-api.us-west-2.amazonaws.com/copy'
SERVERLESS_S3_URL = 's3://space-stone-dev-preprocessedbucketf21466dd-bxjjlz4251re.s3.us-west-1.amazonaws.com/'
SERVERLESS_TEMPLATE = '{{dir_parts[-1..-1]}}/{{ filename }}'
SERVERLESS_SPLIT_SQS_URL = 'sqs://us-west-2.amazonaws.com/559021623471/space-stone-dev-split-ocr-thumbnail/'
SERVERLESS_OCR_SQS_URL = 'sqs://us-west-2.amazonaws.com/559021623471/space-stone-dev-ocr/'
SERVERLESS_THUMBNAIL_SQS_URL = 'sqs://us-west-2.amazonaws.com/559021623471/space-stone-dev-thumbnail/'

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
  end
  attr_reader :csv

  def insert_into_spacestone
    csv.each do |row|
      puts row.inspect
      needs_thumbnail = !has_thumbnail?(row)
      copy_original(row, needs_thumbnail)
      copy_access(row, needs_thumbnail)
      break
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
      jobs << enqueue_destination(row, key: 'original', url: SERVERLESS_SPLIT_SQS_URL)
    else
      jobs << enqueue_destination(row, key: 'original', url: SERVERLESS_OCR_SQS_URL)
    end
    if needs_thumbnail
      jobs << enqueue_destination(row, key: 'original', url: SERVERLESS_THUMBNAIL_SQS_URL)
    end

    post_to_serverless_copy({ row['original'] => jobs })
  end

  def copy_access(row, needs_thumbnail)
    return if row['reader'].to_s.strip.empty?
    original_extention = File.extname(row['original'])
    return unless original_extention == '.pdf'

    jobs = [original_destination(row, key: 'reader')]

    if needs_thumbnail
      jobs << enqueue_destination(row, key: 'reader', url: SERVERLESS_THUMBNAIL_SQS_URL)
    end

    post_to_serverless_copy({ row['original'] => jobs })
  end

  def post_to_serverless_copy(workload)
    puts "\t#{SERVERLESS_COPY_URL}\n\t#{JSON.generate(workload)}"
    HTTParty.post(SERVERLESS_COPY_URL, body: JSON.generate([workload]), headers: { 'Content-Type' => 'application/json' }) unless ENV['DRY_RUN']
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

LoadSpaceStoneFromCsv.new.insert_into_spacestone
