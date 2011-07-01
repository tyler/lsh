class PQueue
  def initialize(size)
    @size = size
    @items = []
    @priorities = []
  end

  attr_reader :items

  def add(item, priority)
    perform_add(item, priority)# if @items.size < @size || priority > @priorities.last
    self
  end

  def pop
    if @items.size > 0
      [@items.shift, @priorities.shift]
    else
      nil
    end
  end

  private

  def perform_add(item, priority)
    performed = false
    @priorities.each_with_index do |existing_priority, i|
      if existing_priority > priority
        @priorities.insert(i, priority)
        @items.insert(i, item)
        performed = true
        break
      end
    end

    unless performed
      @priorities << priority
      @items << item
    end
    
    @items = @items[0,@size]
    @priorities = @priorities[0,@size]
  end
end
