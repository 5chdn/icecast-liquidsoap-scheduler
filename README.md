# icecast-liquidsoap-scheduler
a ruby module to schedule podcasts and livestream relays to an icecast server utilizing liquidsoap

### requires

- `ruby` > 1.9.3, but `ruby` > 2.3.0 recommended
- `liquidsoap` > 1.2.0
- `icecast` > 2.4.2

rubygems:

    gem install taglib-ruby tee

### usage

see `example.rb`, setup environment

    #!/usr/bin/env ruby

    require 'csv'
    require 'uri'
    require 'taglib'
    require 'tee'
    require './rub/liquidsoap.rb'

handy to pass verbose flag

    verbose = true if ARGV.first.eql? "-v" or ARGV.first.eql? "--verbose"

create a new liquidsoap scheduler

    s = Liquidsoap::Scheduler.new verbose

set path to podcasts directory which is to be scanned

    s.set_podcast_path "/tmp/podcasts"

configure icecast

    s.configure_icecast "localhost", "8000", "hackme", "relay", "podcast"

run the scheduler

    s.run_scheduler if not s.running?

### to do

- add stream relay support

### credits

quick and dirty by 5chdn (schoedon@uni-potsdam.de)

free and open source released under gplv3.
