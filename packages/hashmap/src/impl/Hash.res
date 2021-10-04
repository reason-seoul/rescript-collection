// v8 has an optimization for small integers (smi)
let smi = i32 => {
  lor(i32->lsr(1)->land(0x40000000), i32->land(0xbfffffff))
}

let hashInt = (. n) => smi(n)

// /**
//  * reference:
//  * https://github.com/openjdk/jdk/blob/7700b25460b9898060602396fed7bc590ba242b8/src/java.base/share/classes/java/lang/StringUTF16.java#L414
//  */
// let stringHash = s => {
//   let h = ref(0)
//   for i in 0 to s->Js.String2.length - 1 {
//     h := Js.Math.imul(31, h.contents) + Js.String2.charCodeAt(s, i)->Obj.magic
//   }
//   smi(h.contents)
// }

%%raw(`
let stringHashCache = {}
let stringHashCacheCount = 0;

function stringHash(s) {
  let h = 0;
  for (let i = 0, len = s.length; i < len; ++i){
    h = Math.imul(31, h) + s.charCodeAt(i);
  }
  return hashInt(h);
}
`)

let hashString = %raw(`
function (s) {
  let h = stringHashCache[s];
  if (h !== undefined) {
    return h;
  }

  if (stringHashCacheCount > 255) {
    stringHashCache = {};
    stringHashCacheCount = 0;
  }
  
  h = stringHash(s);
  stringHashCache[s] = h;
  stringHashCacheCount++;

  return h;
}
`)
