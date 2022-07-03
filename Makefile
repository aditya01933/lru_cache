build:
	docker build -t lru-cache .

test: build
	docker run --rm lru-cache bundle exec rspec lru_cache_spec.rb

benchmark: build
	ruby benchmark.rb