# OVERRIDE in v2.9.6 of Hyrax
module ImportUrlJobDecorator
  # OVERRIDE there are calls to send_error that send two arguments.
  #
  # @see https://github.com/samvera/hyrax/blob/426575a9065a5dd3b30f458f5589a0a705ad7be2/app/jobs/import_url_job.rb#L76-L105
  def send_error(error_message, *args)
    super(error_message)
  end
end

ImportUrlJob.prepend(ImportUrlJobDecorator)
