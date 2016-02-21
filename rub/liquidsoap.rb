#!/usr/bin/env ruby

require 'taglib' # gem install taglib-ruby
require 'tee'    # gem install tee

module Liquidsoap
  class Scheduler
    attr_accessor :is_verbose
    attr_accessor :is_running
    attr_accessor :is_streaming
    attr_accessor :date_prefix
    attr_accessor :path_prefix
    attr_accessor :icecast_host
    attr_accessor :icecast_port
    attr_accessor :icecast_pass
    attr_accessor :icecast_mount

    def initialize _verbose = false
      @is_verbose = _verbose
      @is_running = false
      @is_streaming = false
      log_verbose "Liquidsoap::Scheduler.initialize ..."
      log_verbose "Liquidsoap::Scheduler.is_verbose ... #{@is_verbose}"
      log_verbose "Liquidsoap::Scheduler.is_running ... #{@is_running}"
      log_verbose "Liquidsoap::Scheduler.is_streaming ... #{@is_streaming}"
      @path_prefix = "/tmp"
      log_verbose "Liquidsoap::Scheduler.path_prefix ... #{@path_prefix}"
      @icecast_host = "localhost"
      log_verbose "Liquidsoap::Scheduler.icecast_host ... #{@icecast_host}"
      @icecast_port = "8000"
      log_verbose "Liquidsoap::Scheduler.icecast_port ... #{@icecast_port}"
      @icecast_pass = "hackme"
      @icecast_mount = "mount"
      log_verbose "Liquidsoap::Scheduler.icecast_mount ... #{@icecast_mount}"
    end # Liquidsoap::Scheduler.initialize

    def set_path_prefix _path
      log_verbose "Liquidsoap::Scheduler.set_path_prefix ..."
      @path_prefix = _path
      log_verbose "Liquidsoap::Scheduler.path_prefix ... #{@path_prefix}"
    end # Liquidsoap::Scheduler.set_path_prefix

    def configure_icecast _host, _port, _pass, _mount
      log_verbose "Liquidsoap::Scheduler.configure_icecast ..."
      @icecast_host = _host
      log_verbose "Liquidsoap::Scheduler.icecast_host ... #{@icecast_host}"
      @icecast_port = _port
      log_verbose "Liquidsoap::Scheduler.icecast_port ... #{@icecast_port}"
      @icecast_pass = _pass
      @icecast_mount = _mount
      log_verbose "Liquidsoap::Scheduler.icecast_mount ... #{@icecast_mount}"
    end # Liquidsoap::Scheduler.configure_icecast

    def run_scheduler
      log_verbose "Liquidsoap::Scheduler.run_scheduler ..."
      @is_running = true
      log_verbose "Liquidsoap::Scheduler.is_running ... #{@is_running}"
      #pid = fork do
      begin
        loop do
          update_prefix if @is_running
          check_for_streams if @is_running and not @is_streaming
          offset = Time::now.strftime("%S").to_i
          sleep 60 - offset
        end
      rescue Interrupt => int
        log_verbose "Liquidsoap::Scheduler.Interrupt ... Shutting down. #{int}"
      end
      #end
      #log_verbose "Liquidsoap::Scheduler.run_scheduler ... forked process #{pid}"
    end # Liquidsoap::Scheduler.run_scheduler

    def update_prefix
      log_verbose "Liquidsoap::Scheduler.update_prefix ..."
      @date_prefix = Time::now.strftime("%Y-%m-%d-%H-%M")
      log_verbose "Liquidsoap::Scheduler.date_prefix ... #{@date_prefix}"
    end # Liquidsoap::Scheduler.update_prefix

    def check_for_streams
      log_verbose "Liquidsoap::Scheduler.check_for_streams ..."
      relay = find_files "txt,csv"
      podcast = find_files "mp3,ogg"
      if not relay.nil?
        log_verbose "Liquidsoap::Scheduler.check_for_streams ... #{relay}"
        duration = -999
        session = nil
        ### @TODO parse relay info from file
        start_relay relay, duration, session
      elsif not podcast.nil?
        log_verbose "Liquidsoap::Scheduler.check_for_streams ... #{podcast}"
        duration = -999
        session = nil
        TagLib::FileRef.open(podcast) do | ref |
          unless ref.nil?
            tag = ref.tag
            session = tag.artist
            session += " - "
            session += tag.title
            props = ref.audio_properties
            duration = props.length - 1
          end
        end
        if duration > 0
          log_verbose "Liquidsoap::Scheduler.check_for_streams ... #{duration} seconds"
          start_podcast podcast, duration, session
        else
          log_verbose "Liquidsoap::Scheduler.check_for_streams ... invalid duration #{duration}"
        end
      else
        log_verbose "Liquidsoap::Scheduler.check_for_streams ... none found"
      end
    end # Liquidsoap::Scheduler.check_for_streams

    def start_podcast _podcast, _duration, _session
      log_verbose "Liquidsoap::Scheduler.start_podcast ..."
      podcast_start = Time::now.to_i
      podcast_end = podcast_start + _duration.to_i
      liq = "liquidsoap \'output.icecast(%vorbis, host=\"#{@icecast_host}\", port=#{icecast_port}, password=\"#{icecast_pass}\", mount=\"#{icecast_mount}\", name=\"#{_session}\", mksafe(single(\"#{_podcast}\")))\'"
      pid = Process::spawn liq # don't try this as root
      @is_streaming = true
      log_verbose "Liquidsoap::Scheduler.start_podcast ... liquidsoap process #{pid}"
      while Time.now.to_i < podcast_end
        _diff = podcast_end - Time::now.to_i
        log_verbose "Liquidsoap::Scheduler.start_podcast ... running, dies in #{_diff} seconds" if (_diff % 10).zero?
        sleep 1
      end
      Process::kill "TERM", pid
      Process::waitall
      @is_streaming = false
    end # Liquidsoap::Scheduler.start_podcast

    def start_relay _relay, _duration, _session
      log_verbose "Liquidsoap::Scheduler.start_relay ..."
      relay_start = Time::now.to_i
      relay_end = relay_start + _duration.to_i
      liq = "liquidsoap" ### @TODO start liquidsoap relay
    end # Liquidsoap::Scheduler.start_relay

    def find_files _types
      log_verbose "Liquidsoap::Scheduler.find_files ... #{_types}"
      result = nil
      _types.split(',').each do |ext|
        Dir["#{@path_prefix}/#{@date_prefix}*.#{ext}"].each do | file |
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

    def streaming?
      log_verbose "Liquidsoap::Scheduler.streaming? ... #{@is_streaming}"
      return @is_streaming
    end # Liquidsoap::Scheduler.streaming?

    def log_verbose _message
      time_stamp = Time::now.strftime("%Y/%m/%d %H:%M:%S")
      Tee::open('liquidsoap.log', mode: 'a') do |t|
        t.puts "#{time_stamp} #{_message}" if @is_verbose
      end
    end # Liquidsoap::Scheduler.log_verbose
  end # Liquidsoap::Scheduler
end # Liquidsoap
