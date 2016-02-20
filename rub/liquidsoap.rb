#!/usr/bin/env ruby

module Liquidsoap

  class Scheduler

    attr_accessor :is_verbose

    attr_accessor :is_running
    attr_accessor :is_streaming
    attr_accessor :is_podcasting

    attr_accessor :date_prefix

    attr_accessor :stream_path
    attr_accessor :podcast_path

    def initialize _verbose = false

      @is_verbose = _verbose
      @is_running = false
      @is_streaming = false
      @is_podcasting = false

      log_verbose "Liquidsoap::Scheduler.initialize ..."
      log_verbose "Liquidsoap::Scheduler.is_verbose ... #{@is_verbose}"
      log_verbose "Liquidsoap::Scheduler.is_running ... #{@is_running}"
      log_verbose "Liquidsoap::Scheduler.is_streaming ... #{@is_streaming}"
      log_verbose "Liquidsoap::Scheduler.is_podcasting ... #{@is_podcasting}"

      @stream_path = "/tmp"
      @podcast_path = "/tmp"

      log_verbose "Liquidsoap::Scheduler.stream_path ... #{@stream_path}"
      log_verbose "Liquidsoap::Scheduler.podcast_path ... #{@podcast_path}"

    end # Liquidsoap::Scheduler.initialize

    def set_stream_path _path

      log_verbose "Liquidsoap::Scheduler.set_stream_path ..."

      @stream_path = _path

      log_verbose "Liquidsoap::Scheduler.stream_path ... #{@stream_path}"

    end # Liquidsoap::Scheduler.set_stream_path

    def set_podcast_path _path

      log_verbose "Liquidsoap::Scheduler.set_podcast_path ..."

      @podcast_path = _path

      log_verbose "Liquidsoap::Scheduler.podcast_path ... #{@podcast_path}"

    end # Liquidsoap::Scheduler.set_podcast_path

    def run_scheduler

      log_verbose "Liquidsoap::Scheduler.run_scheduler ..."

      @is_running = true

      log_verbose "Liquidsoap::Scheduler.is_running ... #{@is_running}"

#      pid = fork do ### @TODO

      begin

        loop do

          update_prefix if @is_running

          check_streams if @is_running and not @is_streaming

          check_podcasts if @is_running and not @is_streaming and not is_podcasting

          sleep 15

        end

      rescue Interrupt => int

        log_verbose "Liquidsoap::Scheduler.Interrupt ... Shutting down. #{int}"

      end
#
#      end
#
#      log_verbose "Liquidsoap::Scheduler.run_scheduler ... forked process #{pid}"

    end # Liquidsoap::Scheduler.run_scheduler

    def update_prefix

      log_verbose "Liquidsoap::Scheduler.update_prefix ..."

      @date_prefix = Time::now.strftime("%Y-%m-%d-%H-%M")

      log_verbose "Liquidsoap::Scheduler.date_prefix ... #{@date_prefix}"

    end # Liquidsoap::Scheduler.update_prefix

    def check_streams

      log_verbose "Liquidsoap::Scheduler.check_streams ..."

      stream_types = "m3u,pls"
      stream_types.split(',').each do |ext|

        puts "#{@stream_path}/#{@date_prefix}*.#{ext}"
        Dir["#{@stream_path}/#{@date_prefix}*.#{ext}"].each do | file |
          puts "#{file} -------------------------------------"
        end

      end

    end # Liquidsoap::Scheduler.check_streams

    def check_podcasts

      log_verbose "Liquidsoap::Scheduler.check_podcasts ..."

    end # Liquidsoap::Scheduler.check_podcasts

    def running?

      log_verbose "Liquidsoap::Scheduler.running? ... #{@is_running}"

      return @is_running

    end # Liquidsoap::Scheduler.running?

    def log_verbose _message

      time_stamp = Time::now.strftime("%Y%m%d.%H%M%S")
      puts "#{time_stamp} #{_message}" if @is_verbose

    end # Liquidsoap::Scheduler.log_verbose

  end # Liquidsoap::Scheduler

end # Liquidsoap
