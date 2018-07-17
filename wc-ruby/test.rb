require_relative './lib/wc-ruby.rb'
require 'benchmark'

path = ARGV[0]

if path == nil
  puts "Usage: ruby test.rb [DIRECTORY]"
  exit(1)
end

files = list_files(path)

test_cases = [
  Proc.new { puts "Base case - #{Benchmark.realtime { get_results(files, path) }}s" },
  Proc.new { puts "Green threads - #{Benchmark.realtime { get_results_green_threaded(files, path) }}s" },
  Proc.new { puts "System threads and socket IPC - #{Benchmark.realtime { get_results_system_threads(files, path) }}s" },
  Proc.new { puts "Green threads w/ threadpool - #{Benchmark.realtime { get_results_threadpool(files, path) }}s" }
]

puts "Running tests 3 times..."
3.times do
  test_cases.shuffle.map(&:call)
  puts "---"
end
