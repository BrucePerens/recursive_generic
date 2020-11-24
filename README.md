# recursive_generic

WARNING - THIS IS UNDER DEVELOPMENT, NOT READY FOR YOU TO USE.

Implementation of a pseudo-generic that contains itself without use of
recursively-defined aliases, which are problematical and/or broken
in the compiler.

## Usage

`require "recursive_generic"`

Use the `recursive_generic` macro to declare generic classes which contain
themselves without use of recursively-defined aliases. You may then
instantiate them as you would a normal class.
```crystal
recursive_generic(MyHash, Hash, {Symbol, String|MyHash|Array(MyHash)})
h = MyHash.new
h[:itself] = h
```

This works by wrapping the value stored in the generic in a struct
`ValueWrapper` that itself contains the specified types, and wrapping
the generic in a new class which includes `GenericWrapper(...)`, which
handles wrapping and unwrapping of values.

The code presently assumes that the wrapped generic implements the methods of
`Iterable` and `Enumerable` (usually by including them) and that the value
implements the methods of `Comparable`.

### Arguments:

**recursive_generic**(*name*, *generic*, *datatype*, *mutate_key*=no-operation, *mutate_value*=no-operation)

- **name:** The name of the new self-containing generic class to create.

- **generic:** The name of a generic class that our new one will be based upon.
  This will be `Array`, `Hash`, etc.

- **datatype:** A tuple containing the type of data that will be stored in the
  generic. For an `Array` containing `Int32`, this would be `{ Int32 }`. For
  a `Hash` with `Symbol` typed keys and `String` typed values, this would be
  `{ Symbol, String }`.

- **mutate_key:** The name of a function that mutates the keys or indices
  in the wrapped generic, and the key or index values used
  to query the wrapped generic. It takes the given key or index as
  its argument, and returns the mutated key or index. So, for
  example, this function would make all of the keys strings as
  they are inserted in a `Hash`.
  ```crystal
  def mutate(key)
    key.to_s
  end
  ```

- **mutate_value:** The name of a function that mutates values as they are
  inserted in the generic. It takes the given value as
  its argument, and returns the mutated value. So, for example,
  this function would make all of the values strings as they
  are inserted in a generic:
  ```crystal
  def mutate(value)
    value.to_s
  end
  ```

## Writing Delegation for the Wrapped Generic

*If you are wrapping `Array` or `Hash`, containing any type, you won't have
to read this. All of the work below has already been done for you.* 

The generic is wrapped in a new class with a name you specify as the first
argument to `recursive_generic`. This class includes `GenericWrapper(...)`.

For *any* wrapped generic, all of the methods of `Iterable` and `Enumerable`,
and `[]`, `[]?`, `[]=`, `clear`, `each`, and `size` are implemented for you.
You will have to write delegation of additional methods of the wrapped generic
*which you intend to use*. An extended `delegate` method is provided to make
this trivial: you will mostly just have to invoke `delegate` for each method,
rather the writing a method body.

Most delegated methods will involve wrapping values in `ValueWrapper`
or unwrapping the returned value. Thus, there is an extended `delegate`
method which you can access by including `RecursiveWrapper::Delegate`.

```crystal
macro delegate(method, to, wrap = nil, return = nil, form = nil)
```

Delegate *method* to the object passed to *to*, with options as described
below.

### Examples

You won't have to write *these* specific examples, as they are already
implemented for you in this shard. They are here to instruct you in how
to support wrapping generics that aren't already supported in this shard.

The user has used `recursive_generic` to create `MyRecursiveArray`, wrapping
the `Array` generic type. The wrapped generic is always assigned to
`@contained`. The code below re-opens the `MyRecursiveArray` class,
and adds a delegate for `Array#push`, wrapping the value in
`ValueWrapper` and then passing it to the wrapped `Array`; and
a delegate for `Array#pop`, unwrapping the returned value.
```crystal
class MyRecursiveArray
  delegate push, to: @contained, wrap: :value
  delegate pop,  to: @contained, return: :unwrap
end
```

This actually generates this code for the user:
```crystal
class MyRecursiveArray
  def push(*arguments, **named_arguments)
    @contained.push(ValueWrapper.new(arguments[0]), **named_arguments)
  end

  def pop(*arguments, **named_arguments)
    @contained.pop(*arguments, **named_arguments).value
  end
end
```

