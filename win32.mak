# various tests to make sure we dist the win32 stuff (for MSVC builds) right

win32 = $(shell cat $(top_srcdir)/win32/MANIFEST)

# wildcard is apparently not portable to other makes
win32defs = $(shell find $(top_srcdir)/win32/common -name '*.def')

win32-debug:
	@echo; \
	echo win32     = $(win32); \
	echo; \
	echo win32defs = $(win32defs); \
	echo

# FIXME: this doesn't seem to work right yet
win32-check-crlf:
	fail=0 ; \
	for each in $(win32); do \
	  if ! (file $$each | grep CRLF >/dev/null) ; then \
	    echo $$each must be fixed to have CRLF line endings ; \
	    fail=1; \
	  fi ; \
	done ; \
	exit $$fail

# make sure all symbols we export on linux are defined in the win32 .def too
# (don't care about other unixes for now, it's enough if it works on one of
# the linux build bots; we assume .so )
check-exports:
	fail=0 ; \
	for l in $(win32defs); do \
	  libbase=`basename "$$l" ".def"`; \
	  libso=`find "$(top_builddir)" -name "$$libbase-0.10.so"`; \
	  libdef="$(top_srcdir)/win32/common/$$libbase.def"; \
	  if test "x$$libso" != "x"; then \
	    echo Checking symbols in $$libso; \
	    if ! ($(top_srcdir)/common/check-exports $$libdef $$libso) ; then \
	      fail=1; \
	    fi; \
	  fi; \
	done


dist-hook: check-exports


