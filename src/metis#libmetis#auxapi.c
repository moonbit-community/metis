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

/**
\file
\brief This file contains various helper API routines for using METIS.

\date   Started 5/12/2011
\author George  
\author Copyright 1997-2009, Regents of the University of Minnesota 
\version\verbatim $Id: auxapi.c 10409 2011-06-25 16:58:34Z karypis $ \endverbatim
*/


#include "metis#libmetis#metislib.h"


/*************************************************************************/
/*! This function frees memory that was allocated by METIS and returns
    to the application.
    
    \param ptr points to the memory that was previously allocated by
           METIS.
*/
/*************************************************************************/
int METIS_Free(void *ptr)
{
  if (ptr != NULL) free(ptr);
  return METIS_OK;
}


/*************************************************************************/
/*! This function sets the default values for the options.
    
    \param options points to an array of size at least METIS_NOPTIONS.
*/
/*************************************************************************/
int METIS_SetDefaultOptions(idx_t *options)
{
  iset(METIS_NOPTIONS, -1, options);

  return METIS_OK;
}


