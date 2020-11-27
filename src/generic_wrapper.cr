module RecursiveGeneric::GenericWrapper(T, WrappedGeneric)
  include Enumerable(T)
  include Iterable(T)
  include Delegate(ValueWrapper)
  include ExtractValue
  include Mutate

  getter contained : WrappedGeneric

  # Creates a new wrapped generic that is *initial_capacity* big.
  # This is useful if you know the size you will need, as it prevents
  # re-allocation and copying as the generic grows.
  def initialize(initial_capacity : Int = 20)
    @contained = WrappedGeneric.new(initial_capacity: initial_capacity)
  end

  # Wrap an existing generic.
  def initialize(@contained)
  end

  # Creates a new wrapped generic, allocating an internal buffer
  # of the generic with the given *capacity*, and passing that
  # buffer to the block. The block must return the desired size
  # of the generic.
  def initialize(initial_capacity : Int, &block : typeof(Pointer(WrappedGeneric).null.value.to_unsafe) -> Int )
    @contained = WrappedGeneric.build { |buffer| yield buffer }
  end

  # Creates a new wrapped generic, allocating an internal buffer
  # of the generic with the given *capacity*, and passing that
  # buffer to the block. The block must return the desired size
  # of the generic.
  def self.build(initial_capacity : Int, &block : typeof(Pointer(WrappedGeneric).null.value.to_unsafe) -> Int ) : self
    self.new(initial_capacity: initial_capacity) { |buffer| yield buffer }
  end

  delegate "[]=",   to: @contained, wrap: :key_value
  delegate "[]",    to: @contained, wrap: :key, return: :unwrap
  delegate "[]?",   to: @contained, wrap: :key, return: :unwrap
  delegate "<=>",   to: @contained, wrap: :unwrap
  delegate "==",    to: @contained, wrap: :unwrap, form: :one_argument
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
