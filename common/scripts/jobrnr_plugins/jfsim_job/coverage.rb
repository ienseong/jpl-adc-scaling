# Author: Rob Donnelly <robert.donnelly@jpl.nasa.gov>
# Created: 2017-01-10

module JFSimJob
  # Provides coverage merging feature.
  class Coverage
    require 'fileutils'

    # Merges coverage databases incrementally into a single coverage database.
    #
    # NOTE: Does not account for NFS delays.  For example, when using LFS the
    # coverage database is written by a remote machine to NFS then read by the
    # local machine.  Synchronization delay may cause the local machine to read
    # stale data.
    #
    # @param instance [Jobrnr::Job::Instance] completed instance to merge from
    # @param output_directory [String] directory to put the merged coverage database
    def merge(instance:, unit:, resdir:, output_directory:)
      job_coverage_db_path = get_coverage_db_path(resdir)
      merged_coverage_db_path = get_merged_coverage_db_path(unit, output_directory)

      coverage_merge_cmd =
        if File.exists?(merged_coverage_db_path)
          "vcover merge -testassociated -outputstore #{merged_coverage_db_path} #{merged_coverage_db_path} #{job_coverage_db_path}"
        else
          "vcover merge -testassociated -outputstore #{merged_coverage_db_path} #{job_coverage_db_path}"
        end

      puts "Running coverage merge: '#{coverage_merge_cmd}'"
      system(coverage_merge_cmd)
    end

    def get_coverage_db_path(resdir)
      File.join(resdir, 'coverstore')
    end

    def get_merged_coverage_db_path(unit, resdir)
      sbox = ENV['SBOX'] + '/'
      unit = unit.gsub(sbox, '').gsub('/', '_')
      coverstore = 'coverstore_%s' % unit
      File.join(resdir, coverstore)
    end
  end
end
