class RecursiveGeneric::ValueWrapper::Iterator
  include ::Iterator(Value)
  include ExtractValue
  @i : ::Iterator(Value)
  
  def initialize(@i)
    super
  end
  
  def next
    v = @i.next
    if v == Stop::INSTANCE
      stop
    else
      extract_value(*v)
    end
  end
  
  def rewind
    @i.rewind
    self
  end
end
