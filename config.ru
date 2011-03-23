require 'rubygems'
require './bingo'

log = ::File.new('log/bingo.log', 'a+')
STDERR.reopen(log)
STDOUT.reopen(log)

run Bingo