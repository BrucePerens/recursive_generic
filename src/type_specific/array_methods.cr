# Methods to add when we are wrapping Array
module RecursiveGeneric::GenericWrapper(WrappedValue)
  delegate "&",   to: @contained, wrap: :unwrap, return: :new
  delegate "*",  	to: @contained, return: :new
  delegate "+",   to: @contained, wrap: :unwrap, return: :new
  delegate "-",   to: @contained, wrap: :unwrap, return: :new
  delegate "<<",  to: @contained, wrap: :unwrap, return: :self
  delegate clone, to: @contained, return: :new
  delegate compact, to: @contained, return: :new
  delegate concat,to: @contained, wrap: :unwrap, return: :self
  delegate push,  to: @contained, wrap: :value
  delegate pop,   to: @contained, return: :unwrap
end
