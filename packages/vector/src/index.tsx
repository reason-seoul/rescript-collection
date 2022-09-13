/* TypeScript file generated from index.res by genType. */
/* eslint-disable import/first */


// @ts-ignore: Implicit any on import
import * as Curry__Es6Import from '@rescript/std/lib/es6/curry.js';
const Curry: any = Curry__Es6Import;

// @ts-ignore: Implicit any on import
import * as indexBS__Es6Import from './index.mjs';
const indexBS: any = indexBS__Es6Import;

import type {t as Vector_t} from './Vector';

// tslint:disable-next-line:interface-over-type-literal
export type t<a> = Vector_t<a>;

export const make: <a>() => t<a> = indexBS.make;

export const makeByU: <a>(_1:number, _2:((_1:number) => a)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.makeByU, Arg1, Arg2);
  return result
};

export const makeBy: <a>(_1:number, _2:((_1:number) => a)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.makeBy, Arg1, Arg2);
  return result
};

export const length: <a>(_1:t<a>) => number = indexBS.length;

export const size: <a>(_1:t<a>) => number = indexBS.size;

export const push: <a>(_1:t<a>, _2:a) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.push, Arg1, Arg2);
  return result
};

export const pop: <a>(_1:t<a>) => t<a> = indexBS.pop;

export const get: <a>(_1:t<a>, _2:number) => (null | undefined | a) = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.get, Arg1, Arg2);
  return result
};

export const getExn: <a>(_1:t<a>, _2:number) => a = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.getExn, Arg1, Arg2);
  return result
};

export const getUnsafe: <a>(_1:t<a>, _2:number) => a = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.getUnsafe, Arg1, Arg2);
  return result
};

export const getByU: <a>(_1:t<a>, _2:((_1:a) => boolean)) => (null | undefined | a) = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.getByU, Arg1, Arg2);
  return result
};

export const getBy: <a>(_1:t<a>, _2:((_1:a) => boolean)) => (null | undefined | a) = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.getBy, Arg1, Arg2);
  return result
};

export const getIndexByU: <a>(_1:t<a>, _2:((_1:a) => boolean)) => (null | undefined | number) = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.getIndexByU, Arg1, Arg2);
  return result
};

export const getIndexBy: <a>(_1:t<a>, _2:((_1:a) => boolean)) => (null | undefined | number) = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.getIndexBy, Arg1, Arg2);
  return result
};

export const set: <a>(_1:t<a>, _2:number, _3:a) => (null | undefined | t<a>) = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.set, Arg1, Arg2, Arg3);
  return result
};

export const setExn: <a>(_1:t<a>, _2:number, _3:a) => t<a> = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.setExn, Arg1, Arg2, Arg3);
  return result
};

export const setUnsafe: <a>(_1:t<a>, _2:number, _3:a) => t<a> = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.setUnsafe, Arg1, Arg2, Arg3);
  return result
};

export const reduceU: <a,b>(_1:t<a>, _2:b, _3:((_1:b, _2:a) => b)) => b = function <a,b>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.reduceU, Arg1, Arg2, Arg3);
  return result
};

export const reduce: <a,b>(_1:t<a>, _2:b, _3:((_1:b, _2:a) => b)) => b = function <a,b>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.reduce, Arg1, Arg2, Arg3);
  return result
};

export const reduceWithIndexU: <a,b>(_1:t<a>, _2:b, _3:((_1:b, _2:a, _3:number) => b)) => b = function <a,b>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.reduceWithIndexU, Arg1, Arg2, Arg3);
  return result
};

export const reduceWithIndex: <a,b>(_1:t<a>, _2:b, _3:((_1:b, _2:a, _3:number) => b)) => b = function <a,b>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.reduceWithIndex, Arg1, Arg2, Arg3);
  return result
};

export const mapU: <a,b>(_1:t<a>, _2:((_1:a) => b)) => t<b> = function <a,b>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.mapU, Arg1, Arg2);
  return result
};

export const map: <a,b>(_1:t<a>, _2:((_1:a) => b)) => t<b> = function <a,b>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.map, Arg1, Arg2);
  return result
};

export const mapWithIndex: <a,b>(_1:t<a>, _2:((_1:a, _2:number) => b)) => t<b> = function <a,b>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.mapWithIndex, Arg1, Arg2);
  return result
};

export const keepU: <a>(_1:t<a>, _2:((_1:a) => boolean)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.keepU, Arg1, Arg2);
  return result
};

