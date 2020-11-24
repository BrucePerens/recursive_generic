struct RecursiveGeneric::ValueWrapper(ValueType)
  include Delegate(self)
  @value : ValueType

  def initialize(@value)
  end

  def value
    @value
  end

  def value=(n)
    @value = mutate_value(n)
  end

  delegate("==",  to: @value, wrap: :unwrap, one_argument: true)
  delegate("===", to: @value, wrap: :unwrap, one_argument: true)
  delegate("<=",  to: @value, wrap: :unwrap, one_argument: true)
  delegate(">=",  to: @value, wrap: :unwrap, one_argument: true)
  delegate("<=>", to: @value, wrap: :unwrap, one_argument: true)
  delegate("!=",  to: @value, wrap: :unwrap, one_argument: true)
end
