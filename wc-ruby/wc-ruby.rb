#!/usr/bin/env ruby

require_relative './lib/wc-ruby'

path = ARGV[0]

if path == nil
  puts "You gotsta give me an argument."
  exit(1)
end

files = list_files(path)
results = get_results(files, path)


sorted_results = results.sort_by { |_, v| v }.reverse
sorted_results.each do |r|
  puts "#{r[1].to_s.rjust(10)} #{r[0]}" 
end

total = results.values.reduce(:+)
puts "#{total.to_s.rjust(10)} [TOTAL]"