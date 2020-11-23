require "./recursive_generic"
recursive_generic(MyHash, Hash, {Symbol, String|MyHash|Array(MyHash)})
recursive_generic(MyArray, Array, {String|MyArray|MyHash})

h = MyHash.new
a = MyArray.new
h[:itself] = h
h[:array] = [h]
p h.inspect
p h.size
a.push(h)
p a
