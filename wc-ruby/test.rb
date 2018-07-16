require_relative './lib/wc-ruby.rb'
require 'benchmark'

path = ARGV[0]

if path == nil
  puts "Usage: ruby test.rb [DIRECTORY]"
  exit(1)
end

files = list_files(path)

puts "Base case - #{Benchmark.realtime { get_results(files, path) }}s"
puts "Green threads - #{Benchmark.realtime { get_results_green_threaded(files, path) }}s"
puts "System threads and socket IPC - #{Benchmark.realtime { get_results_system_threads(files, path) }}s"