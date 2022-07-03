class Node
  attr_accessor :value, :previous_node, :next_node 

  def initialize(value, previous_node, next_node)
    @value = value
    @previous_node = previous_node
    @next_node = next_node
  end
end
