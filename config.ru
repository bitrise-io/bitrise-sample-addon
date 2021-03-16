require File.dirname(__FILE__) + '/app'

log = File.new('.tmp/sinatra.log', 'a+')
$stdout.reopen(log)
$stderr.reopen(log)

run App.run!
