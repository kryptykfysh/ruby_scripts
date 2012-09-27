# sync_async_test.rb

require 'eventmachine' # for async
require 'memcached'    # for sync
require 'benchmark'

DEBUG = false
TEST_SIZE = 100_000

def debug msg
  if DEBUG
    $stderr.puts msg
  end
end

def async
  EM.run do
    cache = EventMachine::Protocols::Memcache.connect 'localhost', 11211
    debug "sending SET requests..."
    (1..TEST_SIZE).each do |n|
      cache.set "key#{n}", "value#{n}" do
        debug "  SET key#{n} complete"
      end
    end
    debug "SET requests sent"
    debug "sending GET requests..."
    (1..TEST_SIZE).each do |n|
      cache.get "key#{n}" do |value|
        debug "  GET key#{n} = #{value} complete"
      end
    end
    debug "GET requests sent"
    debug "sending DEL requests..."
    (1..TEST_SIZE).each do |n|
      cache.del("key#{n}") do
        debug "  DEL key#{n} complete"
        if n == TEST_SIZE
          EM.stop
        end
      end
    end
    debug "DEL requests sent"
  end
end

def sync
  cache = Memcached.new("localhost:11211")
  debug "sending SET requests..."
  (1..TEST_SIZE).each do |n|
    cache.set "key#{n}", "value#{n}"
    debug "  SET key#{n} complete"
  end
  debug "SET requests sent"
  debug "sending GET requests..."
  (1..TEST_SIZE).each do |n|
    value = cache.get "key#{n}"
    debug "  GET key#{n} = #{value} complete"
  end
  debug "GET requests sent"
  debug "sending DEL requests..."
  (1..TEST_SIZE).each do |n|
    cache.delete("key#{n}")
    debug "  DEL key#{n} complete"
  end
  debug "DEL requests sent"
end

puts Benchmark.measure { puts "sync:";  sync  }
puts Benchmark.measure { puts "async:"; async }