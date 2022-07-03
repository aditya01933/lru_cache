require_relative 'node'

class LRUCache
  DEFAULT_SIZE = 100

  attr_accessor :head, :tail, :current_size, :size, :result
  
  def initialize(size: DEFAULT_SIZE)
    @current_size = 0
    @size = size
    @lookup_table = {}
  end

  def read(key)
    @result = @lookup_table[key]

    # Not found
    return unless result

    # Result is already at tail.
    unless result_at_tail?
      # Move result to tail.
      move_result_to_tail
    end

    # Return result value.
    result.value
  end

  def write(key, val)
    # If the value to be written is already present in the cache.
    # read the value to refresh it's position in the DLL.
    if @lookup_table[key] && @lookup_table[key].value == val
      return read(key)
    end

    increase_current_size

    # Remove least recently used object if cache is full.
    if current_size > size
      remove_least_recently_used
    end

    # Add new node at tail
    add_new_node(key, val)

    # Return value
    val
  end

  def remove_least_recently_used
    @lookup_table.delete(@lookup_table.key(@head))   

    # shift head
    shift_head_by(@head.next_node)

    decrease_current_size
  end

  private

  def result_at_tail?
    result.next_node.nil?
  end

  def result_at_head?
    result.previous_node.nil?
  end

  def increase_current_size
    @current_size += 1
  end

  def decrease_current_size
    @current_size -= 1
  end

  # First remove result from the DLL.
  # Then add result at tail of the DLL.
  def move_result_to_tail
    remove_result
    
    add_result_at_tail
  end

  # Remove result from Head or Middle.
  def remove_result
    if result_at_head?
      shift_head_by(result.next_node)
    else
      remove_result_from_mid
    end
  end

  # Point next node of current tail to result and make next node of result nil.
  # Point previous node of result to current tail.
  # Set new node as tail.
  def add_result_at_tail
    @tail.next_node = result
    @result.next_node = nil
    @result.previous_node = tail
    @tail = result
  end

  # Point next_node of previous element to the next node of result.
  # Point the previous node of next node to previous node of result.
  def remove_result_from_mid
    @result.previous_node.next_node = result.next_node
    @result.next_node.previous_node = result.previous_node
  end

  def add_new_node(key, val)
    new_node = Node.new(val, @tail, nil)

    # Check if this is the first entry into the DLL.
    if first_element?
      @head = new_node
    else
      @tail.next_node = new_node
    end

    # Put new node on tail.
    @tail = new_node

    # Insert into lookup table.
    @lookup_table[key] = new_node
  end


  def first_element?
    @tail.nil?
  end

  def shift_head_by(next_node)
    @head = next_node
    @head.previous_node = nil 
  end
end
