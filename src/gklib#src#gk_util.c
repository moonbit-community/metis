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
\file  util.c
\brief Various utility routines

\date   Started 4/12/2007
\author George
\version\verbatim $Id: gk_util.c 16223 2014-02-15 21:34:09Z karypis $ \endverbatim
*/


#include "gklib#include#GKlib.h"


/*************************************************************************
* This file randomly permutes the contents of an array.
* flag == 0, don't initialize perm
* flag == 1, set p[i] = i 
**************************************************************************/
void gk_RandomPermute(size_t n, int *p, int flag)
{
  size_t i, u, v;
  int tmp;

  if (flag == 1) {
    for (i=0; i<n; i++)
      p[i] = i;
  }

  for (i=0; i<n/2; i++) {
    v = RandomInRange(n);
    u = RandomInRange(n);
    gk_SWAP(p[v], p[u], tmp);
  }
}


/************************************************************************/
/*!
\brief Converts an element-based set membership into a CSR-format set-based
       membership.

For example, it takes an array such as part[] that stores where each 
element belongs to and returns a pair of arrays (pptr[], pind[]) that 
store in CSF format the list of elements belonging in each partition.

\param n      
  the number of elements in the array (e.g., # of vertices)
\param range  
  the cardinality of the set (e.g., # of partitions)
\param array
  the array that stores the per-element set membership
\param ptr
  the array that will store the starting indices in ind for
  the elements of each set. This is filled by the routine and
  its size should be at least range+1.
\param ind
  the array that stores consecutively which elements belong to
  each set. The size of this array should be n.
*/
/************************************************************************/
void gk_array2csr(size_t n, size_t range, int *array, int *ptr, int *ind)
{
  size_t i;

  gk_iset(range+1, 0, ptr);

  for (i=0; i<n; i++) 
    ptr[array[i]]++;

  /* Compute the ptr, ind structure */
  MAKECSR(i, range, ptr);
  for (i=0; i<n; i++)
    ind[ptr[array[i]]++] = i;
  SHIFTCSR(i, range, ptr);
}


/*************************************************************************
* This function returns the log2(x)
**************************************************************************/
int gk_log2(int a)
{
  size_t i;

  for (i=1; a > 1; i++, a = a>>1);
  return i-1;
}


/*************************************************************************
* This function checks if the argument is a power of 2
**************************************************************************/
int gk_ispow2(int a)
{
  return (a == (1<<gk_log2(a)));
}


/*************************************************************************
* This function returns the log2(x)
**************************************************************************/
float gk_flog2(float a)
{
  return log(a)/log(2.0);
}


