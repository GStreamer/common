dnl version.m4 0.0.1
dnl autostars m4 macro for versioning
dnl thomas@apestaart.org
dnl
dnl AS_VERSION(PACKAGE, PREFIX, MAJOR, MINOR, MICRO, ACTION_IF_DEV, ACTION_IF_NOT_DEV)
dnl example
dnl AS_VERSION(gstreamer, GST_VERSION, 0, 3, 2)
dnl
dnl this macro
dnl - defines [$PREFIX]_MAJOR, MINOR and MICRO
dnl - adds an --with-dev[=nano] option to configure
dnl - defines [$PREFIX], VERSION, and [$PREFIX]_RELEASE
dnl - executes the relevant action
dnl - AC_SUBST's PACKAGE, VERSION, [$PREFIX] and [$PREFIX]_RELEASE
dnl - calls AM_INIT_AUTOMAKE

AC_DEFUN(AS_VERSION,
[
  PACKAGE=[$1]
  [$2]_MAJOR=[$3]
  [$2]_MINOR=[$4]
  [$2]_MICRO=[$5]
  AC_ARG_WITH(dev, 
    [  --with-dev=[nano] with nano dev version],
    [
      if test "$withval" = "yes"; then
        NANO=1
      else
        NANO=$withval
      fi
      AC_MSG_NOTICE(configuring [$1] for development with nano $NANO)
      VERSION=[$3].[$4].[$5].$NANO
      [$2]_RELEASE=`date +%Y%m%d_%H%M%S`
      dnl execute action
      [$6]
    ],
    [
      AC_MSG_NOTICE(configuring [$1] for release)
      VERSION=[$3].[$4].[$5]
      [$2]_RELEASE=1
      dnl execute action
      [$7]
    ])

  [$2]=$VERSION
  AC_DEFINE_UNQUOTED([$2], "$[$2]")
  AC_SUBST([$2])
  AC_DEFINE_UNQUOTED([$2]_RELEASE, "$[$2]_RELEASE")
  AC_SUBST([$2]_RELEASE)

  AC_DEFINE_UNQUOTED(PACKAGE, "$PACKAGE")
  AC_SUBST(PACKAGE)
  AC_DEFINE_UNQUOTED(VERSION, "$VERSION")
  AC_SUBST(VERSION)
  AM_INIT_AUTOMAKE($PACKAGE, $VERSION)
])
