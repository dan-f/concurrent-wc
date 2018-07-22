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

# using OS processes
def get_results_system_processes(files, basepath)
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

def get_results_threadpool(files, basepath)
  require 'socket'
  results = {}
  sockets = []
  threads = []

  4.times { sockets << create_socket_worker(basepath) }

  socket_pool = Enumerator.new do |y|
    loop do
      y << sockets[0]
      y << sockets[1]
      y << sockets[2]
      y << sockets[3]
    end
  end

  threads << Thread.new {
    files.each do |f|
      socket_pool.take(1).first.send(f, 0)
    end

    socket_pool.take(4).map { |s| s.send("BREAK", 0)}
  }

  threads << Thread.new {
    files.length.times do
      msg = socket_pool.take(1).first.recv(500).force_encoding('UTF-8')
      length, f = msg.split("§")
      results[f] = length
    end
  }

  threads.map(&:join)

  Process.waitall

  return results
end

def create_socket_worker(basepath)
  parent_socket, child_socket = Socket.pair(:UNIX, :DGRAM, 0)

  fork do
    parent_socket.close
    while f = child_socket.recv(500)
      break if f == "BREAK"
      lines = File.readlines File.join(basepath, f)
      child_socket.send(lines.length.to_s + "§" + f, 0)
    end

    child_socket.close
  end

  return parent_socket
end