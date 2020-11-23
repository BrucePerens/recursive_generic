module RecursiveGeneric::GenericWrapper(T, WrappedGeneric, WrappedValue)
  include Enumerable(T)
  include Iterable(T)
  include Delegate
  include ExtractValue
  include Mutate

  @contained = WrappedGeneric.new

  def []=(key, value)
    @contained[mutate_key(key)] = WrappedValue.new(mutate_value(value))
  end

  def [](key)
    v = @contained[mutate_key(key)]
  end

  def []?(key)
    @contained[mutate_key(key)]?
  end

  # Delegate the `clear` method to the wrapped generic, but return self
  # instead of the wrapped generic.
  delegate_but_return_self clear, to: @contained

  def each
    WrappedValue::Iterator.new(@contained.each)
  end

  def each(&block)
    i = @contained.each
    while (v = i.next).is_a?(Tuple)
      yield *extract_value(*v)
    end
  end

  # Override the version of `size` in Enumerable, the one in the underlying
  # generic is faster.
  delegate size, to: @contained
end
