module M = HashMap.String
let m = M.fromArray([("a", 1), ("b", 2)])

// TODO: failing test
assert(m->M.set("a", 2)->M.size == 2)
