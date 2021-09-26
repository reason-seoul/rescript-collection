// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Js_dict from "@rescript/std/lib/es6/js_dict.js";

function smi(i32) {
  return (i32 >>> 1) & 1073741824 | i32 & -1073741825;
}

var hashInt = smi;

function hashString(s) {
  var h = 0;
  for(var i = 0 ,i_finish = s.length; i < i_finish; ++i){
    h = Math.imul(31, h) + s.charCodeAt(i) | 0;
  }
  return smi(h);
}

var stringHashCache = {
  contents: {}
};

var stringHashCacheCount = {
  contents: 0
};

function cachedHashString(s) {
  var h = Js_dict.get(stringHashCache.contents, s);
  if (h !== undefined) {
    return h;
  }
  var h$1 = hashString(s);
  if (stringHashCacheCount.contents > 255) {
    stringHashCache.contents = {};
    stringHashCacheCount.contents = 0;
  }
  stringHashCache.contents[s] = h$1;
  stringHashCacheCount.contents = stringHashCacheCount.contents + 1 | 0;
  return h$1;
}

export {
  smi ,
  hashInt ,
  hashString ,
  stringHashCache ,
  stringHashCacheCount ,
  cachedHashString ,
  
}
/* No side effect */
