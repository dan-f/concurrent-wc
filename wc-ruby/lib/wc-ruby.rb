#!/usr/bin/env ruby

require 'benchmark'

def list_files(path)
  entries = Dir.entries(path)
  return entries.select { |f| File.file? File.join(path, f) }
end

### base case - no parallelism
def get_results(files, basepath)
  results = {}

  files.each do |f|
    lines = File.readlines File.join(basepath, f)
    results[f] = lines.length
  end

  return results
end

# using Threads (green threads)
def get_results_green_threaded(files, basepath)
  results = {}
  threads = []

  files.each do |f|
    threads << Thread.new do
      lines = File.readlines File.join(basepath, f)
      results[f] = lines.length
    end
  end

  threads.map(&:join)

  return results
end

# using processes (system threads)
def get_results_system_threads(files, basepath)
  results = {}

  files.each do |f|
    fork do
      lines = File.readlines File.join(basepath, f)
      results[f] = lines.length
    end
  end

  Process.waitall

  return results
end

# using fibers
def get_results_system_threads(files, basepath)
  results = {}

  files.each do |f|
    fork do
      lines = File.readlines File.join(basepath, f)
      results[f] = lines.length
    end
  end

  Process.waitall

  return results
end
