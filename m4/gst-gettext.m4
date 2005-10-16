dnl gettext setup

dnl GST_GETTEXT([gettext-package])
dnl defines GETTEXT_PACKAGE and LOCALEDIR

AC_DEFUN([GST_GETTEXT],
[
  GETTEXT_PACKAGE=[$1]
  AC_SUBST(GETTEXT_PACKAGE)
  AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], "$GETTEXT_PACKAGE",
                     [gettext package name])

  dnl define LOCALEDIR in config.h
  AS_AC_EXPAND(LOCALEDIR, $datadir/locale)
  AC_DEFINE_UNQUOTED([LOCALEDIR], "$LOCALEDIR",
                     [gettext locale dir])
])
