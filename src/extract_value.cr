module RecursiveGeneric::ExtractValue
  # Make a copy of the *args tuple, except that the last element in the tuple
  # is the wrapped value, so rewrite it as the value extracted from the
  # wrapper.
  def extract_value(*args)
    args.map_with_index do |a, index|
      if index >= args.size - 1
        a.value # Extract the value from the wrapper.
      else
        a # This value is not wrapped, so no change is necessary.
      end
    end
  end
end
