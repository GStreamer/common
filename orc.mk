#
# This is a makefile.am fragment to build Orc code.
#
# Define ORC_BASE and then include this file, such as:
#
#  ORC_BASE=adder
#  include $(top_srcdir)/common/orc.mk
#
# This fragment will create adderorc.c adderorc.h from adder.orc.
#
# When 'make dist' is run at the top level, or 'make orc-update'
# in a directory including this fragment, the generated source 
# files will be copied to $(ORC_BASE)orc-dist.[ch].  These files
# should be checked in to git, since they are used if Orc is
# disabled.
# 
#

ORC_SOURCES = tmp-orc.c $(ORC_BASE)orc.h

EXTRA_DIST = $(ORC_BASE).orc

# This is needed if dist-hook-orc is not used
#EXTRA_DIST = $(ORC_BASE).orc $(ORC_BASE)orc-dist.c $(ORC_BASE)orc-dist.h

BUILT_SOURCES = $(ORC_SOURCES)


orc-update: tmp-orc.c $(ORC_BASE)orc.h
	$(top_srcdir)/common/gst-indent tmp-orc.c
	cp tmp-orc.c $(srcdir)/$(ORC_BASE)orc-dist.c
	cp $(ORC_BASE)orc.h $(srcdir)/$(ORC_BASE)orc-dist.h
	

if HAVE_ORC
tmp-orc.c: $(srcdir)/$(ORC_BASE).orc
	$(ORCC) --implementation --include glib.h -o tmp-orc.c $(srcdir)/$(ORC_BASE).orc

$(ORC_BASE)orc.h: $(srcdir)/$(ORC_BASE).orc
	$(ORCC) --header --include glib.h -o $(ORC_BASE)orc.h $(srcdir)/$(ORC_BASE).orc
else
tmp-orc.c: $(srcdir)/$(ORC_BASE).orc
	cp $(srcdir)/$(ORC_BASE)orc-dist.c tmp-orc.c

$(ORC_BASE)orc.h: $(srcdir)/$(ORC_BASE).orc
	cp $(srcdir)/$(ORC_BASE)orc-dist.h $(ORC_BASE)orc.h
endif


clean-local: clean-orc
.PHONY: clean-orc
clean-orc:
	rm -f tmp-orc.c $(ORC_BASE)orc.h

dist-hook: dist-hook-orc
.PHONY: dist-hook-orc
dist-hook-orc: tmp-orc.c $(ORC_BASE)orc.h
	$(top_srcdir)/common/gst-indent tmp-orc.c
	rm -f tmp-orc.c~
	cmp -s tmp-orc.c $(srcdir)/$(ORC_BASE)orc-dist.c || \
	  cp tmp-orc.c $(srcdir)/$(ORC_BASE)orc-dist.c
	cmp -s $(ORC_BASE)orc.h $(srcdir)/$(ORC_BASE)orc-dist.h || \
	  cp $(ORC_BASE)orc.h $(srcdir)/$(ORC_BASE)orc-dist.h
	cp -p $(srcdir)/$(ORC_BASE)orc-dist.c $(distdir)/
	cp -p $(srcdir)/$(ORC_BASE)orc-dist.h $(distdir)/

