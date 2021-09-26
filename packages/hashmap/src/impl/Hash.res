// v8 has an optimization for small integers (smi)
let smi = i32 => {
  lor(i32->lsr(1)->land(0x40000000), i32->land(0xbfffffff))
}

let hashInt = n => smi(n)

/**
 * reference:
 * https://github.com/openjdk/jdk/blob/7700b25460b9898060602396fed7bc590ba242b8/src/java.base/share/classes/java/lang/StringUTF16.java#L414
 */
let hashString = s => {
  let h = ref(0)
  for i in 0 to s->Js.String2.length - 1 {
    h := Js.Math.imul(31, h.contents) + Js.String2.charCodeAt(s, i)->Obj.magic
  }
  smi(h.contents)
}

let stringHashCache: ref<Js.Dict.t<int>> = ref(Js.Dict.empty())
let stringHashCacheCount = ref(0)

let cachedHashString = s => {
  switch Js.Dict.get(stringHashCache.contents, s) {
  | Some(h) => h
  | None =>
    // add to cache
    let h = hashString(s)
    if stringHashCacheCount.contents > 255 {
      stringHashCache := Js.Dict.empty()
      stringHashCacheCount := 0
    }
    Js.Dict.set(stringHashCache.contents, s, h)
    stringHashCacheCount := stringHashCacheCount.contents + 1
    h
  }
}
