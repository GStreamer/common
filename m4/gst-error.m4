dnl Decide on error flags

dnl Thomas Vander Stichele <thomas@apestaart.org>

dnl Last modification: 08/07/2005

dnl GST_SET_ERROR_CFLAGS([ADD-WERROR])

dnl Sets ERROR_CFLAGS to something the compiler will accept.
dnl AC_SUBST them so they are available in Makefile

dnl -Wall is added if it is supported
dnl -Werror is added if ADD-WERROR is not "no"

dnl These flags can be overridden at make time:
dnl make ERROR_CFLAGS=

AC_DEFUN([GST_SET_ERROR_CFLAGS],
[AC_REQUIRE([AS_COMPILER_FLAG])dnl

dnl if we support -Wall, set it unconditionally
AS_COMPILER_FLAG(-Wall,
                 ERROR_CFLAGS="-Wall",
                 ERROR_CFLAGS="")

dnl if we're in nano >= 1, add -Werror if supported
if test "x$1" != "xno"
then
  AS_COMPILER_FLAG(-Werror, ERROR_CFLAGS="$ERROR_CFLAGS -Werror")
fi

AC_SUBST(ERROR_CFLAGS)
AC_MSG_NOTICE([set ERROR_CFLAGS to $ERROR_CFLAGS])
])
