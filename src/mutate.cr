module RecursiveGeneric::Mutate
  # This No-Operation method is the default for mutate_value and mutate_key
  # It just returns its argument.
  private def nop(value)
    value
  end
end
