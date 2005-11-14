dnl pkg-config-based checks for GStreamer modules

dnl generic:
dnl GST_CHECK_MODULES([PREFIX], [MODULE], [MINVER], [NAME], [REQUIRED])
dnl sets HAVE_[$PREFIX], [$PREFIX]_*

dnl specific:
dnl GST_CHECK_GST([MAJMIN], [MINVER], [REQUIRED])
dnl   also sets/ACSUBSTs GST_TOOLS_DIR and GST_PLUGINS_DIR
dnl GST_CHECK_GST_BASE([MAJMIN], [MINVER], [REQUIRED])
dnl GST_CHECK_GST_GDP([MAJMIN], [MINVER], [REQUIRED])
dnl GST_CHECK_GST_CONTROLLER([MAJMIN], [MINVER], [REQUIRED])
dnl GST_CHECK_GST_CHECK([MAJMIN], [MINVER], [REQUIRED])
dnl GST_CHECK_GST_PLUGINS_BASE([MAJMIN], [MINVER], [REQUIRED])

AC_DEFUN([GST_CHECK_MODULES],
[
  module=[$2]
  minver=[$3]
  name="[$4]"
  required=ifelse([$5], , "yes", [$5]) dnl required by default

  PKG_CHECK_MODULES([$1], $module >= $minver,
    HAVE_[$1]="yes", HAVE_[$1]="no")

  if test "x$HAVE_[$1]" = "xno"; then
    if test "x$required" = "xyes"; then
      AC_MSG_ERROR([no $module >= $minver ($name) found])
    else
      AC_MSG_NOTICE([no $module >= $minver ($name) found])
    fi
  fi
]))

AC_DEFUN([GST_CHECK_GST],
[
  GST_CHECK_MODULES(GST, gstreamer-[$1], [$2], [GStreamer], [$3])
  GST_TOOLS_DIR=`pkg-config --variable=toolsdir gstreamer-[$1]`
  if test -z $GST_TOOLS_DIR; then
    AC_MSG_ERROR(
      [no tools dir set in GStreamer pkg-config file; core upgrade needed.])
  fi
  AC_SUBST(GST_TOOLS_DIR)

  dnl check for where core plug-ins got installed
  dnl this is used for unit tests
  GST_PLUGINS_DIR=`pkg-config --variable=pluginsdir gstreamer-[$1]`
  if test -z $GST_PLUGINS_DIR; then
    AC_MSG_ERROR(
      [no pluginsdir set in GStreamer pkg-config file; core upgrade needed.])
  fi
  AC_SUBST(GST_PLUGINS_DIR)
])

AC_DEFUN([GST_CHECK_GST_BASE],
[
  GST_CHECK_MODULES(GST_BASE, gstreamer-base-[$1], [$2],
    [GStreamer Base Libraries], [$3])
])
  
AC_DEFUN([GST_CHECK_GST_GDP],
[
  GST_CHECK_MODULES(GST_GDP, gstreamer-dataprotocol-[$1], [$2],
    [GStreamer Data Protocol Library], [$3])
])
  
AC_DEFUN([GST_CHECK_GST_CONTROLLER],
[
  GST_CHECK_MODULES(GST_CONTROLLER, gstreamer-controller-[$1], [$2],
    [GStreamer Controller Library], [$3])
])  

AC_DEFUN([GST_CHECK_GST_CHECK],
[
  GST_CHECK_MODULES(GST_CHECK, gstreamer-check-[$1], [$2],
    [GStreamer Check unittest Library], [$3])
])

AC_DEFUN([GST_CHECK_GST_PLUGINS_BASE],
[
  GST_CHECK_MODULES(GST_PLUGINS_BASE, gstreamer-plugins-base-[$1], [$2],
    [GStreamer Base Plug-ins Library], [$3])
])
