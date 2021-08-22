// Generated by ReScript, PLEASE EDIT WITH CARE


function slice(ar, offset, len) {
  return ar.slice(offset, offset + len | 0);
}

function blit(src, srcOffset, dst, dstOffset, len) {
  for(var i = 0; i < len; ++i){
    dst[dstOffset + i | 0] = src[srcOffset + i | 0];
  }
  
}

function cloneAndSet(ar, i, a) {
  var newAr = ar.slice();
  newAr[i] = a;
  return newAr;
}

function cloneWithout(ar, i) {
  var newAr = Array(ar.length - 1 | 0);
  blit(ar, 0, newAr, 0, i);
  blit(ar, i + 1 | 0, newAr, i, (ar.length - 1 | 0) - i | 0);
  return newAr;
}

export {
  slice ,
  blit ,
  cloneAndSet ,
  cloneWithout ,
  
}
/* No side effect */