So, we can see from this example that wrapping a value means creating a new
`ValueWrapper` to contain it, and extracting the wrapped value means
calling `ValueWrapper#value`. The extended `delegate` method provides
a way to write this quickly, consistently, and readably.

### Arguments

**delegate**(*method*, *to*, *wrap*=nil, *return*=nil, *form*=nil)

- **method:** The name of the method to be delegated. Quotes are usually
  not required, but can be used for method names that would not parse
  otherwise, like `[]=`.

- **to:** The object that the method will be delegated to.

- **wrap:** This named argument can be:

  - **:key** or **:index** : wrap one positional (not named) argument in mutate_key().

  - **:value** : wrap one positional argument in `ValueWrapper`.

  - **:key_value** : wrap two positional arguments. The first is wrapped in
    `#mutate_key()`, the second in `ValueWrapper`.

  - **:uwrap** : unwrap the first positional argument from our value-wrapper
    struct, by passing it as `argument.value`.

  The default is to pass on all arguments without modification.
  Named arguments are passed on without modification except when
  `form: :one_argument` is set (see below).

- **return:** This named argument can be:

  - **:unwrap** : unwrap the returned value from our value-wrapper struct.

  - **:self** :   return `self`.

  The default is to return the unmodified value of the delegated method.

  (The method to declare keywords like `return` as argument names is
  documented under
  <https://crystal-lang.org/reference/syntax_and_semantics/default_values_named_arguments_splats_tuples_and_overloading.html#external-names> )

- **form:** This named argument can be:

  - **:one_argument** : This is used when delegating the 
    operators `==`, `===`, `<=`, `>=`, `<=>`, and `!=`. The compiler
    insists that they be declared with only one argument, while the
    normal method of delegation declares delegated methods as
    `delegated_method(*positional_arguments, **named_arguments)`
    so that all positional and named arguments can be passed on to the
    delegate method. When `form: :one_argument` is used, the argument
    list of the delegated method will take only one argument, and not
    pass on any named arguments.

    The default is that all arguments are passed on to the delegate method.

### Delegating methods with blocks.

Alas, the extended `delegate` method doesn't work for methods that expect
to be passed a block. Thus, you must write those methods. Continuing the
example above, this implements `Array#sort` and `Array#map` for
`MyRecursiveArray`, returning a new `MyRecursiveArray` instance containing
the sorted or mapped class.

We will have to wrap newly-created generics in our new class.
We don't have to do anything about the fact that `Array#sort` is sorting
`ValueWrapper` values rather than the types wrapped by `ValueWrapper`,
since `ValueWrapper` already has a delegate for the `<=>` method
used by `Array#sort`. But we *do* have to unwrap and wrap the data for
`Array#map`.

```crystal
class MyRecursiveArray
  def sort
    self.class.new(@contained.sort { |a, b| yield a, b })
  end

  def sort! # In-place, so don't create new object.
    @contained.sort! { |a, b| yield a, b }
  end

  def map
    self.class.new(@contained.map do |data|
      ValueWrapper.new(yield data.value)
    end)
  end
end
```

`self.class.new` is used to remind us that we are creating another instance
of the current object, and code written that way will continue to work even
if you change
the name of `MyRecursiveArray`.

In the `map` method above, we are unwrapping
the wrapped data using `data.value`. The data is then passed
to the block. Then we wrap the block's result in `ValueWrapper.new()`.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     recursive_generic:
       github: BrucePerens/recursive_generic
   ```

2. Run `shards install`

## Usage

```crystal
require "recursive_generic"
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/recursive_generic/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Bruce Perens](<bruce@perens.com>, @BrucePerens, <https://github.com/BrucePerens>) - creator and maintainer.

MIT license. Copyright (C) 2000 Algorithmic LLC. In addition, this may
be a derivative work of the works cited below:

Thanks for lessons from:
* Ary Borenszweig (@asterite) explained the way to implement this
  in https://github.com/crystal-lang/crystal/issues/5155
* Sijawusz Pur Rahnama (@sija) and his `any_hash` shard.
* Johannes Müller (@straight-shoota) and his `crinja` shard.
* The Crystal stdlib implementation of the wrapped types, for the API
  of the various generic classes.

