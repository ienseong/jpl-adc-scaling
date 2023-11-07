# Author: Rob Donnelly <robert.donnelly@jpl.nasa.gov>
# Created: 2021-04-15

module JFSimJob
  class LoadBalance
    attr_reader :hosts
    attr_reader :jobs_by_host

    attr_reader :initialized

    JOBRNR_HOSTS = "JOBRNR_HOSTS"

    def initialize
      @intialized = false
    end

    PoolEntry = Struct.new(:host, :active_jobs)

    def init(options)
      check_env

      @hosts = ENV[JOBRNR_HOSTS].split(/\s/)
      @jobs_by_host = {}
      hosts.each do |host|
        jobs_by_host[host] = 0
      end
      @initialized = true
    end

    def next_host
      min = jobs_by_host.values.min

      jobs_by_host
        .filter { |k, v| v == min }
        .map { |k, v| k }
        .shuffle
        .first
    end

    def pre_instance(message)
      instance = message.instance

      if host = parse_host_option(instance.command)
        if host == "auto"
          init(message.options) unless initialized

          host = next_host
          jobs_by_host[host] += 1

          if parse_host_option(instance.command)
            update_host_option(instance, host)
          end
        end
      end
    end

    def post_instance(message)
      instance = message.instance

      if host = parse_host_option(instance.command)
        jobs_by_host[host] -= 1
      end
    end

    def parse_host_option(command)
      if md = command.match(/\s--host\s+(\S+)\b/)
        md.captures.first
      else
        false
      end
    end

    def update_host_option(instance, host)
      instance.command.gsub!(/\s--host\s+auto\b/, " --host #{host}")
    end

    def check_env
      if !ENV.member?(JOBRNR_HOSTS)
        raise Jobrnr::Error,
          "The JOBRNR_HOSTS environment variable is not defined. " \
          "JOBRNR_HOSTS must be a space separated list of hosts."
      end

      if ENV[JOBRNR_HOSTS].empty?
        raise Jobrnr::Error,
          "The JOBRNR_HOSTS environment variable empty. " \
          "JOBRNR_HOSTS must be a space separated list of hosts."
      end
    end
  end
end
