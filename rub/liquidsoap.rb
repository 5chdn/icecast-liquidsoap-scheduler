#!/usr/bin/env ruby

module Liquidsoap

  class Scheduler

    attr_accessor :is_verbose
    attr_accessor :is_running
    attr_accessor :is_streaming
    attr_accessor :is_podcasting
    attr_accessor :date_prefix

    def initialize _verbose = false

      @is_verbose = _verbose
      @is_running = false
      @is_streaming = false
      @is_podcasting = false

      log_verbose "Liquidsoap::Scheduler.initialize ..."
      log_verbose "Liquidsoap::Scheduler.is_verbose ... #{@is_verbose}"

      run_scheduler

    end # Liquidsoap::Scheduler.initialize

    def run_scheduler

      log_verbose "Liquidsoap::Scheduler.run_scheduler ..."

      @is_running = true

      log_verbose "Liquidsoap::Scheduler.is_running ... #{@is_running}"

      pid = fork do

        begin

          loop do

            update_prefix

            sleep 15

          end

        rescue Interrupt => i

          puts "Interrupt #{i}"

        end

      end

      log_verbose "Liquidsoap::Scheduler.run_scheduler ... forked process #{pid}"

    end # Liquidsoap::Scheduler.run_scheduler

    def update_prefix

      log_verbose "Liquidsoap::Scheduler.update_prefix ..."

      @date_prefix = Time::now.strftime("%Y-%m-%d-%H-%M")

      log_verbose "Liquidsoap::Scheduler.date_prefix ... #{@date_prefix}"

    end # Liquidsoap::Scheduler.update_prefix

    def log_verbose _message

      time_stamp = Time::now.strftime("%Y%m%d.%H%M%S")
      puts "#{time_stamp} #{_message}" if @is_verbose

    end # Liquidsoap::Scheduler.log_verbose

  end # Liquidsoap::Scheduler

end # Liquidsoap::
