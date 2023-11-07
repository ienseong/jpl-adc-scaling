# Author: Rob Donnelly <robert.donnelly@jpl.nasa.gov>
# Created: 2017-01-09

module JFSimJob
  require 'etc'
  require 'rom-repository'
  require 'rom-sql'

  module Relations
    class Runs < ROM::Relation[:sql]
      schema(:runs) do
        attribute :id, Types::Int
        attribute :finished, Types::DateTime
        attribute :unit, Types::String
        attribute :test, Types::String
        attribute :seed, Types::Int
        attribute :command, Types::String
        attribute :duration, Types::Int
        attribute :fail, Types::Bool
        attribute :state, Types::String
        attribute :user, Types::String
        attribute :tag, Types::String
      end

      def by_id(id)
        where(id: id)
      end
    end
  end

  module Repositories
    class Runs < ROM::Repository[:runs]
      commands :create

      def [](id)
        runs.by_id(id).one!
      end

      def all
        runs.where.to_a
      end
    end
  end

  # Provides database logging feature.
  class Database
    attr_accessor :container
    attr_accessor :runs

    def initialize
      return unless enabled?

      puts "WARNING: Using experimental database logging feature"
      puts "INFO: Using database URI '#{database_uri}'"

      @container = ROM.container(:sql, database_uri) do |config|
        config.register_relation Relations::Runs
      end
      create_tables(@container)
      @runs = Repositories::Runs.new(container)
    end

    # Creates necessary tables if the don't exist.
    #
    # Returns nothing.
    def create_tables(container)
      return unless enabled?

      container.gateways[:default].tap do |gateway|
        # Create the table if it doesn't already exist
        unless gateway.dataset?(:runs)
          migration = gateway.migration do
            change do
              # FIXME: The migration should be inferred from the schema for
              # DRYness.
              create_table :runs do
                primary_key :id
                DateTime :finished, null: false
                String :unit, null: false
                String :test, null: false
                Integer :seed, null: false
                String :command, null: false
                Integer :duration, null: false
                Boolean :fail, null: false
                String :state, null: false
                String :user, null: false
                String :tag, null: true
              end
            end
          end
          migration.apply gateway.connection, :up
        end
      end
    end

    def enabled?
      ['true', '1'].include?(ENV['JOBRNR_DATABASE'])
    end

    def database_uri
      ENV['JOBRNR_DATABASE_URI']
    end

    def tag
      ENV['JOBRNR_DATABASE_TAG']
    end

    def log(instance, unit, test, seed)
      return unless enabled?

      record = {
        finished: DateTime.now,
        unit: unit,
        test: test,
        seed: Integer(seed),
        command: instance.command,
        duration: instance.duration,
        state: %x{sbox-state}.chomp,
        fail: !instance.success?,
        user: Etc.getlogin,
        tag: tag
      }

      runs.create(record)
    end
  end
end
