struct RecursiveGeneric::ValueWrapper(ValueType)
  @value : ValueType

  def initialize(@value)
  end

  def value
    @value
  end

  def value=(n)
    @value = mutate_value(n)
  end
end