export const keep: <a>(_1:t<a>, _2:((_1:a) => boolean)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.keep, Arg1, Arg2);
  return result
};

export const keepMapU: <a,b>(_1:t<a>, _2:((_1:a) => (null | undefined | b))) => t<b> = function <a,b>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.keepMapU, Arg1, function (Arg11: any) {
      const result1 = Arg2(Arg11);
      return (result1 == null ? undefined : result1)
    });
  return result
};

export const keepMap: <a,b>(_1:t<a>, _2:((_1:a) => (null | undefined | b))) => t<b> = function <a,b>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.keepMap, Arg1, function (Arg11: any) {
      const result1 = Arg2(Arg11);
      return (result1 == null ? undefined : result1)
    });
  return result
};

export const keepWithIndexU: <a>(_1:t<a>, _2:((_1:a, _2:number) => boolean)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.keepWithIndexU, Arg1, Arg2);
  return result
};

export const keepWithIndex: <a>(_1:t<a>, _2:((_1:a, _2:number) => boolean)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.keepWithIndex, Arg1, Arg2);
  return result
};

export const forEachU: <a>(_1:t<a>, _2:((_1:a) => void)) => void = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.forEachU, Arg1, Arg2);
  return result
};

export const forEach: <a>(_1:t<a>, _2:((_1:a) => void)) => void = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.forEach, Arg1, Arg2);
  return result
};

export const forEachWithIndexU: <a>(_1:t<a>, _2:((_1:a, _2:number) => void)) => void = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.forEachWithIndexU, Arg1, Arg2);
  return result
};

export const forEachWithIndex: <a>(_1:t<a>, _2:((_1:a, _2:number) => void)) => void = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.forEachWithIndex, Arg1, Arg2);
  return result
};

export const someU: <a>(_1:t<a>, _2:((_1:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.someU, Arg1, Arg2);
  return result
};

export const some: <a>(_1:t<a>, _2:((_1:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.some, Arg1, Arg2);
  return result
};

export const some2U: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.some2U, Arg1, Arg2, Arg3);
  return result
};

export const some2: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.some2, Arg1, Arg2, Arg3);
  return result
};

export const everyU: <a>(_1:t<a>, _2:((_1:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.everyU, Arg1, Arg2);
  return result
};

export const every: <a>(_1:t<a>, _2:((_1:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.every, Arg1, Arg2);
  return result
};

export const every2U: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.every2U, Arg1, Arg2, Arg3);
  return result
};

export const every2: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.every2, Arg1, Arg2, Arg3);
  return result
};

export const cmpU: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => number)) => number = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.cmpU, Arg1, Arg2, Arg3);
  return result
};

export const cmp: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => number)) => number = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.cmp, Arg1, Arg2, Arg3);
  return result
};

export const eqU: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.eqU, Arg1, Arg2, Arg3);
  return result
};

export const eq: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.eq, Arg1, Arg2, Arg3);
  return result
};

export const zip: <a,b>(_1:t<a>, _2:t<b>) => t<[a, b]> = function <a,b>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.zip, Arg1, Arg2);
  return result
};

export const zipByU: <a,b,c>(_1:t<a>, _2:t<b>, _3:((_1:a, _2:b) => c)) => t<c> = function <a,b,c>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.zipByU, Arg1, Arg2, Arg3);
  return result
};

export const zipBy: <a,b,c>(_1:t<a>, _2:t<b>, _3:((_1:a, _2:b) => c)) => t<c> = function <a,b,c>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(indexBS.zipBy, Arg1, Arg2, Arg3);
  return result
};

export const unzip: <a,b>(_1:t<[a, b]>) => [t<a>, t<b>] = indexBS.unzip;

export const sortU: <a>(_1:t<a>, _2:((_1:a, _2:a) => number)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.sortU, Arg1, Arg2);
  return result
};

export const sort: <a>(_1:t<a>, _2:((_1:a, _2:a) => number)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(indexBS.sort, Arg1, Arg2);
  return result
};

export const reverse: <a>(_1:t<a>) => t<a> = indexBS.reverse;

export const shuffle: <a>(_1:t<a>) => t<a> = indexBS.shuffle;

export const fromArray: <a>(_1:a[]) => t<a> = indexBS.fromArray;

export const toArray: <a>(_1:t<a>) => a[] = indexBS.toArray;
