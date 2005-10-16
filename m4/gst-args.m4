dnl configure-time options shared among gstreamer modules

dnl GST_ARG_DEBUG
dnl GST_ARG_PROFILING
dnl GST_ARG_VALGRIND
dnl GST_ARG_GCOV

dnl GST_ARG_EXAMPLES

dnl GST_ARG_WITH_PKG_CONFIG_PATH
dnl GST_ARG_PACKAGE_NAME
dnl GST_ARG_PACKAGE_ORIGIN

AC_DEFUN([GST_ARG_DEBUG],
[
  dnl debugging stuff
  AC_ARG_ENABLE(debug,
    AC_HELP_STRING([--disable-debug],[disable addition of -g debugging info]),
    [
      case "${enableval}" in
        yes) USE_DEBUG=yes ;;
        no)  USE_DEBUG=no ;;
        *)   AC_MSG_ERROR(bad value ${enableval} for --enable-debug) ;;
      esac
    ],
    [USE_DEBUG=yes]) dnl Default value
])

AC_DEFUN([GST_ARG_PROFILING],
[
  AC_ARG_ENABLE(profiling,
    AC_HELP_STRING([--enable-profiling],
      [adds -pg to compiler commandline, for profiling]),
    [
      case "${enableval}" in
        yes) USE_PROFILING=yes ;;
        no)  USE_PROFILING=no ;;
        *)   AC_MSG_ERROR(bad value ${enableval} for --enable-profiling) ;;
      esac
    ], 
    [USE_PROFILING=no]) dnl Default value
])

AC_DEFUN([GST_ARG_VALGRIND],
[
  dnl valgrind inclusion
  AC_ARG_ENABLE(valgrind,
    AC_HELP_STRING([--disable-valgrind],[disable run-time valgrind detection]),
    [
      case "${enableval}" in
        yes) USE_VALGRIND="$USE_DEBUG" ;;
        no)  USE_VALGRIND=no ;;
        *)   AC_MSG_ERROR(bad value ${enableval} for --enable-valgrind) ;;
      esac
    ],
    [USE_VALGRIND="$USE_DEBUG"]) dnl Default value
  VALGRIND_REQ="2.1"
  if test "x$USE_VALGRIND" = xyes; then
    PKG_CHECK_MODULES(VALGRIND, valgrind > $VALGRIND_REQ,
      USE_VALGRIND="yes", USE_VALGRIND="no")
  fi
  if test "x$USE_VALGRIND" = xyes; then
    AC_DEFINE(HAVE_VALGRIND, 1, [Define if valgrind should be used])
    AC_MSG_NOTICE(Using extra code paths for valgrind)
  fi
])

AC_DEFUN([GST_ARG_GCOV],
[
  AC_ARG_ENABLE(gcov,
    AC_HELP_STRING([--enable-gcov],
      [compile with coverage profiling instrumentation (gcc only)]),
    enable_gcov=$enableval,
    enable_gcov=no)
  if test x$enable_gcov = xyes ; then
    AS_COMPILER_FLAG(["-fprofile-arcs"],
      [GCOV_CFLAGS="$GCOV_CFLAGS -fprofile-arcs"],
      true)
    AS_COMPILER_FLAG(["-ftest-coverage"],
      [GCOV_CFLAGS="$GCOV_CFLAGS -ftest-coverage"],
      true)
    dnl remove any -O flags - FIXME: is this needed ?
    GCOV_CFLAGS=`echo "$GCOV_CFLAGS" | sed -e 's/-O[0-9]*//g'`

    AC_DEFINE_UNQUOTED(GST_GCOV_ENABLED, 1,
      [Defined if gcov is enabled to force a rebuild due to config.h changing])
  fi
  AM_CONDITIONAL(GST_GCOV_ENABLED, test x$enable_gcov = xyes)
])

AC_DEFUN([GST_ARG_EXAMPLES],
[
  AC_ARG_ENABLE(examples,
    AC_HELP_STRING([--disable-examples], [disable building examples]),
      [
        case "${enableval}" in
          yes) BUILD_EXAMPLES=yes ;;
          no)  BUILD_EXAMPLES=no ;;
          *)   AC_MSG_ERROR(bad value ${enableval} for --disable-examples) ;;
        esac
      ],
      [BUILD_EXAMPLES=yes]) dnl Default value
  AM_CONDITIONAL(BUILD_EXAMPLES,      test "x$BUILD_EXAMPLES" = "xyes")
])

AC_DEFUN([GST_ARG_WITH_PKG_CONFIG_PATH],
[
  dnl possibly modify pkg-config path
  AC_ARG_WITH(pkg-config-path, 
     AC_HELP_STRING([--with-pkg-config-path],
                    [colon-separated list of pkg-config(1) dirs]),
     [export PKG_CONFIG_PATH=${withval}])
])


AC_DEFUN([GST_ARG_WITH_PACKAGE_NAME],
[
  dnl package name in plugins
  AC_ARG_WITH(package-name,
    AC_HELP_STRING([--with-package-name],
      [specify package name to use in plugins]),
    [
      case "${withval}" in
        yes) AC_MSG_ERROR(bad value ${withval} for --with-package-name) ;;
        no)  AC_MSG_ERROR(bad value ${withval} for --with-package-name) ;;
        *)   GST_PACKAGE="${withval}" ;;
      esac
    ], 
    [
      dnl default value
      if test "x$GST_CVS" = "xyes"
      then
        dnl nano >= 1
        GST_PACKAGE_NAME="[$1] CVS/prerelease"
      else
        GST_PACKAGE_NAME="[$1] source release"
      fi
    ]
  )
  AC_MSG_NOTICE(Using $GST_PACKAGE_NAME as package name)
  AC_DEFINE_UNQUOTED(GST_PACKAGE_NAME, "$GST_PACKAGE_NAME",
      [package name in plugins])
  AC_SUBST(GST_PACKAGE_NAME)
])

AC_DEFUN([GST_ARG_WITH_PACKAGE_ORIGIN],
[
  dnl package origin URL
  AC_ARG_WITH(package-origin,
    AC_HELP_STRING([--with-package-origin],
      [specify package origin URL to use in plugins]),
    [
      case "${withval}" in
        yes) AC_MSG_ERROR(bad value ${withval} for --with-package-origin) ;;
        no)  AC_MSG_ERROR(bad value ${withval} for --with-package-origin) ;;
        *)   GST_ORIGIN="${withval}" ;;
      esac
    ], 
    [GST_PACKAGE_ORIGIN="[Unknown package origin]"] dnl Default value
  )
  AC_MSG_NOTICE(Using $GST_PACKAGE_ORIGIN as package origin)
  AC_DEFINE_UNQUOTED(GST_PACKAGE_ORIGIN, "$GST_PACKAGE_ORIGIN",
      [package origin])
  AC_SUBST(GST_PACKAGE_ORIGIN)
])
