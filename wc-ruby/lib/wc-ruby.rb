#!/usr/bin/env ruby

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
  mu = Mutex.new

  files.each do |f|
    threads << Thread.new do
      lines = File.readlines File.join(basepath, f)
      mu.synchronize do
        results[f] = lines.length
      end
    end
  end

  threads.map(&:join)

  return results
end

# using processes (system threads)
def get_results_system_threads(files, basepath)
  results = {}

  reader, writer = IO.pipe

  files.each do |f|
    fork do
      reader.close # we aren't using the reader pipe inside the forked process

      lines = File.readlines File.join(basepath, f)
      writer.puts lines.length.to_s + "§" + f
    end
  end

  writer.close
  while msg = reader.gets
    length, f = msg.split("§")
    results[f] = length
  end

  Process.waitall

  return results
end
