#!/usr/bin/env ruby

require 'taglib'

module Liquidsoap
  class Scheduler
    attr_accessor :is_verbose
    attr_accessor :is_running
    attr_accessor :is_podcasting
    attr_accessor :date_prefix
    attr_accessor :podcast_path
    attr_accessor :icecast_host
    attr_accessor :icecast_port
    attr_accessor :icecast_pass
    attr_accessor :icecast_mount

    def initialize _verbose = false
      @is_verbose = _verbose
      @is_running = false
      @is_podcasting = false
      log_verbose "Liquidsoap::Scheduler.initialize ..."
      log_verbose "Liquidsoap::Scheduler.is_verbose ... #{@is_verbose}"
      log_verbose "Liquidsoap::Scheduler.is_running ... #{@is_running}"
      log_verbose "Liquidsoap::Scheduler.is_podcasting ... #{@is_podcasting}"
      @podcast_path = "/tmp"
      log_verbose "Liquidsoap::Scheduler.podcast_path ... #{@podcast_path}"
      @icecast_host = "localhost"
      log_verbose "Liquidsoap::Scheduler.icecast_host ... #{@icecast_host}"
      @icecast_port = "8000"
      log_verbose "Liquidsoap::Scheduler.icecast_port ... #{@icecast_port}"
      @icecast_pass = "hackme"
      log_verbose "Liquidsoap::Scheduler.icecast_pass ... #{@icecast_pass}"
      @icecast_mount = "mount"
      log_verbose "Liquidsoap::Scheduler.icecast_mount ... #{@icecast_mount}"
    end # Liquidsoap::Scheduler.initialize

    def set_podcast_path _path
      log_verbose "Liquidsoap::Scheduler.set_podcast_path ..."
      @podcast_path = _path
      log_verbose "Liquidsoap::Scheduler.podcast_path ... #{@podcast_path}"
    end # Liquidsoap::Scheduler.set_podcast_path

    def configure_icecast _host, _port, _pass, _mount
      log_verbose "Liquidsoap::Scheduler.configure_icecast ..."
      @icecast_host = _host
      log_verbose "Liquidsoap::Scheduler.icecast_host ... #{@icecast_host}"
      @icecast_port = _port
      log_verbose "Liquidsoap::Scheduler.icecast_port ... #{@icecast_port}"
      @icecast_pass = _pass
      log_verbose "Liquidsoap::Scheduler.icecast_pass ... #{@icecast_pass}"
      @icecast_mount = _mount
      log_verbose "Liquidsoap::Scheduler.icecast_mount ... #{@icecast_mount}"
    end # Liquidsoap::Scheduler.configure_icecast

    def run_scheduler
      log_verbose "Liquidsoap::Scheduler.run_scheduler ..."
      @is_running = true
      log_verbose "Liquidsoap::Scheduler.is_running ... #{@is_running}"
      pid = fork do
        begin
          loop do
            update_prefix if @is_running
            check_podcasts if @is_running and not is_podcasting
            sleep 15
          end
        rescue Interrupt => int
          log_verbose "Liquidsoap::Scheduler.Interrupt ... Shutting down. #{int}"
        end
      end
      log_verbose "Liquidsoap::Scheduler.run_scheduler ... forked process #{pid}"
    end # Liquidsoap::Scheduler.run_scheduler

    def update_prefix
      log_verbose "Liquidsoap::Scheduler.update_prefix ..."
      @date_prefix = Time::now.strftime("%Y-%m-%d-%H-%M")
      log_verbose "Liquidsoap::Scheduler.date_prefix ... #{@date_prefix}"
    end # Liquidsoap::Scheduler.update_prefix

    def check_podcasts
      log_verbose "Liquidsoap::Scheduler.check_podcasts ..."
      podcast = find_files "mp3,ogg"
      if not podcast.nil?
        log_verbose "Liquidsoap::Scheduler.check_podcasts ... #{podcast}"
        duration = -999
        TagLib::FileRef.open(podcast) do | ref |
          unless ref.nil?
            props = ref.audio_properties
            duration = props.length
          end
        end
        if duration > 0
          log_verbose "Liquidsoap::Scheduler.check_podcasts ... #{duration} seconds"
          start_podcast podcast, duration
        else
          log_verbose "Liquidsoap::Scheduler.check_podcasts ... invalid duration #{duration}"
        end
      else
        log_verbose "Liquidsoap::Scheduler.check_podcasts ... none found"
      end
    end # Liquidsoap::Scheduler.check_podcasts

    def start_podcast _podcast, _duration
      log_verbose "Liquidsoap::Scheduler.start_podcast ..."
      track_start = Time::now.to_i
      track_end = track_start + _duration.to_i
      liq = "liquidsoap \'output.icecast(%vorbis, host=\"#{@icecast_host}\", port=#{icecast_port}, password=\"#{icecast_pass}\", mount=\"#{icecast_mount}\", mksafe(single(\"#{_podcast}\")))\'"
      pid = Process::spawn liq
      @is_podcasting = true
      while Time.now.to_i < track_end
        _diff = track_end - Time::now.to_i
        log_verbose "Liquidsoap::Scheduler.start_podcast ... running, dies in #{_diff} seconds"
        sleep 1
      end
      Process::kill "HUP", pid
      Process::waitall
      is_podcasting = false
    end # Liquidsoap::Scheduler.start_podcast

    def find_files _types
      log_verbose "Liquidsoap::Scheduler.find_files ... #{_types}"
      result = nil
      _types.split(',').each do |ext|
        Dir["#{@podcast_path}/#{@date_prefix}*.#{ext}"].each do | file |
          log_verbose "Liquidsoap::Scheduler.find_files ... FOUND #{file}"
          result = file
        end
      end
      return result
    end # Liquidsoap::Scheduler.find_files

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
