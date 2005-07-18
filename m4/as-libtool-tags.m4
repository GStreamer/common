dnl as-libtool-tags.m4 0.1.4

dnl autostars m4 macro for selecting libtool "tags" (languages)

dnl Andy Wingo does not claim credit for this macro

dnl $Id$

dnl AS_LIBTOOL_TAGS([tags...])

dnl example
dnl AS_LIBTOOL_TAGS([]) for only C (no fortran, etc)

dnl this macro
dnl - Sets CXX, GCJ, and F77 to "no" unless they are in TAGS
dnl - Should be called before AC_PROG_LIBTOOL

AC_DEFUN([AS_LIBTOOL_TAGS],
[
  tags=[$1]

  if -n "$tags"; then
    AC_MSG_NOTICE([allowing libtool to support $tag])
  fi

  if test -n "$tags" && echo CXX | grep "$tags"; then
    true
  else
    CXX=no
  fi
  if test -n "$tags" && echo F77 | grep "$tags"; then
    true
  else
    F77=no
  fi
  if test -n "$tags" && echo GCJ | grep "$tags"; then
    true
  else
    GCJ=no
  fi
])
