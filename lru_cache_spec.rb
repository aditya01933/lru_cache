require_relative 'lru_cache'

# Some code in this spec can be made DRY but skipping it for now to make it simple to follow.
RSpec.describe LRUCache do
  let(:lru_cache) { LRUCache.new(size: 2) }
  let(:device_config) { { memory: "100gb" } }
  let(:uuid_x) { "x" }
  let(:uuid_y) { "y" }
  let(:uuid_z) { "z" }

  it 'default size to 100' do
    expect(LRUCache.new.size).to be 100
  end

  it 'allows setting size param' do
    expect(lru_cache.size).to be 2
  end

  describe '#write' do
    context 'when the cache is not full' do
      context 'with a new element' do
        it 'does not replace an element' do
          expect(lru_cache).not_to receive(:remove_least_recently_used)
          expect(lru_cache.write(uuid_x, device_config)).to eq(device_config)
        end

        it 'stores the value' do
          expect(lru_cache.write(uuid_x, device_config)).to eq(device_config)
          expect(lru_cache.read(uuid_x)).to eq(device_config)
        end
      end

      context 'with an existing element' do
        before(:each) do
          lru_cache.write(uuid_x, device_config)
        end
        
        it 'does not replace an element' do
          expect(lru_cache).not_to receive(:remove_least_recently_used)
          expect(lru_cache.write(uuid_x, device_config)).to eq(device_config)
        end

        it 'stores the value' do
          expect(lru_cache.write(uuid_x, device_config)).to eq(device_config)
          expect(lru_cache.read(uuid_x)).to eq(device_config)
        end
      end
    end

    context 'when the cache is full' do
      before(:each) do
        lru_cache.write(uuid_x, device_config)
        lru_cache.write(uuid_y, device_config)
      end

      context 'with a new element' do
        it 'does replace an element' do
          expect(lru_cache).to receive(:remove_least_recently_used)
          expect(lru_cache.write(uuid_z, device_config)).to eq(device_config)
        end

        it 'stores the value' do
          expect(lru_cache.write(uuid_z, device_config)).to eq(device_config)
          expect(lru_cache.read(uuid_z)).to eq(device_config)
        end

        it 'replaces least recently accessed entry' do
          lru_cache.read(uuid_x)

          expect(lru_cache.write(uuid_z, device_config)).to eq(device_config)
          expect(lru_cache.read(uuid_y)).to eq(nil)
        end
      end

      context 'with an existing element' do
        it 'does not remove any element' do
          expect(lru_cache).not_to receive(:remove_least_recently_used)
          expect(lru_cache.write(uuid_y, device_config)).to eq(device_config)
        end

        it 'stores the value' do
          expect(lru_cache.write(uuid_y, device_config)).to eq(device_config)
          expect(lru_cache.read(uuid_y)).to eq(device_config)
        end

        it 'refreshes the elements position' do
          lru_cache.write(uuid_x, device_config)
          expect(lru_cache.write(uuid_z, device_config)).to eq(device_config)
          expect(lru_cache.read(uuid_y)).to eq(nil)
        end
      end
    end
  end

  describe '#read' do
    context 'when the key does not exist' do
      it 'returns nil' do
        expect(lru_cache.read(uuid_y)).to eq(nil)
      end
    end

    context 'when the key is present' do
      let(:another_device_config) { { memory: "200gb" } }

      before(:each) do
        lru_cache.write(uuid_x, device_config)
        lru_cache.write(uuid_y, device_config)
      end

      it 'returns the correct_value' do
        expect(lru_cache.read(uuid_x)).to eq(device_config)
      end

      it 'refreshes the elements position' do
        lru_cache.write(uuid_x, device_config)
        expect(lru_cache.write(uuid_z, device_config)).to eq(device_config)
        expect(lru_cache.read(uuid_y)).to eq(nil)
      end
    end
  end
end
