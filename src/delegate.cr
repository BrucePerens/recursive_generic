module RecursiveGeneric::Delegate(ValueWrapper)
  # Delegate a method. This has additional options over the normal version
  # of `delegate`. It doesn't work with blocks.
  #
  # wrap: This named argument can be:
  #   :key or :index : wrap one positional (not named) argument in mutate_key().
  #   :value : wrap one positional argument in our value-wrapper struct.
  #   :key_value : wrap two positional arguments. The first is wrapped in
  #     mutate_key(), the second in our value-wrapper struct.
  #   :uwrap : unwrap the first positional argument from our value-wrapper
  #     struct, by passing it as `argument.value`.
  #
  #   The default is to pass on all arguments unmodified.
  #   Named arguments are passed on unmodified.
  #

  #
  # result: This named argument can be:
  #   :unwrap : unwrap the returned value from our value-wrapper struct.
  #   :self :   return `self`.
  #
  #   The default is to return the unmodified value of the delegated method.
  #
  macro delegate(method, to, wrap = false, unwrap = false, result = false, one_argument = false)
    {% begin %}
    {% if one_argument %}
      {% arguments = "arg" %}
    {% else %}
      {% arguments = "*args, **named_args" %}
    {% end %}
    def {{method.id}}({{arguments.id}})
      {% if one_argument %}
        args = { arg }
      {% end %}
      {% if wrap == :key || wrap == :index %}
        value = {{to.id}}.{{method.id}}(mutate_key(args[0]), **named_args)
      {% elsif wrap == :value %}
        value = {{to.id}}.{{method.id}}(ValueWrapper.new(args[0]), **named_args)
      {% elsif wrap == :key_value %}
        value = {{to.id}}.{{method.id}}(mutate_key(args[0]), ValueWrapper.new(args[1]), **named_args)
      {% elsif wrap == :unwrap %}
        value = {{to.id}}.{{method.id}}(args[0].value, **named_args)
      {% else %}
        value = {{to.id}}.{{method.id}}(*args, **named_args)
      {% end %}

      {% if result == :unwrap %}
        value.value
      {% elsif result == :self %}
        self
      {% else %}
        value
      {% end %}
    end
    {% end %}
  end
end
