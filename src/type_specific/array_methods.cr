# Methods to add when we are wrapping Array
module RecursiveGeneric::ArrayMethods(WrappedValue)
  def push(o)
    @contained.push(WrappedValue.new(mutate_value(o)))
  end
end
