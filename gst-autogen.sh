# helper functions for autogen.sh

debug ()
# print out a debug message if DEBUG is a defined variable
{
  if test ! -z "$DEBUG"
  then
    echo "DEBUG: $1"
  fi
}

version_check ()
# check the version of a package
# first argument : package name (executable)
# second argument : source download url
# rest of arguments : major, minor, micro version
{
  PACKAGE=$1
  URL=$2
  MAJOR=$3
  MINOR=$4
  MICRO=$5

  WRONG=

  debug "major $MAJOR minor $MINOR micro $MICRO"
  VERSION=$MAJOR
  if test ! -z "$MINOR"; then VERSION=$VERSION.$MINOR; else MINOR=0; fi
  if test ! -z "$MICRO"; then VERSION=$VERSION.$MICRO; else MICRO=0; fi

  debug "major $MAJOR minor $MINOR micro $MICRO"
  
  test -z "$NOCHECK" && {
      echo -n "  checking for $1 >= $VERSION ... "
  } || {
      return 0
  }
  
  ($PACKAGE --version) < /dev/null > /dev/null 2>&1 || 
  {
	echo
	echo "You must have $PACKAGE installed to compile $package."
	echo "Download the appropriate package for your distribution,"
	echo "or get the source tarball at $URL"
	return 1
  }
  # the following line is carefully crafted sed magic
  pkg_version=`$PACKAGE --version|head -n 1|sed 's/^[a-zA-z\.\ ()]*//;s/ .*$//'`
  debug "pkg_version $pkg_version"
  pkg_major=`echo $pkg_version | cut -d. -f1`
  pkg_minor=`echo $pkg_version | cut -d. -f2`
  pkg_micro=`echo $pkg_version | cut -d. -f3`
  test -z "$pkg_minor" && pkg_minor=0
  test -z "$pkg_micro" && pkg_micro=0

  debug "found major $pkg_major minor $pkg_minor micro $pkg_micro"

  #start checking the version
  debug "version check"

  if [ ! "$pkg_major" \> "$MAJOR" ]; then
    debug "$pkg_major <= $MAJOR"
    if [ "$pkg_major" \< "$MAJOR" ]; then
      WRONG=1
    elif [ ! "$pkg_minor" \> "$MINOR" ]; then
      if [ "$pkg_minor" \< "$MINOR" ]; then
        WRONG=1
      elif [ "$pkg_micro" \< "$MICRO" ]; then
	WRONG=1
      fi
    fi
  fi

  if test ! -z "$WRONG"; then
    echo "found $pkg_version, not ok !"
    echo
    echo "You must have $PACKAGE $VERSION or greater to compile $package."
    echo "Get the latest version from $URL"
    return 1
  else
    echo "found $pkg_version, ok."
  fi
}

autoconf_2.52d_check ()
{
  # autoconf 2.52d has a weird issue involving a yes:no error
  # so don't allow it's use
  ac_version=`autoconf --version|head -n 1|sed 's/^[a-zA-z\.\ ()]*//;s/ .*$//'`
  if test "$ac_version" = "2.52d"; then
    echo "autoconf 2.52d has an issue with our current build."
    echo "We don't know who's to blame however.  So until we do, get a"
    echo "regular version.  RPM's of a working version are on the gstreamer site."
    exit 1
  fi
}

autogen_options ()
{
  for i in $@; do
      if test "$i" = "--autogen-noconfigure"; then
          NOCONFIGURE=defined
          echo "+ configure run disabled"
      elif test "$i" = "--autogen-nocheck"; then
          NOCHECK=defined
          echo "+ autotools version check disabled"
      elif test "$i" = "--autogen-debug"; then
          DEBUG=defined
          echo "+ debug output enabled"
      elif test "$i" = "--help"; then
          echo "autogen.sh help options: "
          echo " --autogen-noconfigure    don't run the configure script"
          echo " --autogen-nocheck        don't do version checks"
          echo " --autogen-debug          debug the autogen process"
	  exit 1
      fi
  done
}

toplevel_check ()
{
  srcfile=$1
  test -f $srcfile || {
        echo "You must run this script in the top-level $package directory"
        exit 1
  }
}


tool_run ()
{
  tool=$1
  options=$2
  echo "+ running $tool $options..."
  $tool $options || {
    echo
    echo $tool failed
    exit 1
  }
}
