# Implementation of a pseudo-generic that contains itself without use of
# recursively-defined aliases, which are problematical and/or broken
# in the compiler.
#
# Bruce Perens (@BrucePerens, bruce@perens.com)
# MIT license. Copyright (C) 2000 Algorithmic LLC. In addition, this may
# be a derivative work of the works cited below:
#
# Thanks for lessons from:
# * Ary Borenszweig (@asterite) explained the way to implement this
#   in https://github.com/crystal-lang/crystal/issues/5155
# * Sijawusz Pur Rahnama (@sija) and his `any_hash` shard.
# * Johannes Müller (@straight-shoota) and his `crinja` shard.
# * The Crystal stdlib implementation of the wrapped types, for the
#   the API, methods, some of the tests.
# 
# Use the `recursive_generic` macro to declare generics which contain
# themselves without use of recursively-defined aliases.
# ```crystal
# recursive_generic(MyHash, Hash, {Symbol, String|MyHash|Array(MyHash)})
# recursive_generic(MyArray, Array, {String|MyArray|MyHash})
# ```

# name: The name of the new generic object.
# datatype: A tuple containint the type of data in the generic.
#
# mutate_key: The name of a function that mutates the keys or indices
#            in the wrapped generic, and the key or index values used
#            to query the wrapped generic. It takes the given key or index as
#            its argument, and returns the mutated key or index. So, for
#            example, this function would make all of the keys strings as
#            they are inserted in a hash.
#            ```crystal
#            def mutate(key)
#              key.to_s
#            end
#            ```
#
# mutate_value: The name of a function that mutates values as they are
#            inserted in the generic. It takes the given value as
#            its argument, and returns the mutated value. So, for example,
#            this function would make all of the values strings as they
#            are inserted in a hash:
#            ```crystal
#            def mutate(key)
#              key.to_s
#            end
#            ```
macro recursive_generic(name, generic, datatype, mutate_key = nop, mutate_value = nop)
  # This is the generic wrapper, it behaves like the wrapped generic, except
  # that it can contain itself.
  class {{name.id}}
    # This is the value wrapper. The generic will contain this type.
    alias ValueWrapper = {{"RecursiveGeneric::ValueWrapper(#{datatype.last.id})".id}}

    # The type arguments to the wrapped generic come from the `datatype`
    # tuple, except that the last type specified is wrapped in our value
    # wrapper.
    {% generic_arguments = ((datatype)[0..-2] + ["ValueWrapper".id]).splat.id %}

    # This brings in the methods of our generic-wrapper class. They
    # are mostly concerned with wrapping values in the value-wrapper before
    # they are put in the wrapped generic, and extracting the values from
    # the wrapper when they are queried from the generic.
    {{ "include RecursiveGeneric::GenericWrapper(#{datatype.id}, #{generic.id}(#{generic_arguments.id}), ValueWrapper)".id }}

    # `RecursiveGeneric:<Type>Methods(ValueWrapper)` contains methods that are
    # specific to a particular wrapped generic. For example, methods
    # for `Hash` are in RecursiveWrapper::HashMethods(ValueWrapper)`.
    {% type_specific_module = "#{generic}Methods(ValueWrapper)".id %}
    {{ "module RecursiveGeneric::#{type_specific_module.id} end".id }}
    {{ "include RecursiveGeneric::#{type_specific_module.id}".id }}

    # This is used to mutate keys (or indices) and values as they are stored
    # in the wrapped generic. They default to no-operation.
    module RecursiveGeneric::Mutate
      private def mutate_key(v) # or index.
        {{mutate_key}}(v)
      end

      private def mutate_value(v)
        {{mutate_value}}(v)
      end
    end
  end
end
