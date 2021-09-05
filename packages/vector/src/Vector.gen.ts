/* TypeScript file generated from Vector.resi by genType. */
/* eslint-disable import/first */


// @ts-ignore: Implicit any on import
import * as Curry__Es6Import from '@rescript/std/lib/es6/curry.js';
const Curry: any = Curry__Es6Import;

// @ts-ignore: Implicit any on import
import * as VectorBS__Es6Import from './Vector.mjs';
const VectorBS: any = VectorBS__Es6Import;

// tslint:disable-next-line:max-classes-per-file 
// tslint:disable-next-line:class-name
export abstract class t<a> { protected opaque!: a }; /* simulate opaque types */

export const make: <a>() => t<a> = VectorBS.make;

export const makeByU: <a>(_1:number, _2:((_1:number) => a)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.makeByU, Arg1, Arg2);
  return result
};

export const makeBy: <a>(_1:number, _2:((_1:number) => a)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.makeBy, Arg1, Arg2);
  return result
};

export const length: <a>(_1:t<a>) => number = VectorBS.length;

export const size: <a>(_1:t<a>) => number = VectorBS.size;

export const push: <a>(_1:t<a>, _2:a) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.push, Arg1, Arg2);
  return result
};

export const pop: <a>(_1:t<a>) => t<a> = VectorBS.pop;

export const get: <a>(_1:t<a>, _2:number) => (null | undefined | a) = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.get, Arg1, Arg2);
  return result
};

export const getExn: <a>(_1:t<a>, _2:number) => a = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.getExn, Arg1, Arg2);
  return result
};

export const getUnsafe: <a>(_1:t<a>, _2:number) => a = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.getUnsafe, Arg1, Arg2);
  return result
};

export const getByU: <a>(_1:t<a>, _2:((_1:a) => boolean)) => (null | undefined | a) = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.getByU, Arg1, Arg2);
  return result
};

export const getBy: <a>(_1:t<a>, _2:((_1:a) => boolean)) => (null | undefined | a) = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.getBy, Arg1, Arg2);
  return result
};

export const getIndexByU: <a>(_1:t<a>, _2:((_1:a) => boolean)) => (null | undefined | number) = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.getIndexByU, Arg1, Arg2);
  return result
};

export const getIndexBy: <a>(_1:t<a>, _2:((_1:a) => boolean)) => (null | undefined | number) = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.getIndexBy, Arg1, Arg2);
  return result
};

export const set: <a>(_1:t<a>, _2:number, _3:a) => (null | undefined | t<a>) = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.set, Arg1, Arg2, Arg3);
  return result
};

export const setExn: <a>(_1:t<a>, _2:number, _3:a) => t<a> = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.setExn, Arg1, Arg2, Arg3);
  return result
};

export const setUnsafe: <a>(_1:t<a>, _2:number, _3:a) => t<a> = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.setUnsafe, Arg1, Arg2, Arg3);
  return result
};

export const reduceU: <a,b>(_1:t<a>, _2:b, _3:((_1:b, _2:a) => b)) => b = function <a,b>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.reduceU, Arg1, Arg2, Arg3);
  return result
};

export const reduce: <a,b>(_1:t<a>, _2:b, _3:((_1:b, _2:a) => b)) => b = function <a,b>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.reduce, Arg1, Arg2, Arg3);
  return result
};

export const reduceWithIndexU: <a,b>(_1:t<a>, _2:b, _3:((_1:b, _2:a, _3:number) => b)) => b = function <a,b>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.reduceWithIndexU, Arg1, Arg2, Arg3);
  return result
};

export const reduceWithIndex: <a,b>(_1:t<a>, _2:b, _3:((_1:b, _2:a, _3:number) => b)) => b = function <a,b>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.reduceWithIndex, Arg1, Arg2, Arg3);
  return result
};

export const mapU: <a,b>(_1:t<a>, _2:((_1:a) => b)) => t<b> = function <a,b>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.mapU, Arg1, Arg2);
  return result
};

export const map: <a,b>(_1:t<a>, _2:((_1:a) => b)) => t<b> = function <a,b>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.map, Arg1, Arg2);
  return result
};

export const mapWithIndex: <a,b>(_1:t<a>, _2:((_1:a, _2:number) => b)) => t<b> = function <a,b>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.mapWithIndex, Arg1, Arg2);
  return result
};

export const keepU: <a>(_1:t<a>, _2:((_1:a) => boolean)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.keepU, Arg1, Arg2);
  return result
};

