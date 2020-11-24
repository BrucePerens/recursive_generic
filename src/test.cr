require "./recursive_generic"
recursive_generic(MyHash, Hash, {Symbol, String|MyHash|Array(MyHash)})

h = MyHash.new
