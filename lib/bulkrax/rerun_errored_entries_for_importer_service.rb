module Bulkrax
  ##
  # This class is responsible for rescheduling all failed importers; and creating a run state as if
  # we had run everything.
  #
  # @note This class is starting it's life in the Adventist repository but is being designed so that
  #       we could copy it rather easily into Bulkrax.
  #
  # @see https://github.com/scientist-softserv/adventist-dl/issues/430
  #
  # @example
  #   service = Bulkrax::RerunErroredEntriesForImporterService.new(importer_id: 123, last_run_id: 456)
  #   service.call
  class RerunErroredEntriesForImporterService

    def self.call(importer_id:, last_run_id: nil, error_class: [], logger: Rails.logger)
      new(importer_id: importer_id, last_run_id: last_run_id, error_classes: error_class, logger: logger)
    end

    ##
    # @param importer_id [Integer]
    # @param last_run_id [Integer]
    # @param error_classes [String] only re-run for entries that had failures matching the given
    #        :error_classes.
    # @param logger [Logger]
    def intialize(importer_id:, last_run_id: nil, error_classes: [], logger: Rails.logger)
      @logger = logger
      @importer = Bulkrax::Importer.find(importer_id)
      if last_run_id
        @last_run = @importer.importer_runs.find(last_run_id)
      else
        @last_run = @importer.last_run
      end
      @new_run = create_new_run_from_last_run
      @error_classes = Array.wrap(error_class).map(&:to_s)
    end

    attr_reader :importer, :last_run, :new_run, :logger, :error_classes

    ##
    # We need to:
    #
    # - Create a new importer_run for the given importer
    # - Loop through the statuses of the last_run
    #   - When entry is an error, "enqueue" and create pending status
    #   - When entry is success, "copy status to new run"
    def call
      start_processing_importer!

      # Start processing the importer's entries.
      #
      # HACK: The 'Bulkrax::Entry' may be a bit presumptive so caller beware.
      last_run.statuses.where(statusable_type: 'Bulkrax::Entry').find_each do |status|
        process_status!(status: status)
      end

      finish_processing_importer!
    end

    private

    ##
    # This method should emulate the logic we perform when we begin processing an import.
    def start_processing_importer!
      # Reading through Bulkrax, I'm not seeing anything that needs doing.
    end

    def processes_status!(status:)
      if status.error_classes.present?
        if error_classes.empty? || error_classes.include?(status.error_class)
          reimport!(status: status)
        else
          duplicate!(status: status)
        end
      else
        duplicate!(status: status)
      end
    end

    ##
    # This method should emulate the logic we perform when we begin processing an import.
    def finish_processing_importer!
      # Reading through Bulkrax, I'm not seeing anything that needs doing.  The logic to review is here:
      # https://github.com/samvera-labs/bulkrax/blob/cfaee2f8f697fc408afd3b348b7d1ca04802a48b/app/models/bulkrax/importer.rb#L157-L164
    end

    ##
    # For the given :status, opy that status's data to a new status associated with the {#new_run}.
    #
    # @param status [Bulkrax::Status]
    def reimport!(status:)
      entry = status.statusable
      logger.info("Reimporting for #{entry.class} ID=#{entry.id} for #{importer.class} ID=#{importer.id}.")
      job = case entry.factory_class
            when Collection
              Bulkrax::ImportCollectionJob
            when FileSet
              Bulkrax::ImportFileSetJob
            else
              Bulkrax::ImportWorkJob
            end

      job.perform_later(perform_method, entry.id, new_run.id)

      # The following line of code mimics incrementing the enqueued work; by re-finding the record,
      # we are accounting for the previously enqueued jobs to have already started decrementing the
      # counter.
      #
      # The imporer_behavior uses an incrementer logic that might be a bug:
      # https://github.com/samvera-labs/bulkrax/blob/6174d72c33a98a82ac0d2ef0e309192369da27ab/app/models/concerns/bulkrax/importer_exporter_behavior.rb#L35
      ActiveRecord::Base.uncached do
        ImporterRun.find(new_run.id).increment!(:enqueued_records)
      end
    end

    ##
    # For the given :status, copy that status's data to a new status associated with the {#new_run}.
    #
    # @param status [Bulkrax::Status]
    def duplicate!(status:)
      logger.info("Duplicating for #{status.statusable_type} ID=#{status.statusable_id} for #{importer.class} ID=#{importer.id}.")
      new_run.statuses.create!(
        # Repurpose all of the given status's attributes except the ones identified below.
        status.attributes.except(
          'id', # don't re-use the primary key.
          'runnable_id', # this is the new run's ID, which will be set.
          'runnable_type', # this is the new run's class, which will be set.
          'created_at', # this is a Rails managed field.
          'updated_at' # this is a Rails managed field.
        )
      )
      return 0
    end

    # @see https://github.com/samvera-labs/bulkrax/blob/6174d72c33a98a82ac0d2ef0e309192369da27ab/app/models/bulkrax/importer.rb#L107-L121
    def create_new_run_from_last_run
      logger.info("Creating new run for #{importer.class} ID=#{importer.id} based on #{last_run.class} ID=#{last_run.id}.")
      # We're going to copy and grab the counts; hopefully those are correct.
      importer.importer_runs.create!(
        last_run.attributes.slice(
          'total_work_entries',
          'total_collection_entries',
          'total_file_set_entries'))
    end
  end
end