export const keep: <a>(_1:t<a>, _2:((_1:a) => boolean)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.keep, Arg1, Arg2);
  return result
};

export const keepMapU: <a,b>(_1:t<a>, _2:((_1:a) => (null | undefined | b))) => t<b> = function <a,b>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.keepMapU, Arg1, function (Arg11: any) {
      const result1 = Arg2(Arg11);
      return (result1 == null ? undefined : result1)
    });
  return result
};

export const keepMap: <a,b>(_1:t<a>, _2:((_1:a) => (null | undefined | b))) => t<b> = function <a,b>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.keepMap, Arg1, function (Arg11: any) {
      const result1 = Arg2(Arg11);
      return (result1 == null ? undefined : result1)
    });
  return result
};

export const keepWithIndexU: <a>(_1:t<a>, _2:((_1:a, _2:number) => boolean)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.keepWithIndexU, Arg1, Arg2);
  return result
};

export const keepWithIndex: <a>(_1:t<a>, _2:((_1:a, _2:number) => boolean)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.keepWithIndex, Arg1, Arg2);
  return result
};

export const forEachU: <a>(_1:t<a>, _2:((_1:a) => void)) => void = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.forEachU, Arg1, Arg2);
  return result
};

export const forEach: <a>(_1:t<a>, _2:((_1:a) => void)) => void = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.forEach, Arg1, Arg2);
  return result
};

export const forEachWithIndexU: <a>(_1:t<a>, _2:((_1:a, _2:number) => void)) => void = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.forEachWithIndexU, Arg1, Arg2);
  return result
};

export const forEachWithIndex: <a>(_1:t<a>, _2:((_1:a, _2:number) => void)) => void = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.forEachWithIndex, Arg1, Arg2);
  return result
};

export const someU: <a>(_1:t<a>, _2:((_1:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.someU, Arg1, Arg2);
  return result
};

export const some: <a>(_1:t<a>, _2:((_1:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.some, Arg1, Arg2);
  return result
};

export const some2U: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.some2U, Arg1, Arg2, Arg3);
  return result
};

export const some2: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.some2, Arg1, Arg2, Arg3);
  return result
};

export const everyU: <a>(_1:t<a>, _2:((_1:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.everyU, Arg1, Arg2);
  return result
};

export const every: <a>(_1:t<a>, _2:((_1:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.every, Arg1, Arg2);
  return result
};

export const every2U: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.every2U, Arg1, Arg2, Arg3);
  return result
};

export const every2: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.every2, Arg1, Arg2, Arg3);
  return result
};

export const cmpU: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => number)) => number = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.cmpU, Arg1, Arg2, Arg3);
  return result
};

export const cmp: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => number)) => number = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.cmp, Arg1, Arg2, Arg3);
  return result
};

export const eqU: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.eqU, Arg1, Arg2, Arg3);
  return result
};

export const eq: <a>(_1:t<a>, _2:t<a>, _3:((_1:a, _2:a) => boolean)) => boolean = function <a>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.eq, Arg1, Arg2, Arg3);
  return result
};

export const zip: <a,b>(_1:t<a>, _2:t<b>) => t<[a, b]> = function <a,b>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.zip, Arg1, Arg2);
  return result
};

export const zipByU: <a,b,c>(_1:t<a>, _2:t<b>, _3:((_1:a, _2:b) => c)) => t<c> = function <a,b,c>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.zipByU, Arg1, Arg2, Arg3);
  return result
};

export const zipBy: <a,b,c>(_1:t<a>, _2:t<b>, _3:((_1:a, _2:b) => c)) => t<c> = function <a,b,c>(Arg1: any, Arg2: any, Arg3: any) {
  const result = Curry._3(VectorBS.zipBy, Arg1, Arg2, Arg3);
  return result
};

export const unzip: <a,b>(_1:t<[a, b]>) => [t<a>, t<b>] = VectorBS.unzip;

export const sortU: <a>(_1:t<a>, _2:((_1:a, _2:a) => number)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.sortU, Arg1, Arg2);
  return result
};

export const sort: <a>(_1:t<a>, _2:((_1:a, _2:a) => number)) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(VectorBS.sort, Arg1, Arg2);
  return result
};

export const reverse: <a>(_1:t<a>) => t<a> = VectorBS.reverse;

export const shuffle: <a>(_1:t<a>) => t<a> = VectorBS.shuffle;

export const fromArray: <a>(_1:a[]) => t<a> = VectorBS.fromArray;

export const toArray: <a>(_1:t<a>) => a[] = VectorBS.toArray;
