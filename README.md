# recursive_generic

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

### Arguments:

name: The name of the new self-containing generic class to create.

generic: The name of a generic class that our new one will be based upon.
  This will be `Array`, `Hash`, etc.

datatype: A tuple containing the type of data that will be stored in the
  generic. For an `Array` containing `Int32`, this would be `{ Int32 }`. For
  a `Hash` with `Symbol` typed keys and `String` typed values, this would be
  `{ Symbol, String }`.

mutate_key: The name of a function that mutates the keys or indices
           in the wrapped generic, and the key or index values used
           to query the wrapped generic. It takes the given key or index as
           its argument, and returns the mutated key or index. So, for
           example, this function would make all of the keys strings as
           they are inserted in a hash.
           ```crystal
           def mutate(key)
             key.to_s
           end
           ```

mutate_value: The name of a function that mutates values as they are
           inserted in the generic. It takes the given value as
           its argument, and returns the mutated value. So, for example,
           this function would make all of the values strings as they
           are inserted in a hash:
           ```crystal
           def mutate(key)
             key.to_s
           end
           ```

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     recursive_generic:
       github: your-github-user/recursive_generic
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

## Attribution
- [your-name-here](https://github.com/your-github-user) - creator and maintainer

Copyright Bruce Perens (@BrucePerens, bruce@perens.com)
MIT license. Copyright (C) 2000 Algorithmic LLC. In addition, this may
be a derivative work of the works cited below:

Thanks for lessons from:
* Ary Borenszweig (@asterite) explained the way to implement this
  in https://github.com/crystal-lang/crystal/issues/5155
* Sijawusz Pur Rahnama (@sija) and his `any_hash` shard.
* Johannes Müller (@straight-shoota) and his `crinja` shard.
* The Crystal stdlib implementation of the wrapped types, for the API
  of the various generic classes.
