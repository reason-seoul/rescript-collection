/* TypeScript file generated from Queue.resi by genType. */
/* eslint-disable import/first */


// @ts-ignore: Implicit any on import
import * as Curry__Es6Import from '@rescript/std/lib/es6/curry.js';
const Curry: any = Curry__Es6Import;

// @ts-ignore: Implicit any on import
import * as QueueBS__Es6Import from './Queue.mjs';
const QueueBS: any = QueueBS__Es6Import;

// tslint:disable-next-line:max-classes-per-file 
// tslint:disable-next-line:class-name
export abstract class t<a> { protected opaque!: a }; /* simulate opaque types */

export const make: <a>() => t<a> = QueueBS.make;

export const isEmpty: <a>(_1:t<a>) => boolean = QueueBS.isEmpty;

export const snoc: <a>(_1:t<a>, _2:a) => t<a> = function <a>(Arg1: any, Arg2: any) {
  const result = Curry._2(QueueBS.snoc, Arg1, Arg2);
  return result
};

export const head: <a>(_1:t<a>) => a = QueueBS.head;

export const tail: <a>(_1:t<a>) => t<a> = QueueBS.tail;
