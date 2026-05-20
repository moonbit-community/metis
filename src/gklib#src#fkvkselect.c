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

/*!
\file  dfkvkselect.c
\brief Sorts only the largest k values
 
\date   Started 7/14/00
\author George
\version\verbatim $Id: fkvkselect.c 10711 2011-08-31 22:23:04Z karypis $\endverbatim
*/


#include "gklib#include#GKlib.h"

/* Byte-wise swap two items of size SIZE. */
#define QSSWAP(a, b, stmp) do { stmp = (a); (a) = (b); (b) = stmp; } while (0)


/******************************************************************************/
/*! This function puts the 'topk' largest values in the beginning of the array */
/*******************************************************************************/
int gk_dfkvkselect(size_t n, int topk, gk_fkv_t *cand)
{
  int i, j, lo, hi, mid;
  gk_fkv_t stmp;
  float pivot;

  if (n <= topk)
    return n; /* return if the array has fewer elements than we want */

  for (lo=0, hi=n-1; lo < hi;) {
    mid = lo + ((hi-lo) >> 1);

    /* select the median */
    if (cand[lo].key < cand[mid].key)
      mid = lo;
    if (cand[hi].key > cand[mid].key)
      mid = hi;
    else 
      goto jump_over;
    if (cand[lo].key < cand[mid].key)
      mid = lo;

jump_over:
    QSSWAP(cand[mid], cand[hi], stmp);
    pivot = cand[hi].key;

    /* the partitioning algorithm */
    for (i=lo-1, j=lo; j<hi; j++) {
      if (cand[j].key >= pivot) {
        i++;
        QSSWAP(cand[i], cand[j], stmp);
      }
    }
    i++;
    QSSWAP(cand[i], cand[hi], stmp);


    if (i > topk) 
      hi = i-1;
    else if (i < topk)
      lo = i+1;
    else
      break;
  }

/*
  if (cand[lo].key < cand[hi].key)
    printf("Hmm Error: %d %d %d %f %f\n", i, lo, hi, cand[lo].key, cand[hi].key);


  for (i=topk; i<n; i++) {
    for (j=0; j<topk; j++)
      if (cand[i].key > cand[j].key)
        printf("Hmm Error: %d %d %f %f %d %d\n", i, j, cand[i].key, cand[j].key, lo, hi);
  }
*/

  return topk;
}


/******************************************************************************/
/*! This function puts the 'topk' smallest values in the beginning of the array */
/*******************************************************************************/
int gk_ifkvkselect(size_t n, int topk, gk_fkv_t *cand)
{
  int i, j, lo, hi, mid;
  gk_fkv_t stmp;
  float pivot;

  if (n <= topk)
    return n; /* return if the array has fewer elements than we want */

  for (lo=0, hi=n-1; lo < hi;) {
    mid = lo + ((hi-lo) >> 1);

    /* select the median */
    if (cand[lo].key > cand[mid].key)
      mid = lo;
    if (cand[hi].key < cand[mid].key)
      mid = hi;
    else 
      goto jump_over;
    if (cand[lo].key > cand[mid].key)
      mid = lo;

jump_over:
    QSSWAP(cand[mid], cand[hi], stmp);
    pivot = cand[hi].key;

    /* the partitioning algorithm */
    for (i=lo-1, j=lo; j<hi; j++) {
      if (cand[j].key <= pivot) {
        i++;
        QSSWAP(cand[i], cand[j], stmp);
      }
    }
    i++;
    QSSWAP(cand[i], cand[hi], stmp);


    if (i > topk) 
      hi = i-1;
    else if (i < topk)
      lo = i+1;
    else
      break;
  }

/*
  if (cand[lo].key > cand[hi].key)
    printf("Hmm Error: %d %d %d %f %f\n", i, lo, hi, cand[lo].key, cand[hi].key);


  for (i=topk; i<n; i++) {
    for (j=0; j<topk; j++)
      if (cand[i].key < cand[j].key)
        printf("Hmm Error: %d %d %f %f %d %d\n", i, j, cand[i].key, cand[j].key, lo, hi);
  }
*/

  return topk;
}
