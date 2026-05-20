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
\file blas.c
\brief This file contains GKlib's implementation of BLAS-like routines

The BLAS routines that are currently implemented are mostly level-one.
They follow a naming convention of the type gk_[type][name], where
[type] is one of c, i, f, and d, based on C's four standard scalar
datatypes of characters, integers, floats, and doubles.

These routines are implemented using a generic macro template,
which is used for code generation.

\date   Started 9/28/95
\author George
\version\verbatim $Id: blas.c 14330 2013-05-18 12:15:15Z karypis $ \endverbatim
*/

#include "gklib#include#GKlib.h"



/*************************************************************************/
/*! Use the templates to generate BLAS routines for the scalar data types */
/*************************************************************************/
GK_MKBLAS(gk_c,   char,     int)
GK_MKBLAS(gk_i,   int,      int)
GK_MKBLAS(gk_i32, int32_t,  int32_t)
GK_MKBLAS(gk_i64, int64_t,  int64_t)
GK_MKBLAS(gk_z,   ssize_t,  ssize_t)
GK_MKBLAS(gk_zu,  size_t,   size_t)
GK_MKBLAS(gk_f,   float,    float)
GK_MKBLAS(gk_d,   double,   double)
GK_MKBLAS(gk_idx, gk_idx_t, gk_idx_t)




