require 'benchmark'
require_relative 'lru_cache'

Benchmark.bmbm do |bm|
  bm.report 'LRUCache' do
    1000.times do
      cache = LRUCache.new(size: 100)
      200.times do
        cache.write(rand(10000), 1)
        cache.read(rand(10000))
      end
    end
  end
end
