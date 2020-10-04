let isEmpty = xs => Belt.Array.length(xs) === 0;

let lastUnsafe = ar => Belt.Array.getUnsafe(ar, Belt.Array.length(ar) - 1);

let last = ar => isEmpty(ar) ? None : Some(lastUnsafe(ar));
