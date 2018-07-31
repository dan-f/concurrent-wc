#!/usr/bin/env ruby

require 'time'

require_relative './lib/wc-ruby'

start_time = Time.now

path = ARGV.fetch(0, ".")

files = list_files(path)
results = get_results(files, path)

sorted_results = results.sort_by { |_, v| v }.reverse
sorted_results.each do |r|
  puts "#{r[1].to_s.rjust(10)} #{r[0]}"
end

total = results.values.map(&:to_i).reduce(:+)
puts "#{total.to_s.rjust(10)} [TOTAL]"

end_time = Time.now
elapsed_ms = (end_time - start_time) * 1000

puts "Took #{elapsed_ms.round}ms"
