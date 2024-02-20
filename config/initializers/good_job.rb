
# frozen_string_literal: true

Rails.application.configure do
  # Configure options individually...

  # Preserve finished (successful) and discarded (failed) jobs.
  config.good_job.preserve_job_records = true
  config.good_job.retry_on_unhandled_error = false
  config.good_job.on_thread_error = ->(exception) { Raven.capture_exception(exception) }
  config.good_job.execution_mode = :external
  # config.good_job.queues = '-auxiliary, *'
  config.good_job.shutdown_timeout = 60 # seconds
  config.good_job.poll_interval = 5
  # config.good_job.enable_cron = true
  # config.good_job.cron = { example: { cron: '0 * * * *', class: 'ExampleJob'  } }

  ##################################################################################################
  ## The following values are configured in the .env file.  You can uncomment them here to supersede
  ## those ENV values:
  ##################################################################################################

  ## Discarded jobs are ones that failed.  We do not want to automatically clean them up.
  # config.good_job.cleanup_discarded_jobs = false

  ## We want to clean up successful preserved jobs.
  # config.good_job.cleanup_preserved_jobs_before_seconds_ago = 1.week.to_i

  ## We want to trigger the cleanup every day or so
  # config.good_job.cleanup_interval_seconds = 1.day.to_i
end

# Wrapping this in an after_initialize block to ensure that all constants are loaded
Rails.application.config.after_initialize do
  # baseline of 0, higher is sooner

  # Commented out the following two jobs because they were
  # specfically used for the sdapi ingests.
  # see sdapi_ingest_script directory and
  # ref: https://github.com/scientist-softserv/adventist-dl/issues/468
  # CollectionMembershipJob.priority = 70
  # UpdateCollectionMembershipJob.priority = 60
  Bulkrax::ScheduleRelationshipsJob.priority = 50
  CreateDerivativesJob.priority = 40
  CharacterizeJob.priority = 30
  Hyrax::GrantEditToMembersJob.priority = 10
  ImportUrlJob.priority = 10
  IngestJob.priority = 10
  ApplicationJob.priority = 0
  AttachFilesToWorkJob.priority = -1
  Bulkrax::ImportWorkJob.priority = -5
  Bulkrax::ImportFileSetJob.priority = -15
  IiifPrint::Jobs::ChildWorksFromPdfJob.priority = -17
  Bulkrax::CreateRelationshipsJob.priority = -20
  Bulkrax::ImporterJob.priority = -20
  IiifPrint::Jobs::CreateRelationshipsJob.priority = -20
  ContentDepositEventJob.priority = -50
  ContentUpdateEventJob.priority = -50
end
