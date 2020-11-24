module RecursiveGeneric::GenericWrapper(T, WrappedGeneric, WrappedValue)
  include Enumerable(T)
  include Iterable(T)
  include Delegate(WrappedValue)
  include ExtractValue
  include Mutate

  @contained = WrappedGeneric.new

  delegate("[]=",   to: @contained, wrap: :key_value)
  delegate("[]",    to: @contained, wrap: :key, result: :unwrap)
  delegate("[]?",   to: @contained, wrap: :key, result: :unwrap)
  delegate clear,   to: @contained, result: :self
  delegate size,    to: @contained # Faster than the one in Enumerable.

  def each
    WrappedValue::Iterator.new(@contained.each)
  end

  def each(&block)
    i = @contained.each
    while (v = i.next).is_a?(Tuple)
      yield *extract_value(*v)
    end
  end
end
