# frozen_string_literal: true

# OVERRIDE in v2.9.6 of Hyrax
# <2023-11-22 Wed> Aim is to hopefully not swallow exceptions, and get meaningful info regarding
#                  the observed problem.
module ImportUrlJobDecorator
  # rubocop:disable Metrics/LineLength
  def perform_af
    name = file_set.label

    copy_remote_file(name) do |f|
      # reload the FileSet once the data is copied since this is a long running task
      file_set.reload

      # FileSetActor operates synchronously so that this tempfile is available.
      # If asynchronous, the job might be invoked on a machine that did not have this temp file on its file system!
      # NOTE: The return status may be successful even if the content never attaches.
      log_import_status(f)
    end
  rescue StandardError => e
    message = "ImportUrlJob: #{file_set.class} ID=#{file_set&.id} to_param=#{file_set&.to_param} with " \
              "Parent #{file_set&.parent&.inspect} ID=#{file_set.parent&.id&.inspect} had error on URI #{uri.inspect}." \
              "Error: #{e.class}.  Message: #{e.message}.  Backtrace:\n#{e.backtrace.join("\n")}"
    Raven.capture_exception(e)
    Hyrax.logger.error(message)
    # Does send_error swallow the exception?
    send_error(message)
    raise e
  end
  # rubocop:enable Metrics/LineLength

  # Download file from uri, yields a block with a file in a temporary directory.
  # It is important that the file on disk has the same file name as the URL,
  # because when the file in added into Fedora the file name will get persisted in the
  # metadata.
  # @param name [String] the human-readable name of the file
  # @yield [IO] the stream to write to
  def copy_remote_file(name)
    filename = File.basename(name)
    dir = Dir.mktmpdir
    Hyrax.logger.debug("ImportUrlJob: Copying <#{uri}> to #{dir}")

    File.open(File.join(dir, filename), 'wb') do |f|
      write_file(f)
      yield f
      Hyrax.logger.debug("ImportUrlJob: Closing #{File.join(dir, filename)}")
    end
  end

  # OVERRIDE there are calls to send_error that send two arguments.
  #
  # @see https://github.com/samvera/hyrax/blob/426575a9065a5dd3b30f458f5589a0a705ad7be2/app/jobs/import_url_job.rb#L76-L105
  def send_error(error_message, *)
    super(error_message)
  end
end

ImportUrlJob.prepend(ImportUrlJobDecorator)
