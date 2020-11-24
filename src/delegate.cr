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
  #   The default is to pass on all arguments without modification.
  #   Named arguments are passed on without modification except when
  #   `form: :one_argument` is set (see below).
  #
  # return: This named argument can be:
  #   :unwrap : unwrap the returned value from our value-wrapper struct.
  #   :self :   return `self`.
  #   The default is to return the unmodified value of the delegated method.
  #   (The method to declare keywords like `return` as argument names is
  #   documented under
  #   https://crystal-lang.org/reference/syntax_and_semantics/default_values_named_arguments_splats_tuples_and_overloading.html#external-names )
  #
  # form: This named argument can be:
  #   :one_argument : This is used when delegating the 
  #     operators `==`, `===`, `<=`, `>=`, `<=>`, and `!=`. The compiler
  #     insists that they be declared with only one argument, while the
  #     normal method of delegation declares delegated methods with
  #     (*positional_arguments, **named_arguments) as their argument list
  #     so that all positional and named arguments can be passed on to the
  #     delegate method. When `form: :one_argument` is used, the argument
  #     list of the declared method will take only one argument, and not
  #     pass on any named arguments.
  #
  macro delegate(method, to, wrap = nil, unwrap = nil, return result = nil, form = nil)
    {% begin %}
    {% if form == :one_argument %}
      {% arguments = "arg" %}
    {% else %}
      {% arguments = "*args, **named_args" %}
    {% end %}
    def {{method.id}}({{arguments.id}})
      {% if form == :one_argument %}
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
