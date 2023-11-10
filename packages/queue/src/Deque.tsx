/* TypeScript file generated from Deque.resi by genType. */
/* eslint-disable import/first */


// @ts-ignore: Implicit any on import
import * as Curry__Es6Import from '@rescript/std/lib/es6/curry.js';
const Curry: any = Curry__Es6Import;

// @ts-ignore: Implicit any on import
import * as DequeBS__Es6Import from './Deque.mjs';
const DequeBS: any = DequeBS__Es6Import;

// tslint:disable-next-line:max-classes-per-file 
// tslint:disable-next-line:class-name
export abstract class t<a> { protected opaque!: a }; /* simulate opaque types */

export const make: <a>() => t<a> = DequeBS.make;

export const pushFront: <a>(_1:t<a>, _2:a) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(DequeBS.pushFront, Arg1, Arg2);
  return result
};

export const pushBack: <a>(_1:t<a>, _2:a) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(DequeBS.pushBack, Arg1, Arg2);
  return result
};

export const popFront: <a>(_1:t<a>) => t<a> = DequeBS.popFront;

export const popBack: <a>(_1:t<a>) => t<a> = DequeBS.popBack;

export const peekFront: <a>(_1:t<a>) => (null | undefined | a) = DequeBS.peekFront;

export const peekBack: <a>(_1:t<a>) => (null | undefined | a) = DequeBS.peekBack;

export const toArray: <a>(_1:t<a>) => a[] = DequeBS.toArray;
