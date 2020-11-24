module RecursiveGeneric::GenericWrapper(T, WrappedGeneric)
  include Enumerable(T)
  include Iterable(T)
  include Delegate(ValueWrapper)
  include ExtractValue
  include Mutate

  @contained = WrappedGeneric.new

  delegate("[]=",   to: @contained, wrap: :key_value)
  delegate("[]",    to: @contained, wrap: :key, return: :unwrap)
  delegate("[]?",   to: @contained, wrap: :key, return: :unwrap)
  delegate clear,   to: @contained, return: :self
  delegate size,    to: @contained # Faster than the one in Enumerable.

  def each
    ValueWrapper::Iterator.new(@contained.each)
  end

  def each(&block)
    i = @contained.each
    while (v = i.next).is_a?(Tuple)
      yield *extract_value(*v)
    end
  end
end
