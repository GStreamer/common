AC_DEFUN(GST_ARCH, [
dnl Set up conditionals for (target) architecture:
dnl ==============================================

dnl Determine CPU
case "x${target_cpu}" in
  xi?86 | xk?) HAVE_CPU_I386=yes
              AC_DEFINE(HAVE_CPU_I386, 1, [Define if the target CPU is an 
x86])
              dnl FIXME could use some better detection
              dnl       (ie CPUID)
              case "x${target_cpu}" in
                xi386 | xi486) ;;
                *)             AC_DEFINE(HAVE_RDTSC, 1, [Define if RDTSC is available]) ;;
              esac ;;
  xpowerpc*)   HAVE_CPU_PPC=yes
              AC_DEFINE(HAVE_CPU_PPC, 1, [Define if the target CPU is a PowerPC]) ;;
  xalpha*)    HAVE_CPU_ALPHA=yes
              AC_DEFINE(HAVE_CPU_ALPHA, 1, [Define if the target CPU is an Alpha]) ;;
  xarm*)      HAVE_CPU_ARM=yes
              AC_DEFINE(HAVE_CPU_ARM, 1, [Define if the target CPU is an ARM]) ;;
  xsparc*)    HAVE_CPU_SPARC=yes
              AC_DEFINE(HAVE_CPU_SPARC, 1, [Define if the target CPU is a PPC]) ;;
  xmips*)     HAVE_CPU_MIPS=yes
              AC_DEFINE(HAVE_CPU_MIPS, 1, [Define if the target CPU is a MIPS]) ;;
  xhppa*)     HAVE_CPU_HPPA=yes
              AC_DEFINE(HAVE_CPU_HPPA, 1, [Define if the target CPU is a HPPA]) ;;
  xs390*)     HAVE_CPU_S390=yes
              AC_DEFINE(HAVE_CPU_S390, 1, [Define if the target CPU is a S390]) ;;
  xia64*)     HAVE_CPU_IA64=yes
              AC_DEFINE(HAVE_CPU_IA64, 1, [Define if the target CPU is a IA64]) ;;
  xm68k*)     HAVE_CPU_M68K=yes
              AC_DEFINE(HAVE_CPU_M68K, 1, [Define if the target CPU is a M68K]) ;;
esac

dnl Determine endianness
AC_C_BIGENDIAN

dnl Check for MMX-capable compiler
AC_MSG_CHECKING(for MMX-capable compiler)
AC_TRY_RUN([
#include "include/mmx.h"

main()
{ movq_r2r(mm0, mm1); return 0; }
],
[
HAVE_LIBMMX="yes"
AC_MSG_RESULT(yes)
],
HAVE_LIBMMX="no"
AC_MSG_RESULT(no)
,
HAVE_LIBMMX="no"
AC_MSG_RESULT(no)
)

AM_CONDITIONAL(HAVE_CPU_I386,       test "x$HAVE_CPU_I386" = "xyes")
AM_CONDITIONAL(HAVE_CPU_PPC,        test "x$HAVE_CPU_PPC" = "xyes")
AM_CONDITIONAL(HAVE_CPU_ALPHA,      test "x$HAVE_CPU_ALPHA" = "xyes")
AM_CONDITIONAL(HAVE_CPU_ARM,        test "x$HAVE_CPU_ARM" = "xyes")
AM_CONDITIONAL(HAVE_CPU_SPARC,      test "x$HAVE_CPU_SPARC" = "xyes")
AM_CONDITIONAL(HAVE_CPU_HPPA,       test "x$HAVE_CPU_HPPA" = "xyes")
AM_CONDITIONAL(HAVE_CPU_MIPS,       test "x$HAVE_CPU_MIPS" = "xyes")
AM_CONDITIONAL(HAVE_CPU_S390,       test "x$HAVE_CPU_S390" = "xyes")
AM_CONDITIONAL(HAVE_CPU_IA64,       test "x$HAVE_CPU_IA64" = "xyes")
AM_CONDITIONAL(HAVE_CPU_M68K,       test "x$HAVE_CPU_M68K" = "xyes")
AM_CONDITIONAL(HAVE_LIBMMX,         test "x$USE_LIBMMX" = "xyes")

])
