#!/usr/bin/env ruby

require './rub/liquidsoap.rb'

if ARGV.first.eql? "-h" or ARGV.first.eql? "--help"
  puts "Liquidsoap Scheduler for internet radio automation."
  puts "\t-v, --verbose\tRun in verbose mode."
  puts "\t-h, --help\tDisplay this help."
else
  # handy to pass verbose flag
  verbose = true if ARGV.first.eql? "-v" or ARGV.first.eql? "--verbose"

  # create a new liquidsoap scheduler
  s = Liquidsoap::Scheduler.new verbose

  # set path to podcasts directory which is to be scanned
  s.set_path_prefix "/tmp/podcasts"

  # configure icecast
  s.configure_icecast "localhost", "8000", "hackme", "podcast"

  # run the scheduler (forks in background)
  s.run_scheduler if not s.running?
end
