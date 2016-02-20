#!/usr/bin/env ruby

require './rub/liquidsoap.rb'

if ARGV.first.eql? "-h" or ARGV.first.eql? "--help"
  puts "Liquidsoap Scheduler for internet radio automation."
  puts "\t-v, --verbose\tRun in verbose mode."
  puts "\t-h, --help\tDisplay this help."
else
  verbose = true if ARGV.first.eql? "-v" or ARGV.first.eql? "--verbose"
  s = Liquidsoap::Scheduler.new verbose
  s.set_podcast_path "/tmp/podcasts"
  s.configure_icecast "localhost", "8000", "hackme", "podcast"
  s.run_scheduler if not s.running?
end
