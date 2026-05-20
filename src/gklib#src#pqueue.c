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
\file  pqueue.c
\brief This file implements various max-priority queues.

The priority queues are generated using the GK_MKPQUEUE macro.

\date   Started 3/27/2007
\author George
\version\verbatim $Id: pqueue.c 10711 2011-08-31 22:23:04Z karypis $ \endverbatim
*/

#include "gklib#include#GKlib.h"


/*************************************************************************/
/*! Create the various max priority queues */
/*************************************************************************/
#define key_gt(a, b) ((a) > (b))
GK_MKPQUEUE(gk_ipq,   gk_ipq_t,   gk_ikv_t,   int,      gk_idx_t, gk_ikvmalloc,   INT_MAX,    key_gt)
GK_MKPQUEUE(gk_i32pq, gk_i32pq_t, gk_i32kv_t, int32_t,  gk_idx_t, gk_i32kvmalloc, INT32_MAX,  key_gt)
GK_MKPQUEUE(gk_i64pq, gk_i64pq_t, gk_i64kv_t, int64_t,  gk_idx_t, gk_i64kvmalloc, INT64_MAX,  key_gt)
GK_MKPQUEUE(gk_fpq,   gk_fpq_t,   gk_fkv_t,   float,    gk_idx_t, gk_fkvmalloc,   FLT_MAX,    key_gt)
GK_MKPQUEUE(gk_dpq,   gk_dpq_t,   gk_dkv_t,   double,   gk_idx_t, gk_dkvmalloc,   DBL_MAX,    key_gt)
GK_MKPQUEUE(gk_idxpq, gk_idxpq_t, gk_idxkv_t, gk_idx_t, gk_idx_t, gk_idxkvmalloc, GK_IDX_MAX, key_gt)
#undef key_gt
