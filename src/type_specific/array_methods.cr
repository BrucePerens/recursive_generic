# Methods to add when we are wrapping Array
module RecursiveGeneric::GenericWrapper(WrappedValue)
  delegate push, to: @contained, wrap: :value
end
