#if defined(_WIN32)
#define WIN32
#define MSC
#define _CRT_SECURE_NO_DEPRECATE
#define USE_GKREGEX
#ifndef __thread
#define __thread __declspec(thread)
#endif
#else
#define LINUX
#define _FILE_OFFSET_BITS 64
#define _POSIX_C_SOURCE 200809L
#define NDEBUG
#define NDEBUG2
#define HAVE_GETLINE
#endif

#if defined(__APPLE__)
#define MACOS
#define HAVE_EXECINFO_H
#endif

#if defined(__linux__)
#define HAVE_EXECINFO_H
#endif

/*
 * Copyright 1997, Regents of the University of Minnesota
 *
 * bucketsort.c
 *
 * This file contains code that implement a variety of counting sorting
 * algorithms
 *
 * Started 7/25/97
 * George
 *
 */

#include "metis#libmetis#metislib.h"



/*************************************************************************
* This function uses simple counting sort to return a permutation array
* corresponding to the sorted order. The keys are arsumed to start from
* 0 and they are positive.  This sorting is used during matching.
**************************************************************************/
void BucketSortKeysInc(ctrl_t *ctrl, idx_t n, idx_t max, idx_t *keys, 
         idx_t *tperm, idx_t *perm)
{
  idx_t i, ii;
  idx_t *counts;

  WCOREPUSH;

  counts = iset(max+2, 0, iwspacemalloc(ctrl, max+2));

  for (i=0; i<n; i++)
    counts[keys[i]]++;
  MAKECSR(i, max+1, counts);

  for (ii=0; ii<n; ii++) {
    i = tperm[ii];
    perm[counts[keys[i]]++] = i;
  }

  WCOREPOP;
}

