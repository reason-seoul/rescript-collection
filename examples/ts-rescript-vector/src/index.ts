import assert from 'node:assert';
import * as R from 'remeda';
import * as Vector from 'rescript-vector';

const vec = Vector.make<number>();

assert(
  R.pipe(
    vec,
    vec => Vector.push(vec, 1),
    vec => Vector.push(vec, 1),
    vec => Vector.push(vec, 1),
    Vector.length,
  ) === 3,
);